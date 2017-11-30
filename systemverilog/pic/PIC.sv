/* Independent Parallel Indices Comparison Unit
	output high if indices are equal
	store indices in fifo
*/

module PIC (input logic clk,
				input logic [2:0] A0, B0,
				output logic eq,
				output logic [5:0]dataOut); //indices from fifo
	
				
	logic [15:0] fifo [1:0];
	integer i;
			
	initial begin //initialize fifo
		for(i=0; i<2; i++)
			fifo[i]=i[15:0];
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
