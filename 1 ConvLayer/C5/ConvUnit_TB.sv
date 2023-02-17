`timescale 1ns/1ps

module ConvUnit_TB ();

	parameter DATA_WIDTH = 16;
	parameter Depth = 1;//image depth
	parameter Size = 5; // filter size
	localparam PERIOD = 100;

	reg clk;
	reg reset;
	reg [Depth*Size*Size*DATA_WIDTH-1:0] image;
	reg [Depth*Size*Size*DATA_WIDTH-1:0] filter;
	wire done;
	wire [DATA_WIDTH-1:0] result;

	ConvUnit 
    #(
	    .DATA_WIDTH(DATA_WIDTH),
	    .Depth(Depth),
	    .Size(Size)
    )
	CU
    (
	    .clk(clk),
	    .reset(reset),
	    .image(image),
	    .filter(filter),
		.done(done),
	    .result(result)
    );

	always #(PERIOD/2) clk = ~clk;

	task wait_clk;
		@(posedge clk);
		#(PERIOD/2);
	endtask

	initial begin

	    clk = 1'b0;
	    reset = 1;
	    // The expected result is 448(5f00) generated after 25 clock cycles
	    image =  400'h4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4800;
	    filter = 400'h4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4400_4800;
	
	    wait_clk;
	    reset = 0;
	
	    #(27*PERIOD);
		$displayh(result);
		$stop;

	end

endmodule