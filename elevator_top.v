module toplevel
(
input clk, reset, Dsensor, Emergency,
Dopen, Dclose,
F1, F2, F3, F4,
F1up, F2down, F2up,
F3down, F3up, F4down,
output reg [6:0] floordisp,
output reg [6:0] statedisp
);
reg [2:0] floor;
reg [1:0] state;
wire [6:0] tempseg1, tempseg2;


endmodule 