# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the packages
vlog -sv tb/pkg_tb.sv
vlog -sv rtl/axil_pkg.sv

# Compile the interfaces
vlog -sv rtl/axil_if.sv

# Compile the design and testbench
vlog -sv rtl/axil_decoder_addr_wr.sv
vlog -sv rtl/axil_response_addr_invalid_wr.sv
vlog -sv rtl/axil_arbiter_priority_wr.sv
vlog -sv rtl/axil_crossbar_ms_wr.sv
vlog -sv rtl/axil_crossbar_sm_wr.sv
vlog -sv rtl/axil_interconnect_wr.sv
vlog -sv rtl/axil_decoder_addr_rd.sv
vlog -sv rtl/axil_response_addr_invalid_rd.sv
vlog -sv rtl/axil_arbiter_priority_rd.sv
vlog -sv rtl/axil_crossbar_ms_rd.sv
vlog -sv rtl/axil_crossbar_sm_rd.sv
vlog -sv rtl/axil_interconnect_rd.sv
vlog -sv rtl/axil_interconnect.sv
vlog -sv rtl/axil_interconnect_wrapper_sv.sv
vlog -sv tb/axil_interconnect_tb.sv

# Set the number of master and slave interfaces
set NUMBER_MASTER   32
set NUMBER_SLAVE    16

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" axil_interconnect_tb

# Add signals to the waveform window
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/aclk
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/aresetn

# Run the simulation for the specified time
run 1ms

# Zoom out to show all waveform data
wave zoom full