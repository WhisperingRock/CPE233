`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/28/2026 07:35:34 PM
// Design Name: 
// Module Name: BranchAddrGen
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


module BranchAddrGen(
    input   logic [31:0] RS1, 
    input   logic [31:0] I_TYPE, J_TYPE, B_TYPE,
    input   logic [31:0] PC,
    output  logic [31:0] JAL, JALR, BRANCH  
);
    // ~~~~ combinational logic ~~~~
    assign JAL      = PC    + J_TYPE; 
    assign JALR     = RS1   + I_TYPE; 
    assign BRANCH   = PC    + B_TYPE;
    
endmodule
