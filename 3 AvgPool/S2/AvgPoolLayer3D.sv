// ----------------------------------------------------------------------------------
// -- Function : This module is the average pooling layer
// -- Designer : LXH
// ----------------------------------------------------------------------------------
module AvgPoolLayer3D(
    avgpoolIn,
    avgpoolOut
);

    parameter DATA_WIDTH = 16;
    parameter Depth = 6;
    parameter inputH = 28;
    parameter inputW = 28;

    input [Depth*inputH*inputW*DATA_WIDTH-1:0] avgpoolIn;
    output reg [Depth*(inputH/2)*(inputW/2)*DATA_WIDTH-1:0] avgpoolOut;

    genvar i,j,k;

    generate
        for(k=0; k<Depth; k=k+1) begin
            for (i=0; i<inputH; i=i+2) begin
                for (j=0; j<inputW; j=j+2) begin
                    AvgPoolUnit
                    #(
                        .DATA_WIDTH(DATA_WIDTH)
                    )
                    AU 
                    (
                        .numA(avgpoolIn[(k*inputW*inputH + i*inputW + j)*DATA_WIDTH +: DATA_WIDTH]),
                        .numB(avgpoolIn[(k*inputW*inputH + i*inputW + j+1)*DATA_WIDTH +: DATA_WIDTH]),
                        .numC(avgpoolIn[(k*inputW*inputH + (i+1)*inputW + j)*DATA_WIDTH +: DATA_WIDTH]),
                        .numD(avgpoolIn[(k*inputW*inputH + (i+1)*inputW + j+1)*DATA_WIDTH +: DATA_WIDTH]),
                        .result(avgpoolOut[(k*(inputW/2)*(inputH/2) + (i/2)*(inputW/2) + (j/2))*DATA_WIDTH +: DATA_WIDTH])
                    );    
                end
            end
        end
    endgenerate

endmodule