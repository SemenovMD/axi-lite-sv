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

# Loop to add master write signals
for {set i 0} {$i < $NUMBER_MASTER} {incr i} {
	add wave -radix hexadecimal 	axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_awaddr[$i]
    add wave -radix binary 		    axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_awvalid[$i]
    add wave -radix binary 		    axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_awready[$i]

    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_wdata[$i]
    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_wstrb[$i]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_wvalid[$i]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_wready[$i]

    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_bresp[$i]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_bvalid[$i]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_bready[$i]
}

# Loop to add slave write signals
for {set j 0} {$j < $NUMBER_SLAVE} {incr j} {
    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_awaddr[$j]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_awvalid[$j]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_awready[$j]  
    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_wdata[$j]
    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_wstrb[$j]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_wvalid[$j]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_wready[$j]   
    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_bresp[$j]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_bvalid[$j]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_bready[$j]
}

# Loop to add master read signals
for {set i 0} {$i < $NUMBER_MASTER} {incr i} {
	add wave -radix hexadecimal 	axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_araddr[$i]
    add wave -radix binary 		    axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_arvalid[$i]
    add wave -radix binary 		    axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_arready[$i]

    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_rdata[$i]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_rvalid[$i]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_rready[$i]
    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/m_axil_rresp[$i]
}

# Loop to add slave read signals
for {set j 0} {$j < $NUMBER_SLAVE} {incr j} {
    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_araddr[$j]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_arvalid[$j]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_arready[$j]

    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_rdata[$j]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_rvalid[$j]
    add wave -radix binary          axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_rready[$j]
    add wave -radix hexadecimal     axil_interconnect_tb/axil_interconnect_wrapper_sv_inst/s_axil_rresp[$j]
}

# Run the simulation for the specified time
run 1ms

# Zoom out to show all waveform data
wave zoom full