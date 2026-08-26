`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/25/2026 06:38:30 PM
// Design Name: 
// Module Name: tb_utils_pkg
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

package tb_utils_pkg;

    /*
        Class testcase
        
        - Purpose : track test number and number of errors
    
    
    */
    class testcase;
    
        int err_cnt     = 0;
        int testnum     = 0;
        
        function void new_test(input string mes);
            testnum++;
            err_cnt = 0;
            $display("\nStarting TC%0d : %s", testnum, mes);
        endfunction
        
        function void err(input string mes); 
            err_cnt++; 
            $display("|\tERROR: %s", mes);
        endfunction: err 

        function void test_done();
            $display("TC%0d complete : %0d ERRORS\n", testnum, err_cnt);
        endfunction
    
    endclass
endpackage