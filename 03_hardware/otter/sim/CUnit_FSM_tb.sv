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

    // ~~~~ local vars ~~~~
    
    // ~~ input ~~
    logic       clk;                        
    logic       rst;                        
    //logic     interr;                     
    logic [6:0] opcode;
    
    // ~~ output ~~   
    logic       pc_write;
    logic       reg_write;
    logic       mem_rden1;
    logic       mem_rden2;
    logic       mem_we2;
    logic       pc_reset;
    
    // ~~ testing ~~
    logic[31:0] testcase;
    logic[6:0] opc_arr [0:8];
    int opcCNT = 9; 


    // ~~~~ UUT instance ~~~~
    CUnit_FSM UUT 
    (
        .CLK(clk),                  // 1'b
        .RST(rst),                  // 1'b
        //.INTRR(),                 // 1'b
        .OPCODE(opcode),            // 7'b
         
        .PC_WRITE(pc_write),        // 1'b
        .REG_WRITE(reg_write),      // 1'b
        .MEM_RDEN1(mem_rden1),      // 1'b
        .MEM_RDEN2(mem_rden2),      // 1'b
        .MEM_WE2(mem_we2),          // 1'b
        .RESET(pc_reset)            // 1'b
    );
    
    
    // ~~ action : CLK (10ns period) ~~
    always 
    begin
        #5;
        clk <= !clk;
    end
    
    
    // ~~~~ action : data ~~~~
    initial begin
           
        // ~~ init ~~
        clk =       1'b1; 
        rst =       1'b0;
        opcode =    7'bxxx_xxxx;
        opc_arr = 
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
            8:          7'b110_1111             // jal
        };
        
        // ~~ TC1 : load(3) ~~
        testcase = 1;
        $display("TC%d:", testcase);     
        
        // ~ INIT ~
        $display("INIT");
        #5;
        assert(pc_reset === 1'b1)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ FETCH 1 ~
        $display("FETCH 1");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b1)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
             
        // ~ EXEC 1 ~
        $display("EXEC 1");
        opcode = opc_arr[0];                // load opcode
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ FETCH 2 ~
        $display("FETCH 2");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b1)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ EXEC 2 ~
        $display("EXEC 2");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ WRITEBACK ~
        $display("WRITEBACK");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b1)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b1)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;


        // ~~ TC2 : imm ops (19) ~~
        testcase++;
        $display("TC%d:", testcase);     

        // ~ FETCH ~
        $display("FETCH");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b1)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
             
        // ~ EXEC ~
        $display("EXEC");
        opcode = opc_arr[1];                // load opcode
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ WRITEBACK ~
        $display("WRITEBACK");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b1)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b1)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;


        // ~~ TC3 : auipc (23) ~~
        testcase++;
        $display("TC%d:", testcase);     

        // ~ FETCH ~
        $display("FETCH");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b1)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
             
        // ~ EXEC ~
        $display("EXEC");
        opcode = opc_arr[2];                // load opcode
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ WRITEBACK ~
        $display("WRITEBACK");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b1)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b1)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;


        // ~~ TC4 : store (35) ~~
        testcase++;
        $display("TC%d:", testcase);     

        // ~ FETCH ~
        $display("FETCH");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b1)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
             
        // ~ EXEC ~
        $display("EXEC");
        opcode = opc_arr[3];                // load opcode
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ WRITEBACK ~
        $display("WRITEBACK");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b1)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b1)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;


        // ~~ TC5 : dual reg ops (51) ~~
        testcase++;
        $display("TC%d:", testcase);     

        // ~ FETCH ~
        $display("FETCH");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b1)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
             
        // ~ EXEC ~
        $display("EXEC");
        opcode = opc_arr[4];                // load opcode
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ WRITEBACK ~
        $display("WRITEBACK");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b1)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b1)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;


        // ~~ TC6 : lui (55) ~~
        testcase++;
        $display("TC%d:", testcase);     

        // ~ FETCH ~
        $display("FETCH");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b1)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
             
        // ~ EXEC ~
        $display("EXEC");
        opcode = opc_arr[5];                // load opcode
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ WRITEBACK ~
        $display("WRITEBACK");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b1)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b1)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;


        // ~~ TC7 : branch (99) ~~
        testcase++;
        $display("TC%d:", testcase);     

        // ~ FETCH ~
        $display("FETCH");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b1)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
             
        // ~ EXEC ~
        $display("EXEC");
        opcode = opc_arr[6];                // load opcode
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ WRITEBACK ~
        $display("WRITEBACK");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b1)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;



        // ~~ TC8 : jalr (103) ~~
        testcase++;
        $display("TC%d:", testcase);     

        // ~ FETCH ~
        $display("FETCH");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b1)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
             
        // ~ EXEC ~
        $display("EXEC");
        opcode = opc_arr[7];                // load opcode
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ WRITEBACK ~
        $display("WRITEBACK");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b1)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b1)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;



        // ~~ TC9 : jal (111) ~~
        testcase++;
        $display("TC%d:", testcase);     

        // ~ FETCH ~
        $display("FETCH");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b1)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
             
        // ~ EXEC ~
        $display("EXEC");
        opcode = opc_arr[8];                // load opcode
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ WRITEBACK ~
        $display("WRITEBACK");
        #5;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b1)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b1)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        
        // ~~ TC10 : reset check ~~
        testcase++;
        $display("TC%d:", testcase);     

        // ~ FETCH ~
        $display("FETCH");
        rst = 1'b1; 
        #5;
        assert(pc_reset === 1'b1)   else $error("PC_RESET failed");
        #5; 
        rst = 1'b0;
        #5;
        // we've reached fetch after reset
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b1)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~ EXEC ~
        $display("EXEC");
        rst = 1'b1; 
        #5;
        assert(pc_reset === 1'b1)   else $error("PC_RESET failed");
        #5;
        rst = 1'b0;
        #15;
        // we've reached exec after reset
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b0)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b0)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;

        // ~ WRITEBACK ~
        $display("WRITEBACK");
        rst = 1'b1; 
        #5;
        assert(pc_reset === 1'b1)   else $error("PC_RESET failed");
        #5;
        rst = 1'b0;
        #25;
        assert(pc_reset === 1'b0)   else $error("PC_RESET failed");
        assert(pc_write === 1'b1)   else $error("PC_WRITE failed");
        assert(reg_write === 1'b1)  else $error("REG_WRITE failed");
        assert(mem_we2 === 1'b0)    else $error("MEM_WE2 failed");
        assert(mem_rden1 === 1'b0)  else $error("MEM_RDEN1 failed");
        assert(mem_rden2 === 1'b0)  else $error("MEM_RDEN2 failed");
        #5;
        
        // ~~ TC11 : awkward reset timing ~~
        testcase++;
        $display("TC%d:", testcase);
        
        // 1 clk(pos) to register reset
        #3; 
        rst = 1'b1;
        #1; 
        rst = 1'b0;
        #1; 
        assert(pc_reset === 1'b1)   else $error("PC_RESET failed");
        #6; 

        

    end


endmodule
