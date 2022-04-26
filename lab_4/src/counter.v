module counter (iCLK, iRST, EN, load_toggle, load_value, current_value, count_complete);

//=============================================
// ==> Parameters
//=============================================

parameter COUNTER_WIDTH = 16;

//=============================================
// ==> Input/Output pins
//=============================================

input                           iCLK;
input                           iRST;
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

always @(posedge iCLK, posedge iRST, posedge load_toggle) begin
  if(iRST) begin
    // reset
    counter_value = 0;
  end
  else if (load_toggle) begin
    // initial value to start counting from
    counter_value = load_value;
  end
  else if (EN) begin
    // counter is enabled
    if (counter_value == (2**COUNTER_WIDTH - 1'b1)) begin
      // counter has expired, start from 0
      counter_value = 0;
    end
    else begin
      // increment counter
      counter_value = counter_value + 1'b1;
    end
  end
  else begin
    // counter isn't eanbled, keep current value
    counter_value = counter_value;
  end
end

//=============================================
// ==> Output
//=============================================

assign current_value = counter_value;
assign count_complete = &counter_value;

endmodule
