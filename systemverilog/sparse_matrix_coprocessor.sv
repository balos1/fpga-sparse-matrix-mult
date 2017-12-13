/*
	Top level module for sparse matrix coprocessor project.
*/

module sparse_matrix_coprocessor
(
	input logic clk,
	input logic resetn, op, fpu_complete,
	input logic RxD,
	output logic TxD,
	output logic [135:0] tx_data,
	output logic busy, tx_complete, rx_complete
);

	logic ren_clk;
	logic [135:0] rx_data;

	fall_detect detect
	(
		.clk(clk),
		.d(fpu_complete),
		.q(ren_clk)
	);

	comm c
	(
		.clk(clk),
		.resetn(resetn),
		.op(op),
		.rx(RxD),
		.tx_data(tx_data),
		.tx(TxD),
		.tx_complete(tx_complete),
		.rx_complete(rx_complete),
		.rx_data(rx_data),
		.busy(busy)
	);

	memory mainmem
	(
		.clk(clk),
		.resetn(resetn),
		.wen(rx_complete),
		.ren(ren_clk),
		.inData(rx_data),
		.outData(tx_data)
	);

	// TODO: Connect IPIC to mainmem
	// IPIC pic1
	// (
	// 	.clk(clk),
	// 	.reset(~resetn),
	// 	.ready(fpu_complete),
	// 	.write(rx_complete),
	// 	.read(fpu_ready),
	// 	.row(),
	// 	.fifo0(a0b0),
	// 	.fifo1(a0b1),
	// 	.fifo2(a0b2),
	// 	.fifo3(a0b3),
	// 	.fifo4(a1b0),
	// 	.fifo5(a1b1),
	// 	.fifo6(a1b2),
	// 	.fifo7(a1b3),
	// 	.fifo8(a2b0),
	// 	.fifo9(a2b1),
	// 	.fifo10(a2b2),
	// 	.fifo11(a2b3),
	// 	.fifo12(a3b0),
	// 	.fifo13(a3b1),
	// 	.fifo14(a3b2),
	// 	.fifo15(a3b3)
	// );

	// TODO: Connect FPU to IPIC outputs

endmodule
