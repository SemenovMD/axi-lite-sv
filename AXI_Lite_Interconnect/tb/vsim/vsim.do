# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the design and testbench
vlog -sv rtl/axil_crossbar_wr.sv
vlog -sv tb/axil_crossbar_wr_tb.sv

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" axil_crossbar_wr_tb

# Add signals to the waveform window
add wave -radix binary          axil_crossbar_wr_inst/grant_wr[0]
add wave -radix binary          axil_crossbar_wr_inst/grant_wr[1]
add wave -radix binary          axil_crossbar_wr_inst/grant_wr[2]
add wave -radix binary          axil_crossbar_wr_inst/grant_wr[3]
add wave -radix hexadecimal     axil_crossbar_wr_inst/m_axil_wdata[0]
add wave -radix hexadecimal     axil_crossbar_wr_inst/m_axil_wdata[1]
add wave -radix hexadecimal     axil_crossbar_wr_inst/s_axil_wdata[0]
add wave -radix hexadecimal     axil_crossbar_wr_inst/s_axil_wdata[1]
add wave -radix hexadecimal     axil_crossbar_wr_inst/s_axil_wdata[2]
add wave -radix hexadecimal     axil_crossbar_wr_inst/s_axil_wdata[3]

# Run the simulation for the specified time
run 10ms

# Zoom out to show all waveform data
wave zoom full
