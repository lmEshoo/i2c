`timescale 1ns / 1ps

//initialize inputs and output

module counter();
always @(posedge clk)
begin
if( reset)begin
	counter=1'b0;
	case(state)
	0: begin if(state==waiting)begin
				counter=1'b0; state=0;
			end //if state
			else begin
				if(stretch=1'b0)begin
					counter=counter+1; state=0;
				end //stretch
				else begin
					state=0;
				end //else stretch
			end //else state

	end //case0
	endcase

end// if reset
end //always
endmodule
