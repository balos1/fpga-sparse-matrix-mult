


module comm(
	input logic clk, reset, wen,
	input logic RxD,
	input logic TxD_start,
	output logic TxD,
	output logic TxD_busy
);
	
	logic ready;
	logic RxD_data_ready;
	logic [7:0] RxD_data;
	logic [15:0] writePtr;
	logic [15:0] readPtr;
	logic [7:0] outData;


	control ctl
	(
		.clk(clk), 
		.reset(reset),
		.wen(wen),
		.dataReady(RxD_data_ready),
		.inByte(RxD_data),
		.ready(ready),
		.writePtr(writePtr),
		.readPtr(readPtr),
		.outData(outData)
	);
	
	
	// INSTANTIATE BUFFER/MEM

	async_transmitter #(50000000, 115200)
	(
		.clk(clk),
		.TxD_start(TxD_start),
		.TxD(TxD),
		.TxD_busy(TxD_busy)
	);
	
	async_receiver #(50000000, 115200, 16)
	(
		.clk(clk),
		.RxD(RxD),
		.RxD_data_ready(RxD_data_ready),
		.RxD_data(RxD_data),
		.RxD_idle(),
		.RxD_endofpacket()
	);
	

endmodule
