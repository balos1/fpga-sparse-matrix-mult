module sparse_matrix_coprocessor(
	input logic clk,
	
);

controlPIC ctl1(
//module controlPIC (input logic clk, en, rw, reset,
//				output logic [3:0] raddr, waddr,
//				output logic wen, full, empty);

	.clk(clk),
	.en(en),
	.rw(rw),
	.reset(reset),
	.raddr(raddr),
	.waddr(waddr),
	.wen(wen),
	.full(full),
	.empty(empty)
);

PIC pic(
//module PIC (input logic clk,
//				input logic [2:0] A0, B0, //data and index
//				output logic eq,
//				output logic [5:0]dataOut);
	.clk(clk),
	.A0(),
	.B0(),
	.eq(eq),
	.dataOut(dataOut)
);

fpu/mult m(
//	module mult(input logic clock, reset, clk_en,
//            input logic [15:0] dataa, datab,
//            output logic [15:0] result,
//            output logic overflow, underflow, nan);
	.clock(clk),
	.reset(),
	.clk_en(),
	.dataa(),
	.datab(),
	.result(),
	.overflow(),
	.underflow(),
	.nan()
);

fpu/fpu f(
//	module fpu(input logic clk, clk_en,
//				  input logic [15:0] dataa, datab,
//				  output logic [15:0] result,
//				  output logic sign, overflow, underflow, zero, nan);
	.clk(clk),
	.clk_en(),
	.dataa(),
	.datab(),
	.result(),
	.overflow(),
	.underflow(),
	.zero(),
	.nan()
);

fpu/adder add(
//	module adder(input logic clock, reset, clk_en,
//             input logic [15:0] dataa, datab,
//             output logic [15:0] result,
//             output logic overflow, underflow);
	.clock(clk),
	.reset(),
	.clk_en(),
	.dataa(),
	.datab(),
	.result(),
	.overflow(),
	.underflow(),
);


