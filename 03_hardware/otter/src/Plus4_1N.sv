`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2026 07:28:53 PM
// Design Name: 
// Module Name: Plus4_1N
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Plus4_1N
#(parameter width = 32)                              // default bits
(
    input logic[width-1:0] IN,
    output logic[width-1:0] OUT
);

    always_comb
       OUT = IN + 4;

endmodule
