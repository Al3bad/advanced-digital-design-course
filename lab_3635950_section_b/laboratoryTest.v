
module laboratoryTest(
  input CLOCK50,
  // KEY
  input   [1:0]       KEY,      // Push buttons
  // SW
  input   [2:0]       SW,       // Slide switches
  // LEDs
  output  [5:0]       LED
);

//=============================================
// ==> Wires / registers
//=============================================
wire reset_n = SW[0];
wire WLF = SW[1];
wire WLE = SW[2];
wire P;
wire S;
wire CLK_SLOW;

//=============================================
// ==> Clk generator (DONE)
//=============================================
clk_gen #(
  // num of counts  = (1/50MHz) * x = (1/250kHz) / 2 ==> x = 100 counts
  // counter width  = 2^x = 100 ==> x = ceil(6.64) = 7-bits
  // preload value  = 2^7 - 100 = 28
  .CTR_WIDTH(3'd7),
  .CTR_PRELOAD(7'd28)
  ) clk_gen (
  .CLK(CLOCK50),
  .RST_n(reset_n),
  .CLK_OUT(CLK_SLOW)
);

//=============================================
// ==> Key debouncers
//=============================================
key_debounce kd0 (
  .CLK(CLK_SLOW),
  .RST_n(reset_n),
  .in(~KEY[0]),
  .out(P)
);

key_debounce kd1 (
  .CLK(CLK_SLOW),
  .RST_n(reset_n),
  .in(~KEY[1]),
  .out(S)
);

//=============================================
// ==> State machine
//=============================================
state_machine sm(
  .CLK(CLK_SLOW),
  .RST_n(reset_n),
  .P(P),
  .S(S),
  .WLF(WLF),
  .WLE(WLE),
  .out(LED)
);



endmodule
