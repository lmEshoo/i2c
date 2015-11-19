`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:32:27 11/05/2015 
// Design Name: 
// Module Name:    I2CSlave 
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
module I2CSlave(clk,reset,scl,sda, DOUT, addr, datar,W
    );

inout scl, sda;
input clk, reset;
input [7:0] DOUT;
output  reg W;
output reg[4:0] addr;
output reg [7:0] datar;
reg [7:0] my_addr;
reg [7:0] fR, Txr,RAM;
reg sda_int;
reg scl_int;
reg Nb,dir;
reg state;
wire fsda,fscl;
wire cne,cpe,dne,dpe;

Filter CLOCK1(scl, reset, clk ,fscl, cne, cpe);
Filter data(sda, reset, clk ,fsda, dne,dpe);


always @ (posedge clk)
begin


if (reset)
state<=1;
case (state)


0: begin//state 0
	sda_int<=1;
	scl_int<=1;
	if(dpe&fscl)
		state<=1;
	else
	state<=0;
	end
1: 
begin
sda_int<=1;
	scl_int<=1;
	if (dne&fscl) begin Nb<=8; state<=2; end
	else state<=1;
end
	
2: 
begin
	if(Nb==0 && datar[7:0]==my_addr)
	begin dir<=datar[0]; state<=3;end
	else if (Nb==0 && !datar[7:0]==my_addr)
	begin state<=0; end
	else if (Nb!=0 && cpe==0)
	begin state<=2;end
	else if (Nb==0 && cpe==1)
	begin datar<={datar[6:0],fsda}; Nb<=Nb-1;state<=2; end
end
3: 
begin
if(cne) begin sda_int<=0; state<=4; end
else state<=3;
end

4:
begin
if (cne) begin sda_int<=1; Nb<=8; state<=5; end
else state<=4;
end

5:
begin
if(Nb==0) state<=6;
else if( Nb!=0 && cpe==0) begin state<=5; end
else if (Nb!=0 && cpe==1) begin addr<={addr[3:0], fsda}; Nb<=Nb-1; end // Only using the least 5 significant bits.
end

6:
begin
if (cne) begin sda_int<=0; state<=7;end
else state<=6;
end

7: 
begin
if(cne==0) state<=7;
else if (cne==1 && dir==1) begin sda_int<=1; Nb<=8; state<=11; end
else if (cne==1 && dir==0) begin sda_int<=1; Nb<=8; state<=8; end
end

8:
begin
if(dne&fscl) state<=1;
else if (!(dne&fscl) && Nb!=0 && !cpe) state<=8;
else if (!(dne&fscl) && Nb==0) begin W<=0; addr<=addr+1; state<=9; end
else if (!(dne&&fscl) && Nb!=0 && cpe)begin  datar<={datar[6:0],fsda}; Nb<=Nb-1; end
end

9:
begin
if(cne) begin sda_int<=0; state<=10; end
else state<=9;
end

10:
begin
if(cne) begin sda_int<=1; Nb<=8; state<=8;end
else state<=10;
end

11:
begin
sda_int<=1; scl_int<=1;
if( dpe&fscl) state=1;
else if(!(dpe&fscl) && (! dne& fscl)) state<=11;
else if(!(dpe&fscl) && (dne& fscl)) begin Nb<=8; state<=12; end
end

12:
begin
if( Nb!=0 && cpe==0) state<=12;
else if(  Nb!=0 && cpe==1) begin datar<={datar[6:0],fsda}; Nb<= Nb-1; state<=12; end 
else if (Nb==0 && datar[7:1]==my_addr && datar[0]==1) begin Txr<=DOUT; Nb=8; addr<=addr+1; state<=13; end
else if(Nb==0 && datar[7:1]!=my_addr) state<=0;
else if(Nb==0 && datar[7:1]==my_addr && datar[0]==0) state<=0;
end

13: 
begin
if(cne) state<=13;
else  state<=14;
end

14:
begin
sda_int<=Txr[7]; state<=15;
end

15:
begin
if (dpe&fscl) state<=1;
else if(!dpe&fscl && Nb!=0 && cne==0) state<=15;
else if(!dpe&fscl && Nb!=0 && cne==1) begin Txr<={Txr[6:0], 1'b1}; Nb<=Nb-1; state<=14; end
else if(!dpe&fscl && Nb==0) begin sda_int<=1; state<=16; end
end
 16: 
 begin
 if(!cpe) state<=16;
 else if( cpe && sda) state<=0;
 else if (cpe && !sda) begin Txr<=RAM[addr]; Nb<=8; addr<=addr+1; state=13; end
end
endcase
end//always
endmodule	
		
	
	
	






