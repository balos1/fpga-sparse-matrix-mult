/* Independent Parallel Indices Comparison Unit
*/

module PIC (
	input logic clk,
	input logic [15:0] A0, B0,
	input logic write, read, 
	output logic [31:0]fifo_Out
);
	//w_en = write (from external control) & eq (from compare)
	//r_en = read (from fpu)
	logic [31:0]comp_Out;
	logic equal;
	logic [3:0] waddr, raddr;

	compare m1(.clk(clk), .A0(A0), .B0(B0), .eq(equal), .dataOut(comp_Out));
	controlPIC m2(.clk(clk), .w_en(write & equal), .r_en(r_en), .waddr(waddr), .raddr(raddr));
	fifo m3(.clk(clk), .w_en(write & equal), .waddr(waddr), .raddr(raddr), .dataIn(comp_Out), .dataOut(fifo_Out));

endmodule
