`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: WhisperingRock
// 
// Create Date: 08/24/2026 12:36:46 PM
// Design Name: 
// Module Name: ControlStatusRegister
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Special purpose registers 
//                  + logic to save PC
//                  + disable interrupts during interrupt 
// 
//                  The 7th (and sys) type of instruction
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ControlStatusRegister(
    input logic                   CLK,
    input logic                   RST,            // reset
    input logic                   INTR_TAKEN,     // request : go into interrupt
    input logic                   INTR_RET,       // request : return from ISR subroutine
    input logic                   WR_EN,          // request : overwrite contents in csr[ADDR]
    input logic [11:0]            ADDR,           // requested register addresses
    input logic [31:0]            PC,             // program counter
    input logic [31:0]            WD,             // data to overwrite csr[ADDR]
    output logic                  MSTATUS_MIE,    // Machine Interrupt Status Reg - Machine Interrupt Enable
    output logic [31:0]           MTVEC,          // Machine Trap Vector : instr for PC for particular ISR
    output logic [31:0]           MEPC,           // Machine Exception PC : stores/restores PC around interrupt  
    output logic [31:0]           RD              // data contents of csr[ADDR]
    );

    // ~~~~ local allocs, params, and wires ~~~~
    
    // DONT DO THIS! THIS REGISTER IS SPARSE AND IS GOING TO LARGELY REMAIN THAT WAY
    //logic [31:0]            csr [0:4095];
    
    logic [31:0]            mstatus;
    localparam logic [11:0] mstatus_addr        = 12'h300;
    localparam int          mstatus_mie_bit     = 3;
    localparam int          mstatus_mpie_bit    = 7;                  
    
    logic [31:0]            mtvec;                 
    localparam logic [11:0] mtvec_addr          = 12'h305;                
                     
    logic [31:0]            mepc;
    localparam logic [11:0] mepc_addr           = 12'h341;                                
    
    

    // ~~~~ initial conditions ~~~~
    initial begin
        mstatus                   = 32'h0000_0000;        // disable interrupts by default
        mtvec                     = 32'h0000_0000;        // clear intr vecter
        mepc                      = 32'h0000_0000;        // clear PC
    end
    
    
    // ~~~~ combinational logic ~~
    always_comb begin
        
        // ~~ assign port outputs ~~
        MSTATUS_MIE = mstatus[mstatus_mie_bit];
        MTVEC       = mtvec;
        MEPC        = mepc;
    
        case(ADDR)
            mstatus_addr:   begin RD = mstatus; end
            
            mtvec_addr:     begin RD = mtvec; end
            
            mepc_addr:      begin RD = mepc; end
            
            default:        begin RD = 32'hXXXX_XXXX; end
        endcase
    end
    

    
    // ~~~~ synch logic ~~~~
    always_ff @(posedge CLK or posedge RST) begin
        
        // ~~ priority 0 : reset clears and disables intrr ~~ 
        if(RST == 1'b1) begin
            mstatus                       <= 32'h0000_0000;        // disable interrupts by default
            mtvec                         <= 32'h0000_0000;        // clear intr vecter
            mepc                          <= 32'h0000_0000;        // clear PC
        end
        
        // ~~ priority 1: intrr requested ~~
        else if(INTR_TAKEN == 1'b1) begin
             mepc                         <= PC;                        // save non-intrr PC
             mstatus[mstatus_mpie_bit]    <= mstatus[mstatus_mie_bit];  // store intr setting
             mstatus[mstatus_mie_bit]     <= 1'b0;                      // disable other intr during this intr
        end
        
       
        // ~~ priority 2 : return from intrr requested ~~
        else if(INTR_RET == 1'b1) begin
            mstatus[mstatus_mie_bit]      <= mstatus[mstatus_mpie_bit]; // restore intrr setting
            mstatus[mstatus_mpie_bit]     <= 1'b0;                      // clear MPIE for sanitization
        end
        
        // ~~ priority 3 : update csr register contents ~~
        else if(WR_EN == 1'b1) begin
            case(ADDR)
                mstatus_addr:   begin mstatus <= WD; end                // TODO : mask this guy??
                
                mtvec_addr:     begin mtvec <= WD; end
                
                mepc_addr:      begin mepc <= WD; end
                
                default:        begin end // do nothing
            endcase
        end
        
    end
    
    
endmodule
