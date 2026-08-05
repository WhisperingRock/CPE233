`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/05/2026 08:23:37 AM
// Design Name: 
// Module Name: BranchAddrGen_tb
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


module BranchAddrGen_tb();

    // ~~~~ init local vars ~~~~
    logic[31:0] rs, i, j, b, pc;    // input
    logic[31:0] jal, jalr, bran;    // output
    
    logic[31:0] testcase;           // testing var
    
    // ~~~~ instances ~~~~
    BranchAddrGen UUT
    (
        // ~~ inputs ~~
        .RS1(rs), 
        .I_TYPE(i),
        .J_TYPE(j),
        .B_TYPE(b),
        .PC(pc),
        // ~~ outputs ~~
        .JAL(jal),              // = pc + j
        .JALR(jalr),            // = rs1 + i
        .BRANCH(bran)           // = pc + b
    );
    
    // ~~~~ testing ~~~~
    initial
    begin
    
        // ~~ TC1 : all zero ~~
        #5;
        rs = 32'h0000_0000;
        i = 32'h0000_0000;
        j = 32'h0000_0000;
        b = 32'h0000_0000;
        pc = 32'h0000_0000;
        testcase = 1;
        #5;
        $display("TC%d:", testcase);
        assert(jalr === 32'h0000_0000) else $error("JALR failed");      // = rs + i
        assert(jal === 32'h0000_0000) else $error("JAL failed");        // = pc + j
        assert(bran === 32'h0000_0000) else $error("BRANCH failed");    // = pc + b
        
        
        // ~~ TC2 : only types ~~
        #5;
        rs = 32'h0000_0000;
        i = 32'h0101_0101;
        j = 32'hF0F0_A050;
        b = 32'h1234_5678;
        pc = 32'h0000_0000;
        testcase++;
        #5;
        $display("TC%d:", testcase);
        assert(jalr === 32'h0101_0101) else $error("JALR failed");      // = rs + i
        assert(jal === 32'hF0F0_A050) else $error("JAL failed");        // = pc + j
        assert(bran === 32'h1234_5678) else $error("BRANCH failed");    // = pc + b
        
        
        // ~~ TC3 : only pc ~~
        #5;
        rs = 32'h0000_0000;
        i = 32'h0000_0000;
        j = 32'h0000_0000;
        b = 32'h0000_0000;
        pc = 32'h5EC3_25AF;
        testcase++;
        #5;
        $display("TC%d:", testcase);
        assert(jalr === 32'h0000_0000) else $error("JALR failed");      // = rs + i
        assert(jal === 32'h5EC3_25AF) else $error("JAL failed");        // = pc + j
        assert(bran === 32'h5EC3_25AF) else $error("BRANCH failed");    // = pc + b
        
        
        
        // ~~ TC4 : only rs ~~
        #5;
        rs = 32'h9876_6789;
        i = 32'h0000_0000;
        j = 32'h0000_0000;
        b = 32'h0000_0000;
        pc = 32'h0000_0000;
        testcase++;
        #5;
        $display("TC%d:", testcase);
        assert(jalr === 32'h9876_6789) else $error("JALR failed");      // = rs + i
        assert(jal === 32'h0000_0000) else $error("JAL failed");        // = pc + j
        assert(bran === 32'h0000_0000) else $error("BRANCH failed");    // = pc + b
        
        
        
        // ~~ TC5 : rollover + ceiling 1 ~~
        #5;
        rs = 32'hFFFF_FFFE;
        i = 32'h0000_0001;
        j = 32'h0000_0001;
        b = 32'h0000_0001;
        pc = 32'hFFFF_FFFF;
        testcase++;
        #5;
        $display("TC%d:", testcase);
        assert(jalr === 32'hFFFF_FFFF) else $error("JALR failed");      // = rs + i
        assert(jal === 32'h0000_0000) else $error("JAL failed");        // = pc + j
        assert(bran === 32'h0000_0000) else $error("BRANCH failed");    // = pc + b
        
        
        // ~~ TC6 : rollover + ceiling 2 ~~
        #5;
        rs = 32'h0000_0002;
        i = 32'hFFFF_FFFE;
        j = 32'hFFFF_FFFF;
        b = 32'hFFFF_FFFE;
        pc = 32'h0000_0003;
        testcase++;
        #5;
        $display("TC%d:", testcase);
        assert(jalr === 32'h0000_0000) else $error("JALR failed");      // = rs + i
        assert(jal === 32'h0000_0002) else $error("JAL failed");        // = pc + j
        assert(bran === 32'h0000_0001) else $error("BRANCH failed");    // = pc + b

        
    end

endmodule
