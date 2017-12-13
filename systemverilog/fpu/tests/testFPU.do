# Script to run testbench

# Compile Design
vlog -reportprogress 300 -work work ../fpu/mult.sv
vlog -suppress 2244 -reportprogress 300 -work work ../fpu/adder.sv

# Simulate
set mult "MULT"
set add "ADD"
set condSigA [string compare $1 $mult]
set condSigB [string compare $1 $add]
if "$condSigA==0" {
	# Compile Testbench
	vlog -sv -reportprogress 300 -work work testMult.sv
	vsim -L work -voptargs="+acc" -gtestFileName="test_vectors/testmult.txt" -gnumTests=32 testMult
} elseif "$condSigB==0" {
    # Compile Testbench
	vlog -sv -reportprogress 300 -work work testAdder.sv
	vsim -L work -voptargs="+acc" -gtestFileName="test_vectors/testadd.txt" -gnumTests=32 testAdder
}

# Run simulation and plot
add wave -label clk {clk}
add wave -label reset {reset}
add wave -label clk_en {clk_en}
add wave -radix hex -label A {dataa}
add wave -radix hex -label B {datab}
add wave -radix hex -label Y {result}
add wave -label NaN {nan}
add wave -label overflow {overflow}
add wave -label underflow {underflow}

# Add your debug signals here
add wave dut/next_state
add wave dut/current_state

# Plot signal values
view structure
view signals
run 100000 ns
