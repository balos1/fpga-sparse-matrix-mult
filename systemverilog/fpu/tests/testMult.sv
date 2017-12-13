/*
    file: testMult.sv
    author: Cody Balos <cjbalos@gmail.com>
*/


`timescale 1ns/1ns

/*
        module: testMult

        Verification test bench for half-precision multiplier.
*/
module testMult();
    	// Define parameters when calling from do file
        parameter clock_period = 50;
        parameter latency = 8;
        parameter numTests = 512;
        parameter testFileName;

        int random_delay = 32'd0;
        int random_test = 32'd0;

        // DUT signals
        logic clk = 0;
        logic reset = 1;
        logic clk_en = 0;
        logic [15:0] dataa = 0;
        logic [15:0] datab = 0;
        logic [15:0] result = 0;
        logic [7:0] flags = 0;
        logic overflow = 0;
        logic underflow = 0;
        logic nan = 0;

        // device under test declaration
        mult dut
        (
            .clock(clk),
            .reset(reset),
            .clk_en(clk_en),
            .dataa(dataa),
            .datab(datab),
            .result(result),
            .overflow(overflow),
            .underflow(underflow),
            .nan(nan)
        );

        // test vector and unpacked test vector signals
        logic [59:0] testVector[numTests:0];
        logic [3:0] testvec_clk_en;
        logic [15:0] testvec_dataa, testvec_datab, testvec_result;
        logic [7:0] testvec_flags;

        // test variables
        int numPass = 0;

        // tasks for testing
        task verify();
            flags = {3'b0, nan, testvec_flags[3], overflow, underflow, testvec_flags[0]};
            if ((result[15:0] != testvec_result) || (flags != testvec_flags)) begin
                $display("FAIL 0x%h * 0x%h", testvec_dataa, testvec_datab);
                $display("\texpected: result = %h, NaN = %b, overflow = %b, underflow = %b",
                    testvec_result, testvec_flags[4], testvec_flags[2], testvec_flags[1]);
                $display("\t but got: result = %h, NaN = %b, overflow = %b, underflow = %b",
                    result, nan, overflow, underflow);
            end else begin
                numPass++;
            end
        endtask

        // generate a clock
        always #(clock_period/2) clk = ~clk;

        // begin tests
        initial
        begin
            $readmemh(testFileName, testVector);

            reset <= 0;
            #(clock_period) reset <= 1;

            // assign signals and check result
            for (int i = 0; i < numTests; i++)
            begin
                // select a random test to do
                random_test = $urandom() % (numTests-1);
                // unpack the test
                {testvec_clk_en, testvec_dataa, testvec_datab, testvec_result, testvec_flags} = testVector[random_test];
                // make DUT signal assignments
                clk_en = testvec_clk_en;
                dataa = testvec_dataa;
                datab = testvec_datab;
                // wait until result will be ready to verify
                #(clock_period*latency) verify();
                // randomly delay some amount of time but at least 1/2 clock period
                random_delay = $urandom() % (4*clock_period);
                #(clock_period/2 + random_delay);
            end

            #10 $display("Test Bench Complete: %0d out of %0d passed\n", numPass, numTests);
        end

 endmodule
