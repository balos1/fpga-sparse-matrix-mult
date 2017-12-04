

/*
	module: memory
	
	Implements a memory module with M 16 bit entries.

	inputs
		wen - write enable signal; must be asserted to write to ram
		reset - async active high reset signal which clears memory
*/
module memory(
	input logic clk, reset, wen,
	input logic [15:0] writePtr, readPtr,
	input logic [7:0] inData,
	output logic [127:0] outData
);
	parameter entries = 64;
						 
	logic [entries-1:0] ram [15:0];

	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
			for (int i = 0; i < entries; i++)
				ram[i] = 16'b0;
		end
		if(wen) begin
			ram[writePtr] <= {ram[writePtr], inData};
			outData <= {ram[writePtr], inData};
		end
		else begin
			outData <= ram[readPtr];
		end
	end

endmodule
		
