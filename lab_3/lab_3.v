// Lab 3

// Author       : Abdullah Alabbad
// Description  : Top-lvl design
// Last updated : 07/4/2022

module lab_3 (
  input   [2:0]   SW,
  output  [7:0]   LED
);
// wires connected to physical switches
wire master_rst = SW[2];        // Connected to SW3 on the physical board
wire latch_rst = SW[1];         // Connected to SW1 on the physical board
wire latch_set = SW[0];         // connected to SW0 on the physical board

// wires
wire CLK;                       // latched clk signal
wire [7:0] Q [7:0];             // internal wires for regester files

// Output
assign LED[7:0] = Q[7];


//=============================================
// ==> Clock driven by the input switch (SW0-SW1)
//=============================================
sr_latch SR(
  .R(latch_rst),
  .S(latch_set),
  .Q(CLK)
);

//=============================================
// ==> register file that holds my student num
//=============================================
// my student number - 3635950
d_flip_flop DFF0(
  .CLK(CLK),
  .RST(master_rst),
  .PRELOAD(8'h03),
  .D(Q[7]),
  .Q(Q[0])
);

d_flip_flop DFF1(
  .CLK(CLK),
  .RST(master_rst),
  .PRELOAD(8'h06),
  .D(Q[0]),
  .Q(Q[1])
);

d_flip_flop DFF2(
  .CLK(CLK),
  .RST(master_rst),
  .PRELOAD(8'h03),
  .D(Q[1]),
  .Q(Q[2])
);

d_flip_flop DFF3(
  .CLK(CLK),
  .RST(master_rst),
  .PRELOAD(8'h05),
  .D(Q[2]),
  .Q(Q[3])
);

d_flip_flop DFF4(
  .CLK(CLK),
  .RST(master_rst),
  .PRELOAD(8'h09),
  .D(Q[3]),
  .Q(Q[4])
);

d_flip_flop DFF5(
  .CLK(CLK),
  .RST(master_rst),
  .PRELOAD(8'h05),
  .D(Q[4]),
  .Q(Q[5])
);

d_flip_flop DFF6(
  .CLK(CLK),
  .RST(master_rst),
  .PRELOAD(8'h00),
  .D(Q[5]),
  .Q(Q[6])
);

// Inital value - zero
d_flip_flop DFF_start(
  .CLK(CLK),
  .RST(master_rst),
  .PRELOAD(8'h00),
  .D(Q[6]),
  .Q(Q[7])
);



endmodule
