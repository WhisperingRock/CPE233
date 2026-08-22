`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2026 06:24:25 PM
// Design Name: 
// Module Name: OneShot_tb
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


module OneShot_tb();

    // ~~~~ local vars ~~~~
    
    // ~~ input ~~
    logic           in, clk;
    
    // ~~ output ~~
    logic           out; 
    
    // ~~ testing ~~
    logic [31:0]    testcase; 
    
    
    
    // ~~~~ module instances ~~~~
    OneShot UUT(
        .IN(in),         // 1'b I
        .CLK(clk),       // 1'b I
        .OUT(out)        // 1'b O
    );
    

    
    // ~~~~ heartbeat (10ns) ~~~~
    always begin
        #5;
        clk <= !clk;
    end
    
    // ~~~~ exercise/testing ~~~~
    initial begin
        testcase    = 0;
        clk         = 1'b1;
        in          = 1'b0;
        
        #100;               // get the crap out 

        
        // ~~ TC1 : No button press = no shooting ~~
        testcase++;
        $display("%d", testcase);
        #30; 
        assert(out === 1'b0) else $error("OUT HIGH but expected LOW");
        
        
        // ~~ TC2 : mid-clk cycle button press ~~
        testcase++;
        $display("%d", testcase);
        in = 1'b1; 
        #1; 
        in = 1'b0;

        for(int i = 0; i < (80-2); i++) begin
            #1;
            $display("%d", i);
            assert(out === 1'b1) else $error("OUT LOW but expected HIGH");

        end
        #2;     // brings us to a clean 10 increment clk count
        assert(out === 1'b0) else $error("OUT HIGH but expected LOW");
        
        
        
        // ~~ TC3 : retry button during pulse firing ~~
        testcase++;
        $display("%d", testcase);
        
        // ~ first button ~
        in = 1'b1; 
        #1; 
        in = 1'b0;

        // ~ first half of pulse ~
        for(int i = 0; i < 40; i++) begin
            #1;
            $display("%d", i);
            assert(out === 1'b1) else $error("OUT LOW but expected HIGH");
        end
        

        
        // ~ second half of pulse ~
        for(int i = 0; i < 19; i++) begin
            // ~ second pulse ~ 
            in = 1'b1; 
            #1; 
            
            $display("%d", i);
            assert(out === 1'b1) else $error("OUT LOW but expected HIGH");
            in = 1'b0;
            #1;
        end
        #2;     // brings us to a clean 10 increment clk count
        assert(out === 1'b0) else $error("OUT HIGH but expected LOW");
        
    end
    
    
endmodule
