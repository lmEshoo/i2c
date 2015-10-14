`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/06/2015 03:48:08 PM
// Design Name: 
// Module Name: MUX_2_TO_1
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


module MUX_2_TO_1(
    input A,
    input B,
    input S,
    output OUT
    );
    wire S_NOT, S_A, S_B;
    not(S_NOT, S);
    and(S_A, A, S);
    and(S_B, B, S_NOT);
    or(OUT, S_A, S_B);
endmodule
