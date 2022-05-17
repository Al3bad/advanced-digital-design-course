module HDMI_controller (
  input  CLK_PX,
  input  RST_n,
  output HDMI_CLK,
  output  DE,
  output  HSYNC,
  output  VSYNC,
  output reg [7:0] RED,
  output reg [7:0] GREEN,
  output reg [7:0] BLUE
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

//=============================================
// ==> Wires / registers
//=============================================

reg [9:0] x_counter;
reg [9:0] y_counter;

wire h_end_reached;
wire y_end_reached;
wire active;

assign h_end_reached = (x_counter == H_TOTAL_PX - 1);
assign y_end_reached = (y_counter == V_TOTAL_PX - 1);
assign active = (x_counter > H_BACK_PARCH && x_counter < (H_BACK_PARCH + H_ACTIVE_AREA)) && (y_counter > V_BACK_PARCH && y_counter < (V_BACK_PARCH + V_ACTIVE_AREA));
assign HSYNC = !(x_counter > H_BACK_PARCH + H_ACTIVE_AREA + H_FRONT_PARCH);
assign VSYNC = !(y_counter == V_TOTAL_PX - 1 || y_counter == V_TOTAL_PX - 2);
assign DE = active;

//=============================================
// ==> Horizontal pixels
//=============================================

// Horizontal
always @(posedge CLK_PX, negedge RST_n) begin
  if (!RST_n) begin
    // reset
    x_counter <= 0;
  end
  else begin
    // logic
    if (h_end_reached)
      x_counter <= 0;
    else
      x_counter <= x_counter + 1;
  end
end

//=============================================
// ==> Vertical pixels
//=============================================
always @(posedge CLK_PX, negedge RST_n) begin
  if (!RST_n) begin
    // reset
    y_counter <= 0;
  end
  else begin
    // logic
    if (h_end_reached) begin
      if (y_end_reached)
        y_counter <= 0;
      else
        y_counter <= y_counter + 1;
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
  end
  else begin
    // logic
    if (active) begin
      {RED, GREEN, BLUE} <= {RED + 1'b1, GREEN + 1'b1, BLUE + 1'b1};
    end
    else begin
      {RED, GREEN, BLUE} <= {8'h00, 8'h00, 8'h00};
    end
  end
end

endmodule
