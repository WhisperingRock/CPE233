`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/05/2026 09:27:35 AM
// Design Name: 
// Module Name: Memory_tb
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


module Memory_tb();

// ~~~~ init local vars ~~~~
    
    // ~~ inputs ~~
    logic           clk;
    
    logic           read_en1;
    logic[13:0]     maddr1;
    
    logic           read_en2, write_en2, sign2;
    logic[1:0]      size2;
    logic[31:0]     maddr2, din2;

    logic[31:0]     io_in; 
    
    // ~~ outputs ~~
    logic           io_wen;
    logic[31:0]     dout1, dout2;
    
    // ~~ testing ~~
    logic[31:0] testcase;     
    
          
    
// ~~~~ instances ~~~~
    Memory UUT
    (
        // ~~ inputs ~~
        .MEM_CLK(clk),
        .MEM_RDEN1(read_en1),  
        .MEM_RDEN2(read_en2),  
        .MEM_WE2(write_en2),    
        .MEM_ADDR1(maddr1),  
        .MEM_ADDR2(maddr2),  
        .MEM_DIN2(din2),   
        .MEM_SIZE(size2),   
        .MEM_SIGN(sign2),   
        .IO_IN(io_in),      
	   // ~~ outputs ~~
        .IO_WR(io_sen),      
        .MEM_DOUT1(dout1),  
        .MEM_DOUT2(dout2)   
    );
    
// ~~ Cadence : CLK (10ns period) ~~
    always 
    begin
        #5;
        clk <= !clk;
    end
    
// ~~ Testing ~~
    initial
    begin
    
        clk = 0; 
    
        // ~~ TC1 : todo ~~
        #5;
        
        testcase = 1;
        #5;
        $display("TC%d:", testcase);
        assert() else $error("");
    
    end
    
    
endmodule
