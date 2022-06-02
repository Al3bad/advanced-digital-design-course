module HDMI_controller (
  input             CLK_PX,
  input             RST_n,
  input             INV,
  input      [23:0] PX,
  input      [23:0] TXT_PX,
  output reg [18:0] PX_ADDR,
  output reg [13:0] TXT_PX_ADDR,
  output            HDMI_CLK,
  output            DE,
  output            HSYNC,
  output            VSYNC,
  output     [23:0] HDMI_PX
);

assign HDMI_CLK = CLK_PX;

//=============================================
// ==> Parameters
//=============================================

// Display res = 640 x 480 @ 60Hz
// Pixel Clk = 25 Mhz

parameter H_BACK_PORCH  = 6'd48;
parameter H_ACTIVE_AREA = 10'd640;
parameter H_FRONT_PORCH = 5'd16;
parameter H_SYNC_WIDTH  = 7'd96;
parameter H_TOTAL_PX    = H_BACK_PORCH + H_ACTIVE_AREA + H_FRONT_PORCH + H_SYNC_WIDTH;

parameter V_BACK_PORCH  = 6'd33;
parameter V_ACTIVE_AREA = 10'd480;
parameter V_FRONT_PORCH = 5'd10;
parameter V_SYNC_WIDTH  = 7'd2;
parameter V_TOTAL_PX    = V_BACK_PORCH + V_ACTIVE_AREA + V_FRONT_PORCH + V_SYNC_WIDTH;

parameter IMG_X = 640;
parameter IMG_Y = 480;

parameter MARGIN = 2;
parameter OVERLAY_START_X = MARGIN;
parameter OVERLAY_END_X   = OVERLAY_START_X + 100;

// Hight of the letter = 10px
// Margin between words and borders = 2px
// Two lines = (2 * 10px) + (3 * 2px)
parameter OVERLAY_START_Y = V_ACTIVE_AREA - 30 - (MARGIN * 5);
parameter OVERLAY_END_Y   = V_ACTIVE_AREA;

//=============================================
// ==> Wires / registers
//=============================================

reg [7:0]  RED;
reg [7:0]  GREEN;
reg [7:0]  BLUE;

reg [9:0] counter_x;
reg [9:0] counter_y;

reg [9:0] counter_overlay_x;
reg [9:0] counter_overlay_y;

reg [13:0] counter_overlay;

wire end_reached_h;
wire end_reached_v;

wire active_h;
wire active_v;
wire active;

wire active_overlay_h;
wire active_overlay_v;
wire active_overlay;

wire overlay_end_reached_h;
wire overlay_end_reached_v;

assign end_reached_h    = (counter_x == H_TOTAL_PX);
assign end_reached_v    = (counter_y == V_TOTAL_PX);

assign overlay_end_reached_h    = (counter_overlay_x == OVERLAY_END_X - MARGIN - 1);
assign overlay_end_reached_v    = (counter_overlay_y + OVERLAY_START_Y >= OVERLAY_END_Y);

assign active_h         = (counter_x > H_BACK_PORCH && counter_x <= (H_BACK_PORCH + H_ACTIVE_AREA));
assign active_v         = (counter_y > V_BACK_PORCH && counter_y < (V_BACK_PORCH + V_ACTIVE_AREA));
assign active           = active_h && active_v;

assign active_overlay_h = ((counter_x - H_BACK_PORCH) > OVERLAY_START_X) && ((counter_x - H_BACK_PORCH) <= OVERLAY_END_X);
assign active_overlay_v = ((counter_y - V_BACK_PORCH) > OVERLAY_START_Y) && ((counter_y - V_BACK_PORCH) <= OVERLAY_END_Y);
assign active_overlay   = active_overlay_h && active_overlay_v;

assign HSYNC            = !(counter_x > H_TOTAL_PX - H_SYNC_WIDTH);
assign VSYNC            = !(counter_y >= V_TOTAL_PX - V_SYNC_WIDTH);
assign DE               = active;
assign HDMI_PX          = {RED, GREEN, BLUE};


//=============================================
// ==> Horizontal & vertical counters
//=============================================

always @(posedge CLK_PX, negedge RST_n) begin
  if (!RST_n) begin
    // reset
    counter_x <= 0;
    counter_y <= 0;
  end
  else begin
    // h counter
    if (end_reached_h) counter_x <= 0;
    else counter_x <= counter_x + 1'b1;
    // v counter
    if (end_reached_h) begin
      if (end_reached_v) counter_y <= 0;
      else counter_y <= counter_y + 1'b1;
    end
  end
end

//=============================================
// ==> Horizontal & vertical overlay counters
//=============================================

always @(posedge CLK_PX, negedge RST_n) begin
  if (!RST_n) begin
    // reset
    counter_overlay_x <= 0;
    counter_overlay_y <= 0;
  end
  else begin
    if (active_overlay) begin
      // h counter_overlay
      counter_overlay_x <= (overlay_end_reached_h)?  0 : counter_overlay_x + 1'b1;
      // v counter_overlay
      if (overlay_end_reached_h)
        counter_overlay_y <= (overlay_end_reached_v)? 0 : counter_overlay_y + 1'b1;
    end
    else if (overlay_end_reached_v)
        counter_overlay_y <= 0;
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
    TXT_PX_ADDR <= 0;
    counter_overlay <= 0;
  end
  else begin

    if (active) begin
      // Draw gradient (black-white)
      // {RED, GREEN, BLUE} <= {RED + 1'b1, GREEN + 1'b1, BLUE + 1'b1};
      if (active_overlay) begin
        counter_overlay <= 1'b1;
        // Display pixels
        {RED, GREEN, BLUE} <= {TXT_PX[7:0], TXT_PX[7:0], TXT_PX[7:0]};

        // Select word for the first line
        if (counter_overlay_y == 1) TXT_PX_ADDR <= (INV)? 14'd1300 : 14'd 100;
        // Select word for the second line
        else if (counter_overlay_y == 12) TXT_PX_ADDR <= 14'd2400;
        else if (counter_overlay_y == 24) TXT_PX_ADDR <= 14'd4700;
        // Retrive the pixels of the current word
        else TXT_PX_ADDR <= TXT_PX_ADDR + 1'b1;

      end
      else if (INV)
        {RED, GREEN, BLUE} <= ~{PX[7:0], PX[7:0], PX[7:0]};
      else
        {RED, GREEN, BLUE} <= {PX[7:0], PX[7:0], PX[7:0]};
      PX_ADDR <= PX_ADDR + 1'b1;
    end
    else begin
      // black px when not in active area
      {RED, GREEN, BLUE} <= {8'h00, 8'h00, 8'h00};
    end
    if (end_reached_v) begin
      PX_ADDR <= 0;
      TXT_PX_ADDR <= 0;
      counter_overlay <= 0;
    end
  end
end

endmodule
