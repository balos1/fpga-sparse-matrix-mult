module COMM(input logic clk, RxD,
				input logic [7:0] GPin,//general purspose inputs
				output logic TxD,
				output logic [7:0] GPout); //general purpose output
	
	logic RxD_data_ready;
	logic [7:0] RxD_data;
	async_receiver RX(.clk(clk), .RxD(RxD), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));
	
	always @(posedge clk)
	begin
	if(RxD_data_ready)
		GPout <= RxD_data;
	end
	
	async_transmitter TX(.clk(clk), .TxD(TxD), .TxD_start(RxD_data_ready), .TxD_data(GPin));
		
endmodule
