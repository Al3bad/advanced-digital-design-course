module I2C_controller #(
  parameter I2C_SLAVE_ADDR  = 8'h72,
  parameter NUM_OF_CONFIG   = 14,     // Number of configuration in the memeory
  parameter ADDR_WIDTH      = 4          // 2^x = 14 = ceil(3.8) = 4-bits
) (
  input                         CLK_I2C,
  input                         RST_n,
  input       [15:0]            CONFIG,
  output reg  [ADDR_WIDTH-1:0]  config_addr,
  inout                         I2C_SDA,
  output                        I2C_SCL,
  output reg                    ready
);

//=============================================
// ==> Parameters
//=============================================

// I2C controller states
localparam SETUP         = 4'h00;
localparam START         = 4'h01;
localparam NEW_BIT       = 4'h02;
localparam LOAD_BIT      = 4'h03;
localparam SEND_BIT      = 4'h04;
localparam PREPARE_BIT   = 4'h05;
localparam STOP_0        = 4'h06;
localparam STOP_1        = 4'h07;
localparam STOP_2        = 4'h08;
localparam NEXT_CONFIG   = 4'h09;
localparam DONE          = 4'h0A;

localparam ACK_0          = 4'h0B;
localparam ACK_1          = 4'h0C;
localparam ACK_2          = 4'h0D;
localparam ACK_3          = 4'h0E;
localparam ACK_4          = 4'h0F;

//=============================================
// ==> Wires / registers
//=============================================
reg         SDA, SCL;
reg  [23:0] I2C_DATA;
reg  [4:0]  I2C_STATE;
reg  [4:0]  current_state;
reg  [4:0]  current_bit;

assign I2C_SDA = (!RST_n)? 1'b1 : (SDA)? 1'bz : SDA;
assign I2C_SCL = SCL;

//=============================================
// ==> I2C state machine
//=============================================
// always @(posedge CLK_I2C, negedge RST_n) begin
//   if (!RST_n)
//     current_state <= 0;
//   else
//     current_state <= I2C_STATE;
// end

always @(posedge CLK_I2C, negedge RST_n) begin
  if (!RST_n) begin
    // reset
    current_bit = 1'b0;
    config_addr <= 0;
    ready <= 0;
    SDA <= 1'b1;
    SCL <= 1'b1;
    I2C_DATA <= 0;
    I2C_STATE <= SETUP;
  end
  else begin
    case (I2C_STATE)
      //=============================================
      // ==> Set up initial config
      //=============================================
      SETUP: begin
        // Load config
        I2C_DATA = {I2C_SLAVE_ADDR, CONFIG};
        I2C_STATE = START;
      end
      //=============================================
      // ==> Start
      //=============================================
      START: begin
        // I2C start signal
        SDA <= 1'b0;
        SCL <= 1'b1;
        I2C_STATE = NEW_BIT;
      end
      //=============================================
      // ==> Send current bit
      //=============================================
      NEW_BIT: begin
        // Clear wire for new bit
        SDA <= 1'b0;
        SCL <= 1'b0;
        I2C_STATE = LOAD_BIT;
      end
      LOAD_BIT: begin
        SDA <= I2C_DATA[23];
        SCL <= 1'b0;
        I2C_STATE = SEND_BIT;
      end
      SEND_BIT: begin
        SCL <= 1'b1;
        // Next state
        I2C_STATE = PREPARE_BIT;
      end
      PREPARE_BIT: begin
        SCL <= 1'b0;
        // prepare next bit
        current_bit = current_bit + 1'b1;
        I2C_DATA <= I2C_DATA << 1'b1;
        // decide next state
        if (current_bit == 5'd8 || current_bit == 5'd16 || current_bit == 5'd24) begin
          I2C_STATE = ACK_0;
        end
        else
          I2C_STATE = NEW_BIT;
      end
      //=============================================
      // ==> ACK
      //=============================================
      ACK_0: begin
        // Clear wire for new bit
        SDA <= 1'b0;
        SCL <= 1'b0;
        I2C_STATE = ACK_1;
      end
      ACK_1: begin
        // Allow the bus to be interrupted
        SDA <= 1'b1;
        SCL <= 1'b0;
        I2C_STATE = ACK_2;
      end
      ACK_2: begin
        SCL <= 1'b1;
        // Next state
        I2C_STATE = ACK_3;
      end
      ACK_3: begin
        SCL <= 1'b0;
        if (!I2C_SDA)
          if (current_bit == 5'd24) begin
            I2C_STATE = STOP_0;
          end
          else
            I2C_STATE = NEW_BIT;
        else begin
          SDA <= 1'b1;
          SCL <= 1'b1;
          config_addr <= 0;
          current_bit <= 0;
          config_addr <= 32'hFFFFFFFF;
          I2C_STATE = STOP_0;
        end
      end
      //=============================================
      // ==> Stop
      //=============================================
      STOP_0: begin
        // I2C stop signal
        config_addr <= config_addr + 1'b1;
        SDA <= 1'b0;
        SCL <= 1'b0;
        I2C_STATE = STOP_1;
      end
      STOP_1: begin
        SDA <= 1'b0;
        SCL <= 1'b1;
        I2C_STATE = STOP_2;
      end
      STOP_2: begin
        SDA <= 1'b1;
        SCL <= 1'b1;
        I2C_STATE = NEXT_CONFIG;
      end
      //=============================================
      // ==> Load next config
      //=============================================
      NEXT_CONFIG: begin
        SDA <= 1'b1;
        SCL <= 1'b1;
        if (config_addr == NUM_OF_CONFIG)
          I2C_STATE = DONE;
        else begin
          // Load the next configuration
          current_bit = 5'd0;
          I2C_DATA <= {I2C_SLAVE_ADDR, CONFIG};
          I2C_STATE = START;
        end
      end
      //=============================================
      // ==> HDMI ready / Stop I2C
      //=============================================
      DONE: begin
        // All configurations were sent and the HDMI is ready to be used
        ready <= 1'b1;
      end
      default: begin
          I2C_STATE = SETUP;
      end
    endcase
  end
end

endmodule
