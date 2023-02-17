`timescale 1ns/1ps

module AvgPoolLayer3D_TB();
  
    parameter DATA_WIDTH = 16;
    parameter Depth = 6;
    parameter inputH = 28;
    parameter inputW = 28;
    
    parameter file_image = "./relu1_output.txt";

    localparam PERIOD = 100;

    reg [Depth*inputH*inputW*DATA_WIDTH-1:0] avgpoolIn;
    wire [Depth*(inputH/2)*(inputW/2)*DATA_WIDTH-1:0] avgpoolOut;

    reg [DATA_WIDTH-1:0] memory1[0:Depth*inputH*inputW-1];
    reg [15:0] mem_addr1;

    integer i, out_file;;

    AvgPoolLayer3D
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .Depth(Depth),
        .inputH(inputH),
        .inputW(inputW)
    )
    AP3D
    (
        .avgpoolIn(avgpoolIn),
        .avgpoolOut(avgpoolOut)
    );

	task wait_clk;
		#(PERIOD/2);
	endtask

    always@(*) begin
		for(i=0; i<Depth*inputH*inputW; i=i+1) begin
			avgpoolIn[i*DATA_WIDTH +: DATA_WIDTH] = memory1[i][DATA_WIDTH-1:0];
		end	
    end

    initial begin
        #0
        $readmemh(file_image, memory1);

 		wait_clk;
	    #(Depth*inputH*inputW*PERIOD);

		wait_clk;
		#((560*28+1)*PERIOD);
		out_file = $fopen("./out_file.txt");

		wait_clk;
		for (i=0; i<Depth*(inputH/2)*(inputW/2); i=i+1) begin
			$fdisplay(out_file, "%h", avgpoolOut[i*DATA_WIDTH +: DATA_WIDTH]);
		end 

        #10
        $stop;
    end

endmodule