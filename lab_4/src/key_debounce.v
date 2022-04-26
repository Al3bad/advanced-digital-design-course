module key_debounce(
  input iCLK,
  input iRST,
  input in,
  output reg out
);

parameter DELAY = 20'd1000000;

reg [19:0] counter;
reg latched_in;

always @(posedge iCLK, posedge iRST) begin
  if(iRST) begin
    latched_in <= in;
    out <= in;
    counter <= 0;
  end
  else if(in != latched_in) begin
    latched_in <= in;
    counter <= 0;
  end
  else if(counter == DELAY)
    out <= latched_in;
  else
    counter <= counter + 1;
end
endmodule
