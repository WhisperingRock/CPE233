`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2026 11:23:25 AM
// Design Name: 
// Module Name: Otter_MCU_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: Ensure mem file is using sample code from hw6
// 
//////////////////////////////////////////////////////////////////////////////////


module Otter_MCU_tb();

    // ~~~~ local vars ~~~~
    
    // ~~ inputs ~~
    logic           clk; 
    logic           rst; 
    logic           intrr;
    logic [31:0]    din;  
    
    // ~~ outputs ~~
    logic           write; 
    logic [31:0]    rs2; 
    logic [31:0]    alu_result; 
    
    // ~~ testing ~~
    int testcase; 
    typedef enum {LUI, ADDI, SLLI, SLT, XOR_, BEQ} e_instr;
    e_instr curr_instr;  
    
    // ~~~~ instances ~~~~
    Otter_MCU UUT (
    .IOBUS_IN(din),             // 32'b I 
    .RST(rst),                  // 1'b I
    .INTRR(intrr),              // 1'b I
    .CLK(clk),                  // 1'b I
    .IOBUS_OUT(rs2),            // 32'b O
    .IOBUS_ADDR(alu_result),    // 32'b O
    .IOBUS_WR(write)            // 1'b O      // 0 for non-MMIO
    );
    
    // ~~ action : CLK (10ns period) ~~
    always 
    begin
        #5;
        clk <= !clk;
    end
    
    initial begin
           
        // ~~ init ~~
        testcase = 0; 
        clk =       1'b1; 
        rst =       1'b0;
        intrr =     1'b0;
        din =       32'h0000_0000; 
 
        // ~~ TC1 : 4x walkthough ~~
        testcase++; 
        #10;                // INIT complete
        testall();

        // ~~ TC2 : reset aand repeat TC1 ~~
        testcase++;
        rst =       1'b1;
        #30;
        rst =       1'b0;   // INIT already complete here              
        testall();
    end
        
    task testall();
        for(int i = 0; i < 5; i++) begin
            $display("%d", i); 
        
            // ~~ instr 1 : lui ~~
            $display("lui"); curr_instr = LUI; 
            #10;             // FETCH complete
            #10;             // EXEC complete
            assert(alu_result === 32'hAA05_5000)   else $error("ALU_RESULT failed");
            #10;             // WRITEBACK complete
            
            // ~~ instr 2 : addi ~~
            $display("addi"); curr_instr = ADDI;
            #10;             // FETCH complete
            #10;             // EXEC complete
            assert(alu_result === 32'hAA05_5765)    else $error("ALU_RESULT failed");
            assert(rs2 === 32'hAA05_5000)           else $error("RS2 failed");
            #10;             // WRITEBACK complete
            
            // ~~ instr 3 : slli ~~
            $display("slli"); curr_instr = SLLI;
            #10;             // FETCH complete
            #10;             // EXEC complete
            assert(alu_result === 32'h502A_BB28)    else $error("ALU_RESULT failed");
            #10;             // WRITEBACK complete
            
            // ~~ instr 4 : slt ~~
            $display("slt"); curr_instr = SLT;
            #10;             // FETCH complete
            #10;             // EXEC complete
            assert(alu_result === 32'h0000_0001)    else $error("ALU_RESULT failed");
            assert(rs2 === 32'hAA05_5765)           else $error("RS2 failed");
            #10;             // WRITEBACK complete
            
            // ~~ instr 5 : xor ~~
            $display("xor"); curr_instr = XOR_;
            #10;             // FETCH complete
            #10;             // EXEC complete
            assert(alu_result === 32'hFA2F_EC4D)    else $error("ALU_RESULT failed");
            assert(rs2 === 32'h502A_BB28)           else $error("RS2 failed");
            #10;             // WRITEBACK complete
            
            // ~~ instr 6 : beq ~~
            $display("beq"); curr_instr = BEQ;
            #10;             // FETCH complete
            #10;             // EXEC complete
            assert(rs2 === 32'h0000_0000)           else $error("RS2 failed");
            #10;             // WRITEBACK complete
        end
    endtask    
    

endmodule
