#vsim -gui work.master_spi
vsim -gui work.slave_spi
add wave -position end sim:/master_spi/*
force -freeze sim:/master_spi/clk 1 0, 0 {1000 ps} -r {2 ns}
force -freeze sim:/master_spi/rst 1 0
force -freeze sim:/master_spi/rts 0 0
force -freeze sim:/master_spi/data_in 10101011 0
force -freeze sim:/master_spi/baud 1 0
run
run
force -freeze sim:/master_spi/rst 0 0
run
force -freeze sim:/master_spi/rts 1 0
run
run
run
run 
run 
run 
run
run
