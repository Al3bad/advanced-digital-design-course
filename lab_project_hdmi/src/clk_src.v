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
parameter CTR_WIDTH_PX    = 1'd1;       // Counter width
parameter CTR_PRELOAD_PX  = 1'd0;       // Preload value

// I2C counter config
parameter CTR_WIDTH_I2C   = 4'd9;      // Counter width
parameter CTR_PRELOAD_I2C = 9'd12;     // Preload value

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

