`timescale 1ns / 1ps
//initialize inputs and output
//check case 12?

module controller();
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
	1: state=2; //go to next state:S2
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
	7: state=8; //go to next state:S8
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
	end //case12

	endcase

end// if reset
end //always
endmodule
