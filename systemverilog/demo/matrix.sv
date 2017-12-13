module matrix(input logic clk, w_en,
							  output logic [7:0] result [8:0]);

logic [7:0] matrixA [8:0];
logic [7:0] matrixB [8:0];

logic [3:0] j [8:0] = '{0, 0, 0, 3, 3, 3, 6, 6, 6};
logic [3:0] k [8:0] = '{0, 1, 2, 0, 1, 2, 0, 1, 2};
integer i;
readFile readFile_module(clk, w_en, matrixA, matrixB);

always_ff @(posedge clk) begin
	if(w_en) begin
		for(i=0;i < 9; i++) begin
			result[i] <= matrixA[j[i]] * matrixB[k[i]] + matrixA[j[i]+1] * matrixB[k[i]+3] + matrixA[j[i]+2] * matrixB[k[i]+6]; 
		end
	end
	else
		result <= '{0, 0, 0, 0, 0, 0, 0, 0, 0};
end

endmodule
