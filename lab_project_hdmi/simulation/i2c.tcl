
proc runSim {} {
  # clear current sim and add all waveforms
  restart -force -nowave

  #=============================================
  # ==> Add waveformes
  #=============================================
  # add wave -divider -height 30 "INPUT"
  # add wave CLK
  # add wave RST_n
  # add wave -divider -height 30 "GENERATED CLK"
  # add wave CLK_PX
  # add wave CLK_I2C

  add wave *

  # set the radix of the bases
  property wave -radix hex *
  # property wave -radix bin /project_hdmi/LED

  #=============================================
  # ==> Init
  #=============================================
  force -deposit CLK_I2C 1 0, 0 {50us} -repeat 100us
  force -freeze  RST_n           1'b1

  #=============================================
  # ==> Reset
  #=============================================
  force -freeze  RST_n           1'b0
  run 1ms
  force -freeze  RST_n           1'b1

  #=============================================
  # ==> Start simulation
  #=============================================

  force -freeze CONFIG 16'h1520
  run 3.79ms

  # Address ACK
  force -freeze I2C_SDA 1'b0
  run 0.11ms
  noforce I2C_SDA

  run 6.7ms


 #  puts "Configuration num = 1"
 #  run 200us
 #  sendConfig
 # 
 #  for {set x 0} {$x<13} {incr x} {
 #    puts "Configuration num = [expr $x + 2]"
 #    run 300us
 #    sendConfig
 #  }
 #
 #  run 1ms

  wave zoom full
}

proc sendConfig {} {
  for {set x 0} {$x<3} {incr x} {
    # Keep running to send the first configuration
    run 2800us
    run 2000us
    # ACK signal from the slave
    # force -freeze  I2C_SDA         1'b1
    # run 100us
    # force -freeze  I2C_SDA         1'b0
  }
}
