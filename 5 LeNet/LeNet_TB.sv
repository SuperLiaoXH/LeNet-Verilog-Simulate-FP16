`timescale 1ns/1ps

module LeNet_TB();

	parameter DATA_WIDTH = 16;
	parameter Size_Conv = 5;
    parameter Size_FC = 1;
    //C1
	parameter H_C1 = 32;
	parameter W_C1 = 32;
	parameter input_channel_C1 = 1;
	parameter output_channel_C1 = 6;
    //R1
    parameter H_R1 = 28;
	parameter W_R1 = 28;
	parameter input_channel_R1 = 6;
	parameter output_channel_R1 = 6;
    //S2
    parameter H_S2 = 28;
	parameter W_S2 = 28;
	parameter Depth_S2 = 6;
    //C3
	parameter H_C3 = 14;
	parameter W_C3 = 14;
	parameter input_channel_C3 = 6;
	parameter output_channel_C3 = 16;
    //R2
    parameter H_R2 = 10;
	parameter W_R2 = 10;
	parameter input_channel_R2 = 16;
	parameter output_channel_R2 = 16;
    //S4
    parameter H_S4 = 10;
	parameter W_S4 = 10;
	parameter Depth_S4 = 16;
    //C5
	parameter H_C5 = 5;
	parameter W_C5 = 5;
	parameter input_channel_C5 = 16;
	parameter output_channel_C5 = 120;
    //F6
	parameter H_F6 = 1;
	parameter W_F6 = 1;
	parameter input_channel_F6 = 120;
	parameter output_channel_F6 = 84;
    //F7
	parameter H_F7 = 1;
	parameter W_F7 = 1;
	parameter input_channel_F7 = 84;
	parameter output_channel_F7 = 10;

    parameter file_image = "./input_1024_1.txt";
    parameter file_filter_C1 = "./c1.weight.txt";
    parameter file_bias_C1 = "./c1.bias.txt";
    parameter file_filter_C3 = "./c3.weight.txt";
    parameter file_bias_C3 = "./c3.bias.txt";
    parameter file_filter_C5 = "./c5.weight.txt";
    parameter file_bias_C5 = "./c5.bias.txt";
    parameter file_filter_F6 = "./f6.weight.txt";
    parameter file_bias_F6 = "./f6.bias.txt";
    parameter file_filter_F7 = "./output.weight.txt";
    parameter file_bias_F7 = "./output.bias.txt";

	localparam PERIOD = 100;

	reg clk, reset_C1, reset_C3, reset_C5, reset_F6, reset_F7;

	reg [input_channel_C1*W_C1*H_C1*DATA_WIDTH-1:0] image;
    //C1
	reg [output_channel_C1*input_channel_C1*Size_Conv*Size_Conv*DATA_WIDTH-1:0] filter_C1;
	reg [output_channel_C1*DATA_WIDTH-1:0] bias_C1;
	wire [output_channel_C1*(W_C1-Size_Conv+1)*(H_C1-Size_Conv+1)*DATA_WIDTH-1:0] outputConv_C1;
    //R1
    wire [output_channel_R1*W_R1*H_R1*DATA_WIDTH-1:0] outputRelu_R1;
    //S2
    wire [Depth_S2*(W_S2/2)*(H_S2/2)*DATA_WIDTH-1:0] outputPool_S2;
    //C3
	reg [output_channel_C3*input_channel_C3*Size_Conv*Size_Conv*DATA_WIDTH-1:0] filter_C3;
	reg [output_channel_C3*DATA_WIDTH-1:0] bias_C3;
	wire [output_channel_C3*(W_C3-Size_Conv+1)*(H_C3-Size_Conv+1)*DATA_WIDTH-1:0] outputConv_C3;
    //R2
    wire [output_channel_R2*W_R2*H_R2*DATA_WIDTH-1:0] outputRelu_R2;
    //S4
    wire [Depth_S4*(W_S4/2)*(H_S4/2)*DATA_WIDTH-1:0] outputPool_S4;
    //C5
	reg [output_channel_C5*input_channel_C5*Size_Conv*Size_Conv*DATA_WIDTH-1:0] filter_C5;
	reg [output_channel_C5*DATA_WIDTH-1:0] bias_C5;
	wire [output_channel_C5*(W_C5-Size_Conv+1)*(H_C5-Size_Conv+1)*DATA_WIDTH-1:0] outputConv_C5;
    //F6
    reg [output_channel_F6*input_channel_F6*Size_FC*Size_FC*DATA_WIDTH-1:0] filter_F6;
    reg [output_channel_F6*DATA_WIDTH-1:0] bias_F6;
    wire [output_channel_F6*(W_F6-Size_FC+1)*(H_F6-Size_FC+1)*DATA_WIDTH-1:0] outputConv_F6;
    //F7
    reg [output_channel_F7*input_channel_F7*Size_FC*Size_FC*DATA_WIDTH-1:0] filter_F7;
    reg [output_channel_F7*DATA_WIDTH-1:0] bias_F7;
    wire [output_channel_F7*(W_F7-Size_FC+1)*(H_F7-Size_FC+1)*DATA_WIDTH-1:0] outputConv_F7;

    reg [DATA_WIDTH-1:0] memory1_C1[0:input_channel_C1*W_C1*H_C1-1];
	reg [DATA_WIDTH-1:0] memory2_C1[0:output_channel_C1*input_channel_C1*Size_Conv*Size_Conv-1];
    reg [DATA_WIDTH-1:0] memory3_C1[0:output_channel_C1-1];

	reg [DATA_WIDTH-1:0] memory2_C3[0:output_channel_C3*input_channel_C3*Size_Conv*Size_Conv-1];
    reg [DATA_WIDTH-1:0] memory3_C3[0:output_channel_C3-1];

    reg [DATA_WIDTH-1:0] memory2_C5[0:output_channel_C5*input_channel_C5*Size_Conv*Size_Conv-1];
    reg [DATA_WIDTH-1:0] memory3_C5[0:output_channel_C5-1];

    reg [DATA_WIDTH-1:0] memory2_F6[0:output_channel_F6*input_channel_F6*Size_FC*Size_FC-1];
    reg [DATA_WIDTH-1:0] memory3_F6[0:output_channel_F6-1];

    reg [DATA_WIDTH-1:0] memory2_F7[0:output_channel_F7*input_channel_F7*Size_FC*Size_FC-1];
    reg [DATA_WIDTH-1:0] memory3_F7[0:output_channel_F7-1];

	integer i, out_file_C1, out_file_R1, out_file_S2, out_file_C3, out_file_R2, out_file_S4, out_file_C5, out_file_F6, out_file_F7;
	integer clkCounter;

	ConvLayer3D
	#(
		.DATA_WIDTH(DATA_WIDTH),
		.Size(Size_Conv),
		.H(H_C1),	
		.W(W_C1),
		.input_channel(input_channel_C1),
		.output_channel(output_channel_C1)
	)
	C1
	(
		.clk(clk),
		.reset(reset_C1),
		.image(image),
		.filter(filter_C1),
		.bias(bias_C1),
		.outputConv(outputConv_C1)
	);

	Activation_ReLU
	#(
		.DATA_WIDTH(DATA_WIDTH),
		.H(H_R1),
		.W(W_R1),
		.input_channel(input_channel_R1),
		.output_channel(output_channel_R1)
	)
	R1
	(
		.Input_ReLU(outputConv_C1),
		.Output_ReLU(outputRelu_R1)
	);    

    AvgPoolLayer3D
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .Depth(Depth_S2),
        .inputH(H_S2),
        .inputW(W_S2)
    )
    S2
    (
        .avgpoolIn(outputRelu_R1),
        .avgpoolOut(outputPool_S2)
    );

    ConvLayer3D
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .Size(Size_Conv),
        .H(H_C3),
        .W(W_C3),
        .input_channel(input_channel_C3),
        .output_channel(output_channel_C3)
    )
    C3
    (
        .clk(clk),
        .reset(reset_C3),
        .image(outputPool_S2),
        .filter(filter_C3),
        .bias(bias_C3),
        .outputConv(outputConv_C3)
    );

	Activation_ReLU
	#(
		.DATA_WIDTH(DATA_WIDTH),
		.H(H_R2),
		.W(W_R2),
		.input_channel(input_channel_R2),
		.output_channel(output_channel_R2)
	)
	R2
	(
		.Input_ReLU(outputConv_C3),
		.Output_ReLU(outputRelu_R2)
	);  

    AvgPoolLayer3D
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .Depth(Depth_S4),
        .inputH(H_S4),
        .inputW(W_S4)
    )
    S4
    (
        .avgpoolIn(outputRelu_R2),
        .avgpoolOut(outputPool_S4)
    ); 

    ConvLayer3D
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .Size(Size_Conv),
        .H(H_C5),
        .W(W_C5),
        .input_channel(input_channel_C5),
        .output_channel(output_channel_C5)
    )
    C5
    (
        .clk(clk),
        .reset(reset_C5),
        .image(outputPool_S4),
        .filter(filter_C5),
        .bias(bias_C5),
        .outputConv(outputConv_C5)
    );

    FCLayer
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .Size(Size_FC),
        .H(H_F6),
        .W(W_F6),
        .input_channel(input_channel_F6),
        .output_channel(output_channel_F6)
    )
    F6
    (
        .clk(clk),
        .reset(reset_F6),
        .image(outputConv_C5),
        .filter(filter_F6),
        .bias(bias_F6),
        .outputConv(outputConv_F6)
    );

    FCLayer
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .Size(Size_FC),
        .H(H_F7),
        .W(W_F7),
        .input_channel(input_channel_F7),
        .output_channel(output_channel_F7)
    )
    F7
    (
        .clk(clk),
        .reset(reset_F7),
        .image(outputConv_F6),
        .filter(filter_F7),
        .bias(bias_F7),
        .outputConv(outputConv_F7)
    );

	always #(PERIOD/2) clk = ~clk;

	task wait_clk;
		@(posedge clk);
		#(PERIOD/2);
	endtask

    always@(*) begin
        //C1
		for(i=0; i<input_channel_C1*W_C1*H_C1; i=i+1) begin
			image[i*DATA_WIDTH +: DATA_WIDTH] = memory1_C1[i][DATA_WIDTH-1:0];
		end	
		for(i=0; i<output_channel_C1*input_channel_C1*Size_Conv*Size_Conv; i=i+1) begin
			filter_C1[i*DATA_WIDTH +: DATA_WIDTH] = memory2_C1[i][DATA_WIDTH-1:0];
		end	
		for(i=0; i<output_channel_C1; i=i+1) begin
			bias_C1[i*DATA_WIDTH +: DATA_WIDTH] = memory3_C1[i][DATA_WIDTH-1:0];
		end

        //C3
		for(i=0; i<output_channel_C3*input_channel_C3*Size_Conv*Size_Conv; i=i+1) begin
			filter_C3[i*DATA_WIDTH +: DATA_WIDTH] = memory2_C3[i][DATA_WIDTH-1:0];
		end	
		for(i=0; i<output_channel_C3; i=i+1) begin
			bias_C3[i*DATA_WIDTH +: DATA_WIDTH] = memory3_C3[i][DATA_WIDTH-1:0];
		end

        //C5
        for(i=0; i<output_channel_C5*input_channel_C5*Size_Conv*Size_Conv; i=i+1) begin
            filter_C5[i*DATA_WIDTH +: DATA_WIDTH] = memory2_C5[i][DATA_WIDTH-1:0];
        end
        for(i=0; i<output_channel_C5; i=i+1) begin
            bias_C5[i*DATA_WIDTH +: DATA_WIDTH] = memory3_C5[i][DATA_WIDTH-1:0];
        end

        //F6
        for(i=0; i<output_channel_F6*input_channel_F6*Size_FC*Size_FC; i=i+1) begin
            filter_F6[i*DATA_WIDTH +: DATA_WIDTH] = memory2_F6[i][DATA_WIDTH-1:0];
        end
        for(i=0; i<output_channel_F6; i=i+1) begin
            bias_F6[i*DATA_WIDTH +: DATA_WIDTH] = memory3_F6[i][DATA_WIDTH-1:0];
        end

        //F7
        for(i=0; i<output_channel_F7*input_channel_F7*Size_FC*Size_FC; i=i+1) begin
            filter_F7[i*DATA_WIDTH +: DATA_WIDTH] = memory2_F7[i][DATA_WIDTH-1:0];
        end
        for(i=0; i<output_channel_F7; i=i+1) begin
            bias_F7[i*DATA_WIDTH +: DATA_WIDTH] = memory3_F7[i][DATA_WIDTH-1:0];
        end
    end

	always @ (posedge clk) begin
		clkCounter = clkCounter + 1;
	end

	initial begin
		#0
		clkCounter = 0;
		clk = 1'b0;
		reset_C1 = 1;
		wait_clk;
		reset_C1 = 0;        
        $readmemh(file_image, memory1_C1);
        $readmemh(file_filter_C1, memory2_C1);
        $readmemh(file_bias_C1, memory3_C1);

	    #(input_channel_C1*W_C1*H_C1*PERIOD);
	    #(input_channel_R1*W_R1*H_R1*PERIOD);   
        #(Depth_S2*W_S2*H_S2*PERIOD);
		#((560*28+1)*PERIOD);

		reset_C3 = 1;
        wait_clk;
        reset_C3 = 0;         
        $readmemh(file_filter_C3, memory2_C3);
        $readmemh(file_bias_C3, memory3_C3);   
        #(input_channel_C3*W_C3*H_C3*PERIOD);
        #(input_channel_R2*W_R2*H_R2*PERIOD);
        #(Depth_S4*W_S4*H_S4*PERIOD);
		#((560*28+1)*PERIOD);

		reset_C5 = 1;
        wait_clk;
        reset_C5 = 0; 
        $readmemh(file_filter_C5, memory2_C5);
        $readmemh(file_bias_C5, memory3_C5);
        #(input_channel_C5*W_C5*H_C5*PERIOD);
		#((560*28+1)*PERIOD);

		reset_F6 = 1;
        wait_clk;
        reset_F6 = 0; 
        $readmemh(file_filter_F6, memory2_F6);
        $readmemh(file_bias_F6, memory3_F6); 
        #(input_channel_F6*W_F6*H_F6*PERIOD);
		#((560*28+1)*PERIOD);

		reset_F7 = 1;
        wait_clk;
        reset_F7 = 0; 
        $readmemh(file_filter_F7, memory2_F7);
        $readmemh(file_bias_F7, memory3_F7);
        #(input_channel_F7*W_F7*H_F7*PERIOD);

		wait_clk;
		#((560*28+1)*PERIOD);
		out_file_C1 = $fopen("./out_file_C1.txt");
   		out_file_R1 = $fopen("./out_file_R1.txt");  
        out_file_S2 = $fopen("./out_file_S2.txt");   
        out_file_C3 = $fopen("./out_file_C3.txt");
        out_file_R2 = $fopen("./out_file_R2.txt");
        out_file_S4 = $fopen("./out_file_S4.txt");
        out_file_C5 = $fopen("./out_file_C5.txt");
        out_file_F6 = $fopen("./out_file_F6.txt");
        out_file_F7 = $fopen("./out_file_F7.txt");

		wait_clk;
        for (i=0; i<output_channel_C1*(W_C1-Size_Conv+1)*(H_C1-Size_Conv+1); i=i+1) begin
			$fdisplay(out_file_C1, "%h", outputConv_C1[i*DATA_WIDTH +: DATA_WIDTH]);
		end 
        for (i=0; i<output_channel_R1*W_R1*H_R1; i=i+1) begin
            $fdisplay(out_file_R1, "%h", outputRelu_R1[i*DATA_WIDTH +: DATA_WIDTH]);
        end
        for (i=0; i<Depth_S2*(W_S2/2)*(H_S2/2); i=i+1) begin
            $fdisplay(out_file_S2, "%h", outputPool_S2[i*DATA_WIDTH +: DATA_WIDTH]);
        end
        for (i=0; i<output_channel_C3*(W_C3-Size_Conv+1)*(H_C3-Size_Conv+1); i=i+1) begin
            $fdisplay(out_file_C3, "%h", outputConv_C3[i*DATA_WIDTH +: DATA_WIDTH]);
        end 
        for (i=0; i<output_channel_R2*W_R2*H_R2; i=i+1) begin
            $fdisplay(out_file_R2, "%h", outputRelu_R2[i*DATA_WIDTH +: DATA_WIDTH]);
        end
        for (i=0; i<Depth_S4*(W_S4/2)*(H_S4/2); i=i+1) begin
            $fdisplay(out_file_S4, "%h", outputPool_S4[i*DATA_WIDTH +: DATA_WIDTH]);
        end
        for (i=0; i<output_channel_C5*(W_C5-Size_Conv+1)*(H_C5-Size_Conv+1); i=i+1) begin
            $fdisplay(out_file_C5, "%h", outputConv_C5[i*DATA_WIDTH +: DATA_WIDTH]);
        end 
        for (i=0; i<output_channel_F6*(W_F6-Size_FC+1)*(H_F6-Size_FC+1); i=i+1) begin
            $fdisplay(out_file_F6, "%h", outputConv_F6[i*DATA_WIDTH +: DATA_WIDTH]);
        end
		for (i=0; i<output_channel_F7*(W_F7-Size_FC+1)*(H_F7-Size_FC+1); i=i+1) begin
			$fdisplay(out_file_F7, "%h", outputConv_F7[i*DATA_WIDTH +: DATA_WIDTH]);
		end 
		$stop;
	end

endmodule
