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

	fall_detect falldetect
	(
		.clk(clk),
		.d(fpu_complete),
		.q(ren_clk)
	);

endmodule 
