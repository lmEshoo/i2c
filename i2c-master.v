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
module I2c(go, done, ready, rw, N_Byte, dev_add, dwr, R_pointer,
drd,ack_e, reset,clk );
input go,rw;
input [5:0] N_Byte;
input [6:0] dev_add;
input [7:0] dwr;
input [7:0] R_Pointer;
input reset;

output [7:0] drd;
output ack_e;
output ready, done;
inout scl;
inout sda;
reg scl_int=0;
reg sda_int=0;
reg state=0;
reg [7:0] RTX=0;
reg [7:0] R=0;
reg [5:0] NB=0;
reg rbit=0;
reg ne=0;
reg pe=0;
reg wbit=0;
reg [3:0] bc=0;
reg R_W=0;

always @(posedge clk)
begin
if( reset)begin
		scl_int=1'b1; sda_int=1'b1; drd=1'b0; done=1'b1; ack_e=1'b0; state=0;
	
		case(state)
		//waiting
		0:begin if(go&&idle)begin
					RTX=R_Pointer; NB=N_Byte; R_W=rw; ack_e=1'b0; done=1'b0; R={dev_add,1'b0}; state=1; end //if
					else begin scl_int=1'b1; sda_int=1'b1; state=0; end //else
				end //case 0
		//start		
		1:begin if(rbit)begin sda_int=1'b0;end
				else begin
					if(ne&&sda==0)begin scl_int=1'b0; bc=8; state=2; end		//you sure it's 8? 
					else state=1;
				end //else
			end //case1
		//d_add
		2:begin if(wbit)begin
						if(bc>0)begin
							sda_int=R[bc-1]; bd=bc-1; state=2;
							end
						else state=2;	
				   end //wbit
					else begin if(pe)begin scl_int=1'b1; state=2;end
							else begin if(ne)begin
											if(bc==0)begin
												scl_int=1'b0; sda_int=1'b1; state=3; 
											end 
											else begin scl_int=1'b0; state=2;
											end
											end 
										  else state=2;
										end
					end //
			end //case2
		//sack1
		3:begin if(pe)begin
						scl_int=1'b1; state=3;
					end//pe
				  else begin
						if (rbit) begin
							if(sda!=1'b0)begin 
								ack_e=1'b1; state=3;
							end
							else begin
								ack_e=1'b0; state=3;
							end
						end
						else begin
							if(ne)begin
								scl_int=1'b0; sda_int=1'b1;bc=8;state=4;
							end
							else begin
								state=3;
							end
						end
				  end //else
			
		end //case3
		//wr_rp
		4:begin if(wbit)begin
						if(bc>0)begin
							sda_int=RTX[bc-1]; bc=bc-1; state=4;
						end
						else state=4;
					end //wbit
				  else begin
						if(pe)begin
							scl_int=1'b1; state=4;
						end//pe
						else begin 
							if(ne)begin
								if(bc==0)begin
									scl_int=1'b0; sda_int=1'b1; state=5;
								end//if bc
								else begin
									scl_int=1'b0; state=4;
								end//else
							end//ne
							else state=4;
						end
						end
		end //case4
		//sack2
		5:begin if(pe)begin
						scl_int=1; state=5;
					end
				  else begin
						if(rbit)begin
							if(sda!=1'b0) begin ack_e=1'b1; state=5; end
							else begin ack_e=1'b0; state=5; end
						end
						else begin
							if (ne) begin 
								if(R_W) begin
									scl_int=1'b0; sda_int=1'b1; bc=8; state=6;
								end
								else begin 
									scl_int=1'b0; sda_int=1'b1; bc=8; RTX=dwr; state=9;
								end
							end //if ne
							else state=5;
						end
				  end //else pe
		end //case5
		//Sr
		6: begin if (wbit)begin
					scl_int=1'b1; state=6;
				end//wbit
				else begin
					if (rbit)begin
						sda_int=1'b0; state=6;
					end //rbit
					else begin
						if(ne&&sda==1'b0) begin
							scl_int=1'b0; bc=8; R={dev_add,1'b1}; state=7;
						end //werid if
						else state=6;
					end //else rbit
				end //else wbit
		end //case6
		
		//d_add1
		7:begin if(wbit) begin
					if(bc>0) begin
					sda_int=R[bc-1];bc=bc-1;state=7;
					end
					else state=7;
					end
					else begin
						if(pe) begin
						scl_int=1'b1; state=7;
						end
						else begin
						if(ne)begin
							if(bc==0) begin
							scl_int=1'b0;sda_int=1'b1;state=8;
							end
							else begin
									scl_int=1'b0; state=7;
								end
							end //if ne
						else state=7;
						end
					end
		end //case7
		//sack3
		8: begin if (pe) begin
						scl_int=1'b1; state=8;
					end//pe
					else begin
						if(rbit) begin
							if(sda!=1'b0)begin
								ack_e=1'b1; state=8;
							end
							else begin ack_e=1'b0; state=8;end
						end//if rbit
						else begin
							if(ne)begin
								scl_int=1'b0; sda_int=1'b1; bc=8; state=12; //go to rd state
							end
							else state=8;
						end //else rbit
					end//else pe
		end //case 8
		//wr
		9:begin if (wbit)begin
						if(bc>0)begin
							sda_int=RTX[bc-1]; bc=bc-1; state=9;
						end//bc>0
						else state=9;
					end //wbit
					else begin
						if(pe) begin
							scl_int=1'b1; state=9;
						end //pe
						else begin
							if(ne)begin
								if(bc==0)begin
									scl_int=1'b0; sda_int=1'b1; NB=NB-1; state=10;
								end //bc==0
								else begin
									scl_int=1'b0; state=9;
								end
							end //if ne
							else begin
								state=9;
							end //ne else
						end//if pe else
					end

		end //case 9
		endcase
end
end //begin clk
endmodule
