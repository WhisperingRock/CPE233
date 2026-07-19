`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: WhisperingRock
// 
// Create Date: 07/17/2026 03:36:51 PM
// Design Name: 
// Module Name: PC_Reg
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Program Counter (register) holds PC_COUNT
//                  constant unless a reset has occured or
//                  a write enable overwrites PC_COUNT with
//                  PC_DIN
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module PC_Reg(
    input CLK,                      
    input PC_RST,                   // (highest-priority) active high synch reset s.t. 1 -> PC=0
    input PC_WE,                    // active high synch load value from PC_DIN into PC
    input[31:0] PC_DIN,             // potential unsigned 32-bit PC
    output logic [31:0] PC_COUNT    // current value of PC (used as addr for ProgROM)
    );
    
    always_ff@(posedge CLK)         // changes on clk demand sequental logic (use nonblocking)
    begin
        if(PC_RST) PC_COUNT <= 0;
        else if (PC_WE) PC_COUNT <= PC_DIN;
    end
    
endmodule
