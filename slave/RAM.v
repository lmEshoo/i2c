`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:44:46 11/12/2015 
// Design Name: 
// Module Name:    RAM 
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
module RAM( clk,WADD, DIN, W, RADD, DOUT,
    );
input clk;
input [4:0] WADD;
input [7:0] DIN;
input [4:0] RADD;
input W;
output reg [7:0] DOUT;
reg [7:0] RAM [0:31];
integer i;
initial
 begin 
 for(i=0; i<16; i=i+1)
	begin 
		RAM[i]=8'hFE;
	end
end
always @ (posedge clk)
	if(W) begin RAM[WADD]<=DIN;
					DOUT<=RAM[RADD];
	end
	


endmodule
