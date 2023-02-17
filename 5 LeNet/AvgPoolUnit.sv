// ----------------------------------------------------------------------------------
// -- Function : This module is used for 2*2 average pooling 
// -- Designer : LXH
// ----------------------------------------------------------------------------------
module AvgPoolUnit(
    numA,
    numB,
    numC,
    numD,
    result
);
    
    parameter DATA_WIDTH = 16;

    input [DATA_WIDTH-1:0] numA;
    input [DATA_WIDTH-1:0] numB;
    input [DATA_WIDTH-1:0] numC;
    input [DATA_WIDTH-1:0] numD;
    output reg [DATA_WIDTH-1:0] result;

    wire [DATA_WIDTH-1:0] add1result;
    wire [DATA_WIDTH-1:0] add2result;
    wire [DATA_WIDTH-1:0] add3result;
    wire [DATA_WIDTH-1:0] constQuarter;

    Float16Add FA1(
        .floatA(numA),
        .floatB(numB),
        .sum(add1result)
    );
    Float16Add FA2(
        .floatA(add1result),
        .floatB(numC),
        .sum(add2result)
    );
    Float16Add FA3(
        .floatA(add2result),
        .floatB(numD),
        .sum(add3result)
    );
    Float16Mul FM(
        .floatA(add3result),
        .floatB(constQuarter),
        .product(result)
    );

    assign constQuarter = 16'b0011010000000000;//16'h3400(0.25)

endmodule