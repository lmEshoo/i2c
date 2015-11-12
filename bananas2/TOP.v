`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:48:53 10/22/2015 
// Design Name: 
// Module Name:    TOP 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module TOP(clk, reset, dataout, control,led,led1,sda, scl); // do we need to include sdl and sda here?
input clk,reset;
inout sda,scl;
output [3:0] dataout;
output [2:0] control;
output [3:0] led, led1;
wire go,done, ready, rw, ack_e, W;
wire [5:0] N_Byte;
wire [6:0] dev_add;
wire [7:0] dwr,R_Pointer,drd,DIN;
wire [4:0] WADD;

i2cMaster I2c(go, done, ready, rw, N_Byte, dev_add, dwr, R_Pointer,drd,ack_e, reset,clk ,scl,sda,led );
controller Control(clk,done,ready,drd,ack_e,go, rw, N_Byte, dev_add, dwr, R_Pointer,W,WADD,DIN,led1 );//copy this to the contorller 

LCDI display (clk, DIN,W,WADD, dataout, control);
endmodule
