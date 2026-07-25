`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: WhisperingRock
// 
// Create Date: 07/24/2026 09:28:51 PM
// Design Name: 
// Module Name: ALU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//          A Purely combinational operation execution(er).
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
//parameter BITWIDTH      = 32;
parameter FUNWIDTH      = 4;


module ALU(
    input logic [FUNWIDTH-1:0] ALU_FUN, 
    input logic [BITWIDTH-1:0] SRC_A, SRC_B,
    output logic[BITWIDTH-1:0] ALU_RESULT
    );
    
    // ~~ local vars ~~
    logic[BITWIDTH-1:0] ERR = 32'hDEAD_BEEF;
    
    always_comb
    begin
        case(ALU_FUN)
            // ~~ arithmetic operators~~
            4'b0000: begin ALU_RESULT = SRC_A + SRC_B; end                              // ADD
            4'b1000: begin ALU_RESULT = SRC_A - SRC_B; end                              // SUB
            
            // ~~ bitwise operators ~~
            4'b0111: begin ALU_RESULT = SRC_A & SRC_B; end                              // AND
            4'b0110: begin ALU_RESULT = SRC_A | SRC_B; end                              // OR
            4'b0100: begin ALU_RESULT = SRC_A ^ SRC_B; end                              // XOR

            // ~~ shift operators ~~
            // Note : shifting only uses the 5 LSBs of SRC_B (see manual)
            // Note : arithmetic shifting has its own systemverilog operator
            4'b0101: begin ALU_RESULT = SRC_A >> SRC_B[4:0]; end                        // SRL
            4'b0001: begin ALU_RESULT = SRC_A << SRC_B[4:0]; end                        // SLL
            4'b1101: begin ALU_RESULT = $signed(SRC_A) >>> $signed(SRC_B[4:0]); end     // SRA
            
            // ~~ set operators ~~
            4'b0010: begin ALU_RESULT = $signed(SRC_A) < $signed(SRC_B); end            // SLT
            4'b0011: begin ALU_RESULT = SRC_A < SRC_B; end                              // SLTU
            
            // ~~ copy operator ~~
            4'b1001: begin ALU_RESULT = SRC_A; end                                      // LUI-COPY (MV?)
            
            // ~~ error ~~
            default: begin ALU_RESULT = ERR; end
        endcase
    end
    
endmodule
