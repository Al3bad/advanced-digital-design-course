module counter (
  CLK, RST_n,
  EN, load_toggle,
  load_value, current_value,
  count_complete
);

//=============================================
// ==> Parameters
//=============================================

parameter COUNTER_WIDTH = 16;

//=============================================
// ==> Input/Output pins
//=============================================

input                           CLK;
input                           RST_n;
input                           EN;
input                           load_toggle;
input  [COUNTER_WIDTH - 1:0]    load_value;
output [COUNTER_WIDTH - 1:0]    current_value;
output                          count_complete;

//=============================================
// ==> Internal registers
//=============================================

reg [COUNTER_WIDTH - 1:0] counter_value;

//=============================================
// ==> Counter behaviour
//=============================================

always @(posedge CLK, negedge RST_n, posedge load_toggle) begin
  if(!RST_n)
    counter_value = 0;                                  // Reset
  else if (load_toggle)
    counter_value = load_value;                         // Load value signal
  else if (EN)
    if (counter_value == (2**COUNTER_WIDTH - 1'b1))
      counter_value = 0;                                // Reset to 0 the the timer expires
    else
      counter_value = counter_value + 1'b1;             // Count up if the timer is enabled
  else
    counter_value = counter_value;
end

//=============================================
// ==> Output
//=============================================

assign current_value = counter_value;                   // Counter so far
assign count_complete = &counter_value;                 // Generate a signal when the timer expires

endmodule
