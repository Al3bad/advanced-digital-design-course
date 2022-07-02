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
  # add wave CLK_SLOW
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
  force -deposit CLK 1 0, 0 {2us} -repeat 4us

  force -freeze  SEC           5'd2
  force -freeze  TRR           1'b0
  force -freeze  TRE           1'b1

  #=============================================
  # ==> Reset
  #=============================================
  force -freeze   TRR          1'b1
  run 1ms
  force -freeze   TRR          1'b0
  run 1ms
  force -freeze   TRR          1'b1
  run 1ms
  force -freeze   TRR          1'b0
  run 1ms

  #=============================================
  # ==> Start simulation
  #=============================================
  run 3sec
  
  wave zoom full
}

