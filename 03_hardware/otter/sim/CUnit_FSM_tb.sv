`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2026 12:48:54 PM
// Design Name: 
// Module Name: CUnit_FSM_tb
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


module CUnit_FSM_tb();

    // ~~~~ imports ~~~~
    import tb_utils_pkg::*;

    // ~~~~ local vars ~~~~
    // ~~ input ~~
    logic       clk;                        
    logic       rst;                        
    logic       intrr;                     
    logic [6:0] opcode;
    logic [2:0] func3;
    // ~~ output ~~   
    logic       pc_write;
    logic       reg_write;
    logic       mem_rden1;
    logic       mem_rden2;
    logic       mem_we2;
    logic       pc_reset;
    // ~~ isr (output) ~~
    logic       csr_we;
    logic       int_taken; 
    logic       mret_exec;
    
    // ~~ testing ~~
    testcase tc;
    logic [31:0] tnum;
    
    // ~~ encapsulations ~~
    logic[6:0] opc_arr [0:9];
    int opcCNT = 10;

    // ~~~~ UUT instance ~~~~
    CUnit_FSM UUT 
    (
        .CLK(clk),                  // 1'b I
        .RST(rst),                  // 1'b I
        .INTRR(intrr),              // 1'b I
        .OPCODE(opcode),            // 7'b I
        .FUNC3(func3),              // 3'b I
         
        .PC_WRITE(pc_write),        // 1'b O
        .REG_WRITE(reg_write),      // 1'b O
        .MEM_RDEN1(mem_rden1),      // 1'b O
        .MEM_RDEN2(mem_rden2),      // 1'b O
        .MEM_WE2(mem_we2),          // 1'b O
        .RESET(pc_reset),           // 1'b O
        
        .CSR_WE(csr_we),            // 1'b
        .INT_TAKEN(int_taken),      // 1'b
        .MRET_EXEC(mret_exec)       // 1'b
    );
    
    
    // ~~ action : CLK (10ns period) ~~
    always 
    begin
        #5;
        clk <= !clk;
    end
    
    
    // ~~~~ action : data ~~~~
    initial begin
    
        // ~~ class instances ~~
        tc          = new();
           
        // ~~ init ~~
        clk         = 1'b1; 
        rst         = 1'b0;
        intrr       = 1'b0;
        opcode      = 7'bxxx_xxxx;
        func3       = 3'b000;
        opc_arr     = 
        '{
            default :   7'b000_0000, 
            0:          7'b000_0011,            // load
            1:          7'b001_0011,            // imm ops
            2:          7'b001_0111,            // auipc
            3:          7'b010_0011,            // store
            4:          7'b011_0011,            // dual reg ops
            5:          7'b011_0111,            // lui
            6:          7'b110_0011,            // branch
            7:          7'b110_0111,            // jalr
            8:          7'b110_1111,            // jal
            9:          7'b111_0011             // interrupt
        };
        
        // ~~ TC1 : load(3) ~~
        tc.new_test("load");
        tnum = tc.get_testnum();
             
            // ~ INIT ~
            tc.print_subtest("INIT");
            #5;
            assert(pc_reset === 1'b1)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ FETCH 1 ~
            tc.print_subtest("FETCH 1");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
                 
            // ~ EXEC 1 ~
            tc.print_subtest("EXEC 1");
            opcode = opc_arr[0];                                                //  opcode
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ FETCH 2 ~
            tc.print_subtest("FETCH 2");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b1)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ EXEC 2 ~
            tc.print_subtest("EXEC 2");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ WRITEBACK ~
            tc.print_subtest("WRITEBACK");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b1)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
        tc.test_done();
        

        // ~~ TC2 : imm ops (19) ~~
        tc.new_test("immed");
        tnum = tc.get_testnum();     

            // ~ FETCH ~
            tc.print_subtest("FETCH");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
                 
            // ~ EXEC ~
            tc.print_subtest("EXEC");
            opcode = opc_arr[1];                                                // opcode
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ WRITEBACK ~
            tc.print_subtest("WRITEBACK");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b1)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
        tc.test_done();

        // ~~ TC3 : auipc (23) ~~
        tc.new_test("auipc");
        tnum = tc.get_testnum();     

            // ~ FETCH ~
            tc.print_subtest("FETCH");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
                 
            // ~ EXEC ~
            tc.print_subtest("EXEC");
            opcode = opc_arr[2];                                                    // opcode
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ WRITEBACK ~
            tc.print_subtest("WRITEBACK");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b1)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;  
        tc.test_done();

        // ~~ TC4 : store (35) ~~
        tc.new_test("store");
        tnum = tc.get_testnum();     

            // ~ FETCH ~
            tc.print_subtest("FETCH");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
                 
            // ~ EXEC ~
            tc.print_subtest("EXEC");
            opcode = opc_arr[3];                                                // opcode
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ WRITEBACK ~
            tc.print_subtest("WRITEBACK");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b1)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
        tc.test_done();

        // ~~ TC5 : dual reg ops (51) ~~
        tc.new_test("dual reg ops");
        tnum = tc.get_testnum();     

            // ~ FETCH ~
            tc.print_subtest("FETCH");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
                 
            // ~ EXEC ~
            tc.print_subtest("EXEC");
            opcode = opc_arr[4];                                                    //   opcode
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ WRITEBACK ~
            tc.print_subtest("WRITEBACK");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b1)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
        tc.test_done();

        // ~~ TC6 : lui (55) ~~
        tc.new_test("lui");
        tnum = tc.get_testnum();     

            // ~ FETCH ~
            tc.print_subtest("FETCH");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
                 
            // ~ EXEC ~
            tc.print_subtest("EXEC");
            opcode = opc_arr[5];                                                //  opcode
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ WRITEBACK ~
            tc.print_subtest("WRITEBACK");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b1)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
        tc.test_done();
        
        
        // ~~ TC7 : branch (99) ~~
        tc.new_test("branch");
        tnum = tc.get_testnum();     

            // ~ FETCH ~
            tc.print_subtest("FETCH");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
                 
            // ~ EXEC ~
            tc.print_subtest("EXEC");
            opcode = opc_arr[6];                                                //  opcode
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ WRITEBACK ~
            tc.print_subtest("WRITEBACK");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
        tc.test_done();
        

        // ~~ TC8 : jalr (103) ~~
        tc.new_test("jalr");
        tnum = tc.get_testnum();     

            // ~ FETCH ~
            tc.print_subtest("FETCH");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
                 
            // ~ EXEC ~
            tc.print_subtest("EXEC");
            opcode = opc_arr[7];                                                 //  opcode
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ WRITEBACK ~
            tc.print_subtest("WRITEBACK");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b1)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
        tc.test_done();


        // ~~ TC9 : jal (111) ~~
        tc.new_test("jal");
        tnum = tc.get_testnum();     

            // ~ FETCH ~
            tc.print_subtest("FETCH");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
                 
            // ~ EXEC ~
            tc.print_subtest("EXEC");
            opcode = opc_arr[8];                                                //   opcode
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ WRITEBACK ~
            tc.print_subtest("WRITEBACK");
            #5;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b1)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
        tc.test_done();       
        
        // ~~ TC10 : reset check ~~
        tc.new_test("reset1");
        tnum = tc.get_testnum();     

            // ~ FETCH ~
            tc.print_subtest("FETCH");
            rst = 1'b1; 
            #5;
            assert(pc_reset === 1'b1)   else tc.err("PC_RESET failed");
            #5; 
            rst = 1'b0;
            #5;
            // we've reached fetch after reset
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
            
            // ~ EXEC ~
            tc.print_subtest("EXEC");
            rst = 1'b1; 
            #5;
            assert(pc_reset === 1'b1)   else tc.err("PC_RESET failed");
            #5;
            rst = 1'b0;
            #15;
            // we've reached exec after reset
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
    
            // ~ WRITEBACK ~
            tc.print_subtest("WRITEBACK");
            rst = 1'b1; 
            #5;
            assert(pc_reset === 1'b1)   else tc.err("PC_RESET failed");
            #5;
            rst = 1'b0;
            #25;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b1)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            #5;
        tc.test_done();
        
        
        // ~~ TC11 : awkward reset timing ~~
        tc.new_test("reset2");
        tnum = tc.get_testnum();
        
            // 1 clk(pos) to register reset
            #3; 
            rst = 1'b1;
            #1; 
            rst = 1'b0;
            #1; 
            assert(pc_reset === 1'b1)   else tc.err("PC_RESET failed");
            #5;
        tc.test_done();
        
        
        // ~~ TC12 : mret opcode returns from interrupt  ~~
        tc.new_test("mret csr instr");
        tnum = tc.get_testnum();
        
            tc.print_subtest("FETCH");
            opcode  = opc_arr[9];               // intrr opcode
            func3    = 3'b000;                  // mret instr
            #10;
            
            tc.print_subtest("EXEC");
            #8;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            assert(csr_we === 1'b0)     else tc.err("CSR_WE failed");
            assert(int_taken === 1'b0)  else tc.err("INT_TAKEN failed");
            assert(mret_exec === 1'b1)  else tc.err("MRET_EXEC failed");
            #2;
            
            tc.print_subtest("WB");
            #8;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            assert(csr_we === 1'b0)     else tc.err("CSR_WE failed");
            assert(int_taken === 1'b0)  else tc.err("INT_TAKEN failed");
            assert(mret_exec === 1'b0)  else tc.err("MRET_EXEC failed");
            #2;
        tc.test_done();
        
        // ~~ TC13 : csr opcode but not mret  ~~
        tc.new_test("non-mret csr instr");
        tnum = tc.get_testnum();
        
            tc.print_subtest("FETCH");
            opcode  = opc_arr[9];               // intrr opcode
            func3    = 3'b001;                  // NOT mret instr
            #10;

            tc.print_subtest("EXEC");
            #8;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            assert(csr_we === 1'b0)     else tc.err("CSR_WE failed");
            assert(int_taken === 1'b0)  else tc.err("INT_TAKEN failed");
            assert(mret_exec === 1'b0)  else tc.err("MRET_EXEC failed");
            #2;
            
            tc.print_subtest("WB");
            #8;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b1)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            assert(csr_we === 1'b1)     else tc.err("CSR_WE failed");
            assert(int_taken === 1'b0)  else tc.err("INT_TAKEN failed");
            assert(mret_exec === 1'b0)  else tc.err("MRET_EXEC failed");
            #2;
        tc.test_done();
            
        // ~~ TC14 : INTR on WB  ~~
        tc.new_test("interrupt on WB");
        tnum = tc.get_testnum();
            
            #5;
            tc.print_subtest("FETCH1");
            opcode  = opc_arr[1];               // opcode not `csr` or `load` = no extra state cycles
            intrr   = 1'b1;
            #5;

            tc.print_subtest("EXEC");           // intrrupt shouldn't trigger here
            #10;
           
            tc.print_subtest("WB");             // interrupt should trigger after WB
            #10;
              
            tc.print_subtest("INTRPT");             // interrupt taken
            #2;
            intrr   = 1'b0;                         // CSR brings down intrr manually
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");     // update PC with ISR
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            assert(csr_we === 1'b0)     else tc.err("CSR_WE failed");
            assert(int_taken === 1'b1)  else tc.err("INT_TAKEN failed");    // interrupt flag is up
            assert(mret_exec === 1'b0)  else tc.err("MRET_EXEC failed");
            #8;
            
            tc.print_subtest("FETCH2");
            #2;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");    // typical fetch
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            assert(csr_we === 1'b0)     else tc.err("CSR_WE failed");
            assert(int_taken === 1'b0)  else tc.err("INT_TAKEN failed");    // interrupt flag is taken down
            assert(mret_exec === 1'b0)  else tc.err("MRET_EXEC failed");
            #8;
            
            #20; // bring past WB
        tc.test_done();


        // ~~ TC14 : INTR on WB  ~~
        tc.new_test("interrupt on EXEC (load instr)");
        tnum = tc.get_testnum();
            
            #5;
            tc.print_subtest("FETCH1");
            opcode  = opc_arr[0];               // opcode load = extra state cycles
            intrr   = 1'b1;
            #5;

            tc.print_subtest("EXEC1");          // intrrupt should trigger here to preserve opcode
            #10;
                                                // delay FETCH2, EXEC2, WB ... straight to INTRPT first       

            tc.print_subtest("INTRPT");        // interrupt taken
            #2;
            intrr   = 1'b0;                         // CSR brings down intrr manually
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b1)   else tc.err("PC_WRITE failed");     // update PC with ISR
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b0)  else tc.err("MEM_RDEN1 failed");
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            assert(csr_we === 1'b0)     else tc.err("CSR_WE failed");
            assert(int_taken === 1'b1)  else tc.err("INT_TAKEN failed");    // interrupt flag is up
            assert(mret_exec === 1'b0)  else tc.err("MRET_EXEC failed");
            #8;
            
            tc.print_subtest("ISR FETCH");
            #2;
            assert(pc_reset === 1'b0)   else tc.err("PC_RESET failed");
            assert(pc_write === 1'b0)   else tc.err("PC_WRITE failed");
            assert(reg_write === 1'b0)  else tc.err("REG_WRITE failed");
            assert(mem_we2 === 1'b0)    else tc.err("MEM_WE2 failed");
            assert(mem_rden1 === 1'b1)  else tc.err("MEM_RDEN1 failed");    // typical fetch
            assert(mem_rden2 === 1'b0)  else tc.err("MEM_RDEN2 failed");
            assert(csr_we === 1'b0)     else tc.err("CSR_WE failed");
            assert(int_taken === 1'b0)  else tc.err("INT_TAKEN failed");    // interrupt flag is taken down
            assert(mret_exec === 1'b0)  else tc.err("MRET_EXEC failed");
            #8;
            
            #20; // bring past WB
        tc.test_done();
    end


endmodule
