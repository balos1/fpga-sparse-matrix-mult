module bram(input logic clk, wen,
				    input logic [127:0] row,
				    output logic [127:0] outRow
);

//typedef enum logic {idle, active} State;
//State curState = idle;
//State nextState;

logic [127:0] ram;

always_ff @(posedge clk) begin
	if(wen)
		ram <= row;
	outRow <= row;
end

endmodule
		

