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
    logic           mei; 
    logic [31:0]    mtvec; 
    logic [31:0]    mepc; 
    logic [31:0]    rd_word; 
    
    // ~~ consts ~~
    localparam [11:0]   mstatus_addr        = 12'h300;
    const int           mstatus_mei_bit     = 3;
    const int           mstatus_mpie_bit    = 7; 
    localparam [11:0]   mtvec_addr          = 12'h305;
    localparam [11:0]   mepc_addr           = 12'h341;
    
    // ~~ testing ~~
    testcase tc; 
    
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
        .MSTATUS_MIE(mei),          // 1'b O
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
        
        // ~~ TC1 : init register contents are cleared ~~
        tc.new_test("CSR holds data");     
            csr_addr = mstatus_addr;
            #8; 
            assert(rd_word === 32'h0000_0000)   else tc.err("MSTATUS reg was not init to zero");
            assert(mtvec === 32'h0000_0000)     else tc.err("MTVEC reg was not init to zero");
            assert(mepc === 32'h0000_0000)      else tc.err("MEPC reg was not init to zero");
            #2; 
        tc.test_done();
        
        
        
    
    end
endmodule
