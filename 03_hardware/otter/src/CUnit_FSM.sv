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
    typedef enum {INIT, FETCH, EXEC, WRITEBACK, R} e_state;
    e_state curr_state, next_state;
    
    typedef enum{LOAD, LOAD_BAR, ERR}           e_lsignal;
    e_lsignal signal;

 
    // ~~~~ initial conditions ~~~~
    initial
    begin
        next_state      = INIT;
        curr_state      = R;  
        signal          = LOAD;
    end
    
    // ~~~~ state engine ~~~~
    always_ff @(posedge CLK or posedge RST) begin
        if(RST == 1'b1) begin   curr_state <= INIT; end
        else begin              curr_state <= next_state; end
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
                
                next_state = FETCH; 
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
                if(signal == LOAD_BAR) begin
                    MEM_RDEN1   = 1'b0;
                    MEM_RDEN2   = 1'b1;
                end
                // ~~ else, standard FETCH cycle ~~
                else begin
                    MEM_RDEN1   = 1'b1;
                    MEM_RDEN2   = 1'b0;
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
                    if(signal == LOAD) begin
                        signal = LOAD_BAR;
                        next_state = FETCH; 
                    end
                    
                    else if(signal == LOAD_BAR) begin
                        signal = LOAD;
                        next_state = WRITEBACK; 
                    end
                    
                    else begin
                        signal = ERR;
                        next_state = INIT;
                    end
                end
                
                else begin
                    signal      = LOAD; 
                    next_state  = WRITEBACK;
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
                
            end
        endcase

    end
    
endmodule
