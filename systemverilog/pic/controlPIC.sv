module controlPIC (
	input logic clk, w_en, r_en,
	output logic [3:0] raddr, waddr,
	output logic full, empty
);

	typedef enum logic [1:0] {idle, read, write} statetypes;
	statetypes currentState=idle, nextState;
			
	always_ff @(posedge clk)
	begin
		currentState <= nextState;
	end
	
	always_comb
	begin
		case(currentState)
				idle:	begin
				  if(r_en)
					nextState <= read;
				  else if (w_en)
					nextState <=write;
				  else
					nextState <= idle;
				end
				
				read:	begin
				  if(r_en)
					nextState <= read;
				  else
					nextState <= idle;
				end
				
				write: begin
				  if (w_en)
					nextState <=write;
				  else
					nextState <= idle;
				end
				
				default:
					nextState <= idle;
		endcase	
	end
	
		
	always_ff @(posedge clk)
	begin
		case(currentState)
				idle:begin
					waddr <= 4'b0000; //pointers set to beginning
					raddr <= 4'b0000;
					end
				read:
					raddr <= raddr + 4'b0001;//increment read addr
				write:begin
					waddr <= waddr + 4'b0001;//increment write addr
				end
		endcase
	end
	
	assign empty = (raddr == waddr);
	assign full = ((raddr[3] != waddr[3]) && (raddr[2:0] == waddr [2:0]));

endmodule

	
	