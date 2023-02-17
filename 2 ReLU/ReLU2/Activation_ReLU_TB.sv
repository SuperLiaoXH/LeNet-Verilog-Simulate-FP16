`timescale 1ns/1ps

module Activation_ReLU_TB();

    parameter DATA_WIDTH = 16;
	parameter H = 10; //Height of the image
    parameter W = 10; //Width of the image
    parameter input_channel = 16;
    parameter output_channel = 16;

	parameter file_image = "./c3_output.txt";	

	localparam PERIOD = 100;

	reg [H*W*input_channel*DATA_WIDTH-1:0] Input_ReLU;
	wire [H*W*output_channel*DATA_WIDTH-1:0] Output_ReLU;

    reg [DATA_WIDTH-1:0] memory1[0:input_channel*W*H-1];
    reg [15:0] mem_addr1;

	integer i, out_file;

	Activation_ReLU
	#(
		.DATA_WIDTH(DATA_WIDTH),
		.H(H),
		.W(W),
		.input_channel(input_channel),
		.output_channel(output_channel)
	)
	AR1
	(
		.Input_ReLU(Input_ReLU),
		.Output_ReLU(Output_ReLU)
	);

	task wait_clk;
		#(PERIOD/2);
	endtask

    always@(*) begin
		for(i=0; i<input_channel*W*H; i=i+1) begin
			Input_ReLU[i*DATA_WIDTH +: DATA_WIDTH] = memory1[i][DATA_WIDTH-1:0];
		end	
    end

	initial begin
		#0
        $readmemh(file_image, memory1);

		wait_clk;
	    #(input_channel*W*H*PERIOD);

		wait_clk;
		#((560*28+1)*PERIOD);
		out_file = $fopen("./out_file.txt");

		wait_clk;
		for (i=0; i<output_channel*W*H; i=i+1) begin
			$fdisplay(out_file, "%h", Output_ReLU[i*DATA_WIDTH +: DATA_WIDTH]);
		end 
		$stop;
	end

endmodule