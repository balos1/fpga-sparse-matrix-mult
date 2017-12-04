if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

### ---------------------------------------------- ###
### Compile code ###
### Enter files here; copy line for multiple files ###
vlog -sv -work work test_comm_unit.sv
vlog -sv -work work +define+SIMULATION ../comm.sv
vlog -sv -work work +define+SIMULATION ../control.sv
vlog -sv -work work +define+SIMULATION ../tx/async_tx.sv
vlog -sv -work work +define+SIMULATION ../tx/baudtick_tx.sv
vlog -sv -work work +define+SIMULATION ../rx/async_rx.sv
vlog -sv -work work +define+SIMULATION ../rx/baudtick_rx.sv
vlog -sv -work work +define+SIMULATION ../../memory.sv
### ---------------------------------------------- ###
### Load design for simulation ###
### Replace topLevelModule with the name of your top level module (no .sv) ###
### Do not duplicate! ###
vsim test_comm_unit

### ---------------------------------------------- ###
### Add waves here ###
### Use add wave * to see all signals ###
#add wave *
add wave clk
add wave baudclk
add wave resetn
add wave rx
add wave rx_complete
add wave -radix hex rx_data
add wave tx
add wave tx_complete
add wave -radix hex tx_data
add wave busy
#add wave dut/*
add wave dut/TX0/*
add wave dut/ctl/curState
# add wave dut/ctl/nextState
#add wave -radix bin dut/ctl/rx_ready
#add wave -radix hex dut/ctl/rx_byte
#add wave -radix hex dut/ctl/rx_values_buffer
# add wave -radix hex dut/ctl/rx_indices_buffer
add wave -radix bin dut/ctl/tx_ready
add wave -radix hex dut/ctl/tx_byte
add wave -radix hex tx_buffer
add wave -radix dec dut/ctl/size_of
add wave dut/ctl/byte_count
#add wave -radix hex -label main_memory {dut/mainmem/ram}

### Force waves here ###

### ---------------------------------------------- ###
### Run simulation ###
### Do not modify ###
# to see your design hierarchy and signals
view structure

# to see all signal names and current values
view signals

### ---------------------------------------------- ###
### Edit run time ###
run 1 20us

### ---------------------------------------------- ###
### Will create large wave window and zoom to show all signals
view -undock wave
wave zoomfull