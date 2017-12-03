module compare(
	input logic clk,
	input logic [15:0] A0, B0,
	output logic eq,
	output logic [31:0] dataOut
);

	always_ff @(posedge clk) begin
		if (A0 == B0) begin
			eq <= 1'b1;
			dataOut <= {A0, B0};
		end
		else
			eq <= 1'b0;
	end
endmodule