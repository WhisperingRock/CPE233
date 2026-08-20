`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2026 10:35:06 AM
// Design Name: 
// Module Name: Mux_2N
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
module Mux_2N
#(parameter width = 32)
(                              
    input logic[width-1:0]  D0, D1,
    input logic             S,  
    output logic[width-1:0] Y   
);

    always_comb begin
        Y = (S == 1'b1) ? D1 : D0;  
    end
            
endmodule
