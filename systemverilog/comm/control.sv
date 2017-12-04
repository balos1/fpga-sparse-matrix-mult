/* 
	module: control

	Control unit for the system. Collects 4 16-bits or a terminating 0. ready_for_mem signal will trigger
    and send data to the memory unit.

	inputs:
		reset - async active high reset signal
		load_data - when high system is to be ready tp load receive data and write it to memory
		rx_ready - indicates RX data is available
		rx_byte - the data received in a packet
	outputs:
		ready_for_mem - data that was ready is ready to be written to memory

*/
module control(input logic clk, reset, wen, dataReady, 
	       input logic [7:0] inByte, 
	       output logic ready,
	       output logic [15:0] writePtr,
	       output logic [15:0] readPtr,
	       output logic [7:0] outData);
parameter number_of_bytes = 8;
integer byteCounter = 0;
typedef enum logic [2:0] {idle, writing, writeReady, hold, read} State;
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
							nextState = writeReady;
						else if (!wen)
							nextState = read;
						else
							nextState = idle;
		
		writing:		if(byteCounter < number_of_bytes && dataReady)
							nextState = writing;
						else if(byteCounter == number_of_bytes || inByte == 0)
							nextState = writeReady;
						else
							nextState = hold;

		writeReady:		nextState = hold;
		
		hold:			if(wen && dataReady && inByte != 0)
							nextState = writing;
						else if(!wen)
							nextState = read;
						else if(inByte == 0)
							nextState = writeReady;
						else
							nextState = hold;
						
		read:			nextState = hold;
		
		default:		nextState = hold;
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
						byteCounter <= 0;
					end
							
			read:			readPtr <= readPtr + 1;
			
			writing:		byteCounter <= byteCounter + 1;
	endcase
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
