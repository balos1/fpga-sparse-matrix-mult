module top(input logic clk, ready, write, read, reset,
			  input logic [63:0] row,
			  output logic [31:0] dataOut,
			  output logic [31:0] dataOut2);


logic [15:0] indicesOut [3:0];
/*
logic [15:0] indicesOut2;
logic [15:0] indicesOut3;
logic [15:0] indicesOut4;
*/

//bram_module brams[3:0](clk, ready, rw, reset, row, indicesOut);


bram_module bram1(clk, ready, rw, reset, row, indicesOut[0]);
bram_module bram2(clk, ready, rw, reset, row, indicesOut[1]);
bram_module bram3(clk, ready, rw, reset, row, indicesOut[2]);
bram_module bram4(clk, ready, rw, reset, row, indicesOut[3]);


PIC pic1(clk, indicesOut[0], indicesOut[1], write, read, dataOut);
PIC pic2(clk, indicesOut[2], indicesOut[3], write, read, dataOut2);


endmodule
