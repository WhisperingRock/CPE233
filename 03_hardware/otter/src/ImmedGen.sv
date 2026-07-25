`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2026 10:59:49 AM
// Design Name: 
// Module Name: ImmedGen
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


module ImmedGen(
    input logic [BITWIDTH-1:0] INSTR,
    output logic[BITWIDTH-1:0] U_TYPE, I_TYPE, S_TYPE, J_TYPE, B_TYPE
    );
    
    //~~~~ Immediates are immediate! ~~~~
    assign U_TYPE = { INSTR[31:12], 12'b0 };
    
    assign I_TYPE = { {21{INSTR[31]}}, INSTR[30:20] };
    
    assign S_TYPE = { {21{INSTR[31]}}, INSTR[30:25], INSTR[11:7] };
    
    assign B_TYPE = 
    {
        {20{INSTR[31]}},
        INSTR[7], 
        INSTR[30:25],
        INSTR[11:8], 
        1'b0
    };
    
    assign J_TYPE = 
    {
        {12{INSTR[31]}},
        INSTR[19:12],
        INSTR[20],
        INSTR[30:21], 
        1'b0
    };

    
    
endmodule
