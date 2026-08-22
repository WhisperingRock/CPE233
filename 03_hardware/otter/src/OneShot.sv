`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/21/2026 03:38:23 PM
// Design Name: 
// Module Name: OneShot
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


module OneShot(
    input           IN,
    input logic     CLK, 
    output logic    OUT
    );
    
    // ~~~~ local params ~~~~
    localparam      SHOTLEN = 80;
    localparam      PERIOD  = 10;
    logic [31:0]    delay;
    
  
    // ~~~~ inits ~~~~
    initial begin
        delay       = SHOTLEN;     
    end
    
    // ~~~~ asynch button ~~~~
    always_ff @(negedge IN) begin
        if(delay == SHOTLEN) begin
            OUT <= 1'b1;
        end
    end
    
    // ~~~~ synch delay ~~~~
    always_ff @(posedge CLK) begin
    
        // ~~ pulse on and decrementing ~~
        if(OUT == 1'b1) begin
            delay -= PERIOD; 
        end
        
        if(delay <= 0) begin
            OUT <= 1'b0; 
            delay = SHOTLEN; 
        end
    end
    
endmodule
