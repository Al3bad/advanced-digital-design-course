module HDMI_controller (
  input             CLK_PX,
  input             RST_n,
  input      [23:0] PX,
  input             INV,
  output reg [18:0] PX_ADDR,
  output            HDMI_CLK,
  output            DE,
  output            HSYNC,
  output            VSYNC,
  output reg [7:0]  RED,
  output reg [7:0]  GREEN,
  output reg [7:0]  BLUE
);

assign HDMI_CLK = CLK_PX;

//=============================================
// ==> Parameters
//=============================================

// Display res = 640 x 480 @ 60Hz
// Pixel Clk = 25 Mhz

parameter H_BACK_PARCH  = 6'd48;
parameter H_ACTIVE_AREA   = 10'd640;
parameter H_FRONT_PARCH = 5'd16;
parameter H_SYNC_WIDTH  = 7'd96;
parameter H_TOTAL_PX    = H_BACK_PARCH + H_ACTIVE_AREA + H_FRONT_PARCH + H_SYNC_WIDTH;

parameter V_BACK_PARCH  = 6'd33;
parameter V_ACTIVE_AREA   = 10'd480;
parameter V_FRONT_PARCH = 5'd10;
parameter V_SYNC_WIDTH  = 7'd2;
parameter V_TOTAL_PX    = V_BACK_PARCH + V_ACTIVE_AREA + V_FRONT_PARCH + V_SYNC_WIDTH;

parameter IMG_X = 640;
parameter IMG_Y = 480;

//=============================================
// ==> Wires / registers
//=============================================

reg [9:0] counter_x;
reg [9:0] counter_y;

wire end_reached_h;
wire end_reached_v;
wire active;

assign end_reached_h = (counter_x == H_TOTAL_PX);
assign end_reached_v = (counter_y == V_TOTAL_PX);

assign active_h = (counter_x > H_BACK_PARCH && counter_x <= (H_BACK_PARCH + H_ACTIVE_AREA));
assign active_v = (counter_y > V_BACK_PARCH && counter_y < (V_BACK_PARCH + V_ACTIVE_AREA));
assign active = active_h && active_v;

assign HSYNC = !(counter_x > H_TOTAL_PX - H_SYNC_WIDTH);
assign VSYNC = !(counter_y >= V_TOTAL_PX - V_SYNC_WIDTH);
assign DE = active;


//=============================================
// ==> Horizontal pixels
//=============================================

// Horizontal
always @(posedge CLK_PX, negedge RST_n) begin
  if (!RST_n) begin
    // reset
    counter_x <= 0;
  end
  else begin
    // logic
    if (end_reached_h)
      counter_x <= 0;
    else
      counter_x <= counter_x + 1'b1;
  end
end

//=============================================
// ==> Vertical pixels
//=============================================
always @(posedge CLK_PX, negedge RST_n) begin
  if (!RST_n) begin
    // reset
    counter_y <= 0;
  end
  else begin
    // logic
    if (end_reached_h) begin
      if (end_reached_v)
        counter_y <= 0;
      else
        counter_y <= counter_y + 1'b1;
      end
  end
end

//=============================================
// ==> Active view
//=============================================
always @(posedge CLK_PX, negedge RST_n) begin
  if (!RST_n) begin
    // reset
    RED <= 0;
    GREEN <= 0;
    BLUE <= 0;
    PX_ADDR <= 0;
  end
  else begin
    // logic
    if (active) begin
      // Draw gradient (black-white)
      // {RED, GREEN, BLUE} <= {RED + 1'b1, GREEN + 1'b1, BLUE + 1'b1};

      // if (counter_y > IMG_Y + V_BACK_PARCH) begin
        // reset addr when the last row of the image is reached
      //   PX_ADDR <= 0;
      // end
      // else if (counter_x > IMG_X + H_BACK_PARCH)
        // black px when drawing outside the img
        // {RED, GREEN, BLUE} <= {8'h0, 8'h0, 8'h0};
      // Draw img on the top-left corner
      // else if (counter_x <= IMG_X + H_BACK_PARCH && counter_y <= IMG_Y + V_BACK_PARCH) begin
        // {RED, GREEN, BLUE} <= {PX[23:16], PX[15:8], PX[7:0]};
        if (INV)
          {RED, GREEN, BLUE} <= ~{PX[7:0], PX[7:0], PX[7:0]};
        else
          {RED, GREEN, BLUE} <= {PX[7:0], PX[7:0], PX[7:0]};
        PX_ADDR <= PX_ADDR + 1'b1;
      // end

    end
    else begin
      // black px when not in active area
      {RED, GREEN, BLUE} <= {8'h00, 8'h00, 8'h00};
    end

    if (end_reached_v)
      PX_ADDR <= 0;
  end
end

endmodule
