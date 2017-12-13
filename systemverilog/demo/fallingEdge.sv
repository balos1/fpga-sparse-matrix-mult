module fallingEdge(input logic clk, w,
                   output logic z);

logic FF1, FF2, FF3;       
always_ff @(posedge clk)
  begin
    FF1 <= w;
    FF2 <= FF1;
    FF3 <= FF2;
  end
  
assign z = ~FF2 & FF3;
endmodule
