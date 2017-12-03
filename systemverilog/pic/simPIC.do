if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

### ---------------------------------------------- ###
### Compile code ###
### Enter files here; copy line for multiple files ###
vlog -sv -work work [pwd]/testPIC.sv
vlog -sv -work work -suppress 7061 [pwd]/PIC.sv
vlog -sv -work work -suppress 7061 [pwd]/fifo.sv
vlog -sv -work work [pwd]/controlPIC.sv
vlog -sv -work work [pwd]/compare.sv

### ---------------------------------------------- ###
### Load design for simulation ###
### Replace topLevelModule with the name of your top level module (no .sv) ###
### Do not duplicate! ###
vsim testPIC

### ---------------------------------------------- ###
### Add waves here ###
### Use add wave * to see all signals ###
add wave *
add wave dutPIC/m3/fifo
add wave dutPIC/m1/eq
add wave dutPIC/m1/dataOut
add wave dutPIC/m2/currentState
add wave dutPIC/m2/nextState
add wave dutPIC/m2/waddr
add wave dutPIC/m2/raddr

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
run 3000 ns     

### ---------------------------------------------- ###
### Will create large wave window and zoom to show all signals
view -undock wave
wave zoomfull 