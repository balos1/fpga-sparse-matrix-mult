module readFile(input logic clk, w_en,
					 output logic [7:0] matrixA [8:0],
					 output logic [7:0] matrixB [8:0]);
logic [7:0] ramA [8:0];
logic [7:0] ramB [8:0];
					 
initial 
	begin
		$readmemh("maA.txt", ramA);
		$readmemh("maB.txt", ramB);
		
	end


always_ff @(posedge clk) begin
	if(w_en) begin
		matrixA <= ramA;
		matrixB <= ramB;
	end
end
	
endmodule
