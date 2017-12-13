

// 50000000/divisor = BAUDRATE
`define B10Mhz 5
`define B115200 434
`define B50Hz 1000000

/*
	module: comm

	The communication unit for the coprocessor. Handles receving data from host and transmitting data to host.

	inputs:
		clk
		resetn ----- async active low reset that resets tx and rx units, control, and main memory
		op --------- indicates if comm unit should be receiving or transmitting
		rx --------- the serial receive line
		tx_start --- start transmission (1)
		tx_data ---- the row/col of matrix to transmit; must be in instruction format**
	outputs:
		tx ---------- the serial transmit line
		tx_complete - indicates device transmitted full instruction (1)**
		rx_complete - indicates a full instruction** has been received (1)
		rx_data ----- the row/col of matrix which wass received; it is in instruction format**
		busy -------- indicates device is busy doing something (1) or ready to rx/tx (0)

	** instruction format is { OPCODE[7:0], VALUES[MATRIX_N-1:0], INDICES[MATRIX_N-1:0] }
*/
module comm #(
`ifdef SIMULATION
	parameter BAUDRATE = `B10Mhz,
`else
	// parameter BAUDRATE = `B115200,
	parameter BAUDRATE = `B50Hz;
`endif
	parameter MATRIX_N = 4
)(
	input logic clk,
	input logic resetn,
	input logic op,
	input logic start,
	input logic rx,
	input logic [(8+2*16*MATRIX_N-1):0] tx_data,
	output logic tx, tx_complete, rx_complete,
	output logic [(8+2*16*MATRIX_N-1):0] rx_data,
	output logic busy
);

	// Intermediate TX0 and RX0 signals
	logic rx_ready;
	logic [7:0] rx_byte;
	logic [7:0] tx_byte;
	logic tx_start;

	// Intermediate ctl and mainmem signals
	// logic ready_for_mem;
	// logic [15:0] writePtr, readPtr;
	// logic [127:0] wdata, rdata;

	comm_controller ctl
	(
		.clk(clk),
		.resetn(resetn),
		.op(op),
		.rx_ready(rx_ready),
		.rx_byte(rx_byte),
		.rx_complete(rx_complete),
		.rx_data(rx_data),
		.tx_data(tx_data),
		.tx_ready(tx_ready),
		.tx_byte(tx_byte),
		.tx_start(tx_start),
		.tx_complete(tx_complete),
		.busy(busy)
	);

	async_rx #(.BAUDRATE(BAUDRATE)) RX0
	(
		.clk(clk),
		.rstn(resetn),
		.rx(rx),
		.rcv(rx_ready),
		.data(rx_byte)
	);

	async_tx #(.BAUDRATE(BAUDRATE)) TX0
	(
		.clk(clk),
		.rstn(resetn),
		.start(tx_start),
		.data(tx_byte),
		.tx(tx),
		.ready(tx_ready)
	);

endmodule
