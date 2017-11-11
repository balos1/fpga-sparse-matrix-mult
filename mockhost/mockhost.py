"""
mockhost.py

Python program which mocks a host system that uses Cyclone IV E FPGA as a coprocessor for sparse matrix multiplication.

author: Cody Balos <cjbalos@gmail.com>
"""

import serial
import numpy as np
from scipy import sparse
import time

PORT = 'loop://'
TIMEOUT = 10000

def main():
    uart = CommUnit(PORT, TIMEOUT)
    A = np.matrix([[1.0, 0.0, 1.2], [0.0, 0.0, 2.0], [0.0, 3.0, 0.0]])
    B = np.matrix([[0.0, 2.0, 3.2], [1.0, 0.0, 0.0], [0.0, 2.2, 0.0]])
    uart.send_matrices(A, B)

class CommUnit():
    """
    """

    def __init__(self, port, timeout):
        self.uart = serial.serial_for_url(port, timeout=timeout)
        self.uart.baudrate = 115200
        self.uart.parity = serial.PARITY_NONE
        self.uart.bytesize = serial.EIGHTBITS
        self.uart.stopbits = serial.STOPBITS_ONE
        self.uart.rtscts = True

    def send_matrices(self, A, B):
        """
        Sends two matrices over UART
        """
        sA = sparse.csr_matrix(A)
        sparse.csr_matrix.sort_indices(sA)
        sB = sparse.csc_matrix(B)
        sparse.csc_matrix.sort_indices(sB)



        # print("sA = ")
        # print(sA)
        # print("sB = ")
        # print(sB)

if __name__ == "__main__":
    main()
