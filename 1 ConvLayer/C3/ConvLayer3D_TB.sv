`timescale 1ns/1ps

module ConvLayer3D_TB();

	parameter DATA_WIDTH = 16;
	parameter Size = 5; //Size of the filter
	parameter H = 14; //Height of the image
	parameter W = 14; //Width of the image
	parameter input_channel = 6;
	parameter output_channel = 16;

    parameter file_image = "./s2_output.txt";
    parameter file_filter = "./c3.weight.txt";
    parameter file_bias = "./c3.bias.txt";

	localparam PERIOD = 100;

	reg clk, reset;

	reg [input_channel*W*H*DATA_WIDTH-1:0] image;
	reg [output_channel*input_channel*Size*Size*DATA_WIDTH-1:0] filter;
	reg [output_channel*DATA_WIDTH-1:0] bias;
	wire [output_channel*(W-Size+1)*(H-Size+1)*DATA_WIDTH-1:0] outputConv;

    reg [DATA_WIDTH-1:0] memory1[0:input_channel*W*H-1];
    reg [15:0] mem_addr1;
	reg [DATA_WIDTH-1:0] memory2[0:output_channel*input_channel*Size*Size-1];
    reg [15:0] mem_addr2;
    reg [DATA_WIDTH-1:0] memory3[0:output_channel-1];
    reg [15:0] mem_addr3;

	integer i, out_file;
	integer clkCounter;

	ConvLayer3D
	#(
		.DATA_WIDTH(DATA_WIDTH),
		.Size(Size),
		.H(H),	
		.W(W),
		.input_channel(input_channel),
		.output_channel(output_channel)
	)
	C1
	(
		.clk(clk),
		.reset(reset),
		.image(image),
		.filter(filter),
		.bias(bias),
		.outputConv(outputConv)
	);

	always #(PERIOD/2) clk = ~clk;

	task wait_clk;
		@(posedge clk);
		#(PERIOD/2);
	endtask

    always@(*) begin
		for(i=0; i<input_channel*W*H; i=i+1) begin
			image[i*DATA_WIDTH +: DATA_WIDTH] = memory1[i][DATA_WIDTH-1:0];
		end	

		for(i=0; i<output_channel*input_channel*Size*Size; i=i+1) begin
			filter[i*DATA_WIDTH +: DATA_WIDTH] = memory2[i][DATA_WIDTH-1:0];
		end	

		for(i=0; i<output_channel; i=i+1) begin
			bias[i*DATA_WIDTH +: DATA_WIDTH] = memory3[i][DATA_WIDTH-1:0];
		end
    end

	always @ (posedge clk) begin
		clkCounter = clkCounter + 1;
	end

	initial begin
		#0
		clkCounter = 0;
		clk = 1'b0;
		reset = 1;
        $readmemh(file_image, memory1);
        $readmemh(file_filter, memory2);
        $readmemh(file_bias, memory3);

		wait_clk;
		reset = 0;
	    #(input_channel*W*H*PERIOD);

		wait_clk;
		#((560*28+1)*PERIOD);
		out_file = $fopen("./out_file.txt");

		wait_clk;
		for (i=0; i<output_channel*(W-Size+1)*(H-Size+1); i=i+1) begin
			$fdisplay(out_file, "%h", outputConv[i*DATA_WIDTH +: DATA_WIDTH]);
		end 
		$stop;
	end

endmodule
