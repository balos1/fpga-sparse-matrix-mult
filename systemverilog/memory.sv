

/*
	module: memory

	Implements a memory module with M 16 bit entries.

	inputs
		wen - write enable signal; must be asserted to write to ram
		reset - async active high reset signal which clears memory
*/
module memory(
	input logic clk, resetn, wen, ren,
	input logic [135:0] inData,
	output logic [135:0] outData
);
	parameter entries = 64;

	// typedef enum logic [1:0]  { 
	// 	IDLE, WRITE, READ
	// } State;

	// State current_state;
	// State next_state;

	logic [5:0] writePtr, readPtr;

	logic [135:0] ram [entries-1:0];

	// always_comb begin
	// 	case(current_state) begin
	// 		IDLE: begin
	// 			if (wen)
	// 				next_state = WRITE;
	// 			else if (ren)
	// 				next_state = READ;
	// 			else 
	// 				next_state = IDLE;
	// 		end
	// 		WRITE: begin
	// 			if (wen)
	// 				next_state = WRITE;
	// 			else 
	// 				next_state = IDLE;
	// 		end
	// 		READ: begin
	// 			if (ren)
	// 				next_state = READ;
	// 			else 
	// 				next_state = IDLE;
	// 		end
	// 		default: next_state = IDLE; 
	// 	end
	// end

	always_ff @(posedge clk or negedge resetn) begin
		if (!resetn) begin
			writePtr <= 0; readPtr <= 0;
			for (int i = 0; i < entries; i++)
				ram[i] = {i, {104{1'b0}}};
		end else if(wen) begin
			ram[writePtr] <= inData;
			outData <= ram[writePtr];
			writePtr++;
		end else if (ren) begin
			readPtr++;
		end else begin
			outData <= ram[readPtr];
		end
	end

	// always_ff @(posedge clk or negedge resetn) begin
	// 	if (!resetn) begin
	// 		current_state <= IDLE;
	// 	end else begin
	// 		current_state <= next_state;
	// 	end
	// end

endmodule

