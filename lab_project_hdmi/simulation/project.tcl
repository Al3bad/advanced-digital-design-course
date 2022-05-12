
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
  # # add wave CLK_25Mhz
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
  run 200ns
  force -freeze  KEY(0)           1'b1

  #=============================================
  # ==> Start simulation
  #=============================================
  run 10ms

  wave zoom full
}

