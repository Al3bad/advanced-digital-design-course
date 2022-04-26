proc runSim {} {
  # Set zoom scale from 0 to 2 sec
  # WaveRestoreZoom {0 fs} {2 sec}

  # clear current sim and add all waveforms
  restart -force -nowave
  add wave *

  # add wave iRST
  # add wave iCLK
  # add wave prescaler
  # add wave start_at
  # add wave out

  # set the radix of the bases
  property wave -radix hex *

  # set the device into reset
  # force -freeze <pin-name> <value>
  force -freeze  iRST         1
  # force -freeze  prescaler    10'd[expr 1 << 9]
  # force -freeze  prescaler    10'd[expr 1 << 9]
  # force -freeze  start_at     16'd48828
  # force -freeze  start_at     16'd[expr 65536 - 4882]
  # force -freeze  start_at     16'd[expr 65536 - 10024]
  force -freeze  start_at     16'd0

  # generate the system clock (50MHz)
  force -deposit iCLK 1 0, 0 {10ns} -repeat 20000

  # run for 100 ns
  run 100000

  # let the reset go and clock for 100 ns
  force -freeze iRST          0
  run 100000
  run 200000000
  
  wave zoom full

}
