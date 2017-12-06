module sparse_matrix_coprocessor
(
	input logic clk, reset, wen,
	input logic RxD,
	output logic TxD,
	output logic [15:0] result,
	output logic overflow, underflow, zero, nan
);


	logic TxD_start, TxD_busy;

	comm c
	(
		.clk(clk),
		.reset(reset), 
		.wen(wen),
		.RxD(RxD),
		.TxD_start(TxD_start),
		.TxD(TxD),
		.TxD_busy(TxD_busy)
	);

// IPIC p(  
// 	.clk(clk),
// 	.ready(),
// 	.write(),
// 	.read(),
// 	.reset(),
//		.row()
//		.dataOut1(),
//		.dataOut2(),
//		.dataOut3(),
//		.dataOut4(),
// );


// fpu f(  
//	 .clk(clk),
//	 .clk_en(en),
//	 .dataa(), //data at index from ipic
//	 .datab(),
//	 .result(result),
//	 .overflow(overflow),
//	 .underflow(underflow),
//	 .zero(zero),
//	 .nan(nan)
// );

endmodule 


