`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2026 09:18:24 AM
// Design Name: 
// Module Name: CUnit_Decoder_tb
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


module CUnit_Decoder_tb();

    // ~~~~ imports ~~~~
    import tb_utils_pkg::*;

    // ~~~~ local vars ~~~~
    logic [6:0] opcode; 
    logic [2:0] func3; 
    logic       func7;
    logic       br_eq, br_lt, br_ltu;
    logic       int_taken; 
    
    logic [3:0] alu_func; 
    logic [1:0] src_a; 
    logic [2:0] src_b; 
    logic [2:0] pc_src; 
    logic [1:0] rf_wr_sel; 
    
    // ~~ testing ~~
    testcase tc;
    string message; 
    logic [31:0] tnum;
    
    logic [2:0] func3_arr [0:9];
    logic [3:0] alu_arr [0:9];
    int         opcodeCNT; 
    
    
    // ~~~~ DUT instance ~~~~
    CUnit_Decoder UUT
    (
        // ~~ inputs ~~
        .OPCODE(opcode),                    // 7'b
        .FUNC3(func3),                      // 3'b
        .FUNC7(func7),                      // 1'b
        .BR_EQ(br_eq),                      // 1'b
        .BR_LT(br_lt),                      // 1'b
        .BR_LTU(br_ltu),                    // 1'b
        .INT_TAKEN(int_taken),              // 1'b
    
        // ~~ outputs ~~ 
        .ALU_FUNC(alu_func),                // 4'b
        .ALU_SRC_A(src_a),                  // 1'b
        .ALU_SRC_B(src_b),                  // 2'b
        .PC_SOURCE(pc_src),                 // 2'b
        .RF_WR_SEL(rf_wr_sel)               // 2'b
    );
    
    
    // ~~~~ testing ~~~~
    initial
    begin
    
    
        // ~~ class instances ~~
        tc          = new();
    
        // ~~ TC1 : unknown opcode is defaulted ~~
        tc.new_test("unknown opcode defaults");
        tnum = tc.get_testnum();

            opcode      = 7'b000_0000;
            func3       = 3'bxxx; 
            func7       = 1'bx;
            br_eq       = 1'bx;
            br_lt       = 1'bx;
            br_ltu      = 1'bx;
            #5;
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5;
       tc.test_done(); 
        
        
        
        // ~~ TC2 : loading  ~~
        tc.new_test("load instr");
        tnum = tc.get_testnum();
        
            opcode  = 7'b000_0011;
            opcodeCNT = 5;
            func3_arr = 
            '{
                default : 3'b000,
                0: 3'b000,                  // lb
                1: 3'b001,                  // lh
                2: 3'b010,                  // lw
                3: 3'b100,                  // lbu
                4: 3'b101                   // lhu
            };
            
            for(int i = 0; i < opcodeCNT; i++)
            begin
            
                func3   = func3_arr[i]; 
                func7   = 1'bx;
                br_eq   = 1'bx;
                br_lt   = 1'bx;
                br_ltu  = 1'bx;
                #5;
                message = $sformatf("FUNC3 = %0d", func3);
                tc.print_subtest(message);
                assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
                assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
                assert(src_b === 3'b001)         else tc.err("ALU_SRC_B failed");
                assert(pc_src === 3'b000)        else tc.err("PC_SOURCE failed");
                assert(rf_wr_sel === 2'b10)     else tc.err("RF_WR_SEL failed");
                #5;
            end
        tc.test_done();
        
        
        // ~~ TC3 : immed ops ~~
        tc.new_test("immed instr");
        tnum = tc.get_testnum();
        
            opcode  = 7'b001_0011;
            opcodeCNT = 9;
            func3_arr = 
            '{
                default : 3'b000,
                0: 3'b000,                  // addi
                1: 3'b001,                  // slli
                2: 3'b010,                  // slti
                3: 3'b011,                  // sltiu
                4: 3'b100,                  // xori
                5: 3'b101,                  // srli
                6: 3'b101,                  // srai
                7: 3'b110,                  // ori
                8: 3'b111                   // andi
            };
            
            alu_arr = 
            '{
                default : 4'b0000,
                0: 4'b0000,                  // addi
                1: 4'b0001,                  // slli
                2: 4'b0010,                  // slti
                3: 4'b0011,                  // sltiu
                4: 4'b0100,                  // xori
                5: 4'b0101,                  // srli
                6: 4'b1101,                  // srai
                7: 4'b0110,                  // ori
                8: 4'b0111                   // andi
            }; 
            
            for(int i = 0; i < opcodeCNT; i++)
            begin
            
                func3   = func3_arr[i]; 
                func7   = (i==6) ? 1'b1 : 1'b0;     //srai needs func7
                br_eq   = 1'bx;
                br_lt   = 1'bx;
                br_ltu  = 1'bx;
                #5;
                message = $sformatf("FUNC3 = %0d", func3);
                tc.print_subtest(message);
                assert(alu_func === alu_arr[i])     else tc.err("ALU_FUNC failed");
                assert(src_a === 2'b00)              else tc.err("ALU_SRC_A failed");
                assert(src_b === 3'b001)             else tc.err("ALU_SRC_B failed");
                assert(pc_src === 3'b000)            else tc.err("PC_SOURCE failed");
                assert(rf_wr_sel === 2'b11)         else tc.err("RF_WR_SEL failed");
                #5;
            end
        tc.test_done();
        
        
            
        // ~~ TC4 : auipc ~~
        tc.new_test("auipc instr");
        tnum = tc.get_testnum();

            opcode  = 7'b001_0111;
            func3   = 3'bxxx; 
            func7   = 1'bx;
            br_eq   = 1'bx;
            br_lt   = 1'bx;
            br_ltu  = 1'bx;
            #5;
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b01)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b011)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b11)     else tc.err("RF_WR_SEL failed");
            #5;
        tc.test_done();
        
        
        
        // ~~ TC5 : store  ~~
        tc.new_test("store instr");
        tnum = tc.get_testnum();
            opcode  = 7'b010_0011;
            opcodeCNT = 3;
            func3_arr = 
            '{
                default : 3'b000,
                0: 3'b000,                  // sb
                1: 3'b001,                  // sh
                2: 3'b010                   // sw
            };
            
            for(int i = 0; i < opcodeCNT; i++)
            begin

                func3   = func3_arr[i]; 
                func7   = 1'bx;
                br_eq   = 1'bx;
                br_lt   = 1'bx;
                br_ltu  = 1'bx;
                #5;
                message = $sformatf("FUNC3 = %0d", func3);
                tc.print_subtest(message);
                assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
                assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
                assert(src_b === 3'b010)         else tc.err("ALU_SRC_B failed");
                assert(pc_src === 3'b000)        else tc.err("PC_SOURCE failed");
                assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
                #5;
            end
        tc.test_done();
        
        
        
        // ~~ TC6 : dual register ops  ~~
        tc.new_test("dual src register instr");
        tnum = tc.get_testnum();
            opcode  = 7'b011_0011;
            opcodeCNT = 10;
            func3_arr = 
            '{
                default : 3'b000,
                0: 3'b000,                  // add
                1: 3'b000,                  // sub "
                2: 3'b001,                  // sll
                3: 3'b010,                  // slt
                4: 3'b011,                  // sltu
                5: 3'b100,                  // xor
                6: 3'b101,                  // srl 
                7: 3'b101,                  // sra "
                8: 3'b110,                  // or
                9: 3'b111                   // and
            };
            
            alu_arr = 
            '{
                default : 4'b0000,
                0: 4'b0000,                  // add
                1: 4'b1000,                  // sub 
                2: 4'b0001,                  // sll
                3: 4'b0010,                  // slt
                4: 4'b0011,                  // sltu
                5: 4'b0100,                  // xor
                6: 4'b0101,                  // srl
                7: 4'b1101,                  // sra
                8: 4'b0110,                  // or
                9: 4'b0111                   // and
            }; 
            
    
            for(int i = 0; i < opcodeCNT; i++)
            begin

                func3   = func3_arr[i]; 
                func7   = (i==1 || i==7) ? 1'b1 : 1'b0;     //sub and sra need func7
                br_eq   = 1'bx;
                br_lt   = 1'bx;
                br_ltu  = 1'bx;
                #5;
                message = $sformatf("FUNC3 = %0d", func3);
                tc.print_subtest(message);
                assert(alu_func === alu_arr[i])     else tc.err("ALU_FUNC failed");
                assert(src_a === 2'b00)              else tc.err("ALU_SRC_A failed");
                assert(src_b === 3'b000)             else tc.err("ALU_SRC_B failed");
                assert(pc_src === 3'b000)            else tc.err("PC_SOURCE failed");
                assert(rf_wr_sel === 2'b11)         else tc.err("RF_WR_SEL failed");
                #5;
            end
        tc.test_done();
        
        
        // ~~ TC7 : lui ~~
        tc.new_test("lui instr");
        tnum = tc.get_testnum();

            opcode  = 7'b011_0111;
            func3   = 3'bxxx; 
            func7   = 1'bx;
            br_eq   = 1'bx;
            br_lt   = 1'bx;
            br_ltu  = 1'bx;
            #5;
            assert(alu_func === 4'b1001)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b01)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b11)     else tc.err("RF_WR_SEL failed");
            #5;
       tc.test_done(); 
        
        
        // ~~ TC8 : branch  ~~
        tc.new_test("branch instr");
        tnum = tc.get_testnum();
            opcode  = 7'b110_0011;
            opcodeCNT = 6;
            func3_arr = 
            '{
                default : 3'b000,
                0: 3'b000,                  // beq
                1: 3'b001,                  // bne
                2: 3'b100,                  // blt
                3: 3'b101,                  // bge
                4: 3'b110,                  // bltu
                5: 3'b111                   // bgeu
            };
            
            func7   = 1'bx;
            
            // ~ beq (0) ~
            func3   = func3_arr[0]; 
            br_eq   = 1'b0;
            br_lt   = 1'bx;
            br_ltu  = 1'bx;          
            #5;
            tc.print_subtest("before BEQ");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5; 
            br_eq   = 1'b1;        
            #5;
            tc.print_subtest("after BEQ");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b010)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5;
            
            // ~ bne (1) ~
            func3   = func3_arr[1]; 
            br_eq   = 1'b0;
            br_lt   = 1'bx;
            br_ltu  = 1'bx;       
            #5;
            tc.print_subtest("before BNE");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b010)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5; 
            br_eq   = 1'b1;       
            #5;
            tc.print_subtest("after BNE");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5;
            
            // ~ blt (2) ~
            func3   = func3_arr[2]; 
            br_eq   = 1'bx;
            br_lt   = 1'b0;
            br_ltu  = 1'bx;          
            #5;
            tc.print_subtest("before BLT");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5; 
            br_lt   = 1'b1;      
            #5;
            tc.print_subtest("after BLT");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b010)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5;
            
            // ~ bge (3) ~
            func3   = func3_arr[3]; 
            br_eq   = 1'bx;
            br_lt   = 1'b0;
            br_ltu  = 1'bx;       
            #5;
            tc.print_subtest("before BGE");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b010)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5; 
            br_lt   = 1'b1;      
            #5;
            tc.print_subtest("after BGE");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5;
            
            // ~ bltu (4) ~
            func3   = func3_arr[4]; 
            br_eq   = 1'bx;
            br_lt   = 1'bx;
            br_ltu  = 1'b0;         
            #5;
            tc.print_subtest("before BLTU");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5; 
            br_ltu   = 1'b1;        
            #5;
            tc.print_subtest("after BLTU");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b010)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5;
            
            // ~ bgeu (5) ~
            func3   = func3_arr[5]; 
            br_eq   = 1'bx;
            br_lt   = 1'bx;
            br_ltu  = 1'b0;         
            #5;
            tc.print_subtest("before BGEU");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b010)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5; 
            br_ltu   = 1'b1;         
            #5;
            tc.print_subtest("after BGEU");
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5;
        tc.test_done();
        
        // ~~ TC9 : jalr ~~
        tc.new_test("jalr instr");
        tnum = tc.get_testnum();
            opcode  = 7'b110_0111;
            func3   = 3'bxxx; 
            func7   = 1'bx;
            br_eq   = 1'bx;
            br_lt   = 1'bx;
            br_ltu  = 1'bx;
            #5;
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b001)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5;
        tc.test_done();
        
        // ~~ TC10 : jal ~~
        tc.new_test("jal instr");
        tnum = tc.get_testnum();
            opcode  = 7'b110_1111;
            func3   = 3'bxxx; 
            func7   = 1'bx;
            br_eq   = 1'bx;
            br_lt   = 1'bx;
            br_ltu  = 1'bx;
            #5;
            assert(alu_func === 4'b0000)    else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)          else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)         else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b011)        else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else tc.err("RF_WR_SEL failed");
            #5;
        tc.test_done();
        
        
        // ~~ TC11 : interrupt request dominates ~~
        tc.new_test("requested intrr");
        tnum = tc.get_testnum();
        
            int_taken   = 1'b1;
            opcode      = 7'bxxx_xxxx;
            func3       = 3'bxxx; 
            func7       = 1'bx;
            br_eq       = 1'bx;
            br_lt       = 1'bx;
            br_ltu      = 1'bx;
            #5;
            assert(alu_func === 4'b0000)        else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)             else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b000)            else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b100)           else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)         else tc.err("RF_WR_SEL failed");
            #5;
        tc.test_done();
        
        
        // ~~ TC11 : csr ~~
        tc.new_test("csr instrs");
        tnum = tc.get_testnum();
        
            int_taken   = 1'b0;
            opcode      = 7'b111_0011;
            func3       = 3'b000; 
            func7       = 1'bx;
            br_eq       = 1'bx;
            br_lt       = 1'bx;
            br_ltu      = 1'bx;
            #5;
            tc.print_subtest("MRET");
            assert(alu_func === 4'b0000)        else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)             else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b100)            else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b101)           else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b01)         else tc.err("RF_WR_SEL failed");
            #5;
            
            func3       = 3'b001;
            #5;
            tc.print_subtest("CSRRW");
            assert(alu_func === 4'b1001)        else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)             else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b100)            else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)           else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b01)         else tc.err("RF_WR_SEL failed");
            #5;
            
            func3       = 3'b010;
            #5;
            tc.print_subtest("CSRRS");
            assert(alu_func === 4'b0110)        else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b00)             else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b100)            else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)           else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b01)         else tc.err("RF_WR_SEL failed");
            #5;
            
            func3       = 3'b011;
            #5;
            tc.print_subtest("CSRRC");
            assert(alu_func === 4'b0111)        else tc.err("ALU_FUNC failed");
            assert(src_a === 2'b10)             else tc.err("ALU_SRC_A failed");
            assert(src_b === 3'b100)            else tc.err("ALU_SRC_B failed");
            assert(pc_src === 3'b000)           else tc.err("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b01)         else tc.err("RF_WR_SEL failed");
            #5;
        tc.test_done();
    end
endmodule
