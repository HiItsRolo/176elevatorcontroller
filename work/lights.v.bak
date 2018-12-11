module lights
(
input [2:0] floornum,
input state,
output reg [6:0] seg1,
output reg [6:0] seg2
);

always @(floornum)begin
   case(floornum)
	3'b000: seg1=7'b1111110;//0
	3'b001: seg1=7'b0110000;//1 
	3'b010: seg1=7'b1101101;//2
	3'b011: seg1=7'b1111001;//3
	3'b100: seg1=7'b0110011;//4
	3'b101: seg1=7'b1011011;//5
	3'b110: seg1=7'b1011111;//6
	3'b111: seg1=7'b1110000;//7
	default:seg1=7'b0000000;//defaults to no lights on
   endcase 
end
always @(state)begin
   case(state)
	1'b0: seg2=7'b0111110;//Up
	1'b1: seg2=7'b0111101;//down 
	default:seg2=7'b0000000;//defaults to no lights on
   endcase 
end
endmodule 