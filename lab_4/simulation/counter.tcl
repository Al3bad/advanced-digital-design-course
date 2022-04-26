proc runSim {} {
  # clear current sim and add all waveforms
  restart -force -nowave
  add wave *

  # set the radix of the bases
  property wave -radix hex *

  # set the device into reset
  # force -freeze <pin-name> <value>
  force -freeze  iRST         1
  force -freeze  EN           0
  force -freeze  load_toggle  0
  force -freeze  load_value  16'd[expr 65536 - 3] 

  # generate the system clock (50MHz)
  force -deposit iCLK 1 0, 0 {10ns} -repeat 20000

  # run for 100 ns
  run 100000

  # let the reset go and clock for 100 ns
  force -freeze iRST          0
  run 100000

  force -freeze  load_toggle  1
  run 100000
  force -freeze  load_toggle  0

  # enable counter
  force -freeze EN            1
  run 100000
  run 100000
  run 100000

  run 10000000
  
  wave zoom full
}
