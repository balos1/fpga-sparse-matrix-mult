/*
    file: half_precision_add.sv
    author: Cody Balos <cjbalos@gmail.com>
*/

`define neg 15
`define exponent 14:10
`defien mantissa 9:0

/*
    module: half_precision_add

    A IEEE754-2008 compliant, sequential adder.

    inputs:
        clk - clock signal
        start - indicates that the operation should be started
        Ain - left operand
        Bin - right operand
    outputs:
        sum - A + B
        n - indicates negative sum
        v - indicates overflow
        z - indicates sum == 0
*/
module half_precision_add(input logic clk, start
                          input logic [15:0] Ain, Bin,
                          output logic [15:0] sum,
                          output logic n, v, u, z,
                          output logic ready);

    // Breaking adder into 3 different stages
    // Using a Mealy FSM to determine determine stage
    typedef enum logic [3:0]
    {
        IDLE, STAGE1, STAGE2, STAGE3
    } statetype;

    statetype current_state = IDLE;
    statetype next_state = IDLE;

    logic [15:0] A, B;
    logic Aneg, Bneg, sumneg;
    logic [4:0] Aexp, Bexp, sumexp;
    logic [9:0] Asig, Bsig;
    logic [11:0] sumsig;
    logic [4:0] diff;

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

    // Determine the output of the system in the current state and based on the inputs (Mealy FSM)
    assign ready = current_state == IDLE;
    assign sum = {sumneg, sumexp, sumsig[9:0]};
    assign n = sumneg;
    // STEPS FOR ADDING "A" and "B":
    //   1. If B's exponent > swap A and B
    //   2. Insert 1 in significand if corresponding exponent not zero
    //   3. If necessary, un-normalize B so that A and B's exponent are the same
    //   4. Negate the significand if corresponding sign bit is negative
    //   5. Compute sum of significands
    //   6. Store sign of sum and take absolute value of sum
    //   7. Normalize the sum
    always_comb
    begin
        case(current_state)
            IDLE: begin
                if (start) begin
                    // STEP 1
                    if (Ain[`exponent] < Bin[`exponent]) begin
                        A = Bin; B = Ain;
                    end else begin
                        A = Ain; B = Bin;
                    end
                end
            end
            STAGE1: begin
                // STEP 2 - Insert 1 in significand if corresponding exponent not zero
                Aneg = A[`neg]; Aexp = A[`exponent];
                Bneg = B[`neg]; Bexp = B[`exponent];

                // Put a 0 in bits 11 and 12 (later used for sign and overflow).
                // Put a 1 in bit 10 of significand if exponent is non-zero.
                // Copy mantissa into remaining bits.
                Asig = { 2'b0, Aexp ? 1'b1 : 1'b0, A[`mantissa] };
                Asig = { 2'b0, Bexp ? 1'b1 : 1'b0, B[`mantissa] };

                // STEP 3 - If necessary, un-normalize B so that A and B's exponent are the same
                diff = Aexp - Bexp;
                Bsig = Bsig >> diff;
                // Bexp = Aexp;
            end
            STAGE2: begin
                // STEP 4 - Negate the significand if corresponding sign bit is negative
                Asig = Aneg ? -Asig : Asig;
                Bsig = Bneg ? -Bsig : Bsig;
                // STEP 5 - Compute sum of significands
                sumsig = Asig + Bsig;
            end
            STAGE3: begin
                // STEP 6 - Store sign of sum and take absolute value of sum
                sumneg = sumsig[11];
                sumsig = sumneg ? -sumsig : sumsig;
                // STEP 7 - Normalize the sum (if neccessary)
                if (sumsig[10]) begin
                    // CASE: Overflow
                    sumexp = Aexp + 1;
                    sumsig = sumsig >> 1;
                    u = 0; v = 1; z = 0;
                end else if (sumsig) begin
                    // CASE: Sum is nonzero and did not overflow

                    // Find position of first non-zero digit.
                    int position = 0; int adjust = 0;
                    for (int i = 52; i >= 0; i = i - 1 )
                        if (!position && sumsig[i])
                            position = i;

                    // Shift significand and exponent
                    adjust = 10 - position;
                    if (Aexp < adjust) begin
                        // SUBCASE: Underflow, so set all to zero
                        sumneg = 0; sumexp = 0; sumsig = 0;
                        u = 1; v = 0; z = 1;
                    end else begin
                        sumexp = Aexp - adjust;
                        sumsig = sumsig << adjust;
                        u = 0; v = 1; z = 0;
                    end
                end else begin
                    // CASE: Sum is zero
                    sumexp = 0;
                    sumsig = 0;
                    u = 0; v = 0; z = 1;
                end
            end
            default: begin
                // cover all outputs and intermediates
                sum = 0; n = 0; v = 0; u = 0; z = 0;
                A = 0; B = 0; Aneg = 0; Bneg = 0; Aexp = 0; Bexp = 0; Asig = 0; Bsig = 0;
                sumneg = 0; sumexp = 0; sumsig = 0; diff = 0;
            end
        endcase
    end

    // Go to the next state
    always_ff @(posedge clk)
    begin
        current_state <= next_state;
    end

endmodule
