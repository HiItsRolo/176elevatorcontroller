module lights
(
input [2:0] floornum,
input [1:0] state,
output reg [6:0] floorseg,
output reg [6:0] stateseg
);

always @(floornum)begin
   case(floornum)
	3'b000: floorseg<=7'b0000001;//0
	3'b001: floorseg<=7'b1001111;//1 
	3'b010: floorseg<=7'b0010010;//2
	3'b011: floorseg<=7'b0000110;//3
	3'b100: floorseg<=7'b1001100;//4
	3'b101: floorseg<=7'b0100100;//5
	3'b110: floorseg<=7'b0100000;//6
	3'b111: floorseg<=7'b0001111;//7
	default:floorseg<=7'b1111111;//defaults to no lights on
   endcase 
end
always @(state)begin
   case(state)
	2'b01: stateseg<=7'b1000001;//Up
	2'b10: stateseg<=7'b1000010;//down 
	default:stateseg<=7'b1111111;//defaults to no lights on
   endcase 
end
endmodule 