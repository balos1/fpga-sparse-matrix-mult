/*
    Test bench for communication module.

    author(s): Cody Balos <cjbalos@gmail.com>
*/

`timescale 1ns/1ns

// 50000000/divisor = BAUDRATE

module test_comm_unit();
    parameter clkperiod = 20;  // 50 MHz
    parameter baudperiod = 100; // 10 MHz

    // Test signals
    logic clk = 1'b0;
    logic baudclk = 1'b0;
    logic resetn = 1'b0;
    logic op = 1'b0;
    logic start = 1'b0;
    logic rx = 1'b1;
    logic [(8+2*16*4-1):0] tx_data = {(8+2*16*4-1){1'b0}};
    logic tx = 1'b1;
    logic tx_complete = 1'b0;
    logic rx_complete = 1'b0;
    logic [(8+2*16*4-1):0] rx_data = {(8+2*16*4-1){1'b0}};
    logic busy = 1'b0;

    comm dut
    (
        .clk(clk),
        .resetn(resetn),
        .op(op),
        .start(start),
        .rx(rx),
        .tx_data(tx_data),
        .tx(tx),
        .tx_complete(tx_complete),
        .rx_complete(rx_complete),
        .rx_data(rx_data),
        .busy(busy)
    );


    // Task which mocks a host sending data to the device.
    task host2device(logic [7:0] data);
        // shift out the packet one bit at a time
        // data should go LSB to MSB
        @(posedge baudclk);
        @(posedge baudclk);
        rx = 1'b0; // start bit
        repeat (8) begin
            @(posedge baudclk);
            rx = data[0];
            data = data >> 1;
        end
        @(posedge baudclk);
        rx = 1'b1; // stop bit
    endtask

    logic rx_ready = 1'b0;
    logic [7:0] rx_byte = 8'b0;

    logic startbit, stopbit;
    logic [135:0] tx_buffer = 135'b0;
    task device2host();
        // @(negedge baudclk);
        @(posedge rx_ready);
        tx_buffer = {tx_buffer, rx_byte};
    endtask

	async_rx #(.BAUDRATE(5)) RX
	(
		.clk(clk),
		.rstn(resetn),
		.rx(tx),
		.rcv(rx_ready),
		.data(rx_byte)
	);

    // task for testing comm unit load functionality
    // size_of_A is the size (in bytes) of row values + row indices in matrix A
    // size_of_B is the size (in bytes) of col values + col indices in matrix B
    logic [63:0] host_buffer = 64'b0;
    task test_load(logic [7:0] size_of_A [3:0], logic [63:0] A [3:0], logic [63:0] A0 [3:0],
                   logic [7:0] size_of_B [3:0], logic [63:0] B [3:0], logic [63:0] B0 [3:0]);

        op = 0;

        for (int i = 0; i < 4; ++i) begin
            while (busy) #1;
            // 1st host will transmit size of row
            host2device(size_of_A[i]);
            // 2nd host will transmit vector A values
            host_buffer = A[i];
            repeat (size_of_A[i]) begin
                host2device(host_buffer[63:56]);
                host_buffer = host_buffer << 8;
            end
            // 3rd host will transmit vector A indices
            host_buffer = A0[i];
            repeat (size_of_A[i]) begin
                host2device(host_buffer[63:56]);
                host_buffer = host_buffer << 8;
            end
        end

        // 1st host will transmit size of B
        while (busy) #1;

        for (int i = 0; i < 4; ++i) begin
            while (busy) #1;
            // 4th host will transmit size of col
            host2device(size_of_B[i]);
            // 5th host will transmit vector B values
            host_buffer = B[i];
            repeat (size_of_B[i]) begin
                host2device(host_buffer[63:56]);
                host_buffer = host_buffer << 8;
            end
            // 6th host will transmit vector B indices
            host_buffer = B0[i];
            repeat (size_of_B[i]) begin
                host2device(host_buffer[63:56]);
                host_buffer = host_buffer << 8;
            end
        end
    endtask

    // task for testing comm unit send functionality
    logic [63:0] device_buffer = 64'b0;
    task test_send(logic [7:0] size_of_A [3:0], logic [63:0] A [3:0], logic [63:0] A0 [3:0],
                   logic [7:0] size_of_B [3:0], logic [63:0] B [3:0], logic [63:0] B0 [3:0]);


        for (int i = 0; i < 4; ++i) begin
            while (busy) #1;
            tx_data = {size_of_A[i], A[i], A0[i]};
            op = 1'b1;
            while (!tx_complete) begin
                #1 device2host();
            end
        end

        while (busy) #1;

        for (int i = 0; i < 4; ++i) begin
            while (busy) #1;
            tx_data = {size_of_A[i], A[i], A0[i]};
            op = 1'b1;
            while (!tx_complete)
                #1 device2host();
        end
    endtask

    always #(clkperiod/2) clk = ~clk;
    always #(baudperiod/2) baudclk = ~baudclk;

    initial begin
        resetn <= 0;
        #(2*clkperiod);
        resetn <= 1;

        // // 1st the device must be in load mode.
        // op <= 1'b0;
        // // 2nd host will transmit
        // host2device(8'h74);
        // host2device(8'hFB);

        // test_load
        // (
        //     {4, 4, 4, 4},
        //     {{32'h74FB7BFE, 32'h0},  // 20400.0, 65472.0
        //      {32'h74FB7BFE, 32'h0},  // 20400.0, 65472.0
        //      {32'h74FB7BFE, 32'h0},  // 20400.0, 65472.0
        //      {32'h74FB7BFE, 32'h0}}, // 20400.0, 65472.0
        //     {{16'd0, 16'd3, 32'h0},
        //      {16'd0, 16'd3, 32'h0},
        //      {16'd0, 16'd3, 32'h0},
        //      {16'd0, 16'd3, 32'h0}},
        //     {4, 4, 4, 4},
        //     {{16'hE850, 48'h0},     // -2208.0
        //      {16'hE850, 48'h0},     // -2208.0
        //      {16'hE850, 48'h0},     // -2208.0
        //      {16'hE850, 48'h0}},    // -2208.0
        //     {{16'b1, 48'h0},
        //      {16'b1, 48'h0},
        //      {16'b1, 48'h0},
        //      {16'b1, 48'h0}}
        // );

        // test_load
        // (
        //     {8, 8, 8, 8},
        //     {{64'h74FB7BFE978F83D7},
        //      {64'h74FB7BFE978F83D7},
        //      {64'h74FB7BFE978F83D7},
        //      {64'h74FB7BFE978F83D7}},
        //     {{16'd0, 16'd1, 16'd2, 16'h3},
        //      {16'd0, 16'd1, 16'd2, 16'h3},
        //      {16'd0, 16'd1, 16'd2, 16'h3},
        //      {16'd0, 16'd1, 16'd2, 16'h3}},
        //     {4, 4, 4, 4},
        //     {{16'hE850, 48'h0},
        //      {16'hE850, 48'h0},
        //      {16'hE850, 48'h0},
        //      {16'hE850, 48'h0}},
        //     {{16'b1, 48'h0},
        //      {16'b1, 48'h0},
        //      {16'b1, 48'h0},
        //      {16'b1, 48'h0}}
        // );


        test_send
        (
            {4, 4, 4, 4},
            {{32'h74FB7BFE, 32'h0},  // 20400.0, 65472.0
             {32'h74FB7BFE, 32'h0},  // 20400.0, 65472.0
             {32'h74FB7BFE, 32'h0},  // 20400.0, 65472.0
             {32'h74FB7BFE, 32'h0}}, // 20400.0, 65472.0
            {{16'd0, 16'd3, 32'h0},
             {16'd0, 16'd3, 32'h0},
             {16'd0, 16'd3, 32'h0},
             {16'd0, 16'd3, 32'h0}},
            {4, 4, 4, 4},
            {{16'hE850, 48'h0},     // -2208.0
             {16'hE850, 48'h0},     // -2208.0
             {16'hE850, 48'h0},     // -2208.0
             {16'hE850, 48'h0}},    // -2208.0
            {{16'b1, 48'h0},
             {16'b1, 48'h0},
             {16'b1, 48'h0},
             {16'b1, 48'h0}}
        );
    end

endmodule
