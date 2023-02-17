`timescale 1ns/1ps

module Float16Add_TB ();

	localparam PERIOD = 100;

	reg [15:0] floatA;
	reg [15:0] floatB;
	wire [15:0] sum;

	Float16Add FADD
	(
		.floatA(floatA),
		.floatB(floatB),
		.sum(sum)
	);

	task delay;
		#(PERIOD/2);
	endtask

	initial begin

		// 0.3 + 0
		delay;
		floatA = 16'h34cd;
		floatB = 16'h0000;

		// 0.3 + -0.3
		delay;
		floatA = 16'h34cd;
		floatB = 16'hb4cd;

		// 0.3 + 0.2
		delay;
		floatA = 16'h34cd;
		floatB = 16'h3266;

		// -5.2 + 0.2
		delay;
		floatA = 16'hc533;
		floatB = 16'h3266;

		//5204 + 4400
		delay;
		floatA = 16'h6d15;
		floatB = 16'h6c4c;

		//5204 + -7810
		delay;
		floatA = 16'h6d15;
		floatB = 16'hefa0;

		delay;
		$stop;

	end

endmodule

