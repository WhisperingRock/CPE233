`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/15/2026 11:47:24 AM
// Design Name: 
// Module Name: CUnit_FSM
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


module CUnit_FSM(
    input logic         CLK,
    input logic         RST,            // high-level input : reset
    //input logic         INTRR,          // high-level input : interrupt 
    input logic [6:0]   OPCODE,         // shared with decoder + regfile
     
    output logic        PC_WRITE,       // update PC
    output logic        REG_WRITE,      // update dest reg value
    output logic        MEM_RDEN1,      // fetch value at addr1
    output logic        MEM_RDEN2,      // fetch value at addr2 (occurs after update if enacted)
    output logic        MEM_WE2,        // update value at addr2
    output logic        RESET           // program counter reset
    );
    
    
    // ~~~~ local vars ~~~~
    typedef enum logic [1:0] {INIT, FETCH, EXEC, WRITEBACK} e_state;
    e_state curr_state, next_state;
    
    typedef enum logic {LOAD, LOAD_BAR}                     e_lsignal;
    e_lsignal curr_signal, next_signal;

    logic start; 
 
    // ~~~~ initial conditions ~~~~
    initial
    begin
        start       = 1'b1;
    end
    
    // ~~~~ state engine ~~~~
    always_ff @(posedge CLK or posedge RST) begin
        if(RST == 1'b1 || start == 1'b1) begin
            curr_state      <= INIT;
            curr_signal     <= LOAD; 
            start       <= 1'b0; 
        end
        else begin 
            curr_state  <= next_state;
            curr_signal <= next_signal; 
        end
    end


    // ~~~~ state definitions ~~~~
    always_comb begin
        
       case(curr_state)
       
            // ~ INIT ~
            //      - Defaults all sigals
            //      - Entry point for reset
            INIT: begin
                RESET       = 1'b1;            // reset PC
                PC_WRITE    = 1'b0;              
                REG_WRITE   = 1'b0;
                MEM_WE2     = 1'b0;
                MEM_RDEN1   = 1'b0;            // Dont read current instr
                MEM_RDEN2   = 1'b0;
                
                next_state  = FETCH;
                next_signal = LOAD; 
            end
           
           
            // ~ FETCH ~
            //      - Grabs instruction
            //      - Set memory unit to grab instruction
            FETCH: begin
                RESET       = 1'b0;
                PC_WRITE    = 1'b0;            
                REG_WRITE   = 1'b0;    
                MEM_WE2     = 1'b0;
                
                // ~~ Repeat FETCH in extra cycle ~~
                if(curr_signal == LOAD_BAR) begin
                    MEM_RDEN1   = 1'b0;
                    MEM_RDEN2   = 1'b1;
                    next_signal = LOAD_BAR;
                end
                // ~~ else, standard FETCH cycle ~~
                else begin
                    MEM_RDEN1   = 1'b1;
                    MEM_RDEN2   = 1'b0;
                    next_signal = LOAD;
                end
                
                next_state = EXEC;
            end
           
            // ~ EXEC ~
            //      - Set all control sigs to read memory
            //      - may direct to FETCH for lengthy instr cycles
            //      - OPCODE dictates what is toggled here
            EXEC:begin             
                RESET       = 1'b0;
                PC_WRITE    = 1'b0;              
                REG_WRITE   = 1'b0;
                MEM_WE2     = 1'b0;
                MEM_RDEN1   = 1'b0;            
                MEM_RDEN2   = 1'b0;
                
                if(OPCODE == 7'b000_0011) begin         // load needs an extra cycle
                    if(curr_signal == LOAD) begin
                        next_signal = LOAD_BAR;
                        next_state  = FETCH; 
                    end
                    
                    else begin
                        next_signal = LOAD;
                        next_state  = WRITEBACK; 
                    end
                end
                
                else begin
                    next_signal     = LOAD; 
                    next_state      = WRITEBACK;
                end 
            end
           
           
           
           
            // ~ WRITEBACK ~
            //      - Save contents to reg or memory
            //      - update pc
            WRITEBACK: begin
                RESET       = 1'b0;
                PC_WRITE    = 1'b1;
                
                if(OPCODE == 7'b0100011) begin     // store (35)
                    REG_WRITE   = 1'b0;
                    MEM_WE2     = 1'b1;
                end
                
                else if(OPCODE == 7'b1100011) begin // branch (99)
                    REG_WRITE   = 1'b0;
                    MEM_WE2     = 1'b0;
                end
                
                else begin
                    REG_WRITE   = 1'b1;
                    MEM_WE2     = 1'b0;
                end
                    
                MEM_RDEN1   = 1'b0;            
                MEM_RDEN2   = 1'b0;
                
                next_state = FETCH;
                next_signal= LOAD;
                
            end
        endcase

    end
    
endmodule
