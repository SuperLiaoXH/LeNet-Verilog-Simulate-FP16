// ----------------------------------------------------------------------------------
// -- Function : This module is the designed convolution layer
// -- Designer : LXH
// ----------------------------------------------------------------------------------
module ConvLayer3D(
    clk,
    reset,
    image,
    filter,
    bias,
    outputConv
);
    
    parameter DATA_WIDTH = 16;
    parameter Size = 5; //Size of the filter
    parameter H = 14; //Height of the image
    parameter W = 14; //Width of the image
    parameter input_channel = 6;
    parameter output_channel = 16;

    input clk;
    input reset;
    input [input_channel*W*H*DATA_WIDTH-1:0] image;
    input [output_channel*input_channel*Size*Size*DATA_WIDTH-1:0] filter;
    input [output_channel*DATA_WIDTH-1:0] bias;
    output reg [output_channel*(W-Size+1)*(H-Size+1)*DATA_WIDTH-1:0] outputConv; //output of the module

    wire [(W-Size+1)*output_channel*DATA_WIDTH-1:0] outputConvUnits; //output of the conv units and input to the row selector (after add bias)
    wire [(W-Size+1)*(input_channel*Size*Size)*DATA_WIDTH-1:0] receptiveField; // array of the matrices to be sent to conv units
    reg internalReset;
    wire [output_channel*(W-Size+1)-1:0] cu_done;

    reg [output_channel*(W-Size+1)*(H-Size+1)*DATA_WIDTH-1:0] outputConv_without_bias;
    reg [output_channel*(W-Size+1)*(H-Size+1)*DATA_WIDTH-1:0] outputConv_add_bias;

    //counter: number of clock cycles need for the conv unit to finsish
    //outputCounter: index to map the output of the conv units to the output of the module
    reg [15:0] counter;
    reg [15:0] outputCounter;

    //row: determines the row that is calculated by the conv units
    //column: determines if we are calculating the first or the second 14 pixels of the output row
    reg [7:0] row;
    reg [7:0] column;

    reg [7:0] out_channel_count;
 
	RFSelector
    #(
	    .DATA_WIDTH(DATA_WIDTH),
	    .Depth(input_channel),
	    .Size(Size),
		.H(H),
		.W(W)
    )
    RF
    (
        .image(image),
        .row(row),
        .column(column),
        .receptiveField(receptiveField)
    );

    genvar m, n;
    generate //generating n convolution units
        for(m=0; m<output_channel; m=m+1) begin
            for(n=0; n<W-Size+1; n=n+1) begin
                ConvUnit
                #(
                    .DATA_WIDTH(DATA_WIDTH),
                    .Depth(input_channel),
                    .Size(Size)
                )
                CU 
                (
                    .clk(clk),
                    .reset(internalReset),
                    .image(receptiveField[n*input_channel*Size*Size*DATA_WIDTH +: input_channel*Size*Size*DATA_WIDTH]),
                    .filter(filter[m*input_channel*Size*Size*DATA_WIDTH +: input_channel*Size*Size*DATA_WIDTH]),
                    .done(cu_done[m*(W-Size+1)+n]),
                    .result(outputConvUnits[(m*(W-Size+1)+n)*DATA_WIDTH +: DATA_WIDTH])
                );
            end
        end
    endgenerate

    genvar i,j,k;
    generate
        for(i=0; i<output_channel; i=i+1) begin
            for(j=0; j<H-Size+1; j=j+1) begin
                for(k=0; k<W-Size+1; k=k+1) begin
                    //adding bias to the output of the conv units
                    Float16Add FA
                    (
                        .floatA(outputConv_without_bias[(i*(H-Size+1)*(W-Size+1)+j*(W-Size+1)+k)*DATA_WIDTH +: DATA_WIDTH]),
                        .floatB(bias[i*DATA_WIDTH +: DATA_WIDTH]),
                        .sum(outputConv_add_bias[(i*(H-Size+1)*(W-Size+1)+j*(W-Size+1)+k)*DATA_WIDTH +: DATA_WIDTH])
                    );
                end
            end
        end
    endgenerate

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            internalReset <= 1;
            row <= 0;
            column <= 0;
            counter <= 0;
            outputCounter <= 0;
            outputConv <= 0;
        end
        else 
            if (row == H-Size+1) begin
                outputConv <= outputConv_add_bias;
            end
            if (row < H-Size+1) begin
                //The conv unit finishes ater input_channel*Size*Size+2 clock cycles
                if(counter == input_channel*Size*Size+2) begin
                //if(cu_done == 28'b1111_1111_1111_1111_1111_1111_1111) begin
                    outputCounter <= outputCounter + 1;
                    counter <= 0;
                    internalReset <= 1;
                    row <= row + 1;
                    column <= 0;
                end
                else begin
                    internalReset <= 0;
                    counter <= counter + 1;
                end
            end
    end

    // connecting the output of the conv units with the output of the module
    always @(*) begin
        if(!reset) begin
            //if(cu_done == 160'hffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff_ffff) 
            for(out_channel_count=0; out_channel_count<output_channel; out_channel_count=out_channel_count+1) begin
                if(internalReset != 1) begin
                    outputConv_without_bias[(out_channel_count*(W-Size+1)*(H-Size+1)+outputCounter*(W-Size+1))*DATA_WIDTH +: (W-Size+1)*DATA_WIDTH] = outputConvUnits[(W-Size+1)*out_channel_count*DATA_WIDTH +: (W-Size+1)*DATA_WIDTH];
                    //outputConv[outputCounter*(W-Size+1)*DATA_WIDTH +: (W-Size+1)*DATA_WIDTH] = outputConvUnits_without_bias;
                end
            end
            
        end
    end

endmodule