// Lab 3

// Author       : Abdullah Alabbad
// Description  : Behavioural implementation of the D-flip-flop
// Last updated : 30/3/2022

module d_flip_flop (
    input                     CLK,
    input                     RST,
    input       [7:0]         PRELOAD,
    input       [7:0]         D,
    output reg  [7:0]         Q,
    output reg  [7:0]         Qn
);

//=============================================
// ==> Behavioural implementation of the D-flip-flop
//=============================================
always @(posedge CLK, posedge RST) begin
  // Prelaod Q register on reset
  if (RST) begin
    Q = PRELOAD;
    Qn = ~PRELOAD;
  end
  else begin
    Q = D;
    Qn = ~D;
  end

end

endmodule
