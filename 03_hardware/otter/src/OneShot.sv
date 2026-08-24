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


module OneShot
#(parameter DUR_CNT = 80)
(
    input logic     IN,             // active on falling edge
    input logic     CLK, 
    output logic    OUT
    );
    
    // ~~~~ local params ~~~~
    // ~~ state ~~
    typedef enum logic [1:0] {
        INACTIVE, 
        PULSE, 
        INC
    } e_state;
    e_state curr_state, next_state;
    
    // ~~ timing ~~
    localparam      INC_CNT = 10;
    logic [31:0]    t_elap_ns, next_t_elap_ns; 

    // ~~ button processing ~~
    logic in_meta;
    logic in_sync;
    logic in_sync_d;
    logic button_press;
    
    // ~~~~ synch for falling button : two-flop ~~~~
    /* Note : we introduce some delay in waiting for the CLK and
    //          flops BUT we avoid (re)assigning the same logic synch
    //          and asynch for the button (as before).
    */ 
    always_ff @(posedge CLK) begin
        in_meta             <= IN;
        in_sync             <= in_meta; 
        in_sync_d           <= in_sync; 
    end
    assign button_press     = in_sync_d && !in_sync; // HIGH during falling edge
    
    // ~~~~ synch state progression ~~~~
    always_ff @(posedge CLK) begin
        curr_state  <= next_state; 
        t_elap_ns   <= next_t_elap_ns; 
    end
    
    always_comb begin
    
        // ~~ defaults ~~
        next_state      = curr_state;
        next_t_elap_ns  = t_elap_ns;
        OUT             = 1'b0;
    
        case(curr_state)
        
            INACTIVE:   begin
                next_t_elap_ns   = 0;
                if(button_press) begin next_state = PULSE; end   
            end
            
            
            PULSE:      begin
                
                OUT         = 1'b1;
                
                if(t_elap_ns >= (DUR_CNT - INC_CNT)) begin
                    next_state  = INACTIVE;
                    next_t_elap_ns   = 0;  
                end
                
                else begin 
                    next_state  = PULSE;
                    next_t_elap_ns = t_elap_ns + INC_CNT; 
                end
            end
            /*
            INC:        begin
                OUT         = 1'b1;
                
                if(t_elap_ns >= DUR_CNT) begin
                    next_state  = INACTIVE;
                    next_t_elap_ns   = 0;  
                end
                
                else begin
                    next_state  = PULSE;
                    next_t_elap_ns = t_elap_ns + INC_CNT;
                end
            end
            */
    
            default:    begin
                OUT         = 1'b0;
                next_state  = INACTIVE;
                next_t_elap_ns   = 0; 
            end
        endcase
    end
    
endmodule
