vlib work
vlog -f list.txt +cover -covercells +define+SIM
vsim -voptargs=+acc top -cover 
add wave *
add wave -position insertpoint  \
sim:/top/MONITOR/F_sco
add wave -position insertpoint  \
sim:/top/DUT/wr_ptr \
sim:/top/DUT/rd_ptr \
sim:/top/DUT/count
add wave -position insertpoint  \
sim:/top/DUT/mem
add wave -position insertpoint  \
sim:/top/FIFO_if/FIFO_WIDTH \
sim:/top/FIFO_if/FIFO_DEPTH \
sim:/top/FIFO_if/clk \
sim:/top/FIFO_if/data_in \
sim:/top/FIFO_if/rst_n \
sim:/top/FIFO_if/wr_en \
sim:/top/FIFO_if/rd_en \
sim:/top/FIFO_if/data_out \
sim:/top/FIFO_if/wr_ack \
sim:/top/FIFO_if/overflow \
sim:/top/FIFO_if/full \
sim:/top/FIFO_if/empty \
sim:/top/FIFO_if/almostfull \
sim:/top/FIFO_if/almostempty \
sim:/top/FIFO_if/underflow
coverage save FIFO.ucdb -onexit
run -all 
quit -sim
vcover report FIFO.ucdb -details -annotate -all -output coverage_FIFO.txt