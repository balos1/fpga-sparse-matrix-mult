"""
mockhost.py

Python program which mocks a host system that uses Cyclone IV E FPGA as a coprocessor for sparse matrix multiplication.

author: Cody Balos <cjbalos@gmail.com>
"""

import argparse
import numpy as np
from scipy import sparse
import serial
import struct
import sys
import time
from threading import Thread

PORT = 'loop://'
TIMEOUT = 100

# ser = serial.serial_for_url(PORT, timeout=TIMEOUT)

def main():
    """Main function.
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--size', action='store', default=3,
        help='size of matrices to generate (must be NxN)')
    parser.add_argument('-n', '--num-problems', action='store', default=1,
        help='the number of problems to generate and send')
    parser.add_argument('-p', '--port', action='store', default=PORT,
        help='port to connect to')
    parser.add_argument('-t', '--timeout', action='store', default=TIMEOUT,
        help='timeout for serial comm')
    parser.add_argument('--loopback', action='store_true', help='test communication unit using loopback')
    args = parser.parse_args()

    uart = CommUnit(serial.serial_for_url(args.port, timeout=args.timeout))
    matricesA = [np.matrix([[1.0, 0.0, 1.2], [0.0, 0.0, 2.0], [0.0, 3.0, 0.0]], dtype=np.float16)]
    matricesB = [np.matrix([[0.0, 2.0, 3.2], [1.0, 0.0, 0.0], [0.0, 2.2, 0.0]], dtype=np.float16)]
    if args.loopback:
        test_using_loopback(uart, matricesA, matricesB)
    else:
        write_and_wait(uart, matricesA, matricesB)


def write_and_wait(uart, matricesA, matricesB):
    """Write to coprocessor and wait for result
    """
    for (A, B) in zip(matricesA, matricesB):
        uart.send_matrices(A, B)
        results = uart.recv_matrices()


def test_using_loopback(uart, matricesA, matricesB):
    """Test host unit with loopback.
    """
    for (A, B) in zip(matricesA, matricesB):
        print('------------------------------sending next problem------------------------------')
        thread1 = Thread(target = uart.send_matrices, args=(A,B))
        thread2 = Thread(target = test_send, args=(uart,))
        thread1.start()
        thread2.start()
        thread1.join()
        time.sleep(1)


def test_send(uart):
    """Pretend to be the coprocessor in a receiver state.
    """
    uart.ser.rts = True
    time.sleep(0.1)

    data = b''
    recv_buffer = bytearray()
    while b'\r' not in data:
        data = uart.ser.read()
        recv_buffer.extend(data)
    print('received matrix A')
    print(recv_buffer)

    uart.ser.rts = True
    time.sleep(0.1)

    data = b''
    recv_buffer = bytearray()
    while b'\r' not in data:
        data = uart.ser.read()
        recv_buffer.extend(data)
    print('received matrix B')
    print(recv_buffer)


class CommUnit(object):
    """The host communication unit
    """

    def __init__(self, ser):
        self.ser = ser
        self.ser.baudrate = 115200
        self.ser.parity = serial.PARITY_NONE
        self.ser.bytesize = serial.EIGHTBITS
        self.ser.stopbits = serial.STOPBITS_ONE
        self.ser.rtscts = True

    def send_matrices(self, A, B):
        """
        Sends two matrices over UART
        """
        # wait until we can send A
        while not self.ser.cts:
            time.sleep(0.1)
        self.send_A(A)
        # wait until we can send B
        while not self.ser.cts:
            time.sleep(0.1)
        self.send_B(B)

    def recv_matrices(self):
        """Waits to receive data
        """
        data = None

        # wait for data to start
        while True:
            data = self.ser.read()
            if bytes(0) not in data:
                break

        recv_buffer = bytearray()
        recv_buffer.extend(data)
        while bytes(0) not in data:
            recv_buffer.extend(data)

        return recv_buffer

    def send_A(self, A):
        """Send matrix A in CSR format
        """
        # compress each row one at a time for A
        vectors = [sparse.csr_matrix(row, dtype=np.float16).sorted_indices() for row in A]

        hr_buffer = []
        for vector in vectors:
            for index, value in zip(vector.indices, vector.data):
                hr_buffer.append(value)
                hr_buffer.append(index)
            hr_buffer.append('\n')
        hr_buffer.append('\r')

        send_buffer = bytearray()
        for vector in vectors:
            # need to send everything LSB first, so pack it in little endian order
            for index, value in zip(vector.indices, vector.data):
                # values are send as half-precision floats (16 bits)
                send_buffer.extend(struct.pack('<e', value))
                # indices will be sent as unsigned shorts (16 bits)
                send_buffer.extend(struct.pack('<H', index))
            send_buffer.extend(b'\n')
        send_buffer.extend(b'\r')

        print('sending matrix A')
        print(hr_buffer)
        print(send_buffer)
        self.ser.write(send_buffer)

    def send_B(self, B):
        """Send matrix B in CSC format
        """
        # compress each col one at a time for B
        vectors = [sparse.csr_matrix(col, dtype=np.float16).sorted_indices() for col in B.T]

        hr_buffer = []
        for vector in np.transpose(vectors):
            for index, value in zip(vector.indices, vector.data):
                hr_buffer.append(value)
                hr_buffer.append(index)
            hr_buffer.append('\n')
        hr_buffer.append('\r')

        send_buffer = bytearray()
        for vector in vectors:
            # need to send everything LSB first, so pack it in little endian order
            for index, value in zip(vector.indices, vector.data):
                # values are send as half-precision floats (16 bits)
                send_buffer.extend(struct.pack('<e', value))
                # indices will be sent as unsigned shorts (16 bits)
                send_buffer.extend(struct.pack('<H', index))
            send_buffer.extend(b'\n')
        send_buffer.extend(b'\r')

        print('sending matrix B')
        print(hr_buffer)
        print(send_buffer)
        self.ser.write(send_buffer)


if __name__ == "__main__":
    sys.exit(main())
