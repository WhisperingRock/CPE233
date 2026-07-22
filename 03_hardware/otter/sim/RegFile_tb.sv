`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: WhisperingRock
// 
// Create Date: 07/21/2026 03:42:37 PM
// Design Name: 
// Module Name: RegFile_tb
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

module RegFile_tb();

  // ~~~~ init local vars ~~~~
    logic enable, clk;                  // input
    logic[4:0] addr1, addr2, w_addr;    // input
    logic[31:0] w_val;                  // input
    logic[31:0] out1, out2;             // output

    
    // ~~~~ instances ~~~~
    RegFile UUT(
        .EN(enable),
        .CLK(clk),
        .ADR1(addr1),
        .ADR2(addr2),    
        .W_ADR(w_addr),          
        .W_DATA(w_val),              
        .RS1(out1), 
        .RS2(out2)           
    );
    
    // ~~ predefined tasks ~~
    task fill_ram(input int bias);
        enable = 1;
        for(int i = 0; i < N_REGS; i++)
        begin
            w_addr = i;
            w_val = i + bias;
            #10;
        end
        enable = 0;
    endtask
    
     // ~~ action : CLK (10ns period) ~~
    always begin
        #5;
        clk <= !clk;
    end
    
    // ~~~~ action : data ~~~~
    initial begin
           
        // ~~ init ~~
        clk = 1; enable = 0; 
        addr1 = 0; addr2 = 0;
        w_addr = 0; w_val = 0;
        #10;
        fill_ram(0);
        #10
        
        // ~~ TC1 : same asynch fetch ~~       
        for(int i = 0; i < 32; i++)
        begin
            addr1 = i; 
            addr2 = i;
            #10;
            assert(out1 === i) else $error("TC1: rs1 failed");
            assert(out2 === i) else $error("TC1: rs2 failed");
        end
        
        // ~~ TC2 : prevent write to x0 ~~
        addr1 = 0; enable = 1; 
        #10;
        for(int i = 0; i < 100; i++)
        begin
            w_addr = 0; 
            w_val = $random();
            #10;
            assert(out1 === 0) else $error("TC2: x0 prevent failed");
        end
        
        // ~~ TC3 : write not enabled on same addr ~~
        fill_ram(0);                                // cheap sanitizer
        addr1 = 1; addr2 = 1; w_addr = 1;           // vals should be 1 in reg
        enable = 0; 
        #10;
        for(int i = 0; i < 100; i++)
        begin
            w_val = $random();
            #10;
            assert(out1 === 1) else $error("TC3: write prevent failed");
            assert(out2 === 1) else $error("TC3: write prevent failed");
        end
        
        
        // ~~ TC4 : reading the register being written to ~~
        addr1 = 14; addr2 = 14; w_addr = 14;
        enable = 1; 
        #10;
        for(int i = 0; i < 100; i++)
        begin
            w_val = $random();
            #10;
            assert(out1 === w_val) else $error("TC4: r/w failed");
            assert(out2 === w_val) else $error("TC4: r/w failed");
        end
        
        
    end

endmodule
