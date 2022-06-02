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
  output              HDMI_CLK,       // Video clk
  output              HDMI_DE,        // Data enable signal
  output              HDMI_HS,        // Horizontal sync
  output              HDMI_VS,        // Vertical sync
  output [23:0]       HDMI_PX,         // Video data
  // Unused pins
  input               HDMI_INT,       // Interrupt signal
  output              HDMI_I2S0,         // I2S Channel 0 Audio Data Input
  output              HDMI_MCLK,         // Audio Reference Clock Input
  output              HDMI_SCLK,         // Audio Left/Right Channel SignalInput
  // GPIO
  output [3:0] GPIO_1
);

//=============================================
// ==> Wires / registers
//=============================================
wire RST_n = KEY[0];
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

// assign GPIO_1[0] = HDMI_DE? 1'b1 : 1'b0;
// assign GPIO_1[1] = HDMI_HS? 1'b1 : 1'b0;
// assign GPIO_1[2] = HDMI_VS? 1'b1 : 1'b0;

assign GPIO_1[0] = CLK_I2C;
assign GPIO_1[1] = I2C_SCL? 1'b1 : 1'b0;
assign GPIO_1[2] = I2C_SDA? 1'b1 : 1'b0;
assign GPIO_1[3] = 1'b0;

assign LED[0] = KEY[0];
assign LED[7:1] = 0;

//=============================================
// ==> Clk srcs
//=============================================

clk_src #(
  // PX counter config
  // For 25MHz clock:
  //    num of counts  = (1/50MHz) * x = (1/25MHz) / 2 ==> x = 1 counts
  .CTR_WIDTH_PX(2'd2),
  .CTR_PRELOAD_PX(2'd2),
  // I2C counter config
  // For 250 kHz clock:
  //    num of counts  = (1/50MHz) * x = (1/250kHz) / 2 ==> x = 100 counts
  //    counter width  = 2^x = 100 ==> x = cail(6.64) = 7-bits
  //    preload value  = 2^7 - 100 = 28
  .CTR_WIDTH_I2C(3'd7),
  .CTR_PRELOAD_I2C(7'd28)
  ) clk_src (
  .CLK(CLK_50MHz),
  .RST_n(RST_n),
  .CLK_PX(CLK_PX),
  .CLK_I2C(CLK_I2C)
);

//=============================================
// ==> Configure HDMI transmitter via I2C
//=============================================

parameter NUM_OF_CONFIG   = 14;      // Number of configuration in the memeory
parameter ADDR_WIDTH      = 4;       // 2^x = 14 = ceil(3.8) = 4-bits
parameter I2C_SLAVE_ADDR  = 8'h72;   // I2C slave address + write command
wire [15:0] HDMI_CONFIG_MEM [NUM_OF_CONFIG-1:0];
wire [ADDR_WIDTH-1:0] config_addr;
wire ready;

// ROM containing ADV7513 config
// Refernce: ADV7513 programming guide - Quick start guide - page 14
// Configure ADV7513 to use:
//    - HDMI
//    - RGB colour space
//    - 4:4:4 video format

//                          mem_addr payload
assign HDMI_CONFIG_MEM[0]  = {8'h15, 8'h20};
assign HDMI_CONFIG_MEM[1]  = {8'h16, 8'h30};
assign HDMI_CONFIG_MEM[2]  = {8'h17, 8'h00};
assign HDMI_CONFIG_MEM[3]  = {8'h18, 8'h46};
assign HDMI_CONFIG_MEM[4]  = {8'h41, 8'h10};
assign HDMI_CONFIG_MEM[5]  = {8'h97, 8'h00};
assign HDMI_CONFIG_MEM[6]  = {8'h98, 8'h03};
assign HDMI_CONFIG_MEM[7]  = {8'h9A, 8'hE0};
assign HDMI_CONFIG_MEM[8]  = {8'h9C, 8'h30};
assign HDMI_CONFIG_MEM[9]  = {8'h9D, 8'h61};
assign HDMI_CONFIG_MEM[10] = {8'hA2, 8'hA4};
assign HDMI_CONFIG_MEM[11] = {8'hA3, 8'hA4};
assign HDMI_CONFIG_MEM[12] = {8'hAF, 8'h16};
assign HDMI_CONFIG_MEM[13] = {8'hF9, 8'h00};

// The data should contain "slave address" + "memory address" + "data"
I2C_controller #(
  .I2C_SLAVE_ADDR(I2C_SLAVE_ADDR),
  .NUM_OF_CONFIG(NUM_OF_CONFIG),
  .ADDR_WIDTH(ADDR_WIDTH)
) i2c(
  .CLK_I2C(CLK_I2C),
  .RST_n(RST_n),
  .CONFIG(HDMI_CONFIG_MEM[config_addr]),
  .config_addr(config_addr),
  .I2C_SCL(I2C_SCL),    // CLK
  .I2C_SDA(I2C_SDA),    // DATA
  .ready(ready)
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
// ==> TXT ROM
//=============================================

// Notes:
//    - Memory size should be limited to (2^17) × 3 = 393216 becouse of hardware limitation
wire [13:0] TXT_PX_ADDR;
wire [23:0] TXT_PX;

TXT_MEM rom_txt(
  .clock(CLK_50MHz),
  .address(TXT_PX_ADDR),
  .q(TXT_PX[7:0])
);

//=============================================
// ==> Display the img
//=============================================

HDMI_controller ig (
  .CLK_PX(CLK_PX),
  .RST_n(RST_n || ready),
  .PX(PX),
  .PX_ADDR(PX_ADDR),
  .TXT_PX(TXT_PX),
  .TXT_PX_ADDR(TXT_PX_ADDR),
  .HDMI_CLK(HDMI_CLK),
  .DE(HDMI_DE),
  .HSYNC(HDMI_HS),
  .VSYNC(HDMI_VS),
  .HDMI_PX(HDMI_PX),
  .MODE(SW[1:0])
);

endmodule

