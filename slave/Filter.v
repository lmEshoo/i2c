`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:42:59 11/05/2015 
// Design Name: 
// Module Name:    Filter 
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
module Filter(sig, reset, clk ,fsig, ne, pe
    );
	 input sig, reset, clk;
	 output reg  fsig;
output	 ne, pe;
	 reg [7:0] fR;
	 reg state=0;
	 wire A0s, A01;

	assign A0s = (fR == 0);	 
	assign A1s= (fR==8'hFF);
	assign ne = A0s & fsig;
	assign pe= !fsig & A1s;
	 always @ (posedge clk)
begin//alwasy
	 	 if(reset)
		 begin 
		 fR<=0; fsig<=0; state<=1;
		 end
		 case (state)
 1: 
	 begin
		 fR<={sig,fR[7:1]};
		 
		 if(A0s) begin fsig<=0; state<=1;end
		 else if(A0s==0 && A1s==0) state<=1;
		 else if(A0s==0 && A1s==1) begin fsig<=1; state<=1; end
	 end
	 
endcase
end
endmodule
