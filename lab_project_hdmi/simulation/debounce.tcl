
proc runSim {} {
  # clear current sim and add all waveforms
  restart -force -nowave

  # input iCLK,
  # input RST_n,
  # input  in,
  # output out
  add wave *
  property wave -radix hex *
  

  #=============================================
  # ==> Init
  #=============================================
  force -deposit CLK 1 0, 0 {2us} -repeat 4us
  force -freeze  RST_n   1
  force -freeze  in     0
  
  #=============================================
  # ==> Reset
  #=============================================
  force -freeze  RST_n   0
  run 10ms
  force -freeze  RST_n   1
  run 10ms
  
  #=============================================
  # ==> Start simulation
  #=============================================
  normalPress

  shortPress
  
  longPress

  wave zoom full
}


proc normalPress {} {
  run 100ms
  # First press - normal
  force -freeze  in     1
  #==== bounce effect ====
  bounceEffect 1
  #======================
  run 100ms
  force -freeze  in     0
  #==== bounce effect ====
  bounceEffect 0
  bounceEffect 0
  #======================
  run 300ms
}

proc shortPress {} {
  # Third press - short
  force -freeze  in     1
  #==== bounce effect ====
  bounceEffect 1
  #======================
  run 50ms
  force -freeze  in     0
  #==== bounce effect ====
  bounceEffect 0
  #======================
  run 300ms
}

proc longPress {} {
  # Second press - lonVg
  force -freeze  in     1
  #==== bounce effect ====
  bounceEffect 1
  #======================
  run 1000ms
  force -freeze  in     0
  #==== bounce effect ====
  bounceEffect 0
  #======================
  run 300ms

}

proc bounceEffect {hight} {
  run 1ms
  force -freeze  in     1
  run 1ms
  force -freeze  in     0
  run 2ms
  force -freeze  in     1
  run 1ms
  force -freeze  in     0
  run 5ms

  if {$hight} {
    run 10ms
    force -freeze  in     1
  }
}

