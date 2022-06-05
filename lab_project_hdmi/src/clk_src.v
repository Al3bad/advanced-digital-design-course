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
parameter CTR_WIDTH_PX    = 2'd2;       // Counter width
parameter CTR_PRELOAD_PX  = 2'd2;       // Preload value

// I2C counter config
parameter CTR_WIDTH_I2C   = 3'd7;      // Counter width
parameter CTR_PRELOAD_I2C = 7'd28;     // Preload value

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

