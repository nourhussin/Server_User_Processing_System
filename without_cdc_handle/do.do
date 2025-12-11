quit -sim
vlib work
vmap work work


vlog  Server_FSM.v
vlog  OPU.v
vlog  User.v
vlog  Top.v

vlog  Top_tb.v

vsim  work.Top_tb

add wave -color white     sim:/Top_tb/rst_n


add wave -divider "USER MODULE"
add wave -color green     sim:/Top_tb/u_clk
add wave -color cyan       sim:/Top_tb/dut/user/start
add wave -color cyan       sim:/Top_tb/dut/user/frame_out
add wave -color cyan       sim:/Top_tb/dut/user/auth_done
add wave -color cyan       sim:/Top_tb/dut/user/write_back_en
add wave -color cyan       sim:/Top_tb/dut/user/processed_data
add wave sim:/Top_tb/dut/user/state
add wave sim:/Top_tb/dut/user/next_state
add wave -color magenta sim:/Top_tb/dut/user/addr
add wave -color lightblue sim:/Top_tb/dut/user/RAM


add wave -divider "SERVER MODULE"
add wave -color yellow    sim:/Top_tb/s_clk
add wave -color cyan sim:/Top_tb/dut/server/start
add wave -color cyan sim:/Top_tb/dut/server/frame
add wave -color cyan sim:/Top_tb/dut/server/auth_done
add wave -color cyan sim:/Top_tb/dut/server/op_start
add wave -color cyan sim:/Top_tb/dut/server/op_code
add wave -color cyan sim:/Top_tb/dut/server/data
add wave -color cyan sim:/Top_tb/dut/server/op_done
add wave  sim:/Top_tb/dut/server/current_state
add wave  sim:/Top_tb/dut/server/next_state


add wave -divider "OPU MODULE"
add wave -color orange    sim:/Top_tb/op_clk
add wave -color cyan sim:/Top_tb/dut/opu/op_start
add wave -color cyan sim:/Top_tb/dut/opu/op_done
add wave -color cyan sim:/Top_tb/dut/opu/op_code
add wave -color cyan sim:/Top_tb/dut/opu/data_in
add wave -color cyan sim:/Top_tb/dut/opu/data_out


# Optionally run simulation automatically
run 2000ns
