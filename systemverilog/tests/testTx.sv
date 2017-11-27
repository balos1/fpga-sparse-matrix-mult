`timescale 1ns/1ns
module testTx();


//DUT signals
	logic clk = 1'b0;
	logic [7:0] TxD_data;
	logic TxD_start = 1'b1;
	logic [7:0] buffer;
	logic TxD;
	logic TxD_busy;

	
	//connect to device to test
	async_transmitter dutFP(.clk(clk), .TxD_start(TxD_start), .TxD(TxD), .TxD_data(TxD_data), .TxD_busy(TxD_busy));
	
	//generate clock
	int clkcycle=100;
	always #(clkcycle/2) clk <= ~clk;
	
//	//tasks
//	task test (input logic [7:0]d, input logic s);
//		//@(negedge clk)
//			TxD_start <= s;
//			TxD_data <= d;
//			repeat(8) begin
//				#50
//				buffer[i] = TxD;
//				i++;
//			end
//	endtask
	
	//generate inputs
	initial
	begin
		int i =0;
//		test(8'b10101011, 1);		
//		test(8'b11111011, 1);
			TxD_data = 8'b10110011;
			repeat(8) begin
				#(clkcycle)
				buffer[i] = TxD;
				i++;
			end

	end
endmodule 