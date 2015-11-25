`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:28:28 11/19/2015 
// Design Name: 
// Module Name:    topSlave 
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
module topSlave( dataout, control, Pb1, switches, clk, reset, scl, sda,led,led1);
output [3:0] dataout;
input [3:0] switches;
output [2:0] control;
input Pb1, clk, reset;
inout scl, sda;
wire W1,W2, E;//W1 from slave to LCDI, W2 from the Ram controller to RAM
wire [4:0] WADDslave, WADDCtrl, addr;
wire [7:0] DINslave, DIN, DOUT; //DIN is output from RAMCtrl
output [3:0] led, led1;
//WADDslave=addr=WADD?
//how to get spb in Debouncer
LCDI lcd(clk, DINslave,W1,WADDslave, dataout, control);
RamController ramCtrl(E,clk, switches, WADDCtrl, DIN, W2,led1);
RAM ramm( clk,WADDCtrl, DIN, W2, WADDslave, DOUT);
DeBouncer debounce(clk, spb, E);
I2CSlave slave(clk,reset,scl,sda, DOUT, WADDslave, DINslave,W1,led);

endmodule
