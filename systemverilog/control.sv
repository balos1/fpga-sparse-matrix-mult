/* Control unit for the system:
    collect 8 bytes or a terminating byte, ready signal will trigger
    and send data to the memory unit
*/

module control(input logic clk, reset, wen, dataReady, 
				       input logic [7:0] inByte, 
					     output logic ready,
					     output logic [31:0] writePtr,
					     output logic [63:0] outData); // not sure if this will work, looks like the maximum data bus width is 32-bit..
					
typedef enum logic [1:0] {idle, hold, write} State;
State curState = idle;
State nextState;
integer byteCount = 0;

always_ff @(posedge clk) begin
	if(reset)	curState <= idle;
	else			curState <= nextState;
end


always_comb begin
	case(curState)
		idle:		if(wen && dataReady)
						nextState = write;
					else
						nextState = idle;
		
		write:	nextState = hold;
		
		hold:		if(wen && dataReady)
						nextState = write;
					else
						nextState = hold;
		default:		nextState = idle;
	endcase
end


always_ff @(posedge clk) begin
  	if(inByte == 8'd255) // check for terminating byte
	  byteCount <= 8;
  else if(dataReady && byteCount < 8)begin
		outData <= {outData, inByte};
		byteCount <= byteCount + 1;
		end

	else if(byteCount == 8)
	  byteCount <= 0;

end

always_ff @(posedge clk) begin
	case(curState)
		idle:			writePtr <= 0;
						
		write:		writePtr <= writePtr + 1;

	endcase
end

assign ready = (inByte == 8'd255 || byteCount == 8);

endmodule

	
					
					
