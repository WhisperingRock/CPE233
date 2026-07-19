`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/17/2026 04:26:27 PM
// Design Name: 
// Module Name: Mux_6N_tb
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


module Mux_6N_tb();

    // ~~ local variables ~~
    logic CLK;
    logic[31:0]  d0, d1, d2, d3, d4, d5;
    logic[3:0]                      sel;
    logic[31:0]                     out;
    
        
    // ~~ high-level module instances (and hooks) ~~
    Mux_6N #(32) UUT (
        .D0(d0),
        .D1(d1),
        .D2(d2),
        .D3(d3),
        .D4(d4),
        .D5(d5),
        .S(sel),
        .Y(out)
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
        d0 = 32'h0000_0000;
        d1 = 32'h1234_0000;
        d2 = 32'h0000_5678;
        d3 = 32'h1111_1111;
        d4 = 32'hFFFF_FFFF;
        d5 = 32'hDEAD_BEEF;
        
        // ~ selector test ~
        sel = 0; #10
        assert(out === d0) else $error("sel = 0 failed");
        
        sel = 1; #10
        assert(out === d1) else $error("sel = 1 failed");
        
        sel = 2; #10
        assert(out === d2) else $error("sel = 2 failed");
        
        sel = 3; #10
        assert(out === d3) else $error("sel = 3 failed");
        
        sel = 4; #10
        assert(out === d4) else $error("sel = 4 failed");
        
        sel = 5; #10
        assert(out === d5) else $error("sel = 5 failed");
        
        sel = 0; #10
        assert(out === d0) else $error("sel = 0 failed");
        
        sel = 2; #10
        assert(out === d2) else $error("sel = 2 failed");
        
        sel = 0; #10
        assert(out === d0) else $error("sel = 0 failed");
        
        sel = 4; #10
        assert(out === d4) else $error("sel = 4 failed");
        
        // ~ edge case : input changes ~
        sel = 3; #10
        assert(out === d3) else $error("sel = 3 failed");
        
        d3 = 32'hF000_0000; #10
        assert(out ===  32'hF000_0000) else $error("h7 failed");
        
        d3 = 32'h0F00_0000; #10
        assert(out ===  32'h0F00_0000) else $error("h6 failed");
        
        d3 = 32'h00F0_0000; #10
        assert(out ===  32'h00F0_0000) else $error("h5 failed");
        
        d3 = 32'h000F_0000; #10
        assert(out ===  32'h000F_0000) else $error("h4 failed");
        
        d3 = 32'h0000_F000; #10
        assert(out ===  32'h0000_F000) else $error("h3 failed");
        
        d3 = 32'h0000_0F00; #10
        assert(out ===  32'h0000_0F00) else $error("h2 failed");
        
        d3 = 32'h0000_00F0; #10
        assert(out ===  32'h0000_00F0) else $error("h1 failed");
        
        d3 = 32'h0000_000F; #10
        assert(out ===  32'h0000_000F) else $error("h0 failed");
        
        // ~ default case ~ 
        sel = 6;
        while(sel < 15) begin
            #10;
            assert(out === (32'hFFFF_FFFF - 13)) else $error("default %d failed", sel);
            sel = sel + 1;
        end
        
    end


endmodule

