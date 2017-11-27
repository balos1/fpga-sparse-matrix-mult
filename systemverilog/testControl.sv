// Code your testbench here
// or browse Examples
`timescale 1ns/1ns
module testControl();

  logic clk = 1'b0;
  logic reset, wen, dataReady, ready;
  logic [7:0] inByte;
  logic [15:0] writePtr, readPtr;
  logic [7:0] outData;
  
  integer count = 1;
  control dut(clk, reset, wen, dataReady, inByte, ready, writePtr, readPtr, outData);
  

  
  always	#50 clk = ~clk;
  initial begin
    #10 reset <= 0;
    wen <= 1;
    test();
  end
  
  task test();
    
    for(int i = 0; i < 100; i++) begin
      @(negedge clk) begin
      count <= count + 1;
  end
    if (count % 8 == 0) begin
      dataReady = 1;
      inByte = count;
    end
  else if(count==10)  begin
      dataReady = 1;
      inByte = 0;
    end
  else  dataReady = 0;
  
  end
  endtask

  
endmodule
