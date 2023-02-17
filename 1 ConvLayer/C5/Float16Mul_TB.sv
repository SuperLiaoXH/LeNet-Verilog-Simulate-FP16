`timescale 1ns/1ps

module Float16Mul_TB ();

	localparam PERIOD = 100;

	reg [15:0] floatA;
	reg [15:0] floatB;
	wire [15:0] product;

	Float16Mul FM
	(
		.floatA(floatA),
		.floatB(floatB),
		.product(product)
	);

	task delay;
		#(PERIOD/2);
	endtask

	initial begin
	
		// 0.005 * 0
		delay;
		floatA = 16'h9d1f;
		floatB = 16'h0000;

		// 4 * 5
		delay;
		floatA = 16'h4400;
		floatB = 16'h4500;

		// 4 * -6
		delay;
		floatA = 16'h4400;
		floatB = 16'hc600;

		// 332 * 105
		delay;
		floatA = 16'h5d30;
		floatB = 16'h5690;

		// 102 * -335
		delay;
		floatA = 16'h5660;
		floatB = 16'hdd3c;

		delay;
		$stop;
		
	end

endmodule
