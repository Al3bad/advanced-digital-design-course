
proc runSim {} {
  # clear current sim and add all waveforms
  restart -force -nowave

  #=============================================
  # ==> Add waveformes
  #=============================================
  # add wave -divider -height 30 "INPUT"
  # add wave SW
  # add wave KEY
  # add wave CLK_50MHz
  # add wave -divider -height 30 "GENERATED CLK"
  # add wave CLK_PX
  # add wave CLK_I2C
  # add wave -divider -height 30 ""
  # add wave -divider -height 30 "OUTPUT"
  # add wave LED

  add wave *

  # set the radix of the bases
  property wave -radix hex *
  # property wave -radix bin /project_hdmi/LED

  #=============================================
  # ==> Init
  #=============================================
  # generate the system clock (50MHz)
  force -deposit CLK_50MHz 1 0, 0 {10ns} -repeat 20ns

  force -freeze  SW            4'b0000
  force -freeze  KEY           2'b11

  #=============================================
  # ==> Reset
  #=============================================
  force -freeze  KEY(0)           1'b0
  run 1us
  force -freeze  KEY(0)           1'b1

  #=============================================
  # ==> Start simulation
  #=============================================
  run 0.148ms

  # CONFIG 0

  # Address ACK 1
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA

  run 0.140ms

  # Address ACK 2
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA


  run 0.14ms

  # Address ACK 3
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA


  # END
  run 0.16ms

  # CONFIG 1

  # Address ACK 1
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA
  
  run 0.140ms

  # Address ACK 2
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA


  run 0.14ms

  # Address ACK 3
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA

  # END
  run 0.16ms

  # CONFIG 2

  # Address ACK 1
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA
  
  run 0.140ms

  # Address ACK 2
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA


  run 0.14ms

  # Address ACK 3
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA

  # CONFIG 3

  # Address ACK 1
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA
  
  run 0.140ms

  # Address ACK 2
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA


  run 0.14ms

  # Address ACK 3
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA

  # END
  run 0.16ms
  force -freeze KEY(1) 1'b0

  # CONFIG 4
  sendConfig
  # CONFIG 5
  sendConfig
  # CONFIG 6
  sendConfig


  run 0.7ms
  # run 10ms
  
  wave zoom full
}

proc sendConfig {} {
  # Address ACK 1
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA
  
  run 0.140ms

  # Address ACK 2
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA


  run 0.14ms

  # Address ACK 3
  force -freeze I2C_SDA 1'b0
  run 0.0025ms
  noforce I2C_SDA

  # END
  run 0.16ms
}
