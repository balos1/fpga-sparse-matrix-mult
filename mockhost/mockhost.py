"""
mockhost.py

Python program which mocks a host system that uses Cyclone IV E FPGA as a coprocessor for sparse matrix multiplication.

author: Cody Balos <cjbalos@gmail.com>
"""

import numpy as np
from scipy import sparse
import serial
import struct
import time
from threading import Thread

PORT = 'loop://'
TIMEOUT = 100

ser = serial.serial_for_url(PORT, timeout=TIMEOUT)

def main():
    uart = CommUnit(ser)

    A = np.matrix([[1.0, 0.0, 1.2], [0.0, 0.0, 2.0], [0.0, 3.0, 0.0]], dtype=np.float16)
    B = np.matrix([[0.0, 2.0, 3.2], [1.0, 0.0, 0.0], [0.0, 2.2, 0.0]], dtype=np.float16)
    # uart.send_matrices(A, B)

    thread1 = Thread(target = uart.send_matrices, args=(A,B))
    thread2 = Thread(target = test_sender)
    thread1.start()
    thread2.start()
    thread1.join()
    time.sleep(2)
    exit()

def test_sender():
    # print("test")
    data = b''
    buffer = bytearray()
    while b'\n' not in data:
        data = ser.read()
        print(data)
        # buffer.append()
    # print(buffer)

class CommUnit():
    """
    """

    def __init__(self, ser):
        self.ser = ser
        self.ser.baudrate = 115200
        self.ser.parity = serial.PARITY_NONE
        self.ser.bytesize = serial.EIGHTBITS
        self.ser.stopbits = serial.STOPBITS_ONE
        self.ser.rtscts = False

    def send_matrices(self, A, B):
        """
        Sends two matrices over UART
        """
        sA = sparse.csr_matrix(A)
        sparse.csr_matrix.sort_indices(sA)
        sB = sparse.csc_matrix(B)
        sparse.csc_matrix.sort_indices(sB)

        value_buffer = bytearray()
        for value in sA.data:
            print(struct.pack('e', value))
        # print(value_buffer)

        index_buffer = bytearray()
        for index in sA.indices:
            index_buffer.append(index)

        # self.ser.write(index_buffer)
        # self.ser.write(b'\n')
        time.sleep(0.1)


if __name__ == "__main__":
    main()
