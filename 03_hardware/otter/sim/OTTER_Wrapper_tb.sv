`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2026 10:09:19 AM
// Design Name: 
// Module Name: OTTER_Wrapper_tb
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
//                          ----> pair with cpe233 hw8 given testcode
//////////////////////////////////////////////////////////////////////////////////


module OTTER_Wrapper_tb();

    // ~~~~ imports ~~~~
    import tb_utils_pkg::*;

    // ~~~~ local vars ~~~~
    // ~~ inputs ~~
    logic           clk; 
    logic           reset;
    logic           interrupt;
    logic [15:0]    switches;
    // ~~ outputs ~~
    logic [15:0]    leds;
    logic [7:0]     catho;
    logic [3:0]     ano; 
    
    // ~~ testing ~~
    testcase tc;
    logic [31:0] tnum;
    
    // ~~~~ module instances ~~~~
    OTTER_Wrapper UUT(
        .CLK(clk),              // 1'b I
        .BTNL(interrupt),       // 1'b I
        .BTNC(reset),           // 1'b I
        .SWITCHES(switches),    // 16'b I
        .LEDS(leds),            // 16'b O
        .CATHODES(catho),       // 8'b O
        .ANODES(ano)            // 4'b O
    );
    
    // ~~~~ heartbeat (10ns) ~~~~
    always begin
        #5;
        clk <= !clk;
    end
    
    // ~~~~ testing ~~~~
    initial begin
    
            // ~~ class instances ~~
            tc          = new();
            
            // ~~ defaults ~~
            clk         = 1'b1; 
            reset       = 1'b0;
            interrupt   = 1'b0; 
            switches    = 16'h01;               // mem file demands SW[0] high to write 1 to mie bit 
            #3000;                              // enough to start LOOP in asm
            
            
            // ~~ TC1 ~~
            tc.new_test("First Interrupt");
            tnum = tc.get_testnum();
                interrupt   = 1'b1;
                #500;      
                interrupt   = 1'b0;                 // OneShot and intrr actives on falling edge
                #2050;       
            tc.test_done();
            
            
            // ~~ TC2 ~~
            tc.new_test("Second Interrupt");
            tnum = tc.get_testnum();
                interrupt   = 1'b1;
                #500;      
                interrupt   = 1'b0;                 // OneShot and intrr actives on falling edge
                #2000;       
            tc.test_done();
    end

endmodule
