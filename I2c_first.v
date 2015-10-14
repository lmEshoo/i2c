//initialize inputs and output

module I2c_first();
always @(posedge clk)
begin
if( reset)begin
	stretch=1'b0; Q3=1'b0;
	case(state)
	0: begin if(pe)begin
				Q3=1'b1; state=0;
			end //ifpe
			else begin
				if(rbit)begin
					Q3=1'b0; state=0;
				end //if rbit
				else begin
					if(Q3)begin
						if(scl)begin
							stretch=1'b0; state=0;
						end //if scl
						else begin
							stretch=1'b1; state=0;
						end //else scl
					end //if Q3
					else begin
						Q3=1'b0;
						state=0;
					end //else Q3
				end //else rbit
			end //endpe

	end //case0
	endcase

end// if reset
end //always
endmodule
