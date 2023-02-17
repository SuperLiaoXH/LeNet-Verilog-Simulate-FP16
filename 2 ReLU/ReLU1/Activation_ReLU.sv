// ----------------------------------------------------------------------------------
// -- Function : This module is the design of relu activation function
// -- Designer : LXH
// ----------------------------------------------------------------------------------
module Activation_ReLU 
(
	Input_ReLU,
	Output_ReLU
);

    parameter DATA_WIDTH = 16;
	parameter H = 28; //Height of the image
    parameter W = 28; //Width of the image
    parameter input_channel = 6;
    parameter output_channel = 6;

	input [H*W*input_channel*DATA_WIDTH-1:0] Input_ReLU;
	output reg [H*W*output_channel*DATA_WIDTH-1:0] Output_ReLU;

	reg [31:0] i;

	//judge by sign bit
	always @(*) begin
		for(i=0; i<H*W*output_channel; i=i+1) begin
			Output_ReLU[i*DATA_WIDTH +: DATA_WIDTH] = (Input_ReLU[(i+1)*DATA_WIDTH-1]) ? 0 : Input_ReLU[i*DATA_WIDTH +: DATA_WIDTH];
		end
	end

endmodule