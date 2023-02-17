`timescale 1ns/1ps

module ProcessingElement_TB();

	localparam PERIOD = 100;

	reg clk;
	reg reset;
	reg enable;
	reg [15:0] floatA;
	reg [15:0] floatB;
	wire [15:0] result;

	ProcessingElement PE 
	(
		.clk(clk),
		.reset(reset),
		.enable(enable),
		.floatA(floatA),
		.floatB(floatB),
		.result(result)
	);

	task wait_clk;
		@(posedge clk);
		#(PERIOD/2);
	endtask

	always #(PERIOD/2) clk = ~clk;

	initial begin

		clk = 1'b0;
		reset = 1;
		enable = 0;
		// A = 2 , B = 3
		floatA = 16'h4000;
		floatB = 16'h4200;

		wait_clk;
		reset = 0;

		wait_clk;
		// A = 5.6 , B = 3.2
		floatA = 16'h459a;
		floatB = 16'h4266;		

		wait_clk;
		enable = 1;

		wait_clk;
		// A = -8.8 , B = 2.4
		floatA = 16'hc866;
		floatB = 16'h40cd;

		wait_clk;
		$stop;	

	end

endmodule
