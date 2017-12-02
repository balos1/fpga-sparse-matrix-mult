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
vlog -sv -work work ../BaudTickGen.sv
vlog -sv -work work +define+SIMULATION ../async_receiver.sv
vlog -sv -work work +define+SIMULATION ../async_transmitter.sv
vlog -sv -work work +define+SIMULATION ../../memory.sv
### ---------------------------------------------- ###
### Load design for simulation ###
### Replace topLevelModule with the name of your top level module (no .sv) ###
### Do not duplicate! ###
vsim test_comm_unit

### ---------------------------------------------- ###
### Add waves here ###
### Use add wave * to see all signals ###
add wave *

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
run 10000 ns     

### ---------------------------------------------- ###
### Will create large wave window and zoom to show all signals
view -undock wave
wave zoomfull 