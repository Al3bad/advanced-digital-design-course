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

//=============================================
// ==> Wires / registers
//=============================================

wire SYS_RST;
wire [2:0] zone_clk;
wire [2:0] zone_sensor;

wire CLK_10Hz;
wire current_state;

wire [2:0] zone_light;
wire armed;
wire triggered;
wire disarmed;
wire strobe_light;

wire panic_key;
wire panic_rst;
wire arm_key;
wire arm_rst;

reg [7:0] LED_REG;

//=============================================
// ==> Input connections
//=============================================

assign zone_sensor[0]   = SW[0];
assign zone_sensor[1]   = SW[1];
assign zone_sensor[2]   = SW[2];
assign SYS_RST          = SW[3];

//=============================================
// ==> SR latches for the keys
//=============================================

// sr_latch sr(
//   .S(~KEY[0]),
//   .R(SYS_RST | panic_rst),
//   .Q(panic_key)
// );
//
// sr_latch sr1(
//   .S(~KEY[1]),
//   .R(SYS_RST | arm_rst),
//   .Q(arm_key)
// );

key_debounce kd1(
  .iCLK(CLK_50MHz),
  .iRST(SYS_RST),
  .in(~KEY[0]),
  .out(panic_key)
);

key_debounce kd2(
  .iCLK(CLK_50MHz),
  .iRST(SYS_RST),
  .in(~KEY[1]),
  .out(arm_key)
);

//=============================================
// ==> Clock sources
//=============================================

// Generate a 3 kHz clk with a prescaler of 2^14
// - 50MHz / 2^14 ==>     327.68 us for half cycle
// - So, 500Hz / 2^13 ==> 327.68 us for full cycle
wire CLK_3kHz;
clk_src #(14 - 1'b1) clk0(
  .iCLK(CLK_50MHz),
  .iRST(SYS_RST),
  .start_at(13'h00),
  .out(CLK_3kHz)
);

// Generate 10 Hz or 100 ms clk (50ms LOW, 50ms HIGH)
// - We need to figure out the number count required with 3 kHz clk
// - 100 ms / 327.68 us = 305 counts
// - Again, this values should be devided by 2 which gives 152
// - So, we need at least 2^8 = 256 counter
// - So, start counting from 256 - 152 = 102
wire CLK_1ms;
clk_src #(8) clk1(
  .iCLK(CLK_3kHz),
  .iRST(SYS_RST),
  .start_at(8'd102),
  .out(CLK_100ms)
);

// 10 sec          = 100 ms * 100
// 5 sec           = 100 ms * 50
// 2.5 Hz = 400 ms = 100 ms * 4

reg [2:0] x;
reg [3:0] counter_400ms;
reg [5:0] counter_5sec;
reg [6:0] counter_10sec;


always @(posedge CLK_100ms, posedge SYS_RST) begin
  if (SYS_RST) begin
    x = 0;
    counter_400ms = 0;
    counter_5sec = 0;
    counter_10sec = 0;
  end
  else begin
    if (counter_400ms == 4'd2) begin
      x[0] = ~x[0];
      counter_400ms = 0;
    end
    if (counter_5sec == 6'd50) begin
      x[1] = ~x[1];
      counter_5sec = 0;
    end
    if (counter_10sec == 7'd100) begin
      x[2] = ~x[2];
      counter_10sec = 0;
    end
    counter_400ms = counter_400ms + 1'b1;
    counter_5sec = counter_5sec + 1'b1;
    counter_10sec = counter_10sec + 1'b1;
  end
end

//=============================================
// ==> State machine
//=============================================

// state_machine fsm(
//   .iCLK(CLK_10Hz),
//   .RST(SYS_RST),
//   .panic_key(panic_key),
//   .arm_key(arm_key),
//   .zone_sensor(),
//   .state(current_state)
// );
//
// parameter RESET         = 4'h0;
// parameter DISAREMED     = 4'h1;
// parameter ARMED_PENDING = 4'h2;
// parameter ARMED         = 4'h3;
// parameter PANIC         = 4'hf;
//
// always @(current_state) begin
//   LED_REG[5] = 1'b0;
//
//   case (current_state)
//     RESET: begin
//       LED_REG = 8'b00000000;
//     end
//     DISAREMED: begin
//       LED_REG[0] = 1'b0;
//       LED_REG[1] = 1'b0;
//       LED_REG[4:2] = zone_sensor[2:0];
//       LED_REG[6] = 1'b0;
//       LED_REG[7] = 1'b1;
//     end
//     ARMED_PENDING: begin
//       LED_REG = 8'b10000000;
//     end
//     ARMED: begin
//       LED_REG = 8'b01000000;
//     end
//     PANIC: begin
//       LED_REG[0] = 1'b1;
//       LED_REG[1] = strobe_light;
//       LED_REG[7:2] = 6'b010000;
//     end
//     default: begin
//       // default state
//     end
//   endcase
//
// end

//=============================================
// ==> Output connections
//=============================================

// assign LED[7:0] = LED_REG[7:0];
//
// assign LED[0] = triggered;
// assign LED[1] = triggered? strobe_light : 1'b0;
//
// assign LED[2] = zone_light[0];
// assign LED[3] = zone_light[1];
// assign LED[4] = zone_light[2];
//
// assign LED[5] = 1'b0;
//
// assign LED[6] = armed | triggered;
// assign LED[7] = disarmed;

endmodule
