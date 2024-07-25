# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the packages
vlog -sv tb/pkg_tb.sv

# Compile the design and testbench
vlog -sv rtl/axil_decoder_addr_wr.sv
vlog -sv rtl/axil_arbiter_priority_wr.sv
vlog -sv rtl/axil_crossbar_wr.sv
vlog -sv rtl/axil_interconnect.sv
vlog -sv rtl/axil_interconnect_wrapper.sv
vlog -sv tb/axil_interconnect_tb.sv

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" axil_interconnect_tb

# Add signals to the waveform window
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/aclk
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/aresetn

add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/axil_interconnect_inst/axil_arbiter_priority_wr[0]/axil_arbiter_priority_wr_inst/grant_wr
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/axil_interconnect_inst/axil_arbiter_priority_wr[0]/axil_arbiter_priority_wr_inst/state_arb

add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_awaddr[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_awvalid[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_awready[0]

add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_wdata[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_wstrb[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_wvalid[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_wready[0]

add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_bresp[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_bvalid[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_bready[0]

add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_awaddr[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_awvalid[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_awready[1]

add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_wdata[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_wstrb[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_wvalid[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_wready[1]

add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_bresp[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_bvalid[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/m_axil_bready[1]



add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awaddr[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awvalid[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awready[0]

add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wdata[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wstrb[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wvalid[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wready[0]

add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bresp[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bvalid[0]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bready[0]

add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awaddr[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awvalid[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awready[1]

add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wdata[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wstrb[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wvalid[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wready[1]

add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bresp[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bvalid[1]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bready[1]

add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awaddr[2]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awvalid[2]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awready[2]

add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wdata[2]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wstrb[2]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wvalid[2]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wready[2]

add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bresp[2]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bvalid[2]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bready[2]

add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awaddr[3]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awvalid[3]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_awready[3]

add wave -radix hexadecimal         axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wdata[3]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wstrb[3]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wvalid[3]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_wready[3]

add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bresp[3]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bvalid[3]
add wave -radix binary              axil_interconnect_tb/axil_interconnect_wrapper_inst/s_axil_bready[3]


# Run the simulation for the specified time
run 10ms

# Zoom out to show all waveform data
wave zoom full
