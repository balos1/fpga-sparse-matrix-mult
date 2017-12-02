module compare(
	input logic clk,
	input logic [15:0] A0, B0,
	output logic eq,
	output logic [31:0] dataOut
);

	always_ff @(posedge clk) begin
		eq <= (A0 == B0);
		if(eq)
			dataOut <= {A0, B0};
	end
endmodule
	