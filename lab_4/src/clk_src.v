module clk_src (
  iCLK,
  iRST,
  start_at,
  out
);

//=============================================
// ==> Parameters
//=============================================

parameter COUNTER_WIDTH = 16;

input                           iCLK;
input                           iRST;
input  [COUNTER_WIDTH-1:0]      start_at;
output                          out;

//=============================================
// ==> Internal wires/registers
//=============================================

wire count_complete;
reg  generated_clk;

//=============================================
// ==> Generate the desired clock speed
//=============================================

counter #(COUNTER_WIDTH) ctr0(
  // inputs
  .iCLK(iCLK),
  .iRST(1'b0),
  .EN(1'b1),
  .load_toggle(iRST | count_complete),
  .load_value(start_at),
  // outputs
  .count_complete(count_complete)
);

always @(posedge count_complete, posedge iRST) begin
  if (iRST)
    generated_clk = 0;
  else
    generated_clk = ~generated_clk;
end

assign out = generated_clk;

endmodule
