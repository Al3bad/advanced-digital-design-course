
proc runSim {} {
  # clear current sim and add all waveforms
  restart -force -nowave

  #=============================================
  # ==> Add waveformes
  #=============================================
  # add wave -divider -height 30 "INPUT"
  # add wave CLK_PX
  # add wave RST_n
  # add wave -divider -height 30 "GENERATED CLK"

  add wave *

  # set the radix of the bases
  property wave -radix hex *

  #=============================================
  # ==> Init
  #=============================================
  # generate the clock 25MHz
  force -deposit CLK_PX 1 0, 0 {20ns} -repeat 40ns
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
  run 23ms

  wave zoom full
}

