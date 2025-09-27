# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the packages
vlog -sv tb/pkg_tb.sv

# Compile the interfaces
vlog -sv rtl/axil_if.sv

# Compile the design and testbench
vlog -sv rtl/axil_master.sv
vlog -sv rtl/axil_master_wrapper_sv.sv
vlog -sv tb/axil_master_tb.sv

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" axil_master_tb

# Add signals to the waveform window
add wave -radix binary          axil_master_tb/aresetn
add wave -radix binary          axil_master_tb/aclk

add wave -divider "User Write Interface"
add wave -radix binary          axil_master_tb/wr_valid
add wave -radix binary          axil_master_tb/wr_ready
add wave -radix hexadecimal     axil_master_tb/wr_addr
add wave -radix hexadecimal     axil_master_tb/wr_data
add wave -radix binary          axil_master_tb/wr_done
add wave -radix hexadecimal     axil_master_tb/wr_error

add wave -divider "User Read Interface"
add wave -radix binary          axil_master_tb/rd_valid
add wave -radix binary          axil_master_tb/rd_ready
add wave -radix hexadecimal     axil_master_tb/rd_addr
add wave -radix hexadecimal     axil_master_tb/rd_data
add wave -radix binary          axil_master_tb/rd_done
add wave -radix hexadecimal     axil_master_tb/rd_error

add wave -divider "AXI-Lite Master Interface"
add wave -radix hexadecimal 	axil_master_tb/s_axil_awaddr
add wave -radix binary 		    axil_master_tb/s_axil_awvalid
add wave -radix binary 		    axil_master_tb/s_axil_awready
add wave -radix hexadecimal     axil_master_tb/s_axil_wdata
add wave -radix hexadecimal     axil_master_tb/s_axil_wstrb
add wave -radix binary          axil_master_tb/s_axil_wvalid
add wave -radix binary          axil_master_tb/s_axil_wready
add wave -radix hexadecimal     axil_master_tb/s_axil_bresp
add wave -radix binary          axil_master_tb/s_axil_bvalid
add wave -radix binary          axil_master_tb/s_axil_bready

add wave -radix hexadecimal 	axil_master_tb/s_axil_araddr
add wave -radix binary 		    axil_master_tb/s_axil_arvalid
add wave -radix binary 		    axil_master_tb/s_axil_arready
add wave -radix hexadecimal     axil_master_tb/s_axil_rdata
add wave -radix binary          axil_master_tb/s_axil_rvalid
add wave -radix binary          axil_master_tb/s_axil_rready
add wave -radix hexadecimal     axil_master_tb/s_axil_rresp

add wave -divider "DUT Internal States"
add wave -radix binary          axil_master_tb/dut/axil_master_inst/state_wr
add wave -radix binary          axil_master_tb/dut/axil_master_inst/state_rd

# Run the simulation for the specified time
run 10ms

# Zoom out to show all waveform data
wave zoom full
