module key_debounce(
  input CLK,
  input RST_n,
  input  in,
  // output registered_key,
  output out
);

reg [2:0] current_state;
reg [2:0] next_state;
// reg [3:0] counter;
reg signal;
wire ctr_exp;

parameter WAIT = 3'h0;
parameter HOLD = 3'h1;
parameter REGISTER = 3'h2;
parameter SIGNAL = 3'h3;
parameter RESET = 3'h4;

// assign registered_key = (current_state == REGISTER)? 1'b1 : 1'b0;

//=============================================
// ==> Counters
//=============================================
counter #(5'h9) kd_ctr(
  .CLK(CLK),
  .RST_n(RST_n),
  .EN(in && ( current_state == HOLD || current_state == REGISTER )),
  .load_toggle(1'b0),
  .load_value(19'd0),
  .count_complete(ctr_exp)
);

//=============================================
// ==> State machine
//=============================================
always @(posedge CLK) begin
  current_state <= next_state;
end

always @(current_state, RST_n, in, ctr_exp) begin
  if (!RST_n) begin
    signal = 0;
    next_state = WAIT;
  end
  else
    case (current_state)
      WAIT: begin
        signal = 0;
        // counter = 0;
        if (in && RST_n) begin
          next_state = HOLD;
        end
        else
          next_state =  WAIT;
      end
      HOLD: begin
        signal = 0;
        if (ctr_exp)
          next_state = REGISTER;
        else
          next_state = HOLD;
      end
      REGISTER: begin
        signal = 0;
        if (!in)
          next_state = SIGNAL;
        else
          next_state = REGISTER;
      end
      SIGNAL: begin
        signal = 1'b1;
        next_state = RESET;
      end
      RESET: begin
        signal = 1'b0;
        next_state = WAIT;
      end
      default: begin
        signal = 1'b0;
        next_state = WAIT;
      end
    endcase
end

assign out = signal;

endmodule
