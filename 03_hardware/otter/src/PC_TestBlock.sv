`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2026 07:34:25 PM
// Design Name: 
// Module Name: PC_TestBlock
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


module PC_TestBlock(
        input logic PC_RST, PC_WE, CLK,
        input logic[2:0] PC_SEL,
        input logic[31:0] JALR, BRANCH, JAL, MTVEC, MEPC,
        output logic[31:0] PC_COUNT, PC_PLUS_FOUR
    );
    
    // ~~~~ inits and wires ~~~~
    logic[31:0] MUX_O_WIRE;
    
    // ~~~~ instances ~~~~
    Mux_6N #(32) Mux(
        .D0(PC_PLUS_FOUR), 
        .D1(JALR),
        .D2(BRANCH),
        .D3(JAL),
        .D4(MTVEC),
        .D5(MEPC),
        .S(PC_SEL),
        .Y(MUX_O_WIRE)
    );
    
    
    PC_Reg PC(
        .CLK(CLK),                      
        .PC_RST(PC_RST),                   
        .PC_WE(PC_WE),                    
        .PC_DIN(MUX_O_WIRE),             
        .PC_COUNT(PC_COUNT)
     );
           
    Plus4_1N #(32) P4(
        .IN(PC_COUNT),
        .OUT(PC_PLUS_FOUR)
    );
    
    
endmodule
