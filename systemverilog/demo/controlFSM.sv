module controlFSM(input logic clk, w_en, reset,
						output logic [1:0] count,
						output logic Z);
						
typedef enum logic {idle, active} State;
State curState = idle;
State nextState;


initial begin
	count = 0;
	end


//logic [1:0] in_count = 0;	
always_ff @(posedge clk) begin
	if(reset)
		curState <= idle;
	else
		curState <= nextState;
end

always_comb begin
	case(curState)
		idle:		if(w_en==1) nextState = active;
					else			nextState = idle;
		active:	if(count<2) nextState = active;
					else			nextState = idle;
		default:  nextState = idle;
	endcase
end

always_ff @(posedge clk) begin
	case(curState)
		active:		begin
							if(count == 2)
								count <= 0;
							else	count <= count + 1;
						end
	endcase
end

assign Z = (curState == active);
//assign count = in_count;
endmodule
