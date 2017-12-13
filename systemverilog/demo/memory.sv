module memory(input logic clk, w_en,
				  input logic [1:0] count,
				  input logic [7:0] inData,
				  output logic [7:0] outData);
				  
logic [7:0] ram [8:0];

always_ff @(posedge clk) begin
	if(w_en)
		ram[count] <= inData;
end

always_ff @(posedge clk) begin
	if(w_en)
		outData <= ram[count];
end

endmodule
