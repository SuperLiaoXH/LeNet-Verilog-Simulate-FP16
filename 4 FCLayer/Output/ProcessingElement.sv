// ----------------------------------------------------------------------------------
// -- Function : This module is used for multiplication and addition calculation
// -- Designer : LXH
// ----------------------------------------------------------------------------------
module ProcessingElement(
    clk,
    reset,
    enable,
    floatA,
    floatB,
    result
);

    parameter DATA_WIDTH = 16;

    input clk;
    input reset;
    input enable;
    input [DATA_WIDTH-1:0] floatA;
    input [DATA_WIDTH-1:0] floatB;
    output reg [DATA_WIDTH-1:0] result;

    wire [DATA_WIDTH-1:0] floatB_Add;
    wire [DATA_WIDTH-1:0] MulResult;
    wire [DATA_WIDTH-1:0] AddResult;

    Float16Mul FM
    (
        .floatA(floatA),
        .floatB(floatB),
        .product(MulResult)
    );

    Float16Add FA
    (
        .floatA(MulResult),
        .floatB(floatB_Add),
        .sum(AddResult)
    );

    always @ (posedge clk or posedge reset) begin
        if(reset) begin
            result <= 0;
        end
        else begin
            result <= AddResult;
        end
    end

    assign floatB_Add = enable?result:0;

endmodule