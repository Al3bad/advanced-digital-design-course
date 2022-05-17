// ----------------------------------------------
// Author       : Abdullah Alabbad
// Description  : Clock generator
// ----------------------------------------------

module clk_gen (
  input CLK,
  input RST_n,
  output reg CLK_OUT
);

//=============================================
// ==> Parameters
//=============================================
parameter CTR_WIDTH    = 4'd4;     // Counter width
parameter CTR_PRELOAD  = 4'd0;     // Preload value

//=============================================
// ==> Wires / registers
//=============================================
wire  ctr_exp;         // Wires for the expired counters
// reg   ctr_load_sig;    // Wires for the load signal

//=============================================
// ==> Counters
//=============================================
counter #(CTR_WIDTH) ctr (
  .CLK(CLK),
  .RST_n(RST_n),
  .EN(1'b1),
  .load_toggle(ctr_exp),
  .load_value(CTR_PRELOAD),
  .count_complete(ctr_exp)
);

//=============================================
// ==> Reload handler
//=============================================
// always @(posedge CLK, negedge RST_n) begin
//   if (!RST_n)
//     ctr_load_sig = 1'b0;
//   else
//     case (ctr_exp)
//       1:        ctr_load_sig = 1'b1;
//       0:        ctr_load_sig = 1'b0;
//       default:  ctr_load_sig = 1'b1;
//     endcase
// end

//=============================================
// ==> Clk generators (Drive output)
//=============================================
always @(posedge ctr_exp, negedge RST_n) begin
  if (!RST_n) begin
    CLK_OUT <= 0;
  end
  else begin
    // Generate clk
    CLK_OUT <= ~CLK_OUT;
  end
end

endmodule

