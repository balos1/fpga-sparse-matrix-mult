/* Control unit for the system:
    collect 4 16-bits or a terminating 0, ready signal will trigger
    and send data to the memory unit
*/

module control(input logic clk, reset, wen, dataReady, 
				   input logic [7:0] inByte, 
					output logic ready,
					output logic [15:0] writePtr,
					output logic [15:0] readPtr,
					output logic [7:0] outData);

integer byteCounter = 0;
typedef enum logic [3:0] {idle, writing, writeReady, zero, hold, read} State;
State curState = idle;
State nextState;


always_ff @(posedge clk) begin
	if(reset) begin
		curState <= idle;
	end
	
	else	curState <= nextState;
end


always_comb begin
	case(curState)
		idle:			if(wen && dataReady && inByte != 0)
							nextState = writing;
						else if(wen && dataReady && inByte == 0)
							nextState = zero;
						else if (!wen)
							nextState = read;
						else
							nextState = idle;
		
		writing:		if(byteCounter < 4 && dataReady)
							nextState = writing;
						else if(byteCounter == 4)
							nextState = writeReady;
						else
							nextState = hold;

		writeReady:	nextState = hold;
		
		hold:			if(wen && dataReady && inByte != 0)
							nextState = writing;
						else if(!wen)
							nextState = read;
						else
							nextState = hold;
						
		read:		nextState = hold;
		
		zero:		if(inByte == 0)
						nextState = zero;
					else
						nextState = writing;
		
		default:	nextState = hold;
	endcase
end


always_ff @(posedge clk) begin
	case(curState)
			idle:		begin			
						writePtr <= 0;
						readPtr <= 0;
					end
			writeReady:	begin
						writePtr <= writePtr + 1;
						//byteCounter <= 0;
					end
							
			read:			readPtr <= readPtr + 1;
	endcase
end

always_ff @(posedge clk) begin
	if (curState == writing)
		byteCounter <= byteCounter + 1;
	else if(inByte == 0)
		byteCounter <= 4;
	else if(curState == writeReady)
		byteCounter <= 0;
end
	

always_ff @(posedge clk) begin
	if(curState == writing) begin
		ready <= 1'b1;
		outData <= inByte;
	end
	else begin
		ready = 1'b0;
		outData <= 8'bX;
	end
end


endmodule








		

