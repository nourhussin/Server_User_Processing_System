vlib work
vmap work work

vlog Server_FSM.v

vlog tb_Server_FSM.v

vsim -voptargs="+acc" tb_Server_FSM

add wave -group TB clk
add wave -group TB rst_n
add wave -group TB start
add wave -group TB frame
add wave -group TB op_done

add wave -group FSM /tb_Server_FSM/DUT/current_state
add wave -group FSM /tb_Server_FSM/DUT/next_state
add wave -group FSM /tb_Server_FSM/DUT/not_multiple_ones

add wave -group Outputs /tb_Server_FSM/DUT/auth_done
add wave -group Outputs /tb_Server_FSM/DUT/op_start
add wave -group Outputs /tb_Server_FSM/DUT/op_code
add wave -group Outputs /tb_Server_FSM/DUT/data

wave zoom full
configure wave -signalnamewidth 200
configure wave -namecolwidth 200
configure wave -valuecolwidth 120

run -all
