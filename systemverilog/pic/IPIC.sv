/*
	module: IPIC

	This module implements a 4x4 independent parallel indicies comparison unit.
*/
module IPIC
(
	input logic clk, reset, ready, write, read,
	input logic [63:0] row,
	output logic [31:0] fifo0,
	output logic [31:0] fifo1,
	output logic [31:0] fifo2,
	output logic [31:0] fifo3,
	output logic [31:0] fifo4,
	output logic [31:0] fifo5,
	output logic [31:0] fifo6,
	output logic [31:0] fifo7,
	output logic [31:0] fifo8,
	output logic [31:0] fifo9,
	output logic [31:0] fifo10,
	output logic [31:0] fifo11,
	output logic [31:0] fifo12,
	output logic [31:0] fifo13,
	output logic [31:0] fifo14,
	output logic [31:0] fifo15
);

logic [15:0] indicesOut [7:0];

bram_module A0(clk, ready, rw, reset, row, indicesOut[0]);
bram_module A1(clk, ready, rw, reset, row, indicesOut[1]);
bram_module A2(clk, ready, rw, reset, row, indicesOut[2]);
bram_module A3(clk, ready, rw, reset, row, indicesOut[3]);
bram_module B0(clk, ready, rw, reset, row, indicesOut[4]);
bram_module B1(clk, ready, rw, reset, row, indicesOut[5]);
bram_module B2(clk, ready, rw, reset, row, indicesOut[6]);
bram_module B3(clk, ready, rw, reset, row, indicesOut[7]);

// A0 --> B0/B1/B2/B3
PIC pic1(clk, indicesOut[0], indicesOut[4], write, read, fifo0);
PIC pic2(clk, indicesOut[0], indicesOut[5], write, read, fifo1);
PIC pic3(clk, indicesOut[0], indicesOut[6], write, read, fifo2);
PIC pic4(clk, indicesOut[0], indicesOut[7], write, read, fifo3);

// A1 --> B0/B1/B2/B3
PIC pic5(clk, indicesOut[1], indicesOut[4], write, read, fifo4);
PIC pic6(clk, indicesOut[1], indicesOut[5], write, read, fifo5);
PIC pic7(clk, indicesOut[1], indicesOut[6], write, read, fifo6);
PIC pic8(clk, indicesOut[1], indicesOut[7], write, read, fifo7);

// A2 --> B0/B1/B2/B3
PIC pic9(clk, indicesOut[2], indicesOut[4], write, read, fifo8);
PIC pic10(clk, indicesOut[2], indicesOut[5], write, read, fifo9);
PIC pic11(clk, indicesOut[2], indicesOut[6], write, read, fifo10);
PIC pic12(clk, indicesOut[2], indicesOut[7], write, read, fifo11);

// A3 --> B0/B1/B2/B3
PIC pic13(clk, indicesOut[3], indicesOut[4], write, read, fifo12);
PIC pic14(clk, indicesOut[3], indicesOut[5], write, read, fifo13);
PIC pic15(clk, indicesOut[3], indicesOut[6], write, read, fifo14);
PIC pic16(clk, indicesOut[3], indicesOut[7], write, read, fifo15);

endmodule
