	/*
	control
		takes in r_en & data from FPU ad w_en
		wen is eq from compare & write from external control
		takes in write data from compare (indices)
		
	compare
		takes in two indices from BRAM
		outputs equal signal and indices if equal
		
	fifo
		takes data from compare and waddr, raddr from control
		puts into fifos
	*/
module fifo (
	input logic w_en, clk,
	input logic [31:0] dataIn, 
	input logic [3:0] waddr, raddr,
	output logic[31:0] dataOut
);

	parameter fifoEntries = 4;			
	logic [31:0] fifo [fifoEntries-1:0];
	integer i;
			
	initial begin //initialize fifo
		for(i=0; i<fifoEntries; i++)
			fifo[i]= 0;
	end
	
		
	always_ff @(posedge clk) begin	
		if(w_en) begin
			fifo[waddr]<=dataIn; //store indices if equal //{A0, B0}
			dataOut<=fifo[raddr];
		end
		
		else 
			dataOut<=fifo[raddr];
	end
endmodule 