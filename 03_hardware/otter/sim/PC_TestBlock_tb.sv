`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/19/2026 09:39:05 AM
// Design Name: 
// Module Name: PC_TestBlock_tb
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


module PC_TestBlock_tb();

    // ~~~~ init local vars ~~~~
    logic reset, write, clk;
    logic[2:0] sel;
    logic[5:0][31:0] d;         // d[0] is unused b/c its p+4 on mux
    logic[31:0] pc, pc_plus_4;
    
    // ~~~~ instances ~~~~
    PC_TestBlock UUT(
        .PC_RST(reset),
        .PC_WE(write),
        .CLK(clk),
        .PC_SEL(sel),
        .JALR(d[1]),
        .BRANCH(d[2]),
        .JAL(d[3]),
        .MTVEC(d[4]),
        .MEPC(d[5]),
        .PC_COUNT(pc),
        .PC_PLUS_FOUR(pc_plus_4) 
    );
    
     // ~~ action : CLK (10ns period) ~~
    always begin
        #5;
        clk <= !clk;
    end
    
    // ~~~~ action : data ~~~~
    initial begin
           
        // ~~ init ~~
        clk = 1; reset = 0; write = 0; sel = 0;
        d[1] = 32'h1234_5678;
        d[2] = 32'hBAAC_4444;
        d[3] = 32'h0000_01A1;
        d[4] = 32'hBEEF_BEEF;
        d[5] = 32'hDEAD_DEAD;
        pc = 0; pc_plus_4 = 0;
        #10;
        
        // ~~ TC1 : sel all w/ write disabled ~~
        for (int i = 0; i < 16; i++) begin
            sel = i;
            #10;
            assert(pc === 0) else $error("TC1: sel failed (pc)");
            assert(pc_plus_4 === 4) else $error("TC1: sel failed (pc+4)");
        end
        
        
        
        // ~~ TC2 : sel all w/ write enabled ~~
        reset = 1; sel = 0; #10; reset = 0; #10;
        write = 1; #10; 
        
        assert(pc === 4) else $error("TC2: sel(0) failed on pc");       // Not zero b/c d[0] is 0+4 already
        assert(pc_plus_4 === 8) else $error("TC2: sel(0) failed on pc+4");
        
        for(int i=1; i < 6; i++) begin
            sel = i; #10;
            assert(pc === d[i]) else $error("TC2: failed on pc");
            assert(pc_plus_4 === (d[i]+4) ) else $error("TC2: failed on pc+4");
        end
        
            
        // ~~ TC3 : inc pc ~~
        reset = 1; sel = 0; #10; reset = 0;
        for(int i=1; i < 256; i++) begin
            #10;
            assert(pc === (4*i)) else $error("TC3: failed on pc");
            assert(pc_plus_4 === (4+(4*i)) ) else $error("TC3: failed on pc+4");
        end
        
        
        // ~ test conclusion ~
        reset = 1;
    end
endmodule
