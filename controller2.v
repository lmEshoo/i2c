module Controller(input clk, output [3:0] dataout, output [2:0]control );






reg [0:7]Din;

reg [32:0] count;

reg [5:0] WADD;

reg W ;

LCDI Display(clk, Din,W,WADD, dataout, control);

initial

begin 

count<=0;

W<=0;

end








always @ (posedge clk)




count<=count+1;




always @ (posedge clk)




case(count)

0:  W<=1;

1: begin WADD<=5'b000000; Din=8'h4C;end 

2: begin WADD<=5'b000001; Din=8'b 01001001;end 

3: begin WADD<=5'b000010; Din=8'b 01001110;end 

4: begin WADD<=5'b000011; Din=8'b 01001001;end



5: begin WADD<=5'b000100; Din=8'b 00100000;end



6: begin WADD<=5'b000101; Din=8'b 01001101;end

7: begin WADD<=5'b000110; Din=8'b 01000101;end

8: begin WADD<=5'b000111; Din=8'b 01010011;end

9: begin WADD<=5'b001000; Din=8'b 01010100;end

10: begin WADD<=5'b001001; Din=8'b 01000001;end

11: begin WADD<=5'b001010; Din=8'b 01010010;end 






12: begin WADD<=5'b10000; Din=8'b 01000001;end 

13: begin WADD<=5'b10001; Din=8'b 01010010;end 

14: begin WADD<=5'b10010; Din=8'b 01010000;end 

15: begin WADD<=5'b10011; Din=8'b 01001001;end  

16: begin WADD<=5'b10100; Din=8'b 01001110;end 

17: begin WADD<=5'b10101; Din=8'b 01000101;end 

18: begin WADD<=5'b10110; Din=8'b 01001000;end 

19: W<=0; 

endcase

endmodule
