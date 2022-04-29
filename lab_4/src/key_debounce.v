module key_debounce(
  input iCLK,
  input iRST,
  input  in,
  // output registered_key,
  output out
);

reg [2:0] current_state;
reg [2:0] next_state;
reg [3:0] counter;
reg signal;

parameter WAIT = 3'h0;
parameter HOLD = 3'h1;
parameter REGISTER = 3'h2;
parameter SIGNAL = 3'h3;
parameter RESET = 3'h4;

// assign registered_key = (current_state == REGISTER)? 1'b1 : 1'b0;

always @(posedge iCLK) begin
  current_state <= next_state;
end

always @(current_state, iRST, in) begin
  if (iRST) begin
    signal = 0;
    next_state = WAIT;
  end
  else
    case (current_state)
      WAIT: begin
        signal = 0;
        counter = 0;
        if (in && !iRST) begin
          next_state = HOLD;
        end
        else 
          next_state =  WAIT;
      end
      HOLD: begin
        next_state = REGISTER;
      end
      REGISTER: begin
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
        next_state = WAIT;
      end
    endcase
end

assign out = signal;

endmodule
