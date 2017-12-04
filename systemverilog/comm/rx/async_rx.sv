// 50000000/divisor = BAUDRATE
`define B10000000 5
`define B115200 434

/*
    module: async_rx
    references: https://github.com/FPGAwars/FPGA-peripherals
*/
module async_rx #(
  parameter BAUDRATE = `B115200
)(
  input logic clk,
  input logic rstn,
  input logic rx,
  output logic rcv,
  output logic [7:0] data
);

//-- Transmission clock
logic clk_baud;

//-- Control signals
logic bauden;  //-- Enable the baud generator
logic clear;   //-- Clear the bit counter
logic load;    //-- Load the received character into the data register


//-- Sync rx with clk
logic rx_r;
always @(posedge clk) rx_r <= rx;

//-- Baud generator
baudtick_rx #(BAUDRATE) baudgen0
(
    .rstn(rstn),
    .clk(clk),
    .clk_ena(bauden),
    .clk_out(clk_baud)
);

//-- Bit counter
logic [3:0] bitc;

always_ff @(posedge clk) begin
    if (clear)
        bitc <= 4'd0;
    else if (clear == 0 && clk_baud == 1)
        bitc <= bitc + 1;
end

//-- Shift register for storing the received bits
logic [9:0] raw_data;
always_ff @(posedge clk) begin
  if (clk_baud == 1)
    raw_data <= {rx_r, raw_data[9:1]};
end

//-- Data register. Store the character received
always_ff @(posedge clk) begin
  if (rstn == 0)
    data <= 0;
  else if (load)
    data <= raw_data[8:1];
end

// Control FSM
typedef enum logic [1:0] {IDLE, RECV, LOAD, DAV } State;

State current_state;
State next_state;

always_ff @(posedge clk) begin
    if (!rstn)
    current_state <= IDLE;
    else
    current_state <= next_state;
end

//-- Control signal generation and next states
always_ff @(*) begin
    next_state = current_state;
    bauden = 0;
    clear = 0;
    load = 0;

    case(current_state)
        //-- Remain in this current_state until a start bit is received in rx_r
        IDLE: begin
            clear = 1;
            rcv = 0;
            if (rx_r == 0)
            next_state = RECV;
        end
        //-- Turn on the baud generator and wait for the serial package to be received
        RECV: begin
            bauden = 1;
            rcv = 0;
            if (bitc == 4'd10)
            next_state = LOAD;
        end
        //-- Store the received character in the data register (1 cycle)
        LOAD: begin
            load = 1;
            rcv = 0;
            next_state = DAV;
        end
        //-- Data Available (1 cycle)
        DAV: begin
            rcv = 1;
            next_state = IDLE;
        end
        default:
            rcv = 0;
    endcase
end

endmodule
