if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

### ---------------------------------------------- ###
### Compile code ###
### Enter files here; copy line for multiple files ###
vlog -sv -work work test_system.sv
vlog -sv -work work +define+SIMULATION ../comm/comm.sv
vlog -sv -work work +define+SIMULATION ../comm/control.sv
vlog -sv -work work +define+SIMULATION ../comm/tx/async_tx.sv
vlog -sv -work work +define+SIMULATION ../comm/tx/baudtick_tx.sv
vlog -sv -work work +define+SIMULATION ../comm/rx/async_rx.sv
vlog -sv -work work +define+SIMULATION ../comm/rx/baudtick_rx.sv
vlog -sv -work work +define+SIMULATION ../memory.sv
vlog -sv -work work +define+SIMULATION ../sparse_matrix_coprocessor.sv
vlog -sv -work work +define+SIMULATION ../fall_detect.sv
### ---------------------------------------------- ###
### Load design for simulation ###
### Replace topLevelModule with the name of your top level module (no .sv) ###
### Do not duplicate! ###
vsim test_system

### ---------------------------------------------- ###
### Add waves here ###
### Use add wave * to see all signals ###
add wave *
add wave dut/c/ctl/*
add wave dut/mainmem/*
add wave dut/mainmem/ram

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