module delay_timer (
  input CLK,
  input [4:0] SEC,
  input RST_n,
  input EN,
  output expired
);

//=============================================
// ==> Wires / registers
//=============================================
reg [4:0] sec_value;

wire ctr_exp;
//=============================================
// ==> Connections
//=============================================
assign  expired = (SEC == sec_value)? 1'b1 : 1'b0;

//=============================================
// ==> 1 sec counter
//=============================================
// final implementation
// parameter CTR_WIDTH    = 5'd18;       // Counter width
// parameter CTR_PRELOAD  = 18'd12144;   // Preload value

// testing
parameter CTR_WIDTH    = 5'd18;       // Counter width
parameter CTR_PRELOAD  = 18'd12144;   // Preload value

counter #(CTR_WIDTH) ctr (
  .CLK(CLK),
  .RST_n(RST_n),
  .EN(EN),
  .load_toggle(ctr_exp),
  .load_value(CTR_PRELOAD),
  .count_complete(ctr_exp)
);

always @(posedge ctr_exp, negedge RST_n) begin
  if (!RST_n) sec_value <= 0;
  else
    sec_value <= sec_value + 1'b1;
end


endmodule
