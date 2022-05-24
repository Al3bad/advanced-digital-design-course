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
wire px_invert = SW[0];
wire CLK_PX;
wire CLK_I2C;

wire [7:0] RED;
wire [7:0] GREEN;
wire [7:0] BLUE;

//=============================================
// ==> Connection
//=============================================
// Connect unused pins to ground
assign HDMI_I2S0 = 1'b0;
assign HDMI_MCLK = 1'b0;
assign HDMI_SCLK = 1'b0;
assign HDMI_TX_D = {RED, GREEN, BLUE};

assign GPIO_1[0] = HDMI_TX_DE? 1'b1 : 1'b0;
assign GPIO_1[1] = HDMI_TX_HS? 1'b1 : 1'b0;
assign GPIO_1[2] = HDMI_TX_VS? 1'b1 : 1'b0;

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
// ==> Configure HDMI via I2C
//=============================================

// The data should contain "slave address" + "memory address" + "data"
HDMI_I2C_controller i2c(
  .CLK_I2C(CLK_I2C),
  .RST_n(RST_n),
  .I2C_SCL(I2C_SCL),    // CLK
  .I2C_SDA(I2C_SDA)     // DATA
);

//=============================================
// ==> IMG ROM
//=============================================
// Notes:
//    - Memory size should be limited to (2^17) × 3 = 393216 becouse of hardware limitation
wire [18:0] PX_ADDR;
wire [23:0] PX;

IMG_MEM_BW rom(
  .clock(CLK_50MHz),
  .address(PX_ADDR),
  .q(PX[7:0])
);

//=============================================
// ==> Display the img
//=============================================

HDMI_controller ig (
  .CLK_PX(CLK_PX),
  .RST_n(RST_n),
  .PX(PX),
  .PX_ADDR(PX_ADDR),
  .HDMI_CLK(HDMI_TX_CLK),
  .DE(HDMI_TX_DE),
  .HSYNC(HDMI_TX_HS),
  .VSYNC(HDMI_TX_VS),
  .RED(RED),
  .GREEN(GREEN),
  .BLUE(BLUE),
  .INV(px_invert)
);

endmodule

