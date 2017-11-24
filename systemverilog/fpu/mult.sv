/*
    file: mult.sv
    author: Cody Balos <cjbalos@gmail.com>
*/

`define sign 15
`define exponent 14:10
`define mantissa 9:0

/*
    module: multiplier

    A IEEE754-2008 compliant, 8-stage multiplier.

    inputs:
        clock - clock signal
        clk_en - indicates that the addition should be performed
        dataa - left operand
        datab - right operand
    outputs:
        result - A + B
        sign - indicates negative result
        overflow - indicates overflow
        underflow - indicates underflow
        zero - indicates result == 0
*/
module mult(input logic clock, clk_en,
            input logic [15:0] dataa, datab,
            output logic [15:0] result,
            output logic sign, overflow, underflow, zero, nan);

    // Breaking adder into 7/8 different stages
    // Using a Mealy FSM to determine determine stage
    typedef enum logic [3:0]
    {
        IDLE, STAGE0, STAGE1, STAGE2, STAGE3, STAGE4, STAGE5, STAGE6
    } statetype;

    statetype current_state = IDLE;
    statetype next_state = IDLE;

    // Determine the next state based on current state
    always_comb
    begin
        case(current_state)
            IDLE: next_state = clk_en ? STAGE0 : IDLE;
            STAGE0: next_state = STAGE1;
            STAGE1: next_state = STAGE2;
            STAGE2: next_state = STAGE3;
            STAGE3: next_state = STAGE4;
            STAGE4: next_state = STAGE5;
            STAGE5: next_state = STAGE6;
            STAGE6: next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    logic a_sin, b_sin, result_sin;
    logic [6:0] a_exp, b_exp, result_exp;
    logic [10:0] a_man, b_man, result_man;
    logic [21:0] man_product;
    logic guard, sticky, round;

    // Determine outputs
    always_ff @(posedge clock)
    begin
        case(current_state)
            IDLE: begin
                if (clk_en) begin
                    // Unpack operands
                    a_sin <= dataa[`sign]; b_sin <= datab[`sign];
                    a_exp <= dataa[`exponent]; b_exp <= datab[`exponent];
                    a_man <= dataa[`mantissa]; b_man <= datab[`mantissa];
                end
            end
            STAGE0: begin
                // STEP 0. denormalize
                if ($signed(a_exp) == -15) begin
                    a_exp <= -14;
                end else begin
                    a_man[10] <= 1;
                end
                if ($signed(b_exp) == -15) begin
                    b_exp <= -14;
                end else begin
                    b_man[10] <= 1;
                end
            end
            STAGE1: begin
                // STEP 1. normalize A and B
                if (a_man[10] == 0) begin
                    a_man <= a_man << 1;
                    a_exp <= a_exp - 1;
                end
                if (b_man[10] == 0) begin
                    b_man <= b_man << 1;
                    b_exp <= b_exp - 1;
                end
            end
            STAGE2: begin
                // STEP 2. calculate sign of result
                result_sin <= a_sin^b_sin;
                // STEP 3. multiply mantissas
                man_product <= a_man*b_man;
                // STEP 4. calculate tentative exponent
                result_exp <= a_exp + b_exp - 15;
            end
            STAGE3: begin
                // STEP 5. calculate guard, round, sticky
                result_man <= man_product[21:12];
                guard <= man_product[11];
                round <= man_product[10];
                sticky <= man_product[9:0] != 0;
            end
            STAGE4: begin
                // STEP 6. normalize result
                if (result_man[10] == 0) begin
                    result_man <= result_man << 1;
                    result_exp <= result_exp - 1;
                    result_man[0] <= guard;
                    guard <= round;
                    round <= 0;
                end else if ($signed(result_exp) < -14) begin
                    result_man <= result_man >> 1;
                    result_exp <= result_exp + 1;
                    guard <= result_man[0];
                    round <= guard;
                    sticky <= sticky | round;
                end
            end
            STAGE5: begin
                // STEP 7. round
                if (guard && (round | sticky | result_man)) begin
                    result_man <= result_man + 1;
                    if (result_man == 10'hfff) begin
                        result_exp <= result_exp + 1;
                    end
                end
            end
            STAGE6: begin
                // STEP 8. Determine final output
                if ((a_exp == 15 && a_man != 0) || (b_exp && b_man != 0)) begin
                    // case where one or both inputs are NaN
                    nan <= 1;
                    result <= {1'b1, 5'd32, 10'h200};
                end else if (a_exp == 16) begin
                    // case when A is infty
                    if ($signed(b_exp == -15) && (b_man == 0)) begin
                        // B is zero --> 0*infty = NaN
                        nan <= 1;
                        result <= {1'b1, 5'd32, 10'h200};
                    end else begin
                        // B is not zero --> N*infty = infty
                        result <= {result_sin, 5'd32, 10'd0};
                    end
                end else if (b_exp == 16) begin
                    // case when B is infty
                    if ($signed(a_exp == -15) && (a_man == 0)) begin
                        // A is zero --> infty*0 = NaN
                        nan <= 1;
                        result <= {1'b1, 5'd32, 10'h200};
                    end else begin
                        // A is not zero --> N*infty = infty
                        result <= {result_sin, 5'd32, 10'd0};
                    end
                end else if (($signed(a_exp) == -15) && (a_man == 0)) begin
                    // case when A iz zero
                    result <= {result_sin, 5'd0, 10'd0};
                end else if (($signed(b_exp) == -15) && (b_man == 0)) begin
                    // case when B iz zero
                    result <= {result_sin, 5'd0, 10'd0};
                end else if ($signed(result_exp) < -14) begin
                    // in case of underflow, return 0
                    underflow <= 1;
                    result <= {result_sin, 5'd0, 10'd0};
                end else if ($signed(result_exp) > 15) begin
                    // in case of overflow, return infty
                    overflow <= 1;
                    result <= {result_sin, 5'd32, 10'd0};
                end else begin
                    result <= {result_sin, result_exp[4:0] + 15, result_man[9:0]};
                    // handle case where exponent in result is the minimum
                    if ($signed(result_exp) == -14 && result_man[10] == 0) begin
                        result[`exponent] <= 0;
                    end
                end
            end
            default: begin
                // cover all outputs and intermediates
            end
        endcase
    end

    // zero flag is much easier to determine combinationally
	 assign sign = result[`sign];
    assign zero = (result[`exponent] == 0) && (result[`mantissa] == 0);

    // Go to the next state
    always_ff @(posedge clock)
    begin
        current_state <= next_state;
    end

endmodule
