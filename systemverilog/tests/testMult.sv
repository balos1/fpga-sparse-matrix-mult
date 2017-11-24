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
        parameter testFileName;
        parameter numTests;

        int random_delay = 32'd0;
        int random_test = 32'd0;
        int random_num_tests = 32'd0;

        // DUT signals
        logic clk = 0;
        logic clk_en = 0;
        logic [15:0] dataa = 0;
        logic [15:0] datab = 0;
        logic [15:0] result = 0;
        logic sign = 0;
        logic overflow = 0;
        logic underflow = 0;
        logic zero = 0;
        logic nan = 0;

        // device under test declaration
        mult dutMult
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

        // test vector and unpacked test vector signals
        logic [59:0] testVector[numTests:0];
        logic [3:0] testvec_clk_en;
        logic [15:0] testvec_dataa, testvec_datab, testvec_result;
        logic [7:0] testvec_flags;

        // test variables
        int numPass = 0;

        // tasks for testing
        task verify();
            assert((result[15:0] == testvec_result)) numPass++;
            else begin
                $error("FAIL 0x%h * 0x%h ... wrong result");
            end
            assert(({3'b0, sign, overflow, underflow, zero, nan} == testvec_flags)) numPass++;
            else begin
                $error("FAIL 0x%h * 0x%h ... wrong flags");
            end
        endtask

        // generate a clock
        #(clock_period/2) clk = ~clk;

        // begin tests
        initial
        begin
            // Execute a random number of tests from test vector (up to 4*numTests)
            $readmemh(testFileName, testVector);
            random_num_tests = $urandom() % numTests*4;

            // Assign signals and check result
            for (int i = 0; i < random_num_tests; i++)
            begin
                // select a random test to do
                random_test = $urandom() % (numTests-1);
                // unpack the test
                {testvec_clk_en, testvec_dataa, testvec_datab, testvec_result, testvec_flags} = testVector[random_test];
                // make DUT signal assignments
                clk_en = testvec_clk_en[0];
                dataa = testvec_dataa;
                datab = testvec_datab;
                // wait until result will be ready to verify
                #(clock_period*latency) verify();
                // randomly delay some amount of time
                random_delay = $urandom() % 250;
                #(random_delay);
            end

            #10 $display("Test Bench Complete: %d/%d passed\n", numpass, random_num_tests);
        end

 endmodule
