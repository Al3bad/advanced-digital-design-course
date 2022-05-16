// ----------------------------------------------
// Author       : Abdullah Alabbad
// Description  : Clock generator
// ----------------------------------------------

module clk_gen (
  input CLK,
  input RST_n,
  output reg CLK_PX,
  output reg CLK_I2C
);

//=============================================
// ==> Parameters
//=============================================
parameter EN_CLK          = 1'b1;       // WARN: DO NOT TOUCH THIS
parameter CTR_NUM         = 2;          // Number of counters

// PX counter config
// For 25MHz clock:
//    counter width  = 4-bits
//    preload value  = 14
parameter CTR_IDX_PX      = 1'b0;       // WARN: DO NOT TOUCH THIS
parameter CTR_WIDTH_PX    = 4'd4;       // Counter width
parameter CTR_PRELOAD_PX  = 4'd14;      // Preload value

// I2C counter config
// For 10 kHz clock:
//    counter width  = 12-bits
//    num of counts  = 20ns * X = 50us ==> 2500 counts
//    preload value  = 2^15 - 2500 = 1596
parameter CTR_IDX_I2C     = 1'b1;       // WARN: DO NOT TOUCH THIS
parameter CTR_WIDTH_I2C   = 5'd12;      // Counter width
parameter CTR_PRELOAD_I2C = 15'd1596;   // Preload value


//=============================================
// ==> Wires / registers
//=============================================
wire [CTR_NUM - 1:0] ctr_exp;         // Wires for the expired counters
reg  [CTR_NUM - 1:0] ctr_load_sig;    // Wires for the load signal

//=============================================
// ==> Counters
//=============================================
// PX counter
counter #(CTR_WIDTH_PX) ctr_px (
  .CLK(CLK),
  .RST_n(RST_n),
  .EN(EN_CLK),
  .load_toggle(ctr_exp[CTR_IDX_PX]),
  .load_value(CTR_PRELOAD_PX),
  .count_complete(ctr_exp[CTR_IDX_PX])
);

// I2C counter
counter #(CTR_WIDTH_I2C) ctr_i2c (
  .CLK(CLK),
  .RST_n(RST_n),
  .EN(EN_CLK),
  .load_toggle(ctr_load_sig[CTR_IDX_I2C]),
  .load_value(CTR_PRELOAD_I2C),
  .count_complete(ctr_exp[CTR_IDX_I2C])
);


//=============================================
// ==> Reload handler
//=============================================
always @(posedge CLK) begin
  // Reload PX counter
  case (ctr_exp[CTR_IDX_PX])
    1:        ctr_load_sig[CTR_IDX_PX] = 1'b1;
    0:        ctr_load_sig[CTR_IDX_PX] = 1'b0;
    default:  ctr_load_sig[CTR_IDX_PX] = 1'b1;
  endcase
  // Reload I2C counter
  case (ctr_exp[CTR_IDX_I2C])
    1:        ctr_load_sig[CTR_IDX_I2C] = 1'b1;
    0:        ctr_load_sig[CTR_IDX_I2C] = 1'b0;
    default:  ctr_load_sig[CTR_IDX_PX] = 1'b1;
  endcase
end

//=============================================
// ==> Clk generators (Drive output)
//=============================================
always @(ctr_exp, RST_n) begin
  if (!RST_n) begin
    CLK_I2C <= 0;
    CLK_PX <= 0;
  end
  else begin
    // Generate PX clock
    if (ctr_exp[CTR_IDX_PX]) CLK_PX <= ~CLK_PX;
    // Generate I2C clock
    if (ctr_exp[CTR_IDX_I2C]) CLK_I2C <= ~CLK_I2C;
  end
end

endmodule

