module state_machine (
  input iCLK,
  input iRST,
  input panic_key,
  input arm_key,
  input [2:0] zone_sensor,
  output reg counter_10sec_expired_out,
  output [4:0] state
);

//=============================================
// ==> States
//=============================================
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

parameter PANIC              = 5'h10;
parameter PANIC_RESET        = 5'h11;

//=============================================
// ==> Wires / registers
//=============================================

reg [4:0] current_state;
reg [4:0] next_state;

reg counter_5sec_en;
wire counter_5sec_expired;

reg counter_10sec_en;
wire counter_10sec_expired;

reg [6:0] counter_5sec;
reg [7:0] counter_10sec;

//=============================================
// Counters (input clock cycle == 50 ms)
//=============================================

// 10 sec          = 50 ms * 200
// 5 sec           = 50 ms * 100

assign counter_5sec_expired = (counter_5sec == 7'd100)? 1'b1: 1'b0;
assign counter_10sec_expired = (counter_10sec == 8'd200)? 1'b1: 1'b0;

always @(posedge iCLK) begin
  // If the counter is enabled, count up
  if (counter_5sec_en) begin
    counter_5sec = counter_5sec + 1'b1;
  end
  else
    counter_5sec = 0;
end

always @(posedge iCLK) begin
  // If the counter is enabled, count up
  if (counter_10sec_en) begin
    counter_10sec = counter_10sec + 1'b1;
  end
  else
    counter_10sec = 0;
end

//=============================================
// ==> Handle current state / next state transition
//=============================================
always @(posedge iCLK, posedge iRST) begin
    // Update the state variable on the clock transition.
    if (iRST)
      current_state <= RESET;
    else
      current_state <= next_state;
end

//=============================================
// ==> Handle on "current_state" change
//=============================================
always @(
         posedge iCLK,
         posedge iRST,
         posedge panic_key,
         posedge arm_key,
         posedge counter_5sec_expired,
         posedge counter_10sec_expired
       ) begin
  if (iRST) begin
    next_state = RESET;
    counter_5sec_en = 1'b0;
  end
  else
    case (current_state)
      RESET: begin
        counter_10sec_en = 1'b0;
        counter_5sec_en = 1'b0;
        next_state = DISARMED;
      end
      DISARMED: begin
        if (panic_key) begin
          next_state = PANIC;
        end
        else if (arm_key) begin
          next_state = ARMED_PENDING;
        end
        else
          next_state = CHECK_ZONE_1;
      end
      ARMED_PENDING: begin
        if (panic_key) begin
          next_state = PANIC;
        end
        else if (!counter_5sec_en)
          counter_5sec_en = 1'b1;
        else if (counter_5sec_expired) begin
          next_state = ARMED;
        end
      end
      ARMED: begin
        counter_5sec_en = 1'b0;    // Stop 5 sec counter
        counter_10sec_en = 1'b0;    // Stop 10 sec counter
        if (panic_key)
          next_state = PANIC;
        else if (arm_key) begin
          next_state = DISARMED;
        end
        else if (zone_sensor > 3'b000) begin
          next_state = TRIGGERED;
        end
      end
      TRIGGERED: begin
        if (panic_key) begin
          counter_10sec_en = 1'b1;
          next_state = PANIC;
        end
        else if (arm_key)
          next_state = DISARMED;
        else begin
          counter_10sec_en = 1'b1;
          next_state = TRIGGERED_RESET;
        end
      end
      TRIGGERED_RESET: begin
          counter_10sec_expired_out = 1'b1;
        if (panic_key) begin
          counter_10sec_expired_out = 1'b0;
          next_state = PANIC;
        end
        else if (counter_10sec_expired && (zone_sensor == 3'b000)) begin
          counter_10sec_expired_out = 1'b0;
          next_state = ARMED;
        end
        else if (counter_10sec_expired && (zone_sensor > 3'b000)) begin
          counter_10sec_expired_out = 1'b0;
          next_state = TRIGGERED;
        end
        else if (arm_key)
          next_state = DISARMED;
        else if (!counter_10sec_en)
          counter_10sec_en = 1'b1;
      end
      PANIC: begin
        counter_5sec_en = 1'b0;    // Stop 5 sec counter
        counter_10sec_en = 1'b1;    // Start 10 sec counter
        next_state = PANIC_RESET;
      end
      PANIC_RESET: begin
        if (arm_key) begin
          next_state = DISARMED;
        end
        else if (panic_key || counter_10sec_expired) begin
          next_state = ARMED;
        end
      end
      //=========================================
      // Cycle through zones
      //=========================================
      // Zone 1
      CHECK_ZONE_1: begin
        if (panic_key) begin
          next_state = PANIC;
        end
        else if (arm_key) begin
          next_state = ARMED_PENDING;
        end
        else if (zone_sensor[0])
          next_state = ZONE_1_ON;
        else
          next_state = ZONE_1_OFF;
      end
      ZONE_1_ON: begin
        if (panic_key) begin
          next_state = PANIC;
        end
        else if (arm_key) begin
          next_state = ARMED_PENDING;
        end
        else
        next_state = CHECK_ZONE_2;
      end
      ZONE_1_OFF: begin
        if (panic_key) begin
          next_state = PANIC;
        end
        else if (arm_key) begin
          next_state = ARMED_PENDING;
        end
        else
        next_state = CHECK_ZONE_2;
      end
      // Zone 2
      CHECK_ZONE_2: begin
        if (panic_key) begin
          next_state = PANIC;
        end
        else if (arm_key) begin
          next_state = ARMED_PENDING;
        end
        else if (zone_sensor[1])
          next_state = ZONE_2_ON;
        else
          next_state = ZONE_2_OFF;
      end
      ZONE_2_ON: begin
        if (panic_key) begin
          next_state = PANIC;
        end
        else if (arm_key) begin
          next_state = ARMED_PENDING;
        end
        else
        next_state = CHECK_ZONE_3;
      end
      ZONE_2_OFF: begin
        if (panic_key) begin
          next_state = PANIC;
        end
        else if (arm_key) begin
          next_state = ARMED_PENDING;
        end
        else
        next_state = CHECK_ZONE_3;
      end
      // Zone 3
      CHECK_ZONE_3: begin
        if (panic_key) begin
          next_state = PANIC;
        end
        else if (arm_key) begin
          next_state = ARMED_PENDING;
        end
        else if (zone_sensor[2])
          next_state = ZONE_3_ON;
        else
          next_state = ZONE_3_OFF;
      end
      ZONE_3_ON: begin
        if (panic_key) begin
          next_state = PANIC;
        end
        else if (arm_key) begin
          next_state = ARMED_PENDING;
        end
        else
          next_state = DISARMED;
      end
      ZONE_3_OFF: begin
        if (panic_key) begin
          next_state = PANIC;
        end
        else if (arm_key) begin
          next_state = ARMED_PENDING;
        end
        else
          next_state = DISARMED;
      end
      //=========================================
      default: begin
        next_state = RESET;
      end
    endcase
end

//=============================================
// ==> Output
//=============================================

assign state = current_state;

endmodule
