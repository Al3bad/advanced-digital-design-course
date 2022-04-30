
proc runSim {} {
  # clear current sim and add all waveforms
  restart -force -nowave

  # input iCLK,
  # input iRST,
  # input panic_key,
  # input arm_key,
  # output [3:0] state

  # parameter RESET              = 5'h0;
  # parameter DISARMED           = 5'h1;
  # parameter ARMED_PENDING      = 5'h2;
  # parameter ARMED              = 5'h3;
  # parameter TRIGGERED          = 5'h4;
  # parameter TRIGGERED_RESET    = 5'h5;
  # parameter CHECK_ZONE_1       = 5'h6;
  # parameter CHECK_ZONE_2       = 5'h7;
  # parameter CHECK_ZONE_3       = 5'h8;
  # parameter ZONE_1_ON          = 5'h9;
  # parameter ZONE_2_ON          = 5'ha;
  # parameter ZONE_3_ON          = 5'hb;
  # parameter ZONE_1_OFF         = 5'hc;
  # parameter ZONE_2_OFF         = 5'hd;
  # parameter ZONE_3_OFF         = 5'he;
  # parameter DELAY              = 5'hf;
  # parameter PANIC              = 5'h10;
  # parameter PANIC_RESET        = 5'h11;
  # parameter UPDATE             = 5'h12;

  add wave *
  property wave -radix hex *
  
  # reset state
  force -freeze  iRST        1
  force -freeze  panic_key   0
  force -freeze  arm_key     0
  force -freeze  zone_sensor 3'b000
  run 200ms


  force -deposit iCLK 1 0, 0 {25ms} -repeat 50ms
  run 200ms
  force -freeze  iRST        0

  # Start simulation
  run 2000ms

  force -freeze  iRST        1
  run 200ms
  force -freeze  iRST        0


  # testPanic
  testTriggered

 #  # 1.1 DISARMED to ARMED
 # pressArmKey
 #  run 5000ms

  # 1.2 DISARMED to ARMED - with a key press in the middle during the pending state.
  # force -freeze  arm_key     1
  # run 200ms
  # force -freeze  arm_key     0
  # run 2500ms
  # force -freeze  arm_key     1
  # run 200ms
  # force -freeze  arm_key     0
  # run 2500ms

  # run 2000ms
  # force -freeze  zone_sensor 3'b100
  # run 2000ms
  # force -freeze  zone_sensor 3'b000
  # run 2000ms
  # run 2000ms
  # run 2000ms
  # run 2000ms
  # run 2000ms

  # 2.1 ARMED to DISARMED
  # pressArmKey 
  # run 5000ms
  #
  # # 3.1 DISARMED to ARMED then PANIC
  # pressArmKey 
  # run 6000ms
  # pressPanicKey
  # run 2000ms
  # 
  # # 4.1 PANIC to ARMED - using KEY0
  # pressArmKey 
  # run 2000ms
  #
  # # 5.1 PANIC to ARMED - with the 10 sec timeout
  # run 12000ms
  # pressArmKey 
  # run 6000ms
  # pressPanicKey
  # run 12000ms
  #
  #
  # # 6.1 ARMED to TRIGGERED - 5 sec timerout
  # detectZone1
  # run 5000ms
  # run 5000ms


  # END
  run 2000ms
  wave zoom full
}

proc pressArmKey {} {
  force -freeze  arm_key     1
  run 100ms
  force -freeze  arm_key     0
  run 5000ms
}

proc pressPanicKey {} {
  force -freeze  panic_key     1
  run 100ms
  force -freeze  panic_key     0
  run 5000ms
}

proc detectZone1 {} {
  force -freeze   zone_sensor(0) 1
  run 6000ms
  force -freeze   zone_sensor(0) 0
}

proc testPanic {} {
  # Press arm key
  # pressArmKey

  # Wait 7 sec to go to ARMED state
  run 7000ms
  
  # Now the system should be armed
  # Press panic key
  pressPanicKey

  # The system should be in PANIC then PANIC_RESET state

  # Press arm key before the timer expire
  run 2000ms
  run 2000ms
  # pressArmKey

  # Now the system should be in DISARMED state

  # Go to PANIC steate again then wait the timer to expire
  # pressArmKey
  # run 7000ms
  # pressPanicKey
  # run 12000ms

  # Now the system should be in ARMED state

  # Got to PANIC state one more time then press panic key before the timer expire
  # pressPanicKey
  # run 2000ms
  # pressPanicKey

  # Not the system should be in ARMED state


}

proc testTriggered {} {
  run 2000ms

  pressArmKey
  run 200ms

  detectZone1


  run 2000ms
  run 2000ms
}
