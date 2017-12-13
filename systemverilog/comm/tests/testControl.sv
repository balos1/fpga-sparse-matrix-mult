`timescale 1ns/1ns

module testControl();
    logic clk = 1'b0;
    logic reset, load_data, rx_ready, ready_for_mem;
    logic [7:0] rx_byte;
    logic [15:0] writePtr, readPtr;
    logic [7:0] wdata;

    integer count = 1;
    control dut(clk, reset, load_data, rx_ready, rx_byte, ready_for_mem, writePtr, readPtr, wdata);
    
    always #50 clk = ~clk;

    initial begin
        #10 reset <= 0;
        load_data <= 1;
        test();
    end
    
    task test();
        for(int i = 0; i < 100; i++) begin
            @(negedge clk) begin
                count <= count + 1;
            end
            if (count % 8 == 0) begin
                rx_ready = 1;
                rx_byte = count;
            end
            else if(count==10)  begin
                rx_ready = 1;
                rx_byte = 0;
            end
            else begin
                rx_ready = 0;
            end
        end
    endtask

endmodule
