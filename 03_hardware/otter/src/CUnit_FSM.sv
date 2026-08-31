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
    input logic         INTRR,          // high-level input : interrupt 
    input logic [6:0]   OPCODE,         // shared with decoder + regfile
    input logic [2:0]   FUNC3,          //
     
    output logic        PC_WRITE,       // update PC
    output logic        REG_WRITE,      // update dest reg value
    output logic        MEM_RDEN1,      // fetch value at addr1
    output logic        MEM_RDEN2,      // fetch value at addr2 (occurs after update if enacted)
    output logic        MEM_WE2,        // update value at addr2
    output logic        RESET,          // program counter reset
    
    output logic        CSR_WE,         // update csr[ADDR] = data
    output logic        INT_TAKEN,      // interrupt desired
    output logic        MRET_EXEC       // interrupt return desired
    );
    
    
    // ~~~~ local vars ~~~~
    typedef enum logic [2:0] {INIT, FETCH, EXEC, WRITEBACK, INTRPT} e_state;
    e_state curr_state, next_state;
    
    typedef enum logic {LOAD, LOAD_BAR}                             e_lsignal;
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
    
        // ~~ defaults ~~
        RESET       = 1'b0;            
        PC_WRITE    = 1'b0;              
        REG_WRITE   = 1'b0;
        MEM_WE2     = 1'b0;
        MEM_RDEN1   = 1'b0;            
        MEM_RDEN2   = 1'b0;
        CSR_WE      = 1'b0;       
        INT_TAKEN   = 1'b0;   
        MRET_EXEC   = 1'b0;
        
        next_state  = INIT;
        next_signal = LOAD;   
        
        case(curr_state)
       
            // ~ INIT ~
            //      - Defaults all sigals
            //      - Entry point for reset
            INIT: begin
                RESET       = 1'b1;            // reset PC
                
                next_state  = FETCH;
                next_signal = LOAD; 
            end
           
           
            // ~ FETCH ~
            //      - Grabs instruction
            //      - Set memory unit to grab instruction
            FETCH: begin
                // ~~ Repeat FETCH in extra cycle ~~
                if(curr_signal == LOAD_BAR) begin
                    MEM_RDEN2   = 1'b1;
                    next_signal = LOAD_BAR;
                end
                // ~~ else, standard FETCH cycle ~~
                else begin
                    MEM_RDEN1   = 1'b1;
                    next_signal = LOAD;
                end
                
                next_state = EXEC;
            end
           
            // ~ EXEC ~
            //      - Set all control sigs to read memory
            //      - may direct to FETCH for lengthy instr cycles
            //      - OPCODE dictates what is toggled here
            EXEC:begin 
              
                next_signal     = LOAD; 
                next_state      = WRITEBACK;          
                
                if(OPCODE == 7'b000_0011 && curr_signal == LOAD) begin  // load needs an extra cycle
                    if(INTRR == 1'b1) begin next_state  = INTRPT; end   // take intrr rather than do extra instr
                    
                    else begin                                          // perform the extra cycle (no intrr)
                        next_signal = LOAD_BAR;
                        next_state  = FETCH; 
                    end
                end
                
                // mret discovered
                if(OPCODE == 7'b1110011 && FUNC3 == 3'b000) begin 
                    MRET_EXEC = 1'b1;  
                end
                
            end
           
           
           
           
            // ~ WRITEBACK ~
            //      - Save contents to reg or memory
            //      - update pc
            WRITEBACK: begin
            
                // common default
                PC_WRITE    = 1'b1;
                REG_WRITE   = 1'b1;
                
                // special cases
                case(OPCODE)
                    // store (35)
                    7'b0100011: begin
                        REG_WRITE   = 1'b0;  
                        MEM_WE2     = 1'b1; 
                    end     
    
                    // branch (99)
                    7'b1100011: begin REG_WRITE   = 1'b0; end
                    
                    // csr interrupt (115)
                    7'b1110011: begin 
                        if(FUNC3 == 3'b000) begin REG_WRITE = 1'b0; end    // mret  
                        else                begin CSR_WE = 1'b1; end       // csrXX
                    end
                endcase
                
                next_state = (INTRR == 1'b1)? INTRPT : FETCH;
                next_signal= LOAD;
                
            end
            
            // ~ INTRPT ~
            //      - Signal to CU decoder and CSR that an intrr is occuring
            //      - Load the ISR address into the PC
            INTRPT: begin
                INT_TAKEN   = 1'b1;                 // signal other mods of interrupt taken
                PC_WRITE    = 1'b1;                 // update PC with MVTEC (pray to avoid a race condition) 
                
                next_state  = FETCH;
                next_signal = LOAD;
            end
            
        endcase

    end
    
endmodule
