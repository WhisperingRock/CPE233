`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: WhisperingRock 
// 
// Create Date: 07/21/2026 03:41:49 PM
// Design Name: 
// Module Name: RegFile
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//              A register file is a block of RAM, not ROM,
//              that contains the values of all 32 32-bit
//              registers x0:x31, with x0 held constant to 
//              zero.
// 
//              This register is a dual asynch fetch s.t.
//              the values at ADR1 and ADR2 are fetched 
//              and forwarded immediately to RS1, RS2.
//
//              This register is single synch write s.t.
//              if en is high, W_DATA will overwrite the 
//              value in W_ADR (excluding x0)
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//     
//////////////////////////////////////////////////////////////////////////////////
parameter BITWIDTH      = 32;

parameter N_REGS        = 32;
parameter REG_BUSWIDTH  = 5;

module RegFile(
    input EN, CLK,
    input[REG_BUSWIDTH-1:0] ADR1, ADR2,     // asynch fetch addr(s)
    input[REG_BUSWIDTH-1:0] W_ADR,          // synch write addr
    input[BITWIDTH-1:0] W_DATA,             // synch write value 
    output[BITWIDTH-1:0] RS1, RS2           // asynch fetch'd values
    );
    
    
    // ~~~~ alloc mem ~~~~
    logic [BITWIDTH-1:0] ram [0:N_REGS-1];   // memory uses big-endian
    
    // ~~~~ init mem ~~~~
    initial
    begin
        for(int i = 0; i < N_REGS; i++)
        begin
            ram[i] = 0;
        end
    end
    
    // ~~~~ asynch fetch ~~~~
    assign RS1 = ram[ADR1];
    assign RS2 = ram[ADR2];


    // ~~~~ synch write ~~~~
    always_ff@(posedge CLK)         // changes on clk demand sequental logic (use nonblocking)
    begin
        if(EN & W_ADR != 0)
        begin 
            ram[W_ADR] <= W_DATA;
        end
    end

endmodule
