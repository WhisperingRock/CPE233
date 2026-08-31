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

    // ~~~~ obtain inputs during/after EXEC ~~~~ 
    input logic [6:0]   OPCODE, 
    input logic [2:0]   FUNC3, 
    input logic         FUNC7,
    input logic         BR_EQ, BR_LT, BR_LTU,
    input logic         INT_TAKEN,                              // interrupt in process
    
    // ~~~~ MUX sel outs ~~~~ 
    output logic [3:0]  ALU_FUNC,                               // ALU operation sel
    output logic [1:0]  ALU_SRC_A,                              // ALU srcA sel
    output logic [2:0]  ALU_SRC_B,                              // ALU srcB sel
    output logic [2:0]  PC_SOURCE,                              // input sel for program counter
    output logic [1:0]  RF_WR_SEL                               // register file write (data) source sel
    );
    
    
    always_comb
    begin
    
        // ~~ defaults ~~
        ALU_FUNC   = 4'b0000;
        ALU_SRC_A  = 2'b00;
        ALU_SRC_B  = 3'b000;                                      
        PC_SOURCE  = 3'b000;
        RF_WR_SEL  = 2'b00;  
        
        // if interrupt is requested, select mtvec for pc 
        if(INT_TAKEN == 1'b1) begin  PC_SOURCE  = 3'b100; end
        
        // else interrupt is not requested, process by opcode instead
        else begin            

            case(OPCODE)
           
                // ~~ loads (OP=3) ~~
                7'b0000011: 
                begin
                    ALU_SRC_B  = 3'b001;                                    // Select : immed (I-type)
                    RF_WR_SEL  = 2'b10;                                     // Select : rd = DOUT2 = ram[rs1 + immed]
                end
                
                // ~~ immed value (OP=19) ~~
                7'b0010011: 
                begin
                    ALU_FUNC = ((FUNC3 == 3'b101) && (FUNC7 == 1'b1)) ? ({1'b0, FUNC3} + 4'b1000) : {1'b0, FUNC3};
                    ALU_SRC_B  = 3'b001;                                    // Select immed I
                    RF_WR_SEL  = 2'b11;                                     // Select rd = result
                end
                
                // ~~ add upper imm to pc (auipc) (OP=23) ~~
                7'b0010111: 
                begin
    
                    ALU_SRC_A  = 2'b01;                                     // Select : imm (U-type)
                    ALU_SRC_B  = 3'b011;                                    // Select : PC
                    RF_WR_SEL  = 2'b11;                                     // Select : result
                end
                      
                // ~~ store (OP=35) ~~
                7'b0100011: 
                begin                    
                    ALU_SRC_B  = 3'b010;                                     // Select : immed (S-type)                      
                end
                   
                // ~~ Registers as value (OP=51) ~~
                7'b0110011: 
                begin
                
                     if((FUNC3 == 3'b000) || (FUNC3 == 3'b101))
                     begin
                        ALU_FUNC = (FUNC7 == 1'b1) ? ({1'b0,FUNC3}+4'b1000) : {1'b0,FUNC3};
                     end
                     
                     else begin ALU_FUNC = {1'b0,FUNC3}; end 
                                                          
                     RF_WR_SEL  = 2'b11;                                     // Select rd = result
                end
                     
                // ~~ lui (OP=55) ~~
                7'b0110111: 
                begin
                    ALU_FUNC   = 4'b1001;                                   // Select : copy srcA                  
                    ALU_SRC_A  = 2'b01;                                     // Select : imm (U-type)                                    
                    RF_WR_SEL  = 2'b11;                                     // Select : result
                end
                
                // ~~ Branch (OP=99) ~~
                7'b1100011: 
                begin       
                    case(FUNC3)
                        3'b000: begin PC_SOURCE  = (BR_EQ)  ?   3'b010 : 3'b000;    end   // BEQ :  branch or PC+4
                        3'b001: begin PC_SOURCE  = (~BR_EQ) ?   3'b010 : 3'b000;    end   // BNE :  branch or PC+4
                        3'b100: begin PC_SOURCE  = (BR_LT)  ?   3'b010 : 3'b000;    end   // BLT :  branch or PC+4
                        3'b101: begin PC_SOURCE  = (~BR_LT) ?   3'b010 : 3'b000;    end   // BGE :  branch or PC+4
                        3'b110: begin PC_SOURCE  = (BR_LTU) ?   3'b010 : 3'b000;    end   // BLTU : branch or PC+4
                        3'b111: begin PC_SOURCE  = (~BR_LTU)?   3'b010 : 3'b000;    end   // BGEU : branch or PC+4
                        default: begin PC_SOURCE = 3'b000; end
                    endcase                                    
                end
                          
                // ~~ Jump and link register (OP=103) ~~
                7'b1100111:
                begin                  
                    PC_SOURCE = 3'b001;                                      // Select JALR                                    
                end  
                
                // ~~ Jump and link (OP=111) ~~
                7'b110_1111: 
                begin               
                    PC_SOURCE = 3'b011;                                      // Select JAL                                    
                end
                
                // ~~ CSR (OP=115) ~~
                7'b111_0011: 
                begin
                
                    RF_WR_SEL  = 2'b01;                                     // sel CSR[csr] for regfile mux
                    ALU_SRC_B  = 3'b100;                                    // sel CSR[csr] for ALU-B
                               
                    case(FUNC3)
                        
                        // MRET
                        3'b000: begin PC_SOURCE = 3'b101; end               // MEPC for PC       
                        
                        // CSRRW
                        3'b001: 
                        begin                                     
                            ALU_FUNC   = 4'b1001;                           // mv rs1 to result
                        end
                        
                        // CSRRS   
                        3'b010: 
                        begin
                            ALU_FUNC   = 4'b0110;                           // rs1 | CSR[csr]
                        end   
                        
                        // CSRRC
                        3'b011: 
                        begin   
                            ALU_SRC_A  = 2'b10;                             // sel ~rs1
                            ALU_FUNC   = 4'b0111;                           // ~rs1 & CSR[csr]
                        end   
                        
                        default: begin  end
                    endcase                                  
                end
                           
            endcase
        end
    end
endmodule
