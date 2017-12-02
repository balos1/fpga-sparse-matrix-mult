


module comm
(
	input logic clk, reset, load_data,
	input logic RxD,
	input logic device2host,
	output logic TxD,
	output logic TxD_busy
);
	
	logic ready_for_mem;
	logic RxD_data_ready;
	logic [7:0] RxD_data;
	logic [15:0] writePtr;
	logic [15:0] readPtr;
	logic [7:0] wdata;

	control #(16) ctl
	(
		.clk(clk), 
		.reset(reset),
		.load_data(load_data),
		.rx_ready(RxD_data_ready),
		.rx_byte(RxD_data),
		.ready_for_mem(ready_for_mem),
		.writePtr(writePtr),
		.readPtr(readPtr),
		.wdata(wdata)
	);

	memory main
	(
		.clk(clk),
		.reset(reset),
		.wen(ready_for_mem),
		.writePtr(writePtr),
		.readPtr(readPtr),
		.inData(wdata),
		.outData(rdata)
	);

	async_transmitter #(50000000, 115200) transmiter
	(
		.clk(clk),
		.TxD_start(device2host),
		.TxD(TxD),
		.TxD_busy(TxD_busy)
	);
	
	async_receiver #(50000000, 115200, 16) receiver
	(
		.clk(clk),
		.RxD(RxD),
		.RxD_data_ready(RxD_data_ready),
		.RxD_data(RxD_data),
		.RxD_idle(),
		.RxD_endofpacket()
	);

endmodule
