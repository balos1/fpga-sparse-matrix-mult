module sparse_matrix_coprocessor(
	input logic clk, en,
	output logic [15:0]result,
	output logic overflow, underflow, zero, nan
	
);

comm c(
//	input logic clk, reset, wen,
//	input logic RxD,
//	input logic TxD_start,
//	output logic TxD,
//	output logic TxD_busy
	.clk(clk),
	.reset(),
	.wen(),
	.RxD(),
	.TxD_start(),
	.TxD(),
	.TxD_busy()
);

PIC p1( 	//should have multiple of these
//module PIC (input logic clk,
//				input logic [2:0] A0, B0, //data and index
//				output logic eq,
//				output logic [5:0]dataOut);
	.clk(clk),
	.A0(),
	.B0(),
	.eq(),
	.dataOut()
);

mult m(
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


adder add(
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
	.underflow()
);

endmodule 


