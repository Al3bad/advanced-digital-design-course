proc runSim {} {

  # Clear the current simulatoin and add in all waveforms 
  restart -force -nowave
  add wave *

  # Set the radix of the buses.
  property wave -radix hex *

  # Set the device into reset
  force -freeze reset_n 0

  # Generate the system clock (50MHz).
  force -deposit CLK50 1 0, 0 {10ns} -repeat 20ns

  # Run for 100ns
  run 100ns

  # Let the reset go and clock for 100ns
  force -freeze reset_n 1
  run 100ns

}

