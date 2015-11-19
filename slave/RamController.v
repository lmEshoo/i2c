`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:40:59 11/05/2015 
// Design Name: 
// Module Name:    Controller 
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
module RamController(E,clk, data, WADD, DIN, W);
input clk, E ;
input [3:0] data;
output reg [4:0] WADD=0;
output reg [7:0] DIN;
output reg W;
reg state;
reg reset=0;

always @ (posedge clk)
begin
if(reset)
begin state<=0;end


case (state)

0:
begin 
WADD<=0; state<=1;
end

1:
begin
if(E) begin DIN[7:4]<=data; state<=2; end
else begin state<=1;end
end

2:
begin
if(E) begin DIN[3:0]<=data; state<=3; end
else state<=2;

end

3:
begin
W<=1; WADD<=WADD+1; state<=4;
end
4:
begin
if(WADD ==32) state<=0;
else state<=1;
end



endcase
end
endmodule
