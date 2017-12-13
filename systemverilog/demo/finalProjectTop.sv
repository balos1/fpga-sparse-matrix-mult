module finalProjectTop(input logic clk, w, reset,
							  output logic [7:0] outData [8:0]);

logic sync, en;
logic [1:0] count;
logic [7:0] result [8:0];

fallingEdge fallingEdge_module(.clk(clk), .w(w), .z(sync));

controlFSM controlFSM_module(.clk(clk), .w_en(sync), .reset(reset), .count(count), .Z(en));

matrix matrix_module(.clk(clk), .w_en(en), .result(result));

memory memory_module[8:0](.clk(clk), .w_en(en), .count(count), .inData(result), .outData(outData));

endmodule
