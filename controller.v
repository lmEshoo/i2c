`timescale 1ns / 1ps
//initialize inputs and output
//check case 12?
//LCDI

module controller(go,done, ready, rw, N_Byte, dev_add, dwr, R_Pointer, drd, ack_e);
input ready, done,ack_e;
input drd[7:0];
output go, rw, N_Byte[5:0], dev_add[6:0], dwr[7:0], R_Pointer[7:0];

//LCDI Initials
//do we need dataout and control?
output [3:0] dataout;
output [2:0]control;
reg [0:7]Din;
reg [5:0] WADD;
reg W ;
LCDI Display(clk, Din,W,WADD, dataout, control);
initial begin 
	count<=0;
	W<=0;
end

//binary to BCD
reg [3:0] Dt2,Dt1;
reg [7:0] PR;
reg [1:0] s=0;
always @(posedge clk)begin
	case (s)
		0:if(P[7]) begin PR<= -P; Dt2 <= 0; Dt1<=0; s <= 1; end
		    else begin PR<= P ; Dt2 <= 0; Dt1<=0; s <= 1; end
		2:if(PR > 9)begin PR <= PR - 10; Dt1 <= Dt1 + 1; end
		   else begin s <= 0;D2 <= Dt2; D1 <= Dt1; 
		                   D0 <= PR[3:0] ; end
		default: s <= 0;
	endcase
end


wire go;
assign go = (state == 1 || state==7);
always @(posedge clk)
begin
if( reset)begin
	case(state)
	//s0
	0: begin if(done)begin
				rw=0; N_byte=2; R_Pointer=Conf_R_add; dev_add=device_addresss; state=1; //go to next state:go
			end
			//else done
			else state=0;
	end //case0
	//S1
	1: begin state=2; end //go to next state:S2
	//S2
	2: begin if(ready)begin
				dwr=conifg_first_byte; state=3; //go to next state:S3
			end
			//else done
			else state=2;
	end //case2
	//S3
	3: state=4; //go to next state:S4
	//S4
	4: begin if(ready)begin
				dwr=conifg_second_byte; state=5; //go to next state:S5
			end
			//else done
			else state=4; //go back to S4
	end //case4
	//S5
	5: begin if(done)begin
				state=6; //go to next state:S6
			end
			//else done
			else state=5; //go back to S5
	end //case5
	//S6
	6: begin if(done)begin
				//rw1. N_Byte2, R_PointerTemp_R_add,dev_add device_address
				rw=1; N_byte=2; R_Pointer=Temp_R_add; dev_add=device_address; state=7; //go to next state:S7
			end
			//else done
			else state=6; //go back to S6
	end //case6
	//S7
	7: begin state=8; end  //go to next state:S8
	//S8
	8: begin if(ready)begin
				data[15:8]=drd; state=9; //go to next state:S9
			end
			//else done
			else state=8; //go back to S8
	end //case8
	//S9
	9: begin if(ready)begin
				data[7:0]=drd; state=10; //go to next state:S10
			end
			//else done
			else state=9; //go back to S9
	end //case9
	//S10
	10: begin if(date[12])begin
				T=256-date[11:4]; state=11; //go to next state:S11
			end
			//else done
			else begin
				T=date[11:4]; state=11; //go to next state:S11
			end //else ready
	end //case10
	//S11
	11: begin if(done)begin
				state=12
			end //if done
			else begin
				state=11;
			end //else done
	end //case11
	//S12
	12:begin
		//Convert T to BCD and display it
		W<=1; WADD<=5'b000000; Din={D1,D0}; 
	end //case12

	endcase

end// if reset
end //always
endmodule
