`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/24/2026 02:33:08 PM
// Design Name: 
// Module Name: ControlStatusRegister_tb
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
//
//      ASSUMPTIONS:
//          - CSR is not checking whether intr is enabled, only storing 
//              the mie bit. The CUFSM is gatekeeping the start of intr
//////////////////////////////////////////////////////////////////////////////////


module ControlStatusRegister_tb();

    // ~~~~ imports ~~~~
    import tb_utils_pkg::*; 


    // ~~~~ local wires/params ~~~~
    
    // ~~ inputs ~~
    logic           clk; 
    logic           reset; 
    logic           intr_taken;
    logic           intr_return;  
    logic           wr_en; 
    logic [11:0]    csr_addr; 
    logic [31:0]    pc; 
    logic [31:0]    wd_word;
    
    // ~~ outputs ~~
    logic           mie; 
    logic [31:0]    mtvec; 
    logic [31:0]    mepc; 
    logic [31:0]    rd_word; 
    
    // ~~ consts ~~
    localparam [11:0]   mstatus_addr        = 12'h300;
    const int           mstatus_mie_bit     = 3;
    const int           mie_word            = 32'h0000_0000 | (1'b1 << mstatus_mie_bit);
    const int           mstatus_mpie_bit    = 7;
    const int           mpie_word           = 32'h0000_0000 | (1'b1 << mstatus_mpie_bit);
    localparam [11:0]   mtvec_addr          = 12'h305;
    localparam [11:0]   mepc_addr           = 12'h341;
    
    // ~~ testing ~~
    testcase tc;
    logic [31:0] tnum;  
    
    // ~~~~ module instances ~~~~
    ControlStatusRegister UUT(
        .CLK(clk),                  // 1'b I
        .RST(reset),                // 1'b I
        .INTR_TAKEN(intr_taken),    // 1'b I
        .INTR_RET(intr_return),     // 1'b I
        .WR_EN(wr_en),              // 1'b I
        .ADDR(csr_addr),            // 12'b I
        .PC(pc),                    // 32'b I
        .WD(wd_word),               // 32'b I
        .MSTATUS_MIE(mie),          // 1'b O
        .MTVEC(mtvec),              // 32'b O
        .MEPC(mepc),                // 32'b O  
        .RD(rd_word)                // 32'b O
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
        clk         = 1'b0;
        reset       = 1'b0;
        intr_taken  = 1'b0;
        intr_return = 1'b0;  
        wr_en       = 1'b0; 
        csr_addr    = 12'h000; 
        pc          = 32'h0000_0000;
        wd_word     = 32'h0000_0000;
        #25;  
        
        // ~~ TC1 ~~
        tc.new_test("CSR initialized data");
        tnum = tc.get_testnum();     
            csr_addr = mstatus_addr;
            #8; 
            assert(rd_word === 32'h0000_0000)   else tc.err("MSTATUS reg was not init to zero");
            assert(mtvec === 32'h0000_0000)     else tc.err("MTVEC reg was not init to zero");
            assert(mepc === 32'h0000_0000)      else tc.err("MEPC reg was not init to zero");
            #2; 
        tc.test_done();
        
        
        // ~~ TC2 ~~
        tc.new_test("enter INTRPT state");
        tnum = tc.get_testnum();
        
            // enable intrr
            csr_addr    = mstatus_addr;
            wd_word     = mie_word;
            #10;  
            wr_en       = 1'b1;
            #10;
            wr_en       = 1'b0;
            assert(rd_word === mie_word)        else tc.err("MEI not set");
            
            // place ISR addr into mtvec
            csr_addr    = mtvec_addr;
            wd_word     = 32'hDEAD_BEEF;
            #10;  
            wr_en       = 1'b1;
            #10;
            wr_en       = 1'b0;
            assert(mtvec === 32'hDEAD_BEEF)     else tc.err("MTVEC not set");
            
            // enter INTRPT
            csr_addr    = mstatus_addr;    
            pc          = 32'h1234_ABCD;
            intr_taken  = 1'b1; 
            #8; 
            assert(rd_word === mpie_word)       else tc.err("MPIE swap didn't occur");
            assert(mtvec === 32'hDEAD_BEEF)     else tc.err("MTVEC changed");
            assert(mepc === 32'h1234_ABCD)      else tc.err("MEPC reg not storing pc");
            #2;
            intr_taken  = 1'b0;
            #10; 
        tc.test_done();
        
        // ~~ TC3 ~~
        tc.new_test("exiting interrupt ISR");
        tnum = tc.get_testnum();
            csr_addr    = mstatus_addr;
            intr_return = 1'b1; 
            #8; 
            assert(rd_word === mie_word)       else tc.err("MPIE swap didn't occur");
            assert(mie === 1'b1)               else tc.err("MIE didn't restore");
            assert(mepc === 32'h1234_ABCD)     else tc.err("MEPC did not protect pc");
            #2;
            intr_return = 1'b0;
            #10;
            assert(rd_word === mie_word)       else tc.err("MPIE swap didn't occur");
            assert(mie === 1'b1)               else tc.err("MIE didn't restore");
            assert(mepc === 32'h1234_ABCD)     else tc.err("MEPC did not protect pc");
        tc.test_done();
        
         // ~~ TC4 ~~
        tc.new_test("reset");
        tnum = tc.get_testnum();
            reset       = 1'b1;
            intr_taken  = 1'b0;
            intr_return = 1'b0;  
            wr_en       = 1'b0;
            csr_addr    = mstatus_addr;
            #8;
            assert(rd_word === 32'h0000_0000)   else tc.err("MSTATUS didn't reset");
            assert(mie === 1'b0)                else tc.err("MIE didn't reset");
            assert(mtvec === 32'h0000_0000)     else tc.err("MTVEC didn't reset");
            assert(mepc === 32'h0000_0000)      else tc.err("MEPC didn't reset");
            #2;
            reset       = 1'b0;
        tc.test_done();
       
    end
endmodule
