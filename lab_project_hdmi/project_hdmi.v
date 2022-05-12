// ----------------------------------------------
// Author       : Abdullah Alabbad
// Description  : Top-lvl design - Display img on a monitor via HDMI interface
// ----------------------------------------------

module project_hdmi (
  input               CLK_50MHz,
  // KEY
  input   [1:0]       KEY,
  // SW
  input   [3:0]       SW,                // Slide switches
  // LEDs
  output  [7:0]       LED,
  // I2C
  inout               I2C_SDA,           // I2C data
  output              I2C_SCL,           // I2C clock
  // HDMI
  output              HDMI_TX_CLK,       // Video clk
  output              HDMI_TX_DE,        // Data enable signal
  output              HDMI_TX_HS,        // Horizontal sync
  output              HDMI_TX_VS,        // Vertical sync
  output [23:0]       HDMI_TX_D,         // Video data
  // Unused pins
  input               HDMI_TX_INT,       // Interrupt signal
  output              HDMI_I2S0,         // I2S Channel 0 Audio Data Input
  output              HDMI_MCLK,         // Audio Reference Clock Input
  output              HDMI_SCLK          // Audio Left/Right Channel SignalInput
);

//=============================================
// ==> Connect unused pins to ground
//=============================================
assign HDMI_I2S0 = 1'b0;
assign HDMI_MCLK = 1'b0;
assign HDMI_SCLK = 1'b0;

//=============================================
// ==> Wires / registers
//=============================================
wire RST_n = KEY[0];
wire CLK_PX;
wire CLK_I2C;

//=============================================
// ==> Clk srcs
//=============================================

clk_gen clk_gen(
  .CLK(CLK_50MHz),
  .RST_n(RST_n),
  .CLK_PX(CLK_PX),
  .CLK_I2C(CLK_I2C)
);

//=============================================
// ==> TODO: Configure HDMI via I2C
//=============================================

// I2C clk
// The data should contain "slave address" + "memory address" + "data"


endmodule

