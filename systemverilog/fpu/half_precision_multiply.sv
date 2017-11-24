/*
    file: half_precision_multiply.sv
    author: Cody Balos <cjbalos@gmail.com>
*/

`define neg 15
`define exponent 14:10
`defien mantissa 9:0

/*
    module: half_precision_mutliply

    A IEEE754-2008 compliant, .

    inputs:
        clk - clock signal
        start - indicates that the operation should be started
        Ain - left operand
        Bin - right operand
    outputs:
        produce - A * B
        n - indicates negative sum
        v - indicates overflow
        u - indicates underflow
        z - indicates product == 0
        nan - indicates invalid result such as 0 * infty
        ready - indicates that the product is ready
*/
module half_precision_multiply(input logic clk, start
                               input logic [15:0] Ain, Bin,
                               output logic [15:0] product,
                               output logic n, v, u, z, nan,
                               output logic ready);

    // Breaking multiploer into 5 different stages
    // Using a Mealy FSM to determine determine stage
    typedef enum logic [3:0]
    {
        IDLE, STAGE1, STAGE2, STAGE3, STAGE4, STAGE5
    } statetype;

    // Determine the next state based on current state and ready signal
    always_comb
    begin
        case(current_state)
            IDLE: next_state = start ? STAGE1 : IDLE;
            STAGE1: next_state = STAGE2;
            STAGE2: next_state = STAGE3;
            STAGE3: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    logic prodneg;
    logic [4:0] prodexp;
    logic [19:0] prod;

    always_comb
    begin
        case(current_state)
            IDLE: begin
                if (start) begin
                    // STEP 1 - add exponents and subtract 15 (see IEEE 754 exponent bias)
                    prodexp = Ain[`exp] + Bin[`exp] - 15;
                    // STEP 2 - compute sign of product
                    prodneg = Ain[`neg] ^ Bin[`exp];
                end
            end
            STAGE1: begin
                // STEP 3 - multiply the significands
                prod = Ain[`mantissa] * Bin[`mantissa];
            end
            STAGE2: begin
                // STEP 4 - normalize the product
                prod = prod[]
            end
        endcase
    end


    // Go to the next state
    always_ff @(posedge clk)
    begin
        current_state <= next_state;
    end

endmodule