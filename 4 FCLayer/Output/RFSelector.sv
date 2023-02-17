// ----------------------------------------------------------------------------------
// -- Function : This module completes the rearrangement of images (img2col)
// -- Designer : LXH
// ----------------------------------------------------------------------------------
module RFSelector(
    image,
    row,
    column,
    receptiveField
);

    parameter DATA_WIDTH = 16;
    parameter Depth = 1; //Depth of the filter
    parameter Size = 5; //Size of the filter
    parameter H = 32; //Height of the image
    parameter W = 32; //Width of the image

    input [Depth*H*W*DATA_WIDTH-1:0] image;
    input [7:0] row;
    input [7:0] column;
    output reg [(W-Size+1)*(Depth*Size*Size*DATA_WIDTH)-1:0] receptiveField; //array to hold the matrices (parts of the image) to be sent to the conv units

    //address: counter to fill the receptive filed array
    //c: counter to loop on the columns of the input image
    //k: counter to loop on the depth of the input image
    //i: counter to loop on the rows of the input image
    reg [31:0] address, c, k, i;   

    always @(image or row or column) begin
        address = 0;
        //if the column is zero fill the array with the parts of the image correspoding to the first half of pixels of the row (with rowNumber) of the output image
        for(c=column; c<(W-Size+1); c=c+1) begin
            for(k=0; k<Depth; k=k+1) begin
                for(i=0; i<Size; i=i+1) begin
                    receptiveField[address*Size*DATA_WIDTH +: Size*DATA_WIDTH] = image[row*W*DATA_WIDTH+c*DATA_WIDTH+k*H*W*DATA_WIDTH+i*W*DATA_WIDTH +: Size*DATA_WIDTH];
                    address = address + 1;
                end
            end
        end
    end

endmodule