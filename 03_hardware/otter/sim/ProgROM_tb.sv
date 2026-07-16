`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:        WhisperingRock
// 
// Create Date:     07/15/2026 06:17:46 PM
// Design Name: 
// Module Name:     TB_hw1_ProgROM
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:     Test bed simulation for HW1 : ProgROM
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

// ~~~~ sim identity ~~~~
module ProgROM_tb();

    // ~~ local variables ~~
    logic CLK;
    logic [31:0] PADDR, INSTR;
        
    // ~~ high-level module instances (and hooks) ~~
    ProgROM UUT (
        .PROG_CLK(CLK),
        .PROG_ADDR(PADDR),
        .INSTRUCT(INSTR)
    );
    
    // ~~ action : CLK (10ns period) ~~
    always begin
        #5;
        CLK <= !CLK;
    end
    
    // ~~ action : Data ~~
    initial begin
    
        // ~ init ~
        CLK = 0;
        PADDR = 32'h0000_0000;
        
        // ~ loop ~
        while(PADDR < 32'h0000_002C) begin
            PADDR = PADDR + 32'h0000_0004;  // blocking
            #10;                            //delay to prevent the crazy
        end
    end
    
endmodule
