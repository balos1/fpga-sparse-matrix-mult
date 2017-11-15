/*
    file: half_precision_add.sv
    author: Cody Balos <cjbalos@gmail.com>
*/


/*
    module: half_precision_add

    A IEEE754-2008 compliant, sequential adder.

    inputs:
        clk - clock signal
        start - indicates that the operation should be started
        A - left operand
        B - right operand
    outputs:
        sum - A + B
        n - indicates negative sum
        v - indicates overflow
        z - indicates sum == 0
*/
module half_precision_add(input logic clk, start
                          input logic [15:0] A, B,
                          output logic [15:0] sum,
                          output logic n, v, z,
                          output logic ready);

    // Breaking adder into 3 different stages
    // Using a Mealy FSM to determine determine stage
    typedef enum logic [3:0]
    {
        IDLE, STAGE1, STAGE2, STAGE3
    } statetype;

    statetype current_state = IDLE;
    statetype next_state = IDLE;

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
                end
            end
            STAGE1: begin
                // STEP 2 & STEP 3
            end
            STAGE2: begin
                // STEP 4 & STEP 5
            end
            STAGE3: begin
                // STEP 6 & STEP 7
                ready = 1;
            end
            default: begin
                ready = 0;
            end
        endcase
    endcase

    // Go to the next state
    always_ff @(posedge clk)
    begin
        current_state <= next_state;
    end

endmodule
