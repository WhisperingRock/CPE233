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
// 
//////////////////////////////////////////////////////////////////////////////////


module OTTER_Wrapper_tb();

    // ~~~~ local vars ~~~~
    // ~~ inputs ~~
    logic           clk; 
    logic           c_butt; 
    logic [15:0]    switches;
    // ~~ outputs ~~
    logic [15:0]    leds;
    logic [7:0]     catho;
    logic [3:0]     ano; 
    
    // ~~~~ module instances ~~~~
    OTTER_Wrapper UUT(
        .CLK(clk),              // 1'b I
        //.BTNL(),              // 1'b I
        .BTNC(c_butt),          // 1'b I
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
        clk =       1'b1; 
        c_butt =    1'b0;
        switches =  16'h0000; 
        #500000000000000; 
    end

endmodule
