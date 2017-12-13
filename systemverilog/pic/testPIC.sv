`timescale 1ns/1ns
module testPIC();

//DUT signals
	logic clk = 1'b0;
	logic [15:0] A0, B0;
	logic write, read;
	logic [31:0] fifo_Out;
	
	//connect to device to test
	PIC dutPIC(.clk(clk), .A0(A0), .B0(B0), .write(write), .read(read), .fifo_Out(fifo_Out));
	
	//generate clock
	always #50 clk <= ~clk;
	
	//tasks
	task test (input logic [15:0] a, b, input logic w, r);
		@(negedge clk)
		A0 <= a;
		B0 <= b;
		read <= r;
		write <= w;
	endtask
	
	//generate inputs
	initial
	begin
		test(16'b1110001101010010, 16'b1011100101011011, 1'b1, 1'b0);
		test(16'b1110001101010010, 16'b1110001101010010, 1'b1, 1'b0);
		test(16'b0000000000000011, 16'b0000000000000011, 1'b1, 1'b0);
		test(16'b1110001101010010, 16'b1011100101011011, 1'b1, 1'b0);
		test(16'b1110001101010010, 16'b1011100101011011, 1'b1, 1'b0);
		test(16'b1111111111111111, 16'b1111111111111110, 1'b1, 1'b0);
		test(16'b1001111111111110, 16'b1001111111111110, 1'b1, 1'b0);

		test(16'b1110001101010010, 16'b1011100101011011, 1'b0, 1'b1);
		test(16'b1110001101010010, 16'b1110001101010010, 1'b0, 1'b1);
		test(16'b0000000000000011, 16'b0000000000000011, 1'b0, 1'b1);
		test(16'b1110001101010010, 16'b1011100101011011, 1'b0, 1'b1);
		test(16'b1110001101010010, 16'b1011100101011011, 1'b0, 1'b1);
		test(16'b1111111111111111, 16'b1111111111111110, 1'b0, 1'b1);
		test(16'b1001111111111110, 16'b1001111111111110, 1'b0, 1'b1);		

	end
endmodule 