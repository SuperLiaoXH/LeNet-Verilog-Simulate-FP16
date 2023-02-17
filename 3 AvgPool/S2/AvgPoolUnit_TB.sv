`timescale 1ns/1ps

module AvgPoolUnit_TB();

    reg [15:0] numA;
    reg [15:0] numB;
    reg [15:0] numC;
    reg [15:0] numD;  
    wire [15:0] result;
    
    AvgPoolUnit UUT(
        .numA(numA),
        .numB(numB),
        .numC(numC),
        .numD(numD),
        .result(result)
    );

    initial begin
       	// Avg(2,3,4,5) = 3.5(16'h4300)
	    #0
        numA = 16'h4000;// 2
        numB = 16'h4200;// 3
        numC = 16'h4400;// 4
        numD = 16'h4500;// 5

	    // Avg(-1,-2,-3,-4) = -2.5(16'hc100)
	    #10
	    numA = 16'hBC00;// -1
        numB = 16'hC000;// -2
        numC = 16'hC200;// -3
        numD = 16'hC400;// -4
  
	    // Avg(1000,218,3300,42) = 1140(16'h6474)
	    #10
	    numA = 16'h63D0;// 1000
        numB = 16'h5AD0;// 218
        numC = 16'h6A72;// 3300
        numD = 16'h5140;// 42

	    // Avg(-1000,-518,-6300,-52) = -1967.5(16'he7b0)
	    #10
	    numA = 16'hE3D0;// -1000
        numB = 16'hE00C;// -518
        numC = 16'hEE27;// -6300
        numD = 16'hD280;// -52

	    // Avg(1,2,-3,4) = 1(16'h3C00)
	    #10
	    numA = 16'h3C00;// 1
        numB = 16'h4000;// 2
        numC = 16'hC200;// -3
        numD = 16'h4400;// 4

        // Avg(2,-3,-4,-5) = -2.5(16'hc100)
        #10
	    numA = 16'h4000;// 2
        numB = 16'hC200;// -3
        numC = 16'hC400;// -4
        numD = 16'hC500;// -5

	    // Avg(-1000,-218,3300,42) = 531(16'h6026)
	    #10
	    numA = 16'hE3D0;// -1000
        numB = 16'hDAD0;// -218
        numC = 16'h6A72;// 3300
        numD = 16'h5140;// 42

	    // Avg(-1000,-518,-6300,52) = -1941.5(16'he796)
	    #10
	    numA = 16'hE3D0;// -1000
        numB = 16'hE00C;// -518
        numC = 16'hEE27;// -6300
        numD = 16'h5280;// 52

        #10
	    $stop; 
    end

endmodule