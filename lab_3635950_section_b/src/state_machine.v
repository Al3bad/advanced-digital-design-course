module state_machine (
  input CLK,
  input RST_n,
  input P,
  input S,
  input WLF,
  input WLE,
  output [5:0] out
);

parameter UNPOWERED = 4'b0000;
parameter INIT      = 4'b0001;
parameter START_WP  = 4'b0010;
parameter STOP_WP   = 4'b0011;
parameter READY     = 4'b0100;
parameter FILL      = 4'b0101;
parameter START_WM  = 4'b0110;
parameter DRAIN     = 4'b0111;
parameter STAGE2    = 4'b1000;
parameter STAGE2END = 4'b1001;

//=============================================
// ==> Reg/Wires
//=============================================
reg [2:0] current_state;
reg [2:0] next_state;
reg [4:0] sec;
reg timer_en;
wire expired;

reg PLED;
reg READYLED;
reg WS;
reg WP;
reg WM;
reg LL;

//=============================================
// ==> Connections
//=============================================
assign out = {LL, WM, WP, WS, READYLED, PLED};

//=============================================
// ==> delay timer
//=============================================
delay_timer dt (
  .CLK(CLK),
  .SEC(sec),
  .EN(timer_en),
  .expired(expired)
);

//=============================================
// ==> next state
//=============================================
always @(posedge CLK, negedge RST_n) begin
  if (!RST_n)
    current_state <= UNPOWERED;
  else
    current_state <= next_state;
end

//=============================================
// ==> current state
//=============================================
always @(current_state, P, S, WLE, WLF, RST_n) begin
  case (current_state)
    UNPOWERED: begin
      if (P)
        next_state = INIT;
      else
        next_state = UNPOWERED;
    end
    INIT: begin
      if (P)
        next_state = UNPOWERED;
      else if (WLE == 0)
        next_state = START_WP;
      else
        next_state = STOP_WP;
    end
    START_WP: begin
      if (P)
        next_state = UNPOWERED;
      else
        next_state = STOP_WP;
    end
    STOP_WP: begin
      if (P)
        next_state = UNPOWERED;
      else
        next_state = READY;
    end
    READY: begin
      if (P)
        next_state = UNPOWERED;
      else if (S)
        next_state = FILL;
      else
        next_state = READY;
    end
    FILL: begin
      if (WLF)
        next_state = START_WM;
      else
        next_state = FILL;
    end
    START_WM: begin
      if (!timer_en) begin
        sec <= 4'd10;
        timer_en <= 1'b1;
        next_state <= START_WM;
      end
      else if (timer_en && expired) begin
        sec <= 4'd0;
        timer_en <= 1'b0;
        next_state <= DRAIN;
      end
    end
    DRAIN: begin
      if (WLE)
        next_state = STAGE2;
      else
        next_state = DRAIN;
    end
    STAGE2: begin
      if (!timer_en) begin
        sec <= 4'd5;
        timer_en <= 1'b1;
        next_state <= STAGE2;
      end
      else if (timer_en && expired) begin
        sec <= 4'd0;
        timer_en <= 1'b0;
        next_state <= STAGE2END;
      end
    end
    STAGE2END: begin
      next_state = READY;
    end
    default: begin
    end
  endcase
end

//=============================================
// ==> output logic
//=============================================
always @(current_state, RST_n) begin
  case (current_state)
    UNPOWERED: begin
      PLED <= 0;
      READYLED <= 0;
      WS <= 0;
      WP <= 0;
      WM <= 0;
      LL <= 0;
    end
    INIT: begin
      PLED <= 1'b1;
      READYLED <= 0;
      WS <= 0;
      WP <= 0;
      WM <= 0;
      LL <= 0;
    end
    START_WP: begin
      PLED <= 1'b1;
      READYLED <= 0;
      WS <= 0;
      WP <= 0;
      WM <= 0;
      LL <= 0;
    end
    STOP_WP: begin
      PLED <= 1'b1;
      READYLED <= 1'b1;
      WS <= 0;
      WP <= 0;
      WM <= 0;
      LL <= 0;
    end
    READY: begin
      PLED <= 1'b1;
      READYLED <= 1'b1;
      WS <= 0;
      WP <= 0;
      WM <= 1'b1;
      LL <= 0;
    end
    FILL: begin
      PLED <= 1'b1;
      READYLED <= 0;
      WS <= 1'b1;
      WP <= 0;
      WM <= 0;
      LL <= 0;
    end
    START_WM: begin
      PLED <= 1'b1;
      READYLED <= 0;
      WS <= 0;
      WP <= 0;
      WM <= 1'b1;
      LL <= 0;
    end
    DRAIN: begin
      PLED <= 1'b1;
      READYLED <= 0;
      WS <= 0;
      WP <= 0;
      WM <= 0;
      LL <= 0;
    end
    STAGE2: begin
      PLED <= 1'b1;
      READYLED <= 0;
      WS <= 0;
      WP <= 0;
      WM <= 1'b1;
      LL <= 1'b1;
    end
    STAGE2END: begin
      PLED <= 1'b1;
      READYLED <= 0;
      WS <= 0;
      WP <= 0;
      WM <= 0;
      LL <= 0;
    end
    default: begin
    end
  endcase
end

endmodule
