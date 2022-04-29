
proc runSim {} {
  # clear current sim and add all waveforms
  restart -force -nowave

  # input iCLK,
  # input iRST,
  # input  in,
  # output out
  add wave *
  property wave -radix hex *
  
  force -freeze  iRST   1
  force -freeze  in     0

  force -deposit iCLK 1 0, 0 {50ms} -repeat 100ms
  
  run 100ms

  force -freeze  iRST   0
  run 100ms

  # First press - normal
  force -freeze  in     1
  #==== bounce effect ====
  bounceEffect 1
  #======================
  run 10ms
  force -freeze  in     0
  #==== bounce effect ====
  bounceEffect 0
  #======================
  run 2000ms
  
  # Second press - long
  force -freeze  in     1
  #==== bounce effect ====
  bounceEffect 1
  #======================
  run 1000ms
  force -freeze  in     0
  #==== bounce effect ====
  bounceEffect 0
  #======================
  run 100ms
  run 100ms
  run 100ms
  run 100ms

  # Third press - short
  force -freeze  in     1
  #==== bounce effect ====
  bounceEffect 1
  #======================
  run 100ms
  force -freeze  in     0
  #==== bounce effect ====
  bounceEffect 0
  #======================
  run 1000ms


  wave zoom full
}


proc bounceEffect {hight} {
  run 10ms
  force -freeze  in     1
  run 10ms
  force -freeze  in     0
  run 20ms
  force -freeze  in     1
  run 10ms
  force -freeze  in     0
  run 5ms

  if {$hight} {
    run 10ms
    force -freeze  in     1
  }
}
