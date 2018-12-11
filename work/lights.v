module lights
(
input [2:0] floornum,
input [1:0] state,
output reg [6:0] floorseg,
output reg [6:0] stateseg
);

always @(floornum)begin
   case(floornum)
	3'b000: floorseg=7'b1111110;//0
	3'b001: floorseg=7'b0110000;//1 
	3'b010: floorseg=7'b1101101;//2
	3'b011: floorseg=7'b1111001;//3
	3'b100: floorseg=7'b0110011;//4
	3'b101: floorseg=7'b1011011;//5
	3'b110: floorseg=7'b1011111;//6
	3'b111: floorseg=7'b1110000;//7
	default:floorseg=7'b0000000;//defaults to no lights on
   endcase 
end
always @(state)begin
   case(state)
	2'b01: stateseg=7'b0111110;//Up
	2'b10: stateseg=7'b0111101;//down 
	default:stateseg=7'b0000000;//defaults to no lights on
   endcase 
end
endmodule 