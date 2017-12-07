/*
	module: comm_controller
	author(s): Cody Balos <cjbalos@gmail.com>, Kelvin Hu

	Comm controller which handles receiving and transmitting a row/col of a matrix.
	It is limited to a fixed matrix size provided as a parameter and every matrix
	must have at least 1 entry per row/col.

	parameters:
		MATRIX_N - the size of the square matrix (in number of entries i.e. MATRIX_NxMATRIX_N matrix)
		HEADER - the size of the header (in bytes)
	inputs:
		reset - async active high reset signal
		load_data - when high system is to be ready to load receive data and write it to memory
		rx_ready - indicates RX data is available
		rx_byte - the data received in a packet
	outputs:
		ready_for_mem - data that was ready is ready to be written to memory
*/

// width of one data, which is one matrix row/col  (header + values + indices)
`define DATA_WIDTH (HEADER*8 + 16*MATRIX_N + 16*MATRIX_N)
`define END_VALUES (size_of + HEADER)
`define END_INDICES (2*size_of + HEADER)

module comm_controller #(
	parameter MATRIX_N = 4,
	parameter HEADER = 1
)(
	input logic clk,
	input logic resetn,
	input logic op,
	input logic start,
	input logic rx_ready,
	input logic [7:0] rx_byte,
	input logic [`DATA_WIDTH-1:0] tx_data,
	input logic tx_ready,
	output logic [7:0] tx_byte,
	output logic tx_start,
	output logic tx_complete,
	output logic rx_complete,
	output logic [`DATA_WIDTH-1:0] rx_data,
	output logic busy
);

typedef enum logic [4:0] {
	 IDLE,
	 READHEADER, READVALUES, READINDICES, HOLD, LOAD, DAV,
	 WRITELOAD, WRITEHOLD, WRITE, WRITEDONE
} State;

State curState = IDLE;
State nextState;

integer byte_count = 0;
logic [(HEADER*8):0] size_of;
logic [(16*MATRIX_N-1):0] rx_values_buffer, rx_indices_buffer;

always_ff @(posedge clk or negedge resetn) begin
	if(!resetn) begin
		curState <= IDLE;
	end else begin
		curState <= nextState;
	end
end

// determine next state
always_comb begin
	if (!resetn) begin
		nextState = IDLE;
	end else begin
	case(curState)
		IDLE: begin
			if (!op && rx_ready) begin
				nextState = READHEADER;
			end else if (op && tx_ready) begin
				nextState = WRITELOAD;
			end else begin
				nextState = IDLE;
			end
		end
		READHEADER: begin
			nextState = HOLD;
		end
		HOLD: begin
			// If header has been read, then we can go to normal read step.
			// If all bytes were read, then we can go to load step where rx_data is packed.
			// Otherwise wait for the next byte.
			case(rx_ready)
				0: begin
					if (byte_count == `END_INDICES)
						nextState = LOAD;
					else
						nextState = HOLD;
				end
				1: begin
					if (byte_count < HEADER)
						nextState = READHEADER;
					else if (byte_count >= HEADER && byte_count < `END_VALUES)
						nextState = READVALUES;
					else if (byte_count >= `END_VALUES && byte_count < `END_INDICES)
						nextState = READINDICES;
					else
						nextState = IDLE; // for debuggin
				end
			endcase
		end
		READVALUES: begin
			nextState = HOLD;
		end
		READINDICES: begin
			nextState = HOLD;
		end
		LOAD: begin
			nextState = DAV;
		end
		DAV: begin
			nextState = IDLE;
		end
		WRITELOAD: begin
			nextState = WRITEHOLD;
		end
		WRITEHOLD: begin
			nextState = WRITE;
		end
		WRITE: begin
			if (!tx_ready) begin
				nextState = WRITE;
			end else begin
				if (byte_count < (`DATA_WIDTH/8))
					nextState = WRITELOAD;
				else
					nextState = WRITEDONE;
			end
		end
		WRITEDONE: begin
			nextState = IDLE;
		end
		default: begin
			nextState = IDLE;
		end
	endcase
	end
end

logic [135:0] le_tx_data;
logic [7:0] shiftout;

// determine outputs
always_ff @(posedge clk or negedge resetn) begin
	if (!resetn) begin
		tx_start <= 0;
		tx_byte <= 0;
		tx_complete <= 0;
		rx_complete <= 0;
		rx_data <= {(`DATA_WIDTH){1'b0}};
		busy <= (tx_ready == 0);
		rx_values_buffer <= {(16*MATRIX_N){1'b0}};
		rx_indices_buffer <= {(16*MATRIX_N){1'b0}};
		size_of <= {(HEADER*8){1'b0}};
	end else begin
	case(curState)
		IDLE: begin
			tx_start <= 0;
			tx_complete <= 0;
			rx_complete <= 0;
			// rx_data <= {(`DATA_WIDTH){1'b0}};
			busy <= (tx_ready == 0);
			// rx_values_buffer <= {(16*MATRIX_N){1'b0}};
			// rx_indices_buffer <= {(16*MATRIX_N){1'b0}};
			// size_of <= {(HEADER*8){1'b0}};
		end
		READHEADER: begin
			size_of <= {size_of, rx_byte};
			busy <= 1;
		end
		HOLD: begin
			busy <= 1;
		end
		READVALUES: begin
			rx_values_buffer <= {rx_values_buffer, rx_byte};
			busy <= 1;
		end
		READINDICES: begin
			rx_indices_buffer <= {rx_indices_buffer, rx_byte};
			busy <= 1;
		end
		LOAD: begin
			rx_data <= {size_of, rx_values_buffer, rx_indices_buffer};
			busy <= 1;
		end
		DAV: begin
			rx_complete <= 1;
			busy <= 1;
		end
		WRITELOAD: begin
			size_of <= tx_data[`DATA_WIDTH-1 -: 8*HEADER];
			le_tx_data <= tx_data;
			// shiftout <= 
			//tx_byte <= shiftout;
			tx_start <= 1;
			busy <= 1;
		end
		WRITEHOLD: begin
			size_of <= size_of;
			tx_byte <= le_tx_data[byte_count*8 +: 8];
			tx_start <= tx_start;
			busy <= 1;
		end
		WRITE: begin
			tx_start <= 0;
			busy <= 1;
		end
		WRITEDONE: begin
			tx_complete <= 1;
			busy <= 1;
		end
		default: begin
			tx_start <= 0;
			tx_complete <= 0;
			rx_complete <= 0;
			rx_data <= {(`DATA_WIDTH){1'b0}};
			busy <= (tx_ready == 0);
			rx_values_buffer <= {(16*MATRIX_N){1'b0}};
			rx_indices_buffer <= {(16*MATRIX_N){1'b0}};
			size_of <= {(HEADER*8){1'b0}};
		end
	endcase
	end
end


// increment byte counter when read/write
always_ff @(posedge clk) begin
	if (curState == READHEADER || curState == READVALUES || curState == READINDICES || curState == WRITELOAD)
		byte_count <= byte_count + 1;
	else if (curState == HOLD || curState == WRITE || curState == WRITEHOLD || curState == WRITEDONE)
		byte_count <= byte_count;
	else
		byte_count <= 0;
end

endmodule
