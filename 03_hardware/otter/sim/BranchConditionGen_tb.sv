`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/04/2026 10:49:22 AM
// Design Name: 
// Module Name: BranchConditionGen_tb
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


module BranchConditionGen_tb();

    // ~~~~ init local vars ~~~~
    logic[31:0] a, b;
    logic       eq, lts, ltu;
    
    logic[31:0] testcase;       // testing var
    
    // ~~~~ instances ~~~~
    BranchConditionGen UUT
    (
        .RS1(a),
        .RS2(b),
        .BR_EQ(eq),
        .BR_LT(lts),
        .BR_LTU(ltu)
    );
    
    // ~~~~ testing ~~~~
    initial
    begin
    
        // ~~ TC1 : equal are not less (simple) ~~
        #5;
        a = 32'h1234_5678;
        b = 32'h1234_5678;
        testcase = 1;
        #5;
        $display("TC%d:", testcase);
        assert(eq === 1'b1) else $error("Equality failed");
        assert(lts === 1'b0) else $error("LessThan Signed failed");
        assert(ltu === 1'b0) else $error("LessThan Unsigned failed");
        
        
        // ~~ TC2 : signed vs unsigned (simple) ~~
        #5;
        a = 32'hA50F_96C3; // is less than b if signed
        b = 32'h5AF0_693C;
        testcase++;
        #5;
        $display("TC%d:", testcase);
        assert(eq === 1'b0) else $error("Equality failed");
        assert(lts === 1'b1) else $error("LessThan Signed failed");
        assert(ltu === 1'b0) else $error("LessThan Unsigned failed");
        
        
        // ~~ TC3 : equal are not less (ceiling) ~~
        #5;
        a = 32'hFFFF_FFFF;
        b = 32'hFFFF_FFFF;
        testcase++;
        #5;
        $display("TC%d:", testcase);
        assert(eq === 1'b1) else $error("Equality failed");
        assert(lts === 1'b0) else $error("LessThan Signed failed");
        assert(ltu === 1'b0) else $error("LessThan Unsigned failed");
        
        
        // ~~ TC4 : equal are not less (floor) ~~
        #5;
        a = 32'h0000_0000;
        b = 32'h0000_0000;
        testcase++;
        #5;
        $display("TC%d:", testcase);
        assert(eq === 1'b1) else $error("Equality failed");
        assert(lts === 1'b0) else $error("LessThan Signed failed");
        assert(ltu === 1'b0) else $error("LessThan Unsigned failed");
        
        
        // ~~ TC5 : signed vs unsigned (simple reversed) ~~
        #5;
        a = 32'h5AF0_693C;
        b = 32'hA50F_96C3;
        testcase++;
        #5;
        $display("TC%d:", testcase);
        assert(eq === 1'b0) else $error("Equality failed");
        assert(lts === 1'b0) else $error("LessThan Signed failed");
        assert(ltu === 1'b1) else $error("LessThan Unsigned failed");
        
        
        // ~~ TC6 : signed vs unsigned (floor and ceiling 1) ~~
        #5;
        a = 32'h0000_0000;
        b = 32'hFFFF_FFFF;
        testcase++;
        #5;
        $display("TC%d:", testcase);
        assert(eq === 1'b0) else $error("Equality failed");
        assert(lts === 1'b0) else $error("LessThan Signed failed");
        assert(ltu === 1'b1) else $error("LessThan Unsigned failed");
        
        
        // ~~ TC7 : signed vs unsigned (floor and ceiling 2) ~~
        #5;
        a = 32'hFFFF_FFFF;
        b = 32'h0000_0000;
        testcase++;
        #5;
        $display("TC%d:", testcase);
        assert(eq === 1'b0) else $error("Equality failed");
        assert(lts === 1'b1) else $error("LessThan Signed failed");
        assert(ltu === 1'b0) else $error("LessThan Unsigned failed");
    end

endmodule
