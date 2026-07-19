`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2026 04:24:06 PM
// Design Name: 
// Module Name: Mux_6N
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


module Mux_6N
#(parameter width = 32)                              // default bits
(
    input logic[width-1:0] D0, D1, D2, D3, D4, D5,  // data channels
    input logic[2:0]                            S,  // selector
    output logic[width-1:0]                     Y   
);

    logic[width-1:0] ERR = 0;

    always_comb
        case(S)
            0:  Y = D0;
            1:  Y = D1;
            2:  Y = D2;
            3:  Y = D3;
            4:  Y = D4;
            5:  Y = D5;
            default Y = (~ERR) -13 ;
        endcase        

endmodule