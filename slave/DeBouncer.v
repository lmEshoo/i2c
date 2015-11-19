`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:14:08 11/12/2015 
// Design Name: 
// Module Name:    DeBouncer 
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
module DeBouncer(clk, spb, E
    );
input spb,clk;
output E;
reg state=0;
reg SDC;
always @ (posedge clk)
begin
case (state)
0://SD0
begin
if(spb) begin SDC<=35000;state<=1;  end
else state<=0;
end

1://SD1
begin
SDC=SDC-1; 
if(SDC==0) state<=2;
else state<=1;
end

2://SD2
begin
if(spb) state<=3;
else state<=0;
end

3:// SD3
begin
if(spb) state<=3;
else  begin SDC<=5000; state<=4; end
end

4://SD4
begin
SDC=SDC-1;
if(SDC==0) state<=5;
else state<=4;
end

5://SD5
begin
E=1; state<=0;

end

endcase
end


endmodule
