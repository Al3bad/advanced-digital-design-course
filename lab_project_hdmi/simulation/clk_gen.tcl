
proc runSim {} {
  # clear current sim and add all waveforms
  restart -force -nowave

  #=============================================
  # ==> Add waveformes
  #=============================================
  add wave -divider -height 30 "INPUT"
  add wave CLK
  add wave RST_n
  add wave -divider -height 30 "GENERATED CLK"
  add wave CLK_PX
  add wave CLK_I2C

  add wave *

  # set the radix of the bases
  property wave -radix hex *
  # property wave -radix bin /project_hdmi/LED

  #=============================================
  # ==> Init
  #=============================================
  # generate the system clock (50MHz)
  force -deposit CLK 1 0, 0 {10ns} -repeat 20ns
  force -freeze  RST_n           1'b1

  #=============================================
  # ==> Reset
  #=============================================
  force -freeze  RST_n           1'b0
  run 100ns
  force -freeze  RST_n           1'b1

  #=============================================
  # ==> Start simulation
  #=============================================
  run 5ms

  wave zoom full
}

