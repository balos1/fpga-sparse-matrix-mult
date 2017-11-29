module memory(input logic clk, wen,
						 input logic [15:0] writePtr, readPtr,
						 input logic [7:0] inData,
						 output logic [63:0] outData);
						 

logic [63:0] ram [15:0];

always_ff @(posedge clk) begin
	if(wen) begin
		ram[writePtr] <= {ram[writePtr], inData};
	end
	else
		outData <= ram[readPtr];
end

endmodule
		
