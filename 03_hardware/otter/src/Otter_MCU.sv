`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/19/2026 08:57:52 AM
// Design Name: 
// Module Name: Otter_MCU
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


module Otter_MCU(
    input logic [31:0]  IOBUS_IN, 
    input logic         RST, 
    input logic         INTRR, 
    input logic         CLK, 
    
    output logic [31:0] IOBUS_OUT, 
    output logic [31:0] IOBUS_ADDR, 
    output logic        IOBUS_WR
    );
    
    
    // ~~~~ inits / wires ~~~~
    
    // ~~ pc + mux ~~
    logic           reset; 
    logic           pc_write; 
    logic [1:0]     pc_source; 
    logic [31:0]    pc;
    logic [31:0]    pc_p4;
    logic [31:0]    pcmux_out;
    
    // ~~ memory ~~
    logic           mem_rden1; 
    logic           mem_rden2; 
    logic           mem_we2; 
    logic [31:0]    din2; 
    logic [31:0]    ir, dout2; 
    
    // ~~ reg file + mux ~~
    logic           reg_write;  
    logic [31:0]    reg_w_data; 
    logic [31:0]    rs1, rs2;
    logic [1:0]     rf_wr_sel;
    
    // ~~ immed gen ~~
    logic [31:0]    ut, it, st, jt, bt;
    
    // ~~ branch addr gen ~~
    logic [31:0]    jalr, branch, jal;
    
    // ~~ alu + mux ~~
    logic           alu_src_a;
    logic [1:0]     alu_src_b;
    logic [3:0]     alu_func; 
    logic [31:0]    src_a, src_b, result;
    
    // ~~ csr ~~ ????????????????????????????????????????????????
    logic [31:0]    csr_reg; 
                    
    // ~~ bcond + control decode and fsm ~~
    logic           br_eq, br_lt, br_ltu;
    
    
    // ~~~~ modules (l-2-r on diagram) ~~~~
    PC_Reg PC(
        .CLK(CLK),              // 1'b I                 
        .PC_RST(reset),         // 1'b I     
        .PC_WE(pc_write),       // 1'b I     
        .PC_DIN(pcmux_out),     // 32'b I
        .PC_COUNT(pc)           // 32'b O
     );
       
    Mux_4N #(32) PC_MUX(                              
        .D0(pc_p4),             // 32'b I 
        .D1(jalr),              // 32'b I
        .D2(branch),            // 32'b I
        .D3(jal),               // 32'b I
        .S(pc_source),          // 2'b I
        .Y(pcmux_out)           // 32'b O
    );
        
    Plus4_1N #(32) P4(
        .IN(pc),                // 32'b I
        .OUT(pc_p4)             // 32'b O
    );

    Memory MEMORY
    (
        .MEM_CLK(CLK),          // 1'b I
        .MEM_RDEN1(mem_rden1),  // 1'b I 
        .MEM_RDEN2(mem_rden2),  // 1'b I
        .MEM_WE2(mem_we2),      // 1'b I
        .MEM_ADDR1(pc[15:2]),   // 14'b I  
        .MEM_ADDR2(result),     // 32'b I
        .MEM_DIN2(din2),        // 32'b I
        .MEM_SIZE(ir[13:12]),   // 2'b I
        .MEM_SIGN(ir[14]),      // 1'b I
        .IO_IN(IOBUS_IN),       // 32'b I  

        .IO_WR(IOBUS_WR),       // 1'b O  
        .MEM_DOUT1(ir),         // 32'b O
        .MEM_DOUT2(dout2)       // 32'b O
    );
          
    Mux_4N #(32) REG_MUX(                              
        .D0(pc_p4),             // 32'b I 
        .D1(csr_reg),           // 32'b I
        .D2(dout2),             // 32'b I
        .D3(result),            // 32'b I
        .S(rf_wr_sel),          // 2'b I
        .Y(reg_w_data)          // 32'b O
    );
    
    RegFile REG_FILE(
        .EN(reg_write),         // 1'b I
        .CLK(CLK),              // 1'b I
        .ADR1(ir[19:15]),       // 5'b I
        .ADR2(ir[24:20]),       // 5'b I
        .W_ADR(ir[11:7]),       // 5'b I
        .W_DATA(reg_w_data),    // 32'b I
        .RS1(rs1),              // 32'b O
        .RS2(rs2)               // 32'b O
    );
    assign IOBUS_OUT = rs2; 
    
    ImmedGen IMMED_GEN(
        .INSTR(ir),             // 32'b I but only 25 are used 
        .U_TYPE(ut),            // 32'b O
        .I_TYPE(it),            // 32'b O
        .S_TYPE(st),            // 32'b O
        .J_TYPE(jt),            // 32'b O
        .B_TYPE(bt)             // 32'b O
    );
    
    BranchAddrGen BRANCH_ADDR_GEN(
        .RS1(rs1),              // 32'b I 
        .I_TYPE(it),            // 32'b I 
        .J_TYPE(jt),            // 32'b I
        .B_TYPE(bt),            // 32'b I
        .PC(pc),                // 32'b I
        .JAL(jal),              // 32'b O
        .JALR(jalr),            // 32'b O
        .BRANCH(branch)         // 32'b O
    );
    
    Mux_2N #(32) ALU_SRCA_MUX(                              
        .D0(rs1),               // 32'b I 
        .D1(ut),                // 32'b I
        .S(alu_src_a),          // 2'b I
        .Y(src_a)               // 32'b O
    );
            
    Mux_4N #(32) ALU_SRCB_MUX(                              
        .D0(rs2),               // 32'b I 
        .D1(it),                // 32'b I
        .D2(st),                // 32'b I
        .D3(pc),                // 32'b I
        .S(alu_src_b),          // 2'b I
        .Y(src_b)               // 32'b O
    );
    
    ALU ALU(
        .ALU_FUN(alu_func),     // 4'b I
        .SRC_A(src_a),          // 32'b I
        .SRC_B(src_b),          // 32'b I
        .ALU_RESULT(result)     // 32'b O
    );
    assign IOBUS_ADDR = result; 
    
    BranchConditionGen BRANCH_COND_GEN(
        .RS1(rs1),              // 32'b I
        .RS2(rs2),              // 32'b I
        .BR_EQ(br_eq),          // 1'b O
        .BR_LT(br_lt),          // 1'b O
        .BR_LTU(br_ltu)         // 1'b O
    );
    
    CUnit_Decoder CU_DCDR(
        .OPCODE(ir[6:0]),       // 7'b I
        .FUNC3(ir[14:12]),      // 3'b I
        .FUNC7(ir[30]),         // 1'b I
        .BR_EQ(br_eq),          // 1'b I
        .BR_LT(br_lt),          // 1'b I
        .BR_LTU(br_ltu),        // 1'b I
        .ALU_FUNC(alu_func),    // 4'b O
        .ALU_SRC_A(alu_src_a),      // 1'b O
        .ALU_SRC_B(alu_src_b),      // 2'b O
        .PC_SOURCE(pc_source),  // 2'b O
        .RF_WR_SEL(rf_wr_sel)   // 2'b O
    );
    
    CUnit_FSM CU_FSM(
        .CLK(CLK),              // 1'b I
        .RST(RST),              // 1'b I
        //.INTRR(),             // 1'b I
        .OPCODE(ir[6:0]),       // 7'b I
        .PC_WRITE(pc_write),    // 1'b O
        .REG_WRITE(reg_write),  // 1'b O
        .MEM_RDEN1(mem_rden1),  // 1'b O
        .MEM_RDEN2(mem_rden2),  // 1'b O
        .MEM_WE2(mem_we2),      // 1'b O
        .RESET(reset)           // 1'b O
    );
endmodule
