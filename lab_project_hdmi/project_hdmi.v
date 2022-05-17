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
  inout               I2C_SCL,           // I2C clock
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
  output              HDMI_SCLK,         // Audio Left/Right Channel SignalInput
  // GPIO
  inout [3:0] GPIO_1
);

//=============================================
// ==> Wires / registers
//=============================================
wire RST_n = KEY[0];
wire CLK_PX;
wire CLK_I2C;

//=============================================
// ==> Connection
//=============================================
// Connect unused pins to ground
assign HDMI_I2S0 = 1'b0;
assign HDMI_MCLK = 1'b0;
assign HDMI_SCLK = 1'b0;

assign GPIO_1[0] = CLK_I2C? 1'b1 : 1'b0;
assign GPIO_1[1] = I2C_SCL? 1'b1 : 1'b0;
assign GPIO_1[2] = I2C_SDA? 1'b1 : 1'b0;

assign LED[0] = KEY[0];

//=============================================
// ==> Clk srcs
//=============================================

clk_src clk_src(
  .CLK(CLK_50MHz),
  .RST_n(RST_n),
  .CLK_PX(CLK_PX),
  .CLK_I2C(CLK_I2C)
);

//=============================================
// ==> TODO: Configure HDMI via I2C
//=============================================

// The data should contain "slave address" + "memory address" + "data"
HDMI_I2C_controller i2c(
  .CLK_I2C(CLK_I2C),
  .RST_n(RST_n),
  .I2C_SCL(I2C_SCL),    // CLK
  .I2C_SDA(I2C_SDA)     // DATA
);

//=============================================
// ==> TODO: Display the img
//=============================================

// HDMI_controller ig (
//   .CLK_PX(CLK_PX),
//   .RST_n(RST_n),
//   .HDMI_CLK(HDMI_TX_CLK),
//   .DE(HDMI_TX_DE),
//   .HSYNC(HDMI_TX_HS),
//   .VSYNC(HDMI_TX_VS),
//   .RED(HDMI_TX_DATA[24:16]),
//   .GREEN(HDMI_TX_DATA[15:8]),
//   .BLUE(HDMI_TX_DATA[7:0])
// );

endmodule

