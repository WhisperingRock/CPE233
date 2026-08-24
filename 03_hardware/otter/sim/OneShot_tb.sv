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
    localparam      p_dur = 80;
    
    
    
    // ~~~~ module instances ~~~~
    OneShot #(p_dur) UUT(
        .IN(in),         // 1'b I
        .CLK(clk),       // 1'b I
        .OUT(out)        // 1'b O
    );
    

    
    // ~~~~ heartbeat (10ns) ~~~~
    always begin
        #5;
        clk <= !clk;
    end
    
    // ~~~~ testing ~~~~
    initial begin
        testcase    = 0;
        clk         = 1'b1;
        in          = 1'b0;
        
        #100;                           // get the poo out 

        
        // ~~ TC1 : No button press = no shooting ~~
        testcase++;
        $display("TC %d", testcase);
        for(int i = 0; i < 30; i++) begin 
            assert(out === 1'b0) else $error("OUT HIGH but expected LOW");
        end
        
        
        // ~~ TC2 : mid-clk cycle button press ~~
        testcase++;
        $display("TC %d", testcase);
        in = 1'b1; 
        #1; 
        in = 1'b0;
        #29;    // wait the 30ns for button processing delay

        for(int i = 0; i < p_dur; i++) begin
            #1;
            $display("%d", i);
            assert(out === 1'b1) else $error("OUT LOW but expected HIGH");

        end
        #1;
        assert(out === 1'b0) else $error("OUT HIGH but expected LOW");
        
        
        
        // ~~ TC3 : small blip (not on clk) is ignored as noise) ~~
        testcase++;
        $display("TC %d", testcase);
        
        // ~ first button ~
        in = 1'b1; 
        #1; 
        in = 1'b0;
        #29;    // wait the 30ns for button processing delay
        
        // ~ first half of pulse is on ~
        for(int i = 0; i < 40; i++) begin
            #1;
            $display("%d", i);
            assert(out === 1'b0) else $error("OUT HIGH but expected LOW");
        end
        #9; //readjustment to clk
        

        // ~~ TC4 : retry button during pulse firing ~~
        testcase++;
        $display("TC %d", testcase);
        
        // ~ first button ~
        in = 1'b1; 
        #1; 
        in = 1'b0;
        #29;    // wait the 30ns for button processing delay
        
        // ~ first half of pulse is on ~
        for(int i = 0; i < 14; i++) begin
            #1;
            $display("%d", i);
            assert(out === 1'b1) else $error("OUT LOW but expected HIGH");
        end
        // ~ second half of pulse is still on (regardless of button) ~
        for(int i = 0; i < 14; i++) begin
            // ~ second pulse ~ 
            in = 1'b1; 
            #2; 
            
            $display("%d", i);
            assert(out === 1'b1) else $error("OUT LOW but expected HIGH");
            in = 1'b0;
            #1;
        end
        #24;          
        assert(out === 1'b1) else $error("OUT LOW but expected HIGH");
        #1;
        assert(out === 1'b0) else $error("OUT HIGH but expected LOW");
        #200; 
        
        
        // ~~ TC4 : long press ~~
        testcase++;
        $display("TC %d", testcase);
        in = 1'b1;
        #300; 
        in = 1'b0;
        #30;                                        // recognize button propagation
        for(int i = 0; i < 80; i++) begin
            $display("%d", i);
            assert(out === 1'b1) else $error("OUT LOW but expected HIGH");
            #1;
        end
        #80; 
    end
    
    
endmodule
