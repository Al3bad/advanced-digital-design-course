proc runSim {} {
  # clear current sim and add all waveforms
  restart -force -nowave

  # add wave CLK_50MHz
  add wave -divider -height 30 "INPUT"
  add wave SW
  add wave KEY
  add wave -divider -height 30 "GENERATED CLK"
  add wave CLK_50ms
  # add wave CLK_100ms
  add wave -divider -height 30 ""
  add wave SYS_RST
  add wave arm_key
  add wave panic_key
  add wave current_state
  add wave -divider -height 30 "OUTPUT"
  add wave LED

  # add wave *

  # set the radix of the bases
  property wave -radix hex *
  property wave -radix bin /Lab_4_alarm_system/LED

  # set the device into reset
  # force -freeze <pin-name> <value>
  force -freeze  SW            4'b0000
  force -freeze  KEY           2'b11

  resetON
  run 100ns
  resetOFF

  # generate the system clock (50MHz)
  force -deposit CLK_50MHz 1 0, 0 {10ns} -repeat 20ns

  # testClkGeneration
  
  # testKeyPress
  
  # testPanic

  testPanicToArmedWithTimout


  wave zoom full
}

proc testClkGeneration {} {
  run 400ms
}

proc testKeyPress {} {
  run 100ms
  # Noise input
  pressArmKey 1ms
  run 1ms
  pressArmKey 2ms
  run 1ms
  # Stable input
  pressArmKey 50ms
  # Noise release
  pressArmKey 1ms
  run 1ms
  pressArmKey 2ms
  run 1ms
  # Stable release
  run 300ms
}

proc testPanic {} {
  run 200ms

  # From DISARMED to PANIC to DISARMED (using arm_key)
  pressPanicKey 100ms
  run 300ms
  pressArmKey 100ms
  run 500ms

  run 500ms

  # From DISARMED to PANIC to ARMED (using panic_key)
  pressPanicKey 100ms
  run 300ms
  pressPanicKey 100ms
  run 500ms
  
  run 500ms

  # From DISARMED to PANIC to ARMED (using 10 sec timerout)
  pressPanicKey 100ms
  run 1000sec
  
  run 500ms
}

proc testPanicToArmedWithTimout {} {
  run 100ms

  pressPanicKey 50ms
  run 500ms
  
  run 500ms

}


proc pressArmKey {time} {
  force -freeze  KEY(1)     0
  run $time
  force -freeze  KEY(1)     1
}

proc pressPanicKey {time} {
  force -freeze  KEY(0)     0
  run $time
  force -freeze  KEY(0)     1
}

proc resetON {} {
  force -freeze  SW(3)      1'b0
}

proc resetOFF {} {
  force -freeze  SW(3)      1'b1
}



