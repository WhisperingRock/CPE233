`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/28/2026 07:21:37 PM
// Design Name: 
// Module Name: BranchConditionGen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//              Determines the branch condition instructions
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BranchConditionGen(
    input   logic [31:0] RS1, RS2,
    output  logic   BR_EQ,             // equal branch
                    BR_LT,             // less than branch
                    BR_LTU             // less then branch (unsigned)
);

    // ~~~~ combinational logic ~~~~
    assign BR_EQ    = (RS1 == RS2);
    assign BR_LT    = ($signed(RS1) < $signed(RS2));
    assign BR_LTU   = (RS1 < RS2);

endmodule
