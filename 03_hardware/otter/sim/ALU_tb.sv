`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/24/2026 10:13:51 PM
// Design Name: 
// Module Name: ALU_tb
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


module ALU_tb();

    // ~~~~ init local vars ~~~~
    logic[4:0] sel;
    logic[31:0] a, b, testcase;
    logic[31:0] result;
    
    // ~~~~ instances ~~~~
    ALU UUT
    (
        .ALU_FUN(sel), 
        .SRC_A(a),
        .SRC_B(b),
        .ALU_RESULT(result)
    );
    
    // ~~~~ testing ~~~~
    initial
    begin
    
        // ~~~~ ADD ~~~~
        sel = 4'b0000;
    
        // ~~ TC1 : ADD1 ~~
        #5;
        a = 32'hA50F_96C3;
        b = 32'h5AF0_693C;
        testcase = 1;
        #5;
        assert(result === 32'hFFFF_FFFF) else $error("TC1 : ADD failed");
        
        // ~~ TC2 : ADD2 ~~
        #5;
        a = 32'h8410_5F21;
        b = 32'h7B10_5FDE;
        testcase++;
        #5;
        assert(result === 32'hFF20_BEFF) else $error("TC2 : ADD failed");
        
        // ~~ TC3 : ADD3 ~~
        #5;
        a = 32'hFFFF_FFFF;
        b = 32'h0000_0001;
        testcase++;
        #5;
        assert(result === 32'h0000_0000) else $error("TC3 : ADD failed");
        
        
        
        // ~~~~ SUB ~~~~       
        sel = 4'b1000;
        
        // ~~ TC4 : SUB4 ~~
        #5;
        a = 32'h0000_0000;
        b = 32'h0000_0001;
        testcase++;
        #5;
        assert(result === 32'hFFFF_FFFF) else $error("TC4 : SUB failed");
        
        // ~~ TC5 : SUB5 ~~
        #5;
        a = 32'hAA80_6355;
        b = 32'h5501_62AA;
        testcase++;
        #5;
        assert(result === 32'h557F_00AB) else $error("TC5 : SUB failed");
        
        // ~~ TC6 : SUB6 ~~
        #5;
        a = 32'h5501_62AA;
        b = 32'hAA80_6355;
        testcase++;
        #5;
        assert(result === 32'hAA80_FF55) else $error("TC6 : SUB failed");
    
    
    
        // ~~~~ AND ~~~~       
        sel = 4'b0111;
        
        // ~~ TC7 : AND7 ~~
        #5;
        a = 32'hA55A_00FF;
        b = 32'h5A5A_FFFF;
        testcase++;
        #5;
        assert(result === 32'h005A_00FF) else $error("TC7 : AND failed");
        
        // ~~ TC8 : AND8 ~~
        #5;
        a = 32'hC3C3_F966;
        b = 32'hFF66_9F5A;
        testcase++;
        #5;
        assert(result === 32'hC342_9942) else $error("TC8 : AND failed");
        
        
        // ~~~~ OR ~~~~       
        sel = 4'b0110;
        
        // ~~ TC9 ~~
        #5;
        a = 32'h9A9A_C300;
        b = 32'h65A3_CC0F;
        testcase++;
        #5;
        assert(result === 32'hFFBB_CF0F) else $error("TC9 : OR failed");
        
        // ~~ TC10 ~~
        #5;
        a = 32'hC3C3_F966;
        b = 32'hFF66_9F5A;
        testcase++;
        #5;
        assert(result === 32'hFFE7_FF7E) else $error("TC10 : OR failed");
        
        
        // ~~~~ XOR ~~~~       
        sel = 4'b0100;
        
        // ~~ TC11 ~~
        #5;
        a = 32'hAA55_00FF;
        b = 32'h5AA5_0FF0;
        testcase++;
        #5;
        assert(result === 32'hF0F0_0F0F) else $error("TC11 : XOR failed");
        
        // ~~ TC12 ~~
        #5;
        a = 32'hA5A5_6C6C;
        b = 32'hFF00_C6FF;
        testcase++;
        #5;
        assert(result === 32'h5AA5_AA93) else $error("TC12 : XOR failed");
        
        
        
        // ~~~~ SRL ~~~~       
        sel = 4'b0101;
        
        // ~~ TC13 ~~
        #5;
        a = 32'h805A_6CF3;
        b = 32'h0000_0010;
        testcase++;
        #5;
        assert(result === 32'h0000_805A) else $error("TC13 : SRL failed");
        
        // ~~ TC14 ~~
        #5;
        a = 32'h705A_6CF3;
        b = 32'h0000_0005;
        testcase++;
        #5;
        assert(result === 32'h0382_D367) else $error("TC14 : SRL failed");
        
        // ~~ TC15 ~~
        #5;
        a = 32'h805A_6CF3;
        b = 32'h0000_0000;
        testcase++;
        #5;
        assert(result === 32'h805A_6CF3) else $error("TC15 : SRL failed");
        
        // ~~ TC16 ~~
        #5;
        a = 32'h805A_6CF3;
        b = 32'h0000_0100;
        testcase++;
        #5;
        assert(result === 32'h805A_6CF3) else $error("TC16 : SRL failed");
        
        
        
        // ~~~~ SLL ~~~~       
        sel = 4'b0001;
        
        // ~~ TC17 ~~
        #5;
        a = 32'h805A_6CF3;
        b = 32'h0000_0010;
        testcase++;
        #5;
        assert(result === 32'h6CF3_0000) else $error("TC17 : SLL failed");
        
        // ~~ TC18 ~~
        #5;
        a = 32'h805A_6CF3;
        b = 32'h0000_0005;
        testcase++;
        #5;
        assert(result === 32'h0B4D_9E60) else $error("TC18 : SLL failed");
        
        // ~~ TC19 ~~
        #5;
        a = 32'h805A_6CF3;
        b = 32'h0000_0100;
        testcase++;
        #5;
        assert(result === 32'h805A_6CF3) else $error("TC19 : SLL failed");
        
        
        
        // ~~~~ SRA ~~~~       
        sel = 4'b1101;
        
        // ~~ TC20 ~~
        #5;
        a = 32'h805A_6CF3;
        b = 32'h0000_0010;
        testcase++;
        #5;
        assert(result === 32'hFFFF_805A) else $error("TC20 : SRA failed");
        
        // ~~ TC21 ~~
        #5;
        a = 32'h705A_6CF3;
        b = 32'h0000_0005;
        testcase++;
        #5;
        assert(result === 32'h0382_D367) else $error("TC21 : SRA failed");
        
        // ~~ TC22 ~~
        #5;
        a = 32'h805A_6CF3;
        b = 32'h0000_0000;
        testcase++;
        #5;
        assert(result === 32'h805A_6CF3) else $error("TC22 : SRA failed");
        
        // ~~ TC23 ~~
        #5;
        a = 32'h805A_6CF3;
        b = 32'h0000_0100;
        testcase++;
        #5;
        assert(result === 32'h805A_6CF3) else $error("TC23 : SRA failed");
        
        
        
    
        // ~~~~ SLT ~~~~       
        sel = 4'b0010;
        
        // ~~ TC24 ~~
        #5;
        a = 32'h7FFF_FFFF;
        b = 32'h8000_0000;
        testcase++;
        #5;
        assert(result === 32'h0000_0000) else $error("TC24 : SLT failed");
        
        // ~~ TC25 ~~
        #5;
        a = 32'h8000_0000;
        b = 32'h0000_0001;
        testcase++;
        #5;
        assert(result === 32'h0000_0001) else $error("TC25 : SLT failed");
        
        // ~~ TC26 ~~
        #5;
        a = 32'h0000_0000;
        b = 32'h0000_0000;
        testcase++;
        #5;
        assert(result === 32'h0000_0000) else $error("TC26 : SLT failed");
        
        // ~~ TC27 ~~
        #5;
        a = 32'h5555_5555;
        b = 32'h5555_5555;
        testcase++;
        #5;
        assert(result === 32'h0000_0000) else $error("TC27 : SLT failed");
    
    
        // ~~~~ SLTU ~~~~       
        sel = 4'b0011;
        
        // ~~ TC28 ~~
        #5;
        a = 32'h7FFF_FFFF;
        b = 32'h8000_0000;
        testcase++;
        #5;
        assert(result === 32'h0000_0001) else $error("TC28 : SLTU failed");
        
        // ~~ TC29 ~~
        #5;
        a = 32'h8000_0000;
        b = 32'h0000_0001;
        testcase++;
        #5;
        assert(result === 32'h0000_0000) else $error("TC29 : SLTU failed");
        
        // ~~ TC30 ~~
        #5;
        a = 32'h0000_0000;
        b = 32'h0000_0000;
        testcase++;
        #5;
        assert(result === 32'h0000_0000) else $error("TC30 : SLTU failed");
        
        // ~~ TC31 ~~
        #5;
        a = 32'h55AA_55AA;
        b = 32'h55AA_55AA;
        testcase++;
        #5;
        assert(result === 32'h0000_0000) else $error("TC31 : SLTU failed");
    
    
        // ~~~~ LUI-COPY (MV?) ~~~~       
        sel = 4'b1001;
        
        // ~~ TC32 ~~
        #5;
        a = 32'h0123_4567;
        b = 32'h7654_3210;
        testcase++;
        #5;
        assert(result === 32'h0123_4567) else $error("TC32 : LUI-COPY failed");
        
        // ~~ TC33 ~~
        #5;
        a = 32'hFEDC_BA98;
        b = 32'h89AB_CDEF;
        testcase++;
        #5;
        assert(result === 32'hFEDC_BA98) else $error("TC33 : LUI-COPY failed");
    
    end

endmodule
