// 50000000/divisor = BAUDRATE
`define B115200 434

/*
    module: async_tx
    references: https://github.com/FPGAwars/FPGA-peripherals
*/
module async_tx #(
    parameter BAUDRATE = `B115200  //-- Default baudrate
)(
    input logic clk,
    input logic rstn,
    input logic start,
    input logic [7:0] data,
    output logic tx,
    output logic ready
);

//-- Transmission clock
logic clk_baud;

//-- Bitcounter
logic [3:0] bitc;

//-- Registered data
logic [7:0] data_r;

typedef enum logic [1:0] {IDLE, START, TRANS } State;

State current_state;
State next_state;

//--------- control signals
logic load;    //-- Load the shifter register / reset
logic baud_en; //-- Enable the baud generator

//--------- DATAPATH

//-- Register the input data
always @(posedge clk) begin
    if (start == 1 && current_state == IDLE)
        data_r <= data;
end

//-- 1 bit start + 8 bits datos + 1 bit stop
//-- Shifter register. It stored the frame to transmit:
//-- 1 start bit + 8 data bits + 1 stop bit
logic [9:0] shifter;

//-- When the control signal load is 1, the frame is loaded
//-- when load = 0, the frame is shifted right to send 1 bit,
//--   at the baudrate determined by clk_baud
//--  1s are introduced by the left
always_ff @(posedge clk) begin
    //-- Reset
    if (rstn == 0)
        shifter <= 10'b1111111111;
    //-- Load mode
    else if (load == 1)
        shifter <= {data_r, 2'b01};
    //-- Shift mode
    else if (load == 0 && clk_baud == 1)
        shifter <= {1'b1, shifter[9:1]};
end

//-- Sent bit counter
//-- When load (=1) the counter is reset
//-- When load = 0, the sent bits are counted (with the raising edge of clk_baud)
always_ff @(posedge clk) begin
  if (!rstn)
    bitc <= 0;

  else if (load == 1)
    bitc <= 0;
  else if (load == 0 && clk_baud == 1)
    bitc <= bitc + 1;
end

//-- The less significant bit is transmited through tx
//-- It is a registed output, because tx is connected to an Asynchronous bus
//--  and the glitches should be avoided
always_ff @(posedge clk) tx <= shifter[0];

//-- Baud generator
baudtick_tx #( .BAUDRATE(BAUDRATE)) BAUD0
(
    .rstn(rstn),
    .clk(clk),
    .clk_ena(baud_en),
    .clk_out(clk_baud)
);

//-- CONTROLLER

//-- Transition between states
always_ff @(posedge clk) begin
  if (!rstn)
    current_state <= IDLE;
  else
    current_state <= next_state;
end

//-- Control signal generation and next states
always @(*) begin
  next_state = current_state;
  load = 0;
  baud_en = 0;

  case (current_state)
    //-- Remain in this current_state until start is 1
    IDLE: begin
        ready = 1;
        if (start == 1)
            next_state = START;
    end
    //-- 1 cycle long
    //-- turn on the baudrate generator and the load the shift register
    START: begin
        load = 1;
        baud_en = 1;
        ready = 0;
        next_state = TRANS;
    end
    //-- Stay here until all the bits have been sent
    TRANS: begin
        baud_en = 1;
        ready = 0;
        if (bitc == 11)
            next_state = IDLE;
    end
    default: ready = 0;
  endcase
end

endmodule
