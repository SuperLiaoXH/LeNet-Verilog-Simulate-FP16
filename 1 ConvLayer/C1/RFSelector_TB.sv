`timescale 1ns/1ps

module RFSelector_TB ();

    parameter DATA_WIDTH = 16;
    parameter Depth = 1; //Depth of the filter
    parameter Size = 5; //Size of the filter
    parameter H = 32; //Height of the image
    parameter W = 32; //Width of the image
	parameter file_input = "./input_1024_1.txt";
	localparam PERIOD = 100;

	reg clk, reset;
    reg [Depth*H*W*DATA_WIDTH-1:0] image;
    reg [5:0] row;
    reg [5:0] column;
    wire [(W-Size+1)*(Depth*Size*Size*DATA_WIDTH)-1:0] receptiveField; //array to hold the matrices (parts of the image) to be sent to the conv units

    reg [DATA_WIDTH:0] memory[0:1023];
    reg [15:0] mem_addr;	

	integer out_file1;
	integer out_file2;
	integer i;

	RFSelector
    #(
	    .DATA_WIDTH(DATA_WIDTH),
	    .Depth(Depth),
	    .Size(Size),
		.H(H),
		.W(W)
    )
	RFS
    (
	    .image(image),		
		.row(row),
		.column(column),
		.receptiveField(receptiveField)
	);

	always #(PERIOD/2) clk = ~clk;

	task wait_clk;
		@(posedge clk);
		#(PERIOD/2);
	endtask

    always@(posedge clk or posedge reset) begin
        if(reset) begin
            image <= 0;
            mem_addr <= 0;
        end
        else begin
			if(mem_addr < 1024) begin
				image[mem_addr*DATA_WIDTH +: DATA_WIDTH] <= memory[mem_addr][DATA_WIDTH:0];
				mem_addr <= mem_addr + 1;
			end
        end
    end

	initial begin

	    clk = 0;
		reset = 1;
		$readmemh(file_input, memory);

	    wait_clk;
	    reset = 0;
	
	    #(1027*PERIOD);

		wait_clk;
		row = 9;
		column = 6;
		out_file1 = $fopen("./out_file1.txt");

		wait_clk;
		#(10*PERIOD);
		for(i=0; i<(W-Size+1)*(Depth*Size*Size); i=i+1) begin
			$fdisplay(out_file1, "%h", receptiveField[i*DATA_WIDTH +: DATA_WIDTH]);
		end

		wait_clk;
		row = 16;
		column = 0;
		out_file2 = $fopen("./out_file2.txt");

		wait_clk;
		#(10*PERIOD);
		for(i=0; i<(W-Size+1)*(Depth*Size*Size); i=i+1) begin
			$fdisplay(out_file2, "%h", receptiveField[i*DATA_WIDTH +: DATA_WIDTH]);
		end

		wait_clk;
		$stop;

	end

endmodule