`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/14/2026 02:38:59 PM
// Design Name: 
// Module Name: CUnit_Decoder
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


module CUnit_Decoder(
    input logic [6:0]   OPCODE, 
    input logic [2:0]   FUNC3, 
    input logic         FUNC7,
    
    // ~~~~ Branch rs1-2 precalcs ~~~~
    input logic BR_EQ, BR_LT, BR_LTU,
    
    // ~~~~ MUX Selectors ~~~~ 
    output logic [3:0]  ALU_FUNC,           // ALU operation sel
    output logic        ALU_SRC_A,          // ALU srcA sel
    output logic [1:0]  ALU_SRC_B,          // ALU srcB sel
    output logic [1:0]  PC_SOURCE,          // input sel for program counter
    output logic [1:0]  RF_WR_SEL           // register file write (data) source sel
    );
    
    
    always_comb
    begin
    
         ALU_FUNC   = 4'b0000;         // default
         ALU_SRC_A  = 1'b0;            // default
         ALU_SRC_B  = 2'b00;           // default
         PC_SOURCE  = 2'b00;           // default
         RF_WR_SEL  = 2'b00;           // default
        
         case(OPCODE)
       
            // ~~ loads (OP=3) ~~
            7'b0000011: 
            begin
                 //ALU_FUNC   = 0                 Select : add (rs1, immed)
                 //ALU_SRC_A  = 0                 Select : rs1
                 ALU_SRC_B  = 2'b01;           // Select : immed (I-type)
                 //PC_SOURCE  = 0                 Select : PC + 4
                 RF_WR_SEL  = 2'b10;           // Select : rd = DOUT2 = ram[rs1 + immed]
            end
            
            // ~~ immed value (OP=19) ~~
            7'b0010011: 
            begin
                 ALU_FUNC = ((FUNC3 == 3'b101) && (FUNC7 == 1'b1)) ? ({1'b0, FUNC3} + 4'b1000) : {1'b0, FUNC3};  
                 //ALU_SRC_A  = 0                 Select rs1
                 ALU_SRC_B  = 2'b01;           // Select immed I
                 //PC_SOURCE  = 0                 Select PC + 4
                 RF_WR_SEL  = 2'b11;           // Select rd = result
            end
            
            
            // ~~ Registers as value (OP=51) ~~
            7'b0110011: 
            begin
            
                 if((FUNC3 == 3'b000) || (FUNC3 == 3'b101))
                 begin
                    ALU_FUNC = (FUNC7 == 1'b1) ? ({1'b0,FUNC3}+4'b1000) : {1'b0,FUNC3};
                 end
                 else
                 begin
                    ALU_FUNC = {1'b0,FUNC3};
                 end 
                 
                 //ALU_SRC_A  = 0;                Select rs1
                 //ALU_SRC_B  = 0;                Select rs2
                 //PC_SOURCE  = 0;                Select PC + 4
                 RF_WR_SEL  = 2'b11;           // Select rd = result
            end
            
            // ~~ Branch (OP=99) ~~
            7'b1100011: 
            begin              
                 case(FUNC3)
                    3'b000: begin PC_SOURCE  = (BR_EQ)  ?   2'b10 : 2'b00;    end   // BEQ : branch or PC+4
                    3'b001: begin PC_SOURCE  = (~BR_EQ) ?   2'b10 : 2'b00;    end   // BNE : branch or PC+4
                    3'b100: begin PC_SOURCE  = (BR_LT)  ?   2'b10 : 2'b00;    end   // BLT : branch or PC+4
                    3'b101: begin PC_SOURCE  = (~BR_LT) ?   2'b10 : 2'b00;    end   // BGE : branch or PC+4
                    3'b110: begin PC_SOURCE  = (BR_LTU) ?   2'b10 : 2'b00;    end   // BLTU : branch or PC+4
                    3'b111: begin PC_SOURCE  = (~BR_LTU)?   2'b10 : 2'b00;    end   // BGEU : branch or PC+4
                    default: begin PC_SOURCE = 2'b00; end
                 endcase
                 // rest are dont cares
            end
            
            
            // ~~ Jump and link register (OP=103) ~~
            7'b1100111: 
            begin

                 PC_SOURCE  = 1;             // Select JALR
                 //RF_WR_SEL  = 0               Select PC + 4
                                             // rest are dont cares
            end
            
            // ~~ Jump and link (OP=111) ~~
            7'b1101111: 
            begin
                 PC_SOURCE  = 3;              // Select JAL
                 //RF_WR_SEL  = 0                Select PC + 4
                                              // rest are dont cares
            end
            
            default: 
            begin        
            end
            
       endcase
    end
    
endmodule
