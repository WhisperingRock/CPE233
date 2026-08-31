`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2026 09:15:04 AM
// Design Name: 
// Module Name: Mux_3N
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
module Mux_3N
#(parameter width = 32)
(                              
    input logic[width-1:0] 		D0, D1, D2,
    input logic[1:0]            S,  
    output logic[width-1:0]     Y   
);

    logic[width-1:0] ERR = 0;

    always_comb
    begin
        case(S)
            0:	Y = D0;
            1:	Y = D1;
            2:	Y = D2;
            default Y = (~ERR) -13 ;
        endcase
    end        
endmodule
