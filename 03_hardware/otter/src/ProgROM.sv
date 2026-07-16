`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:        WhispringRock
// 
// Create Date:     07/15/2026 04:40:03 PM
// Design Name: 
// Module Name:     ProgROM
// Project Name: 
// Target Devices:  OTTER MCU on Basys3
// Description:     Generic 16384x32 ROM device

// 
// Dependencies:    prog_rom.mem file is a raw listing of 16384 32-bit hex values​
//                  prog_rom.mem file is automatically created by the OTTER​
//                  assembler / simulator from an assembly code program.​
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//  Recall :
//              `assign` describes combinational logic
//
//              `logic` : signal variable is boolean (1s, 0s) that
//                        supercede `reg` and shouldn't be used on 
//                        signals with multiple drivers
//
//              Endian : a[3:0] is little-endian s.t. LSB is smallest num (logic)
//                       a[0:3] is big-endian s.t. MSB is smallest num  (memory)
//
//              Continuous assigment statements (=) : "assign y1 = a & b;"
//                       Combinational logic what updates the right side
//                       whenever the left side changes. 
//                       BLOCKING ... use in (logic) and (test bench) 
//
//              Sequential elemements (<=) : used for CLK elements 
//////////////////////////////////////////////////////////////////////////////////


module ProgROM(
    input PROG_CLK,
    input [31:0] PROG_ADDR,
    output logic [31:0] INSTRUCT
    );

    logic [13:0] wordAddr;
    
    //convert byte addr to word addr
    assign wordAddr = PROG_ADDR[15:2];
    
    (* rom_style="{distributed | block}" *)
    (* ram_decomp="power" *) logic [31:0] rom [0:16383];
    
    // init the ROM with the otter_memory.mem file
     initial begin
        $readmemh("otter_memory_hw1.mem", rom, 0, 16383);
     end
     
     always_ff @ (posedge PROG_CLK) begin
        INSTRUCT <= rom[wordAddr];
     end

endmodule
