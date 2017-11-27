`timescale 1ns/1ns
module testPIC();

//DUT signals
	logic clk = 1'b0;
	logic [2:0] A0, B0;
	logic eq;
	logic [5:0] dataOut;
	
	//connect to device to test
	PIC dutFP(.clk(clk), .A0(A0), .B0(B0), .eq(eq), .dataOut(dataOut));
	
	//generate clock
	always #50 clk <= ~clk;
	
	//tasks
	task test (input logic [2:0] a, b);
		@(negedge clk)
		A0 <= a;
		B0 <= b;
		$display("A0: %b =? B0: %b : %b", A0, B0, eq);
		
	endtask
	
	//generate inputs
	initial
	begin
		test(3'b111, 3'b101);
		test(3'b111, 3'b111);
		test(3'b111, 3'b101);
		test(3'b101, 3'b101);
		

	end
endmodule 