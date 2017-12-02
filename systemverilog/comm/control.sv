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
module control(
	input logic clk, reset, load_data, rx_ready, 
	input logic [7:0] rx_byte, 
	output logic ready_for_mem,
	output logic [15:0] writePtr,
	output logic [15:0] readPtr,
	output logic [7:0] wdata
);

parameter number_of_bytes = 16;

integer byteCounter = 0;
typedef enum logic [3:0] {idle, writing, writeReady, zero, hold, read} State;
State curState = idle;
State nextState;

always_ff @(posedge clk or posedge reset) begin
	if(reset) begin
		curState <= idle;
	end
	else begin
		curState <= nextState;
	end
end


always_comb begin
	case(curState)
		idle:			if(load_data && rx_ready && rx_byte != 0)
							nextState = writing;
						else if(load_data && rx_ready && rx_byte == 0)
							nextState = zero;
						else if (!load_data)
							nextState = read;
						else
							nextState = idle;
		
		writing:		if(byteCounter < number_of_bytes && rx_ready)
							nextState = writing;
						else if(byteCounter == number_of_bytes)
							nextState = writeReady;
						else
							nextState = hold;

		writeReady:	nextState = hold;

		hold:			if(load_data && rx_ready && rx_byte != 0)
							nextState = writing;
						else if(!load_data)
							nextState = read;
						else
							nextState = hold;
						
		read:		nextState = hold;
		
		zero:		if(rx_byte == 0)
						nextState = zero;
					else
						nextState = writing;
		
		default:	nextState = hold;
	endcase
end


always_ff @(posedge clk) begin
	case(curState)
			idle: begin			
				writePtr <= 0;
				readPtr <= 0;
			end
			writeReady:	begin
				writePtr <= writePtr + 1;
				//byteCounter <= 0;
			end			
			read: readPtr <= readPtr + 1;
	endcase
end

always_ff @(posedge clk) begin
	if (curState == writing)
		byteCounter <= byteCounter + 1;
	else if(rx_byte == 0)
		byteCounter <= number_of_bytes;
	else if(curState == writeReady)
		byteCounter <= 0;
end
	
always_ff @(posedge clk) begin
	if(curState == writing) begin
		ready_for_mem <= 1'b1;
		wdata <= rx_byte;
	end
	else begin
		ready_for_mem = 1'b0;
		wdata <= 8'bX;
	end
end


endmodule
