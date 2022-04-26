proc runSim {} {
  # clear current sim and add all waveforms
  restart -force -nowave

  # add wave CLK_50MHz
  # add wave SW
  # add wave KEY
  # add wave LED

  add wave *

  # set the radix of the bases
  property wave -radix hex *

  # set the device into reset
  # force -freeze <pin-name> <value>
  force -freeze  SW            4'b0000
  force -freeze  KEY           2'b00
  force -freeze  SW(3)         1

  # generate the system clock (50MHz)
  force -deposit CLK_50MHz 1 0, 0 {10ns} -repeat 20000

  # run for 100 ns
  run 100000

  # let the reset go and clock for 100 ns
  force -freeze SW(3)          0
  run 100000
  run 200000000000

  wave zoom full
}
