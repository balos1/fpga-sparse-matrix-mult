module bramControl(input logic clk, ready, rw, reset,
						      output logic [1:0] bramWritePtr,
						      output logic wen);

	typedef enum logic {idle, write} State;
	State curState=idle;
	State nextState;

	integer writeCounter = 0;

	always_ff @(posedge clk) begin
	if(reset)
		curState <= idle;
	else
		curState <= nextState;
	end

	always_comb begin
		case(curState)
				idle:	begin
				  if (rw && ready)
						nextState =write;
				  else
						nextState = idle;
				end
				write:
					if(writeCounter < 3)
						nextState = write;
					else
						nextState = idle;

				default:
					nextState = idle;
		endcase
	end


	always_ff @(posedge clk) begin
		case(curState)
				idle: begin
					bramWritePtr <= 2'b0;
					writeCounter <= 0;
					end
				write: begin
					bramWritePtr <= bramWritePtr + 2'b1;//increment read addr
					writeCounter <= writeCounter + 1;
					end
		endcase
	end

	assign wen = (curState == write);

endmodule
