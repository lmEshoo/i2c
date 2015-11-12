`timescale 1ns / 1ps
//initialize inputs and output
//check case 12?
//LCDI

module controller(clk,done,ready,drd,ack_e,go, rw, N_Byte, dev_add, dwr, R_Pointer,W,WADD,DIN,led1);
input ready, done,ack_e;
input clk;
input [7:0] drd;
output go;
output reg W;
output reg [4:0] WADD;
output reg [7:0]DIN;
output [4:0] led1;
output reg rw;
output reg [5:0] N_Byte=0;
output reg [6:0] dev_add=0;
output reg [7:0] dwr=0;
output reg [7:0] R_Pointer =8'b00000101;
reg reset=0;
reg [7:0] conifg_second_byte=0,conifg_first_byte=0, Temp_R_add=0;
reg [7:0] T=0;
reg [7:0] Conf_R_add=8'b00000001;
reg [6:0] device_address=7'b0011000;
reg [3:0] D1t,D2t=0;
reg [15:0]data=0 ;
//LCDI Initials
//do we need dataout and control?


reg [4:0] state=0;
initial begin 
	W<=0;
end



//binary to BCD
// Internal variable for storing bits
	reg [3:0] hundreds;
   reg [3:0] tens;
   reg [3:0] ones;
   reg [19:0] shift;
   integer i; 

  /* always @(drd)
   begin
      // Clear previous number and store new number in shift register
      shift[19:8] = 0;
      shift[7:0] = drd;
      
      // Loop eight times
      for (i=0; i<8; i=i+1) begin
         if (shift[11:8] >= 5)
            shift[11:8] = shift[11:8] + 3;
            
         if (shift[15:12] >= 5)
            shift[15:12] = shift[15:12] + 3;
            
         if (shift[19:16] >= 5)
            shift[19:16] = shift[19:16] + 3;
         
         // Shift entire register left once
         shift = shift << 1;
      end
      
      // Push decimal numbers to output
      hundreds = shift[19:16];
      tens     = shift[15:12];
      ones     = shift[11:8];
   end
*/
wire go;
assign go = (state == 1 || state==7 ); //added new
assign led1=state;
always @(posedge clk)

if( reset)begin
state<=0; 
end// if reset
else
	case(state)
	//s0
	0: begin 
				if(done)begin
				rw<=0; N_Byte<=2; R_Pointer<=Conf_R_add; dev_add<=7'b0011_000; state<=1; //go to next state:go
			end
			//else done
			else state<=0;
	end //case0
	//S1
	1: begin  state<=2; end //go to next state:S2
	//S2
	2: begin if(ready)begin
				dwr<=conifg_first_byte; state<=3; //go to next state:S3
				//conifg_first_byte is 0 in the begining
			end
			//else done
			else state<=2;
	end //case2
	//S3
	3: begin  state<=4; end  //go to next state:S4
	//S4
	4: begin  if(ready)begin
				dwr<=conifg_second_byte; state<=6; //go to next state:S5
			end
			//else done
			else state<=4; //go back to S4
	end //case4
	//S5
	5: begin 
			if(done)begin
				state<=6; //go to next state:S6
			end
			//else done
			else state<=5; //go back to S5
	end //case5
	//S6
	6: begin  
			if(done)begin
				rw<=1; N_Byte<=2; R_Pointer<=Temp_R_add; dev_add<=7'b0011_000; state<=7; //go to next state:S7
			end
			//else done
			else state<=6; //go back to S6
	end //case6
	//S7
	7: begin  state<=8; end  //go to next state:S8
	//S8
	8: begin  
			if(ready)begin
				data[15:8]<=drd; state<=9; //go to next state:S9
			end
			//else done
			else state<=8; //go back to S8
	end //case8
	//S9
	9: begin 
			if(ready)begin
				data[7:0]<=drd; state<=10; //go to next state:S10
			end
			//else done
			else state<=9; //go back to S9
	end //case9
	//S10
	10: begin  
			if(data[12])begin
				T<=256-data[11:4]; state<=11; //go to next state:S11
				//T<=8'd125; state<=11; //go to next state:S11
			end
			//else done
			else begin
				T<=data[11:4]; state<=11; //go to next state:S11
				//T<=8'd125; state<=11; //testing
			end //else ready
	end //case10
	//S11
	11: begin  
			if(done)begin
				state<=12;
			end //if done
			else begin
				state<=11;
			end //else done
	end //case11
	//S12
	12:begin
		D1t<=0; D2t<=0; state<=13;
		//Convert T to BCD and display it
		//W<=1; WADD<=5'b00000; DIN<={tens,ones}; W<=0;
		//testing LCD
		//W<=1; WADD<=5'b000000; DIN=8'h4C; W<=0;
	end //case12
	//S13
	13: begin
		if(T>99)begin D2t<=D2t+1; T<=T-100; state<=13; end
		else state<=14;
	end //case13
	
	//S14
	14: begin
		if(T>9)begin D1t<=D1t+1; T<=T-10; state<=14; end
		else state<=15;
	end //caste14
	//S15
	15: begin W<=1; DIN<=8'b01001001; WADD<=5'b10000; state<=16; end

	//S16
	16: begin W<=1; DIN<={4'b0011,D2t}; WADD<=5'b000000; state<=17; end

	//S17
	17: begin W<=1; DIN<={4'b0011,D1t}; WADD<=5'b000001; state<=18; end

	18: begin W<=1; DIN<={4'b0011,T[3:0]}; WADD<=5'b000010; state<=19;end
	//S19
	19: begin W<=0; state<=5;end
	endcase


endmodule
