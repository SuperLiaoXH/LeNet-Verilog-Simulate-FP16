// ----------------------------------------------------------------------------------
// -- Function : This module completes one window convolution calculation
// -- Designer : LXH
// ----------------------------------------------------------------------------------
module ConvUnit(
    clk,
    reset,
    image,
    filter,
    done,
    result
);

    parameter DATA_WIDTH = 16;
    parameter Depth = 1;// image depth
    parameter Size = 5; // filter size

    input clk;
    input reset;
    input [Depth*Size*Size*DATA_WIDTH-1:0] filter;
    input [Depth*Size*Size*DATA_WIDTH-1:0] image;
    output reg done;
    output reg [DATA_WIDTH-1:0] result;

    reg enable;
    reg [DATA_WIDTH-1:0] SelectedInput1;
    reg [DATA_WIDTH-1:0] SelectedInput2;
    reg [15:0] i;

    ProcessingElement PE
	(
		.clk(clk),
		.reset(reset),
        .enable(enable),
		.floatA(SelectedInput1),
		.floatB(SelectedInput2),
		.result(result)
	);

    // The convolution is calculated in a sequential process to save hardware
    // The result of the element wise matrix multiplication is finished after (F*F+2) cycles (2 cycles to reset the processing element and F*F cycles to accumulate the result of the F*F multiplications) 
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            i <= 0;
            enable <= 0;
            done <= 0;
            SelectedInput1 <= 0;
            SelectedInput2 <= 0;
        end
        // if the convolution is finished but we still wait for other blocks to finsih, send zeros to the conv unit (in case of pipelining)
        else if (i > Depth*Size*Size-1) begin
            done <= 1;
            SelectedInput1 <= 0;
            SelectedInput2 <= 0;
        end
        // send one element of the image part and one element of the filter to be multiplied and accumulated
        else begin
            i <= i + 1;   
            enable <= 1;        
            SelectedInput1 <= image[DATA_WIDTH*i +: DATA_WIDTH];
            SelectedInput2 <= filter[DATA_WIDTH*i +: DATA_WIDTH]; 
        end
    end

endmodule