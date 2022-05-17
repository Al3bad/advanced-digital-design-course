// ----------------------------------------------
// Author       : Abdullah Alabbad
// Description  : Clock generator
// ----------------------------------------------

module clk_src (
  input CLK,
  input RST_n,
  output CLK_PX,
  output CLK_I2C
);

//=============================================
// ==> Parameters
//=============================================
// PX counter config
// For 25MHz clock:
//    counter width  = 4-bits
//    preload value  = 14
parameter CTR_WIDTH_PX    = 4'd4;       // Counter width
parameter CTR_PRELOAD_PX  = 4'd14;      // Preload value

// I2C counter config
// For 10 kHz clock:
//    counter width  = 12-bits
//    num of counts  = 20ns * X = 50us ==> 2500 counts
//    preload value  = 2^12 - 2500 = 1596
parameter CTR_WIDTH_I2C   = 5'd12;      // Counter width
parameter CTR_PRELOAD_I2C = 15'd1596;   // Preload value

//=============================================
// ==> Counters
//=============================================
// PX counter
clk_gen #(.CTR_WIDTH(CTR_WIDTH_PX), .CTR_PRELOAD(CTR_PRELOAD_PX)) clk_px (
  .CLK(CLK),
  .RST_n(RST_n),
  .CLK_OUT(CLK_PX)
);

// I2C counter
clk_gen #(.CTR_WIDTH(CTR_WIDTH_I2C), .CTR_PRELOAD(CTR_PRELOAD_I2C)) clk_i2c (
  .CLK(CLK),
  .RST_n(RST_n),
  .CLK_OUT(CLK_I2C)
);

endmodule

