# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the packages
vlog -sv tb/pkg_tb.sv

# Compile the interfaces
vlog -sv rtl/axil_if.sv

# Compile the design and testbench
vlog -sv rtl/axil_slave.sv
vlog -sv rtl/axil_slave_wrapper_sv.sv
vlog -sv tb/axil_slave_tb.sv

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" axil_slave_tb

# Add signals to the waveform window
add wave -radix binary          axil_slave_tb/aresetn
add wave -radix binary          axil_slave_tb/aclk

add wave -radix hexadecimal     axil_slave_tb/gpio_out

# Add AXI-Lite m_axil interface signals
add wave -divider "AXI-Lite Master"
add wave -radix hexadecimal     axil_slave_tb/m_axil.awaddr
add wave -radix binary          axil_slave_tb/m_axil.awvalid
add wave -radix binary          axil_slave_tb/m_axil.awready
add wave -radix hexadecimal     axil_slave_tb/m_axil.wdata
add wave -radix hexadecimal     axil_slave_tb/m_axil.wstrb
add wave -radix binary          axil_slave_tb/m_axil.wvalid
add wave -radix binary          axil_slave_tb/m_axil.wready
add wave -radix hexadecimal     axil_slave_tb/m_axil.bresp
add wave -radix binary          axil_slave_tb/m_axil.bvalid
add wave -radix binary          axil_slave_tb/m_axil.bready
add wave -radix hexadecimal     axil_slave_tb/m_axil.araddr
add wave -radix binary          axil_slave_tb/m_axil.arvalid
add wave -radix binary          axil_slave_tb/m_axil.arready
add wave -radix hexadecimal     axil_slave_tb/m_axil.rdata
add wave -radix hexadecimal     axil_slave_tb/m_axil.rresp
add wave -radix binary          axil_slave_tb/m_axil.rvalid
add wave -radix binary          axil_slave_tb/m_axil.rready

# Run the simulation for the specified time
run 1ms

# Zoom out to show all waveform data
wave zoom full
