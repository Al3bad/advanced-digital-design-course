// Lab 3

// Author       : Abdullah Alabbad
// Description  : Behavioural implementation of the SR-latch
// Last updated : 23/3/2022

module sr_latch (
  input S,
  input R,
  output reg Q,
  output reg Qn
);

//=============================================
// ==> Behavioural implementation of the SR-latch
//=============================================
always @(S, R) begin
  if (S && R) begin
    Q <= 1'b0;
    Qn <= 1'b0;
  end
  else if (R) begin
    Q <= 1'b0;
    Qn <= 1'b1;
  end
  else if (S) begin
    Q <= 1'b1;
    Qn <= 1'b0;
  end
  else if (!S && !R) begin
    Q <= Q;
    Qn <= Qn;
  end
  else begin
    Q <= 1'b0;
    Qn <= 1'b0;
  end
end

endmodule
