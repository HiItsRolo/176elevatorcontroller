module toplevel
(
input clk, reset, Dsensor, Emergency,
Dopen, Dclose,
F1, F2, F3, F4,
F1up, F2down, F2up,
F3down, F3up, F4down,
output reg [6:0] floordisp,//7-segment display for current floor
output reg [6:0] statedisp,//7-segment display for current state
output emergencylight//emergency light
);
wire [2:0] tempfloor;
wire [1:0] tempstate;
reg [2:0] floor;
reg [1:0] state;
wire [6:0] fseg, sseg;//Floorsegment and state segment

elevatorController eC1(
clk, reset, Dsensor, Emergency, Dopen, Dclose,
F1, F2, F3, F4, F1up, F2down, F2up, F3down, F3up, F4down,
tempstate, tempfloor);

always@(*)begin
   state <= tempstate;
   floordisp <= fseg;
   statedisp <= sseg;
end

always@(*)begin
   if(tempfloor == 0)
      floor <= 1;
   else if(tempfloor == 2)
      floor <= 2;
   else if(tempfloor == 4)
      floor <= 3;
   else if(tempfloor == 6)
      floor <= 4;
   else
      floor <= floor;
end

lights lut1(
floor, state,
fseg, sseg);

assign emergencylight = Emergency;
endmodule 