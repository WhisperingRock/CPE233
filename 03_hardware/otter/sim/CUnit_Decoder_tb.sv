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

    // ~~~~ local vars ~~~~
    logic [6:0] opcode; 
    logic [2:0] func3; 
    logic       func7;
    logic       br_eq, br_lt, br_ltu;
    
    logic [3:0] alu_func; 
    logic       src_a; 
    logic [1:0] src_b; 
    logic [1:0] pc_src; 
    logic [1:0] rf_wr_sel; 
    
    // ~~ testing ~~
    logic[31:0] testcase;
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
    
        // ~~ TC1 : unknown opcode is defaulted ~~
        #5;
        opcode  = 7'b000_0000;
        func3   = 3'bxxx; 
        func7   = 1'bx;
        br_eq   = 1'bx;
        br_lt   = 1'bx;
        br_ltu  = 1'bx;
        testcase = 1;
        
        #5;
        $display("TC%d:", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b00)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        
        
        
        // ~~ TC2 : loading  ~~
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
        
        testcase++;
        for(int i = 0; i < opcodeCNT; i++)
        begin
        
            #5;
            func3   = func3_arr[i]; 
            func7   = 1'bx;
            br_eq   = 1'bx;
            br_lt   = 1'bx;
            br_ltu  = 1'bx;
            
            #5;
            $display("TC%d: %d", testcase, i);
            assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
            assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
            assert(src_b === 2'b01)         else $error("ALU_SRC_B failed");
            assert(pc_src === 2'b00)        else $error("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b10)     else $error("RF_WR_SEL failed");
        end
        
        
        // ~~ TC3 : immed ops ~~
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
        
        testcase++;
        for(int i = 0; i < opcodeCNT; i++)
        begin
        
            #5;
            func3   = func3_arr[i]; 
            func7   = (i==6) ? 1'b1 : 1'b0;     //srai needs func7
            br_eq   = 1'bx;
            br_lt   = 1'bx;
            br_ltu  = 1'bx;
            
            #5;
            $display("TC%d: %d", testcase, i);
            assert(alu_func === alu_arr[i])     else $error("ALU_FUNC failed");
            assert(src_a === 1'b0)              else $error("ALU_SRC_A failed");
            assert(src_b === 2'b01)             else $error("ALU_SRC_B failed");
            assert(pc_src === 2'b00)            else $error("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b11)         else $error("RF_WR_SEL failed");
        end
        
        
        
            
        // ~~ TC4 : auipc ~~
        #5;
        opcode  = 7'b001_0111;
        func3   = 3'bxxx; 
        func7   = 1'bx;
        br_eq   = 1'bx;
        br_lt   = 1'bx;
        br_ltu  = 1'bx;
        testcase++;
        
        #5;
        $display("TC%d:", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b1)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b11)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b00)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b11)     else $error("RF_WR_SEL failed");
        
        
        
        // ~~ TC5 : store  ~~
        opcode  = 7'b010_0011;
        opcodeCNT = 3;
        func3_arr = 
        '{
            default : 3'b000,
            0: 3'b000,                  // sb
            1: 3'b001,                  // sh
            2: 3'b010                   // sw
        };
        
        testcase++;
        for(int i = 0; i < opcodeCNT; i++)
        begin
        
            #5;
            func3   = func3_arr[i]; 
            func7   = 1'bx;
            br_eq   = 1'bx;
            br_lt   = 1'bx;
            br_ltu  = 1'bx;
            
            #5;
            $display("TC%d: %d", testcase, i);
            assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
            assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
            assert(src_b === 2'b10)         else $error("ALU_SRC_B failed");
            assert(pc_src === 2'b00)        else $error("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        end
        
        
        
        
        // ~~ TC6 : dual register ops  ~~
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
        
        testcase++;
        for(int i = 0; i < opcodeCNT; i++)
        begin
        
            #5;
            func3   = func3_arr[i]; 
            func7   = (i==1 || i==7) ? 1'b1 : 1'b0;     //sub and sra need func7
            br_eq   = 1'bx;
            br_lt   = 1'bx;
            br_ltu  = 1'bx;
            
            #5;
            $display("TC%d: %d", testcase, i);
            assert(alu_func === alu_arr[i])     else $error("ALU_FUNC failed");
            assert(src_a === 1'b0)              else $error("ALU_SRC_A failed");
            assert(src_b === 2'b00)             else $error("ALU_SRC_B failed");
            assert(pc_src === 2'b00)            else $error("PC_SOURCE failed");
            assert(rf_wr_sel === 2'b11)         else $error("RF_WR_SEL failed");
        end
        
        
        
        // ~~ TC7 : lui ~~
        #5;
        opcode  = 7'b011_0111;
        func3   = 3'bxxx; 
        func7   = 1'bx;
        br_eq   = 1'bx;
        br_lt   = 1'bx;
        br_ltu  = 1'bx;
        testcase++;
        
        #5;
        $display("TC%d:", testcase);
        assert(alu_func === 4'b1001)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b1)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b00)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b11)     else $error("RF_WR_SEL failed");
        
        
        
        // ~~ TC8 : branch  ~~
        opcode  = 7'b110_0011;
        testcase++;
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
        #5;
        func3   = func3_arr[0]; 
        br_eq   = 1'b0;
        br_lt   = 1'bx;
        br_ltu  = 1'bx;    
                
        #5;
        $display("TC%d: BEQ", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b00)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        #5; 
        br_eq   = 1'b1;  
                
        #5;
        $display("TC%d: BEQ", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b10)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        
        // ~ bne (1) ~
        #5;
        func3   = func3_arr[1]; 
        br_eq   = 1'b0;
        br_lt   = 1'bx;
        br_ltu  = 1'bx;    
                
        #5;
        $display("TC%d: BNE", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b10)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        #5; 
        br_eq   = 1'b1;  
                
        #5;
        $display("TC%d: BNE", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b00)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        
        // ~ blt (2) ~
        #5;
        func3   = func3_arr[2]; 
        br_eq   = 1'bx;
        br_lt   = 1'b0;
        br_ltu  = 1'bx;    
                
        #5;
        $display("TC%d: BLT", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b00)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        #5; 
        br_lt   = 1'b1;  
                
        #5;
        $display("TC%d: BLT", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b10)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        
        // ~ bge (3) ~
        #5;
        func3   = func3_arr[3]; 
        br_eq   = 1'bx;
        br_lt   = 1'b0;
        br_ltu  = 1'bx;    
                
        #5;
        $display("TC%d: BGE", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b10)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        #5; 
        br_lt   = 1'b1;  
                
        #5;
        $display("TC%d: BGE", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b00)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        
        
        // ~ bltu (4) ~
        #5;
        func3   = func3_arr[4]; 
        br_eq   = 1'bx;
        br_lt   = 1'bx;
        br_ltu  = 1'b0;    
                
        #5;
        $display("TC%d: BLTU", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b00)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        #5; 
        br_ltu   = 1'b1;  
                
        #5;
        $display("TC%d: BLTU", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b10)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        
        
        // ~ bgeu (5) ~
        #5;
        func3   = func3_arr[5]; 
        br_eq   = 1'bx;
        br_lt   = 1'bx;
        br_ltu  = 1'b0;    
                
        #5;
        $display("TC%d: BGEU", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b10)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        #5; 
        br_ltu   = 1'b1;  
                
        #5;
        $display("TC%d: BGEU", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b00)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        
        // ~~ TC9 : jalr ~~
        #5;
        opcode  = 7'b110_0111;
        func3   = 3'bxxx; 
        func7   = 1'bx;
        br_eq   = 1'bx;
        br_lt   = 1'bx;
        br_ltu  = 1'bx;
        testcase++;
        
        #5;
        $display("TC%d:", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b01)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
        
        
        // ~~ TC10 : jal ~~
        #5;
        opcode  = 7'b110_1111;
        func3   = 3'bxxx; 
        func7   = 1'bx;
        br_eq   = 1'bx;
        br_lt   = 1'bx;
        br_ltu  = 1'bx;
        testcase++;
        
        #5;
        $display("TC%d:", testcase);
        assert(alu_func === 4'b0000)    else $error("ALU_FUNC failed");
        assert(src_a === 1'b0)          else $error("ALU_SRC_A failed");
        assert(src_b === 2'b00)         else $error("ALU_SRC_B failed");
        assert(pc_src === 2'b11)        else $error("PC_SOURCE failed");
        assert(rf_wr_sel === 2'b00)     else $error("RF_WR_SEL failed");
    end
endmodule
