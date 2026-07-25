`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/25/2026 11:41:08 AM
// Design Name: 
// Module Name: ImmedGen_tb
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


module ImmedGen_tb();

    // ~~~~ init local vars ~~~~
    logic[31:0] instr;
    logic[31:0] u, i, s, b, j;
    
    logic[31:0] testcase;   // testing var
    
    // ~~~~ instances ~~~~
    ImmedGen UUT
    (
        .INSTR(instr),
        .U_TYPE(u), 
        .I_TYPE(i), 
        .S_TYPE(s), 
        .J_TYPE(j), 
        .B_TYPE(b)
    );
    
    // ~~~~ testing ~~~~
    initial
    begin
    
        testcase = 1;
        
        // ~~ TC1 : all zero ~~
        #5;
        testcase++;
        instr = 0;
        #5;
        assert(u === 0) else $error("TC1 : U failed");
        assert(i === 0) else $error("TC1 : I failed");
        assert(s === 0) else $error("TC1 : S failed");
        assert(b === 0) else $error("TC1 : B failed");
        assert(j === 0) else $error("TC1 : J failed");
        
        
        // ~~ TC2 : all one ~~
        #5;
        testcase++;
        instr = 32'hFFFF_FFFF;
        #5;
        assert(u === 32'hFFFF_F000) else $error("TC2 : U failed");
        assert(i === 32'hFFFF_FFFF) else $error("TC2 : I failed");
        assert(s === 32'hFFFF_FFFF) else $error("TC2 : S failed");
        assert(b === 32'hFFFF_FFFE) else $error("TC2 : B failed");
        assert(j === 32'hFFFF_FFFE) else $error("TC2 : J failed");
        
        
        
        // ~~ TC3 : hex1 ~~
        #5;
        testcase++;
        instr = 32'h5A5A_5A5A;
        #5;
        assert(u === 32'h5A5A_5000) else $error("TC3 : U failed");
        assert(i === 32'h0000_05A5) else $error("TC3 : I failed");
        assert(s === 32'h0000_05B4) else $error("TC3 : S failed");
        assert(b === 32'h0000_05B4) else $error("TC3 : B failed");
        assert(j === 32'h000A_5DA4) else $error("TC3 : J failed");
        
        
        // ~~ TC4 : hex2 ~~
        #5;
        testcase++;
        instr = 32'hF0F0_F0F0;
        #5;
        assert(u === 32'hF0F0_F000) else $error("TC4 : U failed");
        assert(i === 32'hFFFF_FF0F) else $error("TC4 : I failed");
        assert(s === 32'hFFFF_FF01) else $error("TC4 : S failed");
        assert(b === 32'hFFFF_FF00) else $error("TC4 : B failed");
        assert(j === 32'hFFF0_FF0E) else $error("TC4 : J failed");
        
    
        // ~~ TC5 : hex3 ~~
        #5;
        testcase++;
        instr = 32'h3CA5_5A3C;
        #5;
        assert(u === 32'h3CA5_5000) else $error("TC5 : U failed");
        assert(i === 32'h0000_03CA) else $error("TC5 : I failed");
        assert(s === 32'h0000_03D4) else $error("TC5 : S failed");
        assert(b === 32'h0000_03D4) else $error("TC5 : B failed");
        assert(j === 32'h0005_53CA) else $error("TC5 : J failed");
        
    
    end
    
endmodule
