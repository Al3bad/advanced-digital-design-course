module HDMI_I2C_controller (
  input CLK_I2C,
  input RST_n,
  inout I2C_SDA,
  output I2C_SCL,
  output reg ready
);

//=============================================
// ==> Parameters
//=============================================

parameter I2C_SLAVE_ADDR = 8'h72;

// I2C controller states
parameter SETUP         = 4'h00;
parameter START         = 4'h01;
parameter NEW_BIT       = 4'h02;
parameter LOAD_BIT      = 4'h03;
parameter SEND_BIT      = 4'h04;
parameter PREPARE_BIT   = 4'h05;
parameter STOP          = 4'h06;
parameter HOLD          = 4'h07;
parameter NEXT_CONFIG   = 4'h08;
parameter DONE          = 4'h09;

//=============================================
// ==> Wires / registers
//=============================================
reg         SDA, SCL;
reg  [26:0] I2C_DATA;
reg  [4:0]  I2C_STATE;
reg  [4:0]  current_bit;

reg  [3:0]  config_addr;
wire [17:0] HDMI_CONFIG_MEM [13:0];

assign I2C_SDA = (!RST_n)? 1'b1 : (SDA)? 1'bz : SDA;
assign I2C_SCL = SCL;

//=============================================
// ==> HDMI config
//=============================================

// Refernce: ADV7513 programming guide - Quick start guide - page 14
// Configure ADV7513 to use:
//    - HDMI
//    - RGB colour space
//    - 4:4:4 video format

//                             reg    WR  payload   WR
assign HDMI_CONFIG_MEM[0]  = {8'h15, 1'b1, 8'h20, 1'b1};
assign HDMI_CONFIG_MEM[1]  = {8'h16, 1'b1, 8'h30, 1'b1};
assign HDMI_CONFIG_MEM[2]  = {8'h17, 1'b1, 8'h00, 1'b1};
assign HDMI_CONFIG_MEM[3]  = {8'h18, 1'b1, 8'h46, 1'b1};
assign HDMI_CONFIG_MEM[4]  = {8'h41, 1'b1, 8'h10, 1'b1};
assign HDMI_CONFIG_MEM[5]  = {8'h97, 1'b1, 8'h00, 1'b1};
assign HDMI_CONFIG_MEM[6]  = {8'h98, 1'b1, 8'h03, 1'b1};
assign HDMI_CONFIG_MEM[7]  = {8'h9A, 1'b1, 8'hE0, 1'b1};
assign HDMI_CONFIG_MEM[8]  = {8'h9C, 1'b1, 8'h30, 1'b1};
assign HDMI_CONFIG_MEM[9]  = {8'h9D, 1'b1, 8'h61, 1'b1};
assign HDMI_CONFIG_MEM[10] = {8'hA2, 1'b1, 8'hA4, 1'b1};
assign HDMI_CONFIG_MEM[11] = {8'hA3, 1'b1, 8'hA4, 1'b1};
assign HDMI_CONFIG_MEM[12] = {8'hAF, 1'b1, 8'h16, 1'b1};
assign HDMI_CONFIG_MEM[13] = {8'hF9, 1'b1, 8'h00, 1'b1};

//=============================================
// ==> I2C state machine
//=============================================

always @(posedge CLK_I2C, negedge RST_n) begin
  if (!RST_n) begin
    // reset
    current_bit = 1'b0;
    config_addr = 0;
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
        I2C_DATA = {I2C_SLAVE_ADDR, 1'b1, HDMI_CONFIG_MEM[config_addr]};
        I2C_STATE <= START;
      end
      //=============================================
      // ==> Send current config
      //=============================================
      START: begin
        // I2C start signal
        SDA <= 1'b0;
        SCL <= 1'b1;
        I2C_STATE <= NEW_BIT;
      end
      NEW_BIT: begin
        // Clear wire for new bit
        SDA <= 1'b0;
        SCL <= 1'b0;
        I2C_STATE <= LOAD_BIT;
      end
      LOAD_BIT: begin
        SDA <= I2C_DATA[26];
        SCL <= 1'b0;
        I2C_STATE <= SEND_BIT;
      end
      SEND_BIT: begin
        SCL <= 1'b1;
        // Next state
        I2C_STATE <= PREPARE_BIT;
      end
      PREPARE_BIT: begin
        SCL <= 1'b0;
        // prepare next bit
        current_bit = current_bit + 1'b1;
        I2C_DATA <= I2C_DATA << 1'b1;
        // decide next state
        if (current_bit == 5'd27)
          I2C_STATE <= STOP;
        else
          I2C_STATE <= NEW_BIT;
      end
      STOP: begin
        // I2C stop signal
        config_addr = config_addr + 1'b1;
        SDA <= 1'b0;
        SCL <= 1'b0;
        I2C_STATE <= HOLD;
      end
      HOLD: begin
        SDA <= 1'b0;
        SCL <= 1'b1;
        I2C_STATE <= NEXT_CONFIG;
      end
      //=============================================
      // ==> Load next config
      //=============================================
      NEXT_CONFIG: begin
        SDA <= 1'b1;
        SCL <= 1'b1;
        if (config_addr == 4'd14)
          I2C_STATE <= DONE;
        else begin
          // Load the next configuration
          current_bit = 5'd0;
          I2C_DATA <= {I2C_SLAVE_ADDR, 1'b1, HDMI_CONFIG_MEM[config_addr]};
          I2C_STATE <= START;
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
          I2C_STATE <= SETUP;
      end
    endcase
  end
end

endmodule
