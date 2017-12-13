/*
    file: fpu.sv
    author: Cody Balos <cjbalos@gmail.com>
*/

`define neg 31
`define exponent 30:23
`define mantissa 22:0

module fpu(input logic clk, clk_en,
           input logic [15:0] dataa, datab,
           output logic [15:0] result,
           output logic sign, overflow, underflow, zero, nan);

//    adder add
//    (
//        .clock(clk),
//        .clk_en(clk_en),
//        .dataa(dataa),
//        .datab(datab),
//        .result(result),
//        .sign(sign),
//        .overflow(overflow),
//        .underflow(underflow),
//        .zero(zero)
//    );
	

    mult xmult
    (
        .clock(clk),
        .clk_en(clk_en),
        .dataa(dataa),
        .datab(datab),
        .result(result),
        .overflow(overflow),
        .underflow(underflow),
        .zero(zero),
        .nan(nan)
    );
	
//    multiplier mult
//    (
//        .clock(clk),
//        .clk_en(clk_en),
//        .dataa(dataa),
//        .datab(datab),
//        .result(multresult),
//        .overflow(overflow),
//        .underflow(underflow),
//        .zero(zero),
//        .nan(nan)
//    );


endmodule
