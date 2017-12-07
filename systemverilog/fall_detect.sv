/*
    Cody Balos
	EPCE 174 - Advanced Digital Design
	Fall 2017
	University of the Pacific
*/


/*
    Module: fall_detect

    Falling Edge Detector

    Parameters:
        clk - clock singal
        d - the asynchronous singal
        q - the falling edge indicator signal
*/
module fall_detect(input logic clk, d,
                        output logic q);


    logic ff0 = 1'b1;

    always_ff @(posedge clk)
    begin
        ff0 <= d;
    end

    assign q = ~d & ff0;

endmodule