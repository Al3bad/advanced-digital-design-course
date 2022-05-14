proc runSim {} {
  # clear current sim and add all waveforms
  restart -force -nowave

  #=============================================
  # ==> Add waveformes
  #=============================================
  add wave -divider -height 30 "INPUT"
  add wave SW
  add wave KEY
  add wave CLK_50MHz
  add wave -divider -height 30 "GENERATED CLK"
  add wave CLK_3kHz
  add wave CLK_50ms
  add wave -divider -height 30 ""
  add wave SYS_RST
  add wave zone_sensor
  add wave arm_key
  add wave panic_key
  add wave current_state
  add wave -divider -height 30 "OUTPUT"
  add wave LED

  # add wave *

  # set the radix of the bases
  property wave -radix hex *
  property wave -radix bin /Lab_4_alarm_system/LED

  #=============================================
  # ==> Init
  #=============================================
  # generate the system clock (50MHz)
  # force -deposit CLK_50MHz 1 0, 0 {10ns} -repeat 20ns
  force -deposit CLK_3kHz 1 0, 0 {166us} -repeat 333us
  force -freeze  SW            4'b0000
  force -freeze  KEY           2'b11

  #=============================================
  # ==> Init
  #=============================================
  resetON
  run 50ms
  resetOFF

  #=============================================
  # ==> Start simulation
  #=============================================
  run 1000ms

  # Test 1
  # testClkGeneration

  # Test 2
  # testKeysWhileInDisarmed

  # Test 3
  # testDisaremdToArmed
  # testArmedToDisarmed
 
  # Test 4
  # testDisaremdToArmed
  # force -freeze  SW(1)     1
  # run 1000ms
  # force -freeze  SW(1)     0
  # run 10sec

  # Test 4
  # testPanic
  testPanicToArmedWithTimout


  wave zoom full
}

#================================================
#================================================
#================================================

proc testClkGeneration {} {
  run 400ms
}

proc testKeysWhileInDisarmed {} {
  # run for 1 sec to check that the zones are being checked
  run 1000ms

  # Turn SW0 ON
  force -freeze  SW(0)     1
  run 200ms

  # Turn SW1 ON
  force -freeze  SW(1)     1
  run 1000ms

  # Turn both OFF
  force -freeze  SW(0)     0
  force -freeze  SW(1)     0
  run 100ms

  # Turn SW3 ON
  force -freeze  SW(2)     1
  run 500ms

  # Turn SW3 OFF
  force -freeze  SW(2)     0

  run 2000ms
}

proc testDisaremdToArmed {} {
  run 50ms

  # Press the button
  pressArmKey 100ms

  # Wait for at least 5 sec
  run 7000ms
}

proc testArmedToDisarmed {} {
  run 50ms

  # Press the button
  pressArmKey 100ms

  run 1000ms
}


proc testPanic {} {
  run 200ms

  # From DISARMED to PANIC to DISARMED (using arm_key)
  pressPanicKey 100ms
  run 500ms
  pressArmKey 100ms
  run 500ms

  run 500ms

  # From DISARMED to PANIC to ARMED (using panic_key)
  pressPanicKey 100ms
  run 500ms
  pressPanicKey 100ms
  run 500ms
  
  run 500ms
}

proc testPanicToArmedWithTimout {} {
  run 100ms

  # From DISARMED to PANIC to ARMED (using 10 sec timerout)
  pressPanicKey 50ms
  run 500ms
  
  run 500ms

}


proc pressArmKey {time} {
  force -freeze  KEY(1)     0
  #==== bounce effect ====
  bounceEffectArm 0
  #======================
 
  run $time

  force -freeze  KEY(1)     1
  #==== bounce effect ====
  bounceEffectArm 1
  #======================
}

proc pressPanicKey {time} {
  run 100ms
  force -freeze  KEY(0)     0
  #==== bounce effect ====
  bounceEffectPanic 0
  #======================
 
  run $time

  force -freeze  KEY(0)     1
  #==== bounce effect ====
  bounceEffectPanic 1
  #======================
  run 100ms
}

proc bounceEffectArm {hight} {
  run 1ms
  force -freeze  KEY(1)     1
  run 1ms
  force -freeze  KEY(1)     0
  run 2ms
  force -freeze  KEY(1)     1
  run 1ms
  force -freeze  KEY(1)     0
  run 5ms

  if {$hight} {
    run 10ms
    force -freeze  KEY(1)     1
  }
}

proc bounceEffectPanic {hight} {
  run 1ms
  force -freeze  KEY(0)     1
  run 1ms
  force -freeze  KEY(0)     0
  run 2ms
  force -freeze  KEY(0)     1
  run 1ms
  force -freeze  KEY(0)     0
  run 5ms

  if {$hight} {
    run 10ms
    force -freeze  KEY(0)     1
  }
}

proc resetON {} {
  force -freeze  SW(3)      1'b0
}

proc resetOFF {} {
  force -freeze  SW(3)      1'b1
}



