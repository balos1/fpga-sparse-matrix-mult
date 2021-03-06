/* bram_module: combine  bram unit and bram_control
    input:
      ready: come the control module
      indices: come memory slot
     output:
      indexOut: 1 index
 */

module bram_module
(
  input logic clk, ready, rw, reset,
  input logic [63:0] indices,
  output logic [15:0] indexOut
);

logic [1:0] bramWritePtr;
logic wen;

bramControl dut(clk, ready, rw, reset, bramWritePtr, wen);
bram dut2(clk, rw, wen, bramWritePtr, indices, indicesOut);

endmodule
