// Lab 2 Section B

// Author       : Abdullah Alabbad
// Description  : Behavioural implementation of the decoder
// Last updated : 20/3/2022

module lab_2_B (
  input   [3:0]  SW,   // Input array that will be connected to switches
  output  [6:0]  LED   // Output array that will be connected to LEDs
);

//=============================================
// ==> Block diagram
//=============================================

//                  ----------------
//              4   |              |  7
//   SW[3:0]  ==/==>|    Decoder   |==/==> LED[6:0]
//                  |              |
//                  ----------------

//=============================================
// ==> Declare segment wires
//=============================================
wire a, b, c, d, e, f, g;

//=============================================
// ==> Connect internal reg to segment wires
//=============================================
reg [6:0] segment_reg;
assign {a, b, c, d, e, f, g} = segment_reg;

//=============================================
// ==> Connect segment wires to LEDs
//=============================================

assign LED[6] = a;
assign LED[5] = b;
assign LED[4] = c;
assign LED[3] = d;
assign LED[2] = e;
assign LED[1] = f;
assign LED[0] = g;

//=============================================
// ==> Behavioural implementation
//=============================================

always @(*) begin
  if (SW == 4'b0000)
    segment_reg = 7'b1110111;
  else if (SW == 4'b0001)
    segment_reg = 7'b0011111;
  else if (SW == 4'b0010)
    segment_reg = 7'b1001110;
  else if (SW == 4'b0011)
    segment_reg = 7'b0111101;
  else if (SW == 4'b0100)
    segment_reg = 7'b1001111;
  else if (SW == 4'b0101)
    segment_reg = 7'b1000111;
  else if (SW == 4'b0110)
    segment_reg = 7'b1011110;
  else if (SW == 4'b0111)
    segment_reg = 7'b0010111;
  else if (SW == 4'b1000)
    segment_reg = 7'b0110000;
  else if (SW == 4'b1001)
    segment_reg = 7'b0111100;
  else
    segment_reg = 7'b0000000; // disable segments
end

endmodule
