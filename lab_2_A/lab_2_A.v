// Lab 2 Section A

// Author       : Abdullah Alabbad
// Description  : Structural implementation of the decoder
// Last updated : 20/3/2022

module lab_2_A (
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
// ==> Input wires
//=============================================
wire A = SW[3];
wire B = SW[2];
wire C = SW[1];
wire D = SW[0];

//=============================================
// ==> Segments wires
//=============================================
wire a = (~A & ~D) | (~A & B & ~C);
wire b = (~A & ~B & C & D) | (A & ~B & ~C) | (~B & ~C & ~D);
wire c = (~B & ~C) | (~A & B & C) | (~A & C & D);
wire d = (~A & ~B & D) | (~A & B & ~D) | (~B & ~C & D) | (~A & C & ~D);
wire e = ~A | B | C | D;
wire f = (~A & ~C) | B | (A & C) | (C & ~D);
wire g = (~A & ~C) | (~A & D) | (A & B) | (A & C);

//=============================================
// ==> Assign outputs
//=============================================
assign LED[6] = a;
assign LED[5] = b;
assign LED[4] = c;
assign LED[3] = d;
assign LED[2] = e;
assign LED[1] = f;
assign LED[0] = g;

endmodule
