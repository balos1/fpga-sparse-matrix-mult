module sparse_matrix_coprocessor(
	input logic clk, en,
	output logic [15:0]result,
	output logic overflow, underflow, zero, nan
	
);

comm c(
	.clk(clk),
	.reset(),
	.wen(),
	.RxD(),
	.TxD_start(),
	.TxD(),
	.TxD_busy()
);

PIC p1( 	//should have multiple of these
	.clk(clk),
	.A0(),
	.B0(),
	.eq(),
	.dataOut()
);

//fpu/mult m(
//	.clock(clk),
//	.reset(),
//	.clk_en(),
//	.dataa(),
//	.datab(),
//	.result(),
//	.overflow(),
//	.underflow(),
//	.nan()
//);
//
//
//fpu/adder add(
//	.clock(clk),
//	.reset(),
//	.clk_en(),
//	.dataa(),
//	.datab(),
//	.result(),
//	.overflow(),
//	.underflow()
//);

//fpu/fpu f(  
//	.clk(clk),
//	.clk_en(en),
//	.dataa(),
//	.datab(),
//	.result(result),
//	.overflow(overflow),
//	.underflow(underflow),
//	.zero(zero),
//	.nan(nan)
//);

endmodule 


