/*
    file: adder.sv
    author: Cody Balos <cjbalos@gmail.com>
*/

`define neg 15
`define exponent 14:10
`define mantissa 9:0

/*
    module: adder

    A IEEE754-2008 compliant, sequential adder.

    inputs:
        clock - clock signal
        reset - asynchronous active low reset
        clk_en - indicates that the addition should be performed
        dataa - left operand
        datab - right operand
    outputs:
        result - A + B
        overflow - indicates overflow
        underflow - indicates underflow
*/
module adder(input logic clock, reset, clk_en,
             input logic [15:0] dataa, datab,
             output logic [15:0] result,
             output logic overflow, underflow);

    // Breaking adder into 4 different stages
    // Using a Mealy FSM to determine determine stage
    typedef enum logic [1:0]
    {
        IDLE, STAGE1, STAGE2, STAGE3
    } statetype;

    statetype current_state = IDLE;
    statetype next_state = IDLE;

    // Determine the next state based on current state
    always_comb
    begin
        if (!reset) begin
            next_state = IDLE;
        end else begin
            case(current_state)
                IDLE: next_state = clk_en ? STAGE1 : IDLE;
                STAGE1: next_state = STAGE2;
                STAGE2: next_state = STAGE3;
                STAGE3: next_state = IDLE;
                default: next_state = IDLE;
            endcase
        end
    end

    logic [15:0] A, B;
    logic Aneg, Bneg, sumneg;
    logic [4:0] Aexp, Bexp, sumexp;
    logic [12:0] Asig, Bsig;
    logic [12:0] sumsig;
    logic [4:0] diff;

    // Determine the output of the system in the current state and based on the inputs (Mealy FSM)
    assign result = {sumneg, sumexp, sumsig[9:0]};
    assign sign = sumneg;
    // STEPS FOR ADDING "A" and "B":
    //   1. If B's exponent > swap A and B
    //   2. Insert 1 in significand if corresponding exponent not zero
    //   3. If necessary, un-normalize B so that A and B's exponent are the same
    //   4. Negate the significand if corresponding sign bit is negative
    //   5. Compute result of significands
    //   6. Store sign of result and take absolute value of result
    //   7. Normalize the result
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset) begin
            // cover all outputs and intermediates
            overflow <= 0; underflow <= 0;
            A <= 0; B <= 0; Aneg <= 0; Bneg <= 0; Aexp <= 0; Bexp <= 0; Asig <= 0; Bsig <= 0;
            sumneg <= 0; sumexp <= 0; sumsig <= 0; diff <= 0;
        end else begin
            case(current_state)
                IDLE: begin
                    if (clk_en) begin
                        // STEP 1
                        if (dataa[`exponent] < datab[`exponent]) begin
                            A <= datab; B <= dataa;
                        end else begin
                            A <= dataa; B <= datab;
                        end
                    end
                end
                STAGE1: begin
                    // STEP 2 - Insert 1 in significand if corresponding exponent not zero
                    Aneg <= A[`neg]; Aexp <= A[`exponent];
                    Bneg <= B[`neg]; Bexp <= B[`exponent];

                    // Put a 0 in bits 11 and 12 (later used for sign and overflow).
                    // Put a 1 in bit 10 of significand if exponent is non-zero.
                    // Copy mantissa into remdataaing bits.
                    Asig <= { 2'b0, Aexp ? 1'b1 : 1'b0, A[`mantissa] };
                    Asig <= { 2'b0, Bexp ? 1'b1 : 1'b0, B[`mantissa] };

                    // STEP 3 - If necessary, un-normalize B so that A and B's exponent are the same
                    diff <= Aexp - Bexp;
                    Bsig <= Bsig >> diff;
                    // Bexp <= Aexp;
                end
                STAGE2: begin
                    // STEP 4 - Negate the significand if corresponding sign bit is negative
                    Asig <= Aneg ? -Asig : Asig;
                    Bsig <= Bneg ? -Bsig : Bsig;
                    // STEP 5 - Compute result of significands
                    sumsig <= Asig + Bsig;
                end
                STAGE3: begin
                    // STEP 6 - Store sign of result and take absolute value of result
                    sumneg <= sumsig[12];
                    sumsig <= sumneg ? -sumsig : sumsig;
                    // STEP 7 - Normalize the result (if neccessary)
                    if (sumsig[10]) begin
                        // CASE: Overflow
                        sumexp <= Aexp + 1;
                        sumsig <= sumsig >> 1;
                        underflow <= 0; overflow <= 1;
                    end else if (sumsig) begin
                        // CASE: result is nonzero and did not overflow

                        // Find position of first non-zero digit.
                        int position = 0; int adjust = 0;
                        for (int i = 11; i >= 0; i = i - 1 )
                            if (!position && sumsig[i])
                                position <= i;

                        // Shift significand and exponent
                        adjust <= 10 - position;
                        if (Aexp < adjust) begin
                            // SUBCASE: Underflow, so set all to zero
                            sumneg <= 0; sumexp <= 0; sumsig <= 0;
                            underflow <= 1; overflow <= 0;
                        end else begin
                            sumexp <= Aexp - adjust;
                            sumsig <= sumsig << adjust;
                            underflow <= 0; overflow <= 1;
                        end
                    end else begin
                        // CASE: result is zero
                        sumexp <= 0;
                        sumsig <= 0;
                        underflow <= 0; overflow <= 0;
                    end
                end
                default: begin
                    // cover all outputs and intermediates
                    overflow <= 0; underflow <= 0;
                    A <= 0; B <= 0; Aneg <= 0; Bneg <= 0; Aexp <= 0; Bexp <= 0; Asig <= 0; Bsig <= 0;
                    sumneg <= 0; sumexp <= 0; sumsig <= 0; diff <= 0;
                end
            endcase
        end
    end

    // Go to the next state
    always_ff @(posedge clock or negedge reset)
    begin
        if (!reset) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

endmodule
