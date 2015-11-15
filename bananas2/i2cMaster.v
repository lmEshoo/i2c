`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:00:55 10/08/2015 
// Design Name: 
// Module Name:    I2c 
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
module i2cMaster(go, done, ready, rw, N_Byte, dev_add, dwr, R_Pointer,
drd,ack_e, reset,clk ,scl,sda,led);
input go,rw;
input clk;
input [5:0] N_Byte;
input [6:0] dev_add;
input [7:0] dwr;
input [7:0] R_Pointer;
input reset;
output reg [7:0] drd=0;
output reg ack_e=0;
output ready;
output reg done=1;
inout scl;
inout sda;
output [3:0] led;
//reg scl_int=0;
//reg sda_int=0;
reg [3:0] state=0,state1=0,state2=0;
reg [7:0] RTX=0;
reg [7:0] RRX=0;
reg [7:0] R=0;
reg [5:0] NB=0;
reg [9:0] count=0;
reg stretch=1'b0;
reg Q3=0;

reg [3:0] bc=0;
reg R_W=0;
reg scl_int=1'b1, sda_int=1'b1;

wire rbit;
wire ne;
wire pe;
wire wbit;
wire idle;
assign scl = (scl_int) ? 1'bz: 1'b0;
assign sda = (sda_int) ? 1'bz: 1'b0;

assign ne = (count ==0);
assign wbit = (count ==10'b0100000000);
assign pe = (count ==  10'b1000000000);
assign rbit = (count ==10'b1100000000);

//assign ready = (state==0 ); //testing
assign ready = ((state==5 & !R_W) | (state==10 & NB>0) | (state==13) ) & wbit;//sack2 
//assign ready = (  && wbit==1); //sack 
//assign ready = (  && wbit==1); //mack 
assign idle=(scl & sda); //new added
//count 
always @ (posedge clk)
begin
		if (reset == 1'b1)
			begin
			count <= 0;
			end
		else
		begin
			if (state == 0)
				count <= 0;
			else
				begin
				if (stretch == 1'b0)
					count <= count + 1;
				end
		end
end
//i2c first one//////////////////////////////////////////////
always @ (posedge clk)
begin
	if (reset)
	begin
		stretch <= 0;
		//count <= 0;
		Q3 <= 0;
	end
	else if (pe)
		Q3 <= 1'b1;
		else if (rbit)
			Q3 <= 1'b0;
			else if (Q3)
				begin
				if (scl == 1'b0) // z
					stretch <= 1'b1;
				else
					stretch <= 1'b0;
				end
end
///////////////////////////////////////////////
assign led=state;
//master stuff
always @(posedge clk)
begin
if( reset)begin
	scl_int<=1'b1; sda_int<=1'b1; drd<=0; done<=1'b1; ack_e<=1'b0; state<=0; //changed drd from 1'b0 to 0
end
else 
		case(state)
		//waiting
		0:begin 
					if(go&&idle)begin 
						RTX<=R_Pointer; NB<=N_Byte; R_W<=rw; ack_e<=1'b0; done<=1'b0; R<={dev_add,1'b0}; state<=1; end //if
					else begin  scl_int<=1'b1; sda_int<=1'b1; state<=0; end //else
				end //case 0
		//start		
		1:begin  if(rbit)begin sda_int<=1'b0; state<=1;end //added new
				else begin 
					//if(ne&&(sda==0))begin  scl_int<=1'b0; bc<=8; state<=2; end		//you sure it's 8? 
					//else state<=1;
					if(ne)begin scl_int<=1'b0; bc<=8; state<=2; end
				end //else
			end //case1
		//d_add
		2:begin if(wbit)begin
						if(bc>0)begin
							sda_int<=R[bc-1]; bc<=bc-1; state<=2;
							end
						else state<=2;	
				   end //wbit
					else begin if(pe)begin scl_int<=1'b1; state<=2;end
							else begin if(ne)begin
											if(bc==0)begin
												scl_int<=1'b0; sda_int<=1'b1; state<=3; 
											end 
											else begin scl_int<=1'b0; state<=2;
											end
											end 
										  else state<=2;
										end
					end //
			end //case2
		//sack1
		3:begin  if(pe)begin
						scl_int<=1'b1; state<=3;
					end//pe
				  else begin
						if (rbit) begin
							if(sda!=1'b0)begin 
								ack_e<=1'b1; state<=3;
							end
							else begin
								ack_e<=1'b0; state<=3;
							end
						end
						else begin
							if(ne)begin
								scl_int<=1'b0; sda_int<=1'b1;bc<=8;state<=4;
							end
							else begin
								state<=3;
							end
						end
				  end //else
			
		end //case3
		//wr_rp
		4:begin if(wbit)begin
						if(bc>0)begin
							sda_int<=RTX[bc-1]; bc<=bc-1; state<=4;
						end
						else state<=4;
					end //wbit
				  else begin
						if(pe)begin
							scl_int<=1'b1; state<=4;
						end//pe
						else begin 
							if(ne)begin
								if(bc==0)begin
									scl_int<=1'b0; sda_int<=1'b1; state<=5;
								end//if bc
								else begin
									scl_int<=1'b0; state<=4;
								end//else
							end//ne
							else state<=4;
						end
						end
		end //case4
		//sack2
		5:begin if(pe)begin
						scl_int<=1; state<=5;
					end
				  else begin
						if(rbit)begin
							if(sda!=1'b0) begin ack_e<=1'b1; state<=5; end
							else begin ack_e<=1'b0; state<=5; end
						end
						else begin
							if (ne) begin 
								if(R_W) begin
									scl_int<=1'b0; sda_int<=1'b1; bc<=8; state<=6;
								end
								else begin 
									scl_int<=1'b0; sda_int<=1'b1; bc<=8; RTX<=dwr; state<=9;
								end
							end //if ne
							else state<=5;
						end
				  end //else pe
		end //case5
		//Sr
		6: begin if (wbit)begin
					scl_int<=1'b1; state<=6;
				end//wbit
				else begin
					if (rbit)begin
						sda_int<=1'b0; state<=6;
					end //rbit
					else begin
						if(ne&&sda==1'b0) begin
							scl_int<=1'b0; bc<=8; R<={dev_add,1'b1}; state<=7;
						end //werid if
						else state<=6;
					end //else rbit
				end //else wbit
		end //case6
		
		//d_add1
		7:begin if(wbit) begin
					if(bc>0) begin
					sda_int<=R[bc-1];bc<=bc-1;state<=7;
					end
					else state<=7;
					end
					else begin
						if(pe) begin
						scl_int<=1'b1; state<=7;
						end
						else begin
						if(ne)begin
							if(bc==0) begin
							scl_int<=1'b0;sda_int<=1'b1;state<=8;
							end
							else begin
									scl_int<=1'b0; state<=7;
								end
							end //if ne
						else state<=7;
						end
					end
		end //case7
		//sack3
		8: begin if (pe) begin
						scl_int<=1'b1; state<=8;
					end//pe
					else begin
						if(rbit) begin
							if(sda!=1'b0)begin
								ack_e<=1'b1; state<=8;
							end
							else begin ack_e<=1'b0; state<=8;end
						end//if rbit
						else begin
							if(ne)begin
								scl_int<=1'b0; sda_int<=1'b1; bc<=8; state<=12; //go to rd state
							end
							else state<=8;
						end //else rbit
					end//else pe
		end //case 8
		//wr
		9:begin if (wbit)begin
						if(bc>0)begin
							sda_int<=RTX[bc-1]; bc<=bc-1; state<=9;
						end//bc>0
						else state<=9;
					end //wbit
					else begin
						if(pe) begin
							scl_int<=1'b1; state<=9;
						end //pe
						else begin
							if(ne)begin
								if(bc==0)begin
									scl_int<=1'b0; sda_int<=1'b1; NB<=NB-1; state<=10; //go to next state sack
								end //bc==0
								else begin
									scl_int<=1'b0; state<=9;
								end
							end //if ne
							else begin
								state<=9;
							end //ne else
						end//if pe else
					end

		end //case 9
		//sack
		10:begin if(pe)begin 
					scl_int<=1'b1; state<=10;
				end //if pe
				else begin
					if (rbit)begin
						if(sda!=1'b0)begin
							ack_e<=1'b1; state<=10;
						end //sda
						else begin
							ack_e<=1'b0; state<=9; //go back to wr
						end //else sda
					end //rbit
					else begin
						if (ne)begin
							if(NB>0)begin
								scl_int<=1'b0; sda_int<=1'b1; bc<=8; RTX<=dwr; state<=9; //go back to state wr
							end //NB
							else begin
								scl_int<=1'b0; sda_int<=1'b0; state<=11; //go to next state stop
							end //else NB
						end //if ne
						else state<=10; //go back to wr
					end//else rbit
				end //else pe
		 end //case10
		 //stop
		 11:begin if (pe)begin
		 			scl_int<=1'b1; state<=11; //go back to stop
		 		end //pe
		 		else begin
		 			if (rbit)begin
		 				sda_int<=1'b1; state<=11; //go back to stop
		 			end //if rbit
		 			else begin
		 				if(ne)begin
		 					scl_int<=1'b1; sda_int<=1'b1; drd<=0; ack_e<=1'b0; done<=1; state<=0; //make sure to change back to 0; go to state waiting=0 //check drd!!! and check DONE!!!
		 				end
		 				else state<=11; //go back to stop
		 			end //else rbit
		 		end//else pe
		 	end //case11
		 //rd
		 12:begin if (pe)begin
		 			scl_int<=1'b1; state<=12;
		 		end //if pe
		 		else begin
		 			if(rbit)begin
		 				if(bc>0)begin
		 					RRX[bc-1]<=sda; bc<=bc-1; state<=12; //go back to rd // check WHAT IS RRX!!!
		 				end//if bc
		 				else state<=12; //go back to rd
		 			end //if rbit
		 			else begin
		 				if(ne)begin
		 					if(bc==0)begin
		 						scl_int<=1'b0; drd<=RRX; NB<=NB-1; RRX<=1'b0; state<=13; //go to next state mack // WHAT IS RRX!!!
		 					end //if bc
		 					else begin	
		 						scl_int<=1'b0; state<=12; //go back to rd
		 					end //else bc
		 				end //if ne
		 				else state<=12; //go back to rd
		 			end //else rbit
		 		end //else pe
		 end //case12
		 //mack
		 13:begin if (wbit)begin
		 			if(NB>0)begin
		 				sda_int<=1'b0; state<=13; //go back to mack
		 			end //if NB
		 			else begin
		 				sda_int<=1'b1; state<=13; //go back to mack
		 			end //else NB
		 		end //if wbtit
		 		else begin
		 			if (pe) begin
		 				scl_int<=1'b1; state<=13; //go back to mack
		 			end //if pe
		 			else begin
		 				if(ne)begin
		 					if(NB>0)begin
		 						scl_int<=1'b0; bc<=8; sda_int<=1'b1; state<=12; //go back to previous state rd
		 					end //if NB
		 					else begin
		 						scl_int<=1'b0; bc<=8; sda_int<=1'b0; state<=11; //go back to stop
		 					end //else NB
		 				end //if ne
		 				else state<=13;
		 			end //else pe
		 		end //else wbit
		 end //case13
		endcase

end //begin clk
endmodule
