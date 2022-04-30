// ----------------------------------------------
// Author       : Abdullah Alabbad
// Description  : Top-lvl design - alarm system
// Last updated : 24/4/2022
// ----------------------------------------------

module lab_4_alarm_system (
  input CLK_50MHz,
  input [3:0] SW,
  input [1:0] KEY,
  output [7:0] LED
);

//    -------------------------------------------------------------------------------------------------
//   |    7     |    6    |    5    |      4     |      3     |     2      |      1       |     0      |
//    -------------------------------------------------------------------------------------------------
//   | DISARMED | ARMED/T | ------- | T (zone 3) | T (zone 2) | T (zone 1) | T (flashing) |     T      |
//    -------------------------------------------------------------------------------------------------

wire [4:0] current_state;

parameter RESET              = 5'h0;
parameter DISARMED           = 5'h1;
parameter ARMED_PENDING      = 5'h2;
parameter ARMED              = 5'h3;
parameter TRIGGERED          = 5'h4;
parameter TRIGGERED_RESET    = 5'h5;
parameter CHECK_ZONE_1       = 5'h6;
parameter CHECK_ZONE_2       = 5'h7;
parameter CHECK_ZONE_3       = 5'h8;
parameter ZONE_1_ON          = 5'h9;
parameter ZONE_2_ON          = 5'ha;
parameter ZONE_3_ON          = 5'hb;
parameter ZONE_1_OFF         = 5'hc;
parameter ZONE_2_OFF         = 5'hd;
parameter ZONE_3_OFF         = 5'he;
parameter DELAY              = 5'hf;
parameter PANIC              = 5'h10;
parameter PANIC_RESET        = 5'h11;
parameter UPDATE             = 5'h12;


//=============================================
// ==> Wires / registers
//=============================================

wire SYS_RST;
wire KEY0;
wire KEY1;
wire [2:0] zone_sensor;
reg [7:0] LED_REG;

//=============================================
// ==> Input connections
//=============================================

assign zone_sensor[0]   = SW[0];
assign zone_sensor[1]   = SW[1];
assign zone_sensor[2]   = SW[2];
assign SYS_RST          = ~SW[3];
assign KEY0             = ~KEY[0];
assign KEY1             = ~KEY[1];

//=============================================
// ==> Clock sources (DONE)
//=============================================

// Generate a 3 kHz clk with a prescaler of 2^14
// - 50MHz / 2^14 ==>     327.68 us for half cycle
// - So, 500Hz / 2^13 ==> 327.68 us for full cycle
wire CLK_3kHz;
clk_src #(14 - 1'b1) clk0(
  .iCLK(CLK_50MHz),
  .iRST(1'b0),
  .start_at(13'h00),
  .out(CLK_3kHz)
);

// Generate 10 Hz or 100 ms clk (50ms LOW, 50ms HIGH)
// - We need to figure out the number count required with 3 kHz clk
// - 100 ms / 327.68 us = 305 counts
// - Again, this values should be devided by 2 which gives 152
// - So, we need at least 2^8 = 256 counter
// - So, start counting from 256 - 152 = 102
// wire CLK_100ms;
// clk_src #(8) clk1(
//   .iCLK(CLK_3kHz),
//   .iRST(SYS_RST),
//   .start_at(8'd102),
//   .out(CLK_100ms)
// );

// Generate 20 Hz or 50 ms clk
// - We need to figure out the number count required with 3 kHz clk
// - 50 ms / 327.68 us = 152.58 counts
// - Again, this values should be devided by 2 which gives 76
// - So, we need at least 2^7 = 128 counter
// - So, start counting from 128 - 76 = 52
wire CLK_50ms;
clk_src #(7) clk2(
  .iCLK(CLK_3kHz),
  .iRST(1'b0),
  .start_at(7'd52),
  .out(CLK_50ms)
);

//=============================================
// ==> SR latches for the keys (DONE)
//=============================================

wire panic_key;
wire arm_key;

key_debounce kd0(
  .iCLK(CLK_50ms),
  .iRST(SYS_RST),
  .in(KEY0),
  .out(panic_key)
);

key_debounce kd1(
  .iCLK(CLK_50ms),
  .iRST(SYS_RST),
  .in(KEY1),
  .out(arm_key)
);

//=============================================
// ==> Strobe light
//=============================================

// 2.5 Hz = 400 ms = 100 ms * 4
// 2.5 Hz = 50 ms = 50 ms * 8
reg [3:0] counter_400ms;
reg strobe_light;

always @(posedge CLK_50ms) begin
  if (counter_400ms == 4'h04) begin
    strobe_light = ~strobe_light;
    counter_400ms = 0;
  end
  counter_400ms = counter_400ms + 1'b1;
end

//=============================================
// ==> SR latch for SW
//=============================================
wire [2:0] zone_sensor_latched;
sr_latch srl0 (
  .S(zone_sensor[0]),
  .R(arm_key | SYS_RST),
  .Q(zone_sensor_latched[0])
);
sr_latch srl1 (
  .S(zone_sensor[1]),
  .R(arm_key | SYS_RST),
  .Q(zone_sensor_latched[1])
);
sr_latch srl2 (
  .S(zone_sensor[2]),
  .R(arm_key | SYS_RST),
  .Q(zone_sensor_latched[2])
);

//=============================================
// ==> State machine
//=============================================

reg [2:0] zone_detected;
reg strobe_light_en;
reg siren_en;
reg triggered_armed_en;
reg disarmed_en;
reg latch_sw;

state_machine fsm(
  .iCLK(CLK_50ms),
  .iRST(SYS_RST),
  .panic_key(panic_key),
  .arm_key(arm_key),
  .zone_sensor(zone_sensor),
  .state(current_state)
);

always @(posedge CLK_3kHz) begin
  case (current_state)
    RESET: begin
      strobe_light_en    <= 1'b0;
      siren_en           <= 1'b0;
      zone_detected      <= 3'b000;
      triggered_armed_en <= 1'b0;
      disarmed_en        <= 1'b0;
    end
    DISARMED: begin
      strobe_light_en    <= 1'b0;
      siren_en           <= 1'b0;
      // zone_detected      = 3'b000;   // Controlled by ZONE_X_[ON|OFF] states
      triggered_armed_en <= 1'b0;
      disarmed_en        <= 1'b1;
    end
    ARMED_PENDING: begin
      strobe_light_en    = 1'b0;
      siren_en           = 1'b0;
      zone_detected      = 3'b000;
      triggered_armed_en = 1'b0;
      disarmed_en        = 1'b1;
    end
    ARMED: begin
      strobe_light_en    <= 1'b0;
      siren_en           <= 1'b0;
      // zone_detected      = 3'b000;
      triggered_armed_en <= 1'b1;
      disarmed_en        <= 1'b0;
    end
    TRIGGERED: begin
      strobe_light_en    <= 1'b1;
      siren_en           <= 1'b1;
      // zone_detected      = 3'b000;   // Controlled by ZONE_X_[ON|OFF] states
      zone_detected[2:0] = zone_sensor_latched[2:0];
      triggered_armed_en = 1'b1;
      disarmed_en        = 1'b0;
    end
    // UPDATE: begin
    //   zone_detected      = zone_sensor;
    // end
    ZONE_1_ON: begin
      zone_detected[0] <= 1'b1;
    end
    ZONE_2_ON: begin
      zone_detected[1] <= 1'b1;
    end
    ZONE_3_ON: begin
      zone_detected[2] <= 1'b1;
    end
    ZONE_1_OFF: begin
      zone_detected[0] <= 1'b0;
    end
    ZONE_2_OFF: begin
      zone_detected[1] <= 1'b0;
    end
    ZONE_3_OFF: begin
      zone_detected[2] <= 1'b0;
    end
    PANIC: begin
      strobe_light_en    = 1'b1;
      siren_en           = 1'b1;
      // zone_detected      = 3'b000;   // Controlled by nothing
      triggered_armed_en = 1'b1;
      disarmed_en        = 1'b0;
    end
    default: begin
      // default state
    end
  endcase

end

//=============================================
// ==> Output connections
//=============================================

// assign LED[4:0] = current_state[4:0];

assign LED[0] = siren_en;
assign LED[1] = strobe_light_en? strobe_light : 1'b0;

assign LED[2] = zone_detected[0];
assign LED[3] = zone_detected[1];
assign LED[4] = zone_detected[2];

// assign LED[5] = 1'b0;
assign LED[5] = arm_key | panic_key;

assign LED[6] = triggered_armed_en;
assign LED[7] = disarmed_en;

endmodule
