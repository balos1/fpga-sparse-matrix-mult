module controlPIC (input logic clk, en, rw, reset,
				output logic [3:0] raddr, waddr,
				output logic wen, full, empty);

	typedef enum logic [1:0] {idle, read, write, hold} statetypes;
	statetypes currentState=idle, nextState;
			
	always_ff @(posedge clk)
	begin
		currentState <= nextState;
	end
	
	always_comb
	begin
		case(currentState)
				idle:	begin
				  if(!rw && en)
					nextState <= read;
				  else if (rw && en)
					nextState <=write;
				  else
					nextState <= idle;
				end
				
				read: 
					nextState <= hold;
				
				write:
					nextState <=hold;
				
				hold: begin
					if(!rw && en && !empty)
					nextState <= read;
				  else if (rw && en && !full)
					nextState <=write;
				  else
					nextState <= hold;
				end
				
				default:
					nextState <= idle;
		endcase	
	end
	
		
	always_ff @(posedge clk)
	begin
		if(reset==1'b1) begin
			raddr = 4'b0000;
			waddr = 4'b0000;
		end
		case(currentState)
				idle:begin
					waddr <= 4'b0000; //pointers set to beginning
					raddr <= 4'b0000;
					end
				read:
					raddr <= raddr + 4'b0001;//increment read addr
				write:begin
				//	wen <= 1'b1;
					waddr <= waddr + 4'b0001;//increment write addr
				end
		endcase
	end
	
	assign empty = (raddr == waddr);
	assign full = ((raddr[3] != waddr[3]) && (raddr[2:0] == waddr [2:0]));
	assign wen = (currentState == write);

endmodule

	
	