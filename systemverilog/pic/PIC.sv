/* Independent Parallel Indices Comparison Unit
	output high if indices are equal
	store indices in fifo
	
	indices from A are stored in fifo [32:16]
	indices from B are stored in fifo [15:0]
*/

module PIC (input logic clk,
				input logic [16:0] A0, B0,
				output logic eq,
				output logic [31:0]dataOut); //indices from fifo
	
	parameter fifoEntries = 4;			
	logic [31:0] fifo [fifoEntries-1:0];
	integer i;
			
	initial begin //initialize fifo
		for(i=0; i<fifoEntries; i++)
			fifo[i]=i[31:0];
	end
	
	
	assign eq= (A0==B0);
	
	controlPIC m1(.clk(clk), .waddr(waddr), .raddr(raddr)); //control unit for read/write addresses
	
	always_ff @(posedge clk) begin	
		if(eq) begin
			fifo[waddr]<={A0, B0}; //store indices if equal
			dataOut<=fifo[raddr];
		end
		
		else 
			dataOut<=fifo[raddr];
	end

endmodule
