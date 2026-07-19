`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2026 06:36:03 PM
// Design Name: 
// Module Name: PC_Reg_tb
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


module PC_Reg_tb();

    // ~~ local variables ~~
    logic clk, reset, write;
    logic[31:0] din, dout;
    logic[31:0] answer; 
    
        
    // ~~ high-level module instances (and hooks) ~~
    PC_Reg UUT (
        .CLK(clk),                      
        .PC_RST(reset),                   
        .PC_WE(write),                    
        .PC_DIN(din),             
        .PC_COUNT(dout)    
    );
    
    // ~~ action : CLK (10ns period) ~~
    always begin
        #5;
        clk <= !clk;
    end
    
    // ~~ action : Data ~~
    initial begin
    
        // ~ init ~
        clk = 1; reset = 0; write = 0;
        reset = 1; #10;                     // zero out register
        
        // ~ test cases ~
        answer = 32'hDEAD_BEEF;
        din = answer;
        
        // ~ TC1 : write ~
        reset = 0; #10;
        assert(dout === 0) else $error("TC1: init failed");
        write = 1; #10;
        assert(dout === answer) else $error("TC1: write failed");
        
        // ~ TC2: reset after write ~
        reset = 1; #10;
        assert(dout === 0) else $error("TC2: reset failed");
        
        // ~ TC3: reset priority over write ~
        write = 1; reset = 1; #10;
        assert(dout === 0) else $error("TC3: reset failed");
        
        
        // ~ TC4 : write within range ~ 
        write = 1; reset = 0; #10;
        answer = 32'h0246_8ACE;
        for (int i = 0; i < 8; i++) begin
            din = answer; #10;
            assert(dout === answer) else $error("TC4: write failed");
            answer = answer << 4;
        end
        
        // ~ TC5 : Rollover ~
        din = 32'hFFFF_FFFF; #10;
        assert(dout === din) else $error("TC5: write failed");
        din = din + 1; #10;
        assert(dout === 0) else $error("TC5: rollover failed");
        
        
        
        
    end


endmodule
