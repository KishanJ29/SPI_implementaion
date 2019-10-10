vsim work.test_spi
add wave -position end sim:/test_spi/*
add wave -position end sim:/test_spi/Master/*
add wave -position end sim:/test_spi/Slave/*
force -freeze sim:/test_spi/CLK 1 0, 0 {1000 ps} -r {2 ns}
force -freeze sim:/test_spi/rst 1 0
force -freeze sim:/test_spi/rts_mas 0 0
#force -freeze sim:/test_spi/data_Tx_mas 10111101 0
#force -freeze sim:/test_spi/data_Tx_slv 11011011 0
run 100 ns
force -freeze sim:/test_spi/rst 0 0
run 100 ns
force -freeze sim:/test_spi/rts_mas 1 0
run 800 ns
# Running the Testbench only without any frocing values
#restart 
#add wave -position end sim:/test_spi/*
#add wave -position end sim:/test_spi/Master/*
#add wave -position end sim:/test_spi/Slave/*
#run 1000 ns