/*
    Test bench for communication module.

    author(s): Cody Balos <cjbalos@gmail.com>
*/

`timescale 1ns/1ns

module test_comm_unit();
    parameter clkperiod = 20;

    // Test signals
    logic clk = 1'b0;
    logic reset = 1'b0;
    logic load_data = 1'b0;
    logic Rx = 1'b1;
    logic device2host = 1'b0;
    logic Tx = 1'b1;

    comm dut
    (
        .clk(clk),
        .reset(reset),
        .load_data(load_data),
        .RxD(Rx),
        .device2host(device2host),
        .TxD(Tx),
        .TxD_busy()
    );

    
    // Task which mocks a host sending data to the device.
    // Will send a bit once per clock cycle.
    task host2device(logic [7:0] data);
        // shift out the packet one bit at a time
        // data should go LSB to MSB
        @(posedge clk);
        Rx = 1'b0; // start bit
        repeat (8) begin
            @(posedge clk);
            Rx = data[0];
            data = data >> 1;
        end
        Rx = 1'b1; // stop bit
    endtask

    // task for testing comm unit load functionality
    logic [63:0] host_buffer = 64'b0;
    task test_load_dense(logic [63:0] A, logic [63:0] A0, logic [63:0] B, logic [63:0] B0);
        // 1st the device must be in load mode.
        load_data <= 1'b1;
        // 2nd host will transmit vector A values
        host_buffer = A;
        repeat (8) begin
            host2device(host_buffer[7:0]);
            host_buffer = host_buffer >> 8;
        end
        // 3rd host will transmit vector A indices
        host_buffer = A0;
        repeat (8) begin
            host2device(host_buffer[7:0]);
            host_buffer = host_buffer >> 8;
        end
        // 4th host will transmit vector B values
        host_buffer = B;
        repeat (8) begin
            host2device(host_buffer[7:0]);
            host_buffer = host_buffer >> 8;
        end
        // 5th host will transmit vector B indices
        host_buffer = B0;
        repeat (8) begin
            host2device(host_buffer[7:0]);
            host_buffer = host_buffer >> 8;
        end
        
    endtask

    task test_load();
        // 1st the device must be in load mode.
        load_data <= 1'b1;
        // 2nd host will transmit
        host2device(8'b01010101);
    endtask

    always #(clkperiod/2) clk = ~clk;

    initial begin
        #(2*clkperiod);
        test_load_dense(64'hFFFFFFFFFFFFFFFF, {16'd0, 16'b1, 16'd2, 16'd3}, 64'hEEEEEEEEEEEEEEEE,  {16'd0, 16'b1, 16'd2, 16'd3});
    end

endmodule
