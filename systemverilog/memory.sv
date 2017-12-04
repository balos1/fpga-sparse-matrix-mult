

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
	input logic [127:0] inData,
	output logic [127:0] outData
);
	parameter entries = 16;

	logic [127:0] ram [entries-1:0];

	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
			for (int i = 0; i < entries; i++)
				ram[i] = 128'b0;
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

