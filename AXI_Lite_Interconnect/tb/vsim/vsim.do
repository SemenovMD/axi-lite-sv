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
vlog -sv rtl/axil_arbiter_wr.sv
vlog -sv rtl/axil_crossbar_ms_wr.sv
vlog -sv rtl/axil_crossbar_sm_wr.sv
vlog -sv rtl/axil_interconnect_wr.sv
vlog -sv rtl/axil_decoder_addr_rd.sv
vlog -sv rtl/axil_response_addr_invalid_rd.sv
vlog -sv rtl/axil_arbiter_rd.sv
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

# Create a separator for clarity
add wave -divider "MASTER INTERFACES"

# Loop through all master interfaces (s_axil)
for {set i 0} {$i < $NUMBER_MASTER} {incr i} {
    add wave -divider "Master $i"
    
    # Group master write signals
    add wave -group "Master_${i}_Write" -radix hex \
        axil_interconnect_tb/s_axil\[$i\]/awaddr \
        axil_interconnect_tb/s_axil\[$i\]/awvalid \
        axil_interconnect_tb/s_axil\[$i\]/awready \
        axil_interconnect_tb/s_axil\[$i\]/wdata \
        axil_interconnect_tb/s_axil\[$i\]/wstrb \
        axil_interconnect_tb/s_axil\[$i\]/wvalid \
        axil_interconnect_tb/s_axil\[$i\]/wready \
        axil_interconnect_tb/s_axil\[$i\]/bresp \
        axil_interconnect_tb/s_axil\[$i\]/bvalid \
        axil_interconnect_tb/s_axil\[$i\]/bready
    
    # Group master read signals  
    add wave -group "Master_${i}_Read" -radix hex \
        axil_interconnect_tb/s_axil\[$i\]/araddr \
        axil_interconnect_tb/s_axil\[$i\]/arvalid \
        axil_interconnect_tb/s_axil\[$i\]/arready \
        axil_interconnect_tb/s_axil\[$i\]/rdata \
        axil_interconnect_tb/s_axil\[$i\]/rresp \
        axil_interconnect_tb/s_axil\[$i\]/rvalid \
        axil_interconnect_tb/s_axil\[$i\]/rready
}

# Create a separator for slaves
add wave -divider "SLAVE INTERFACES"

# Loop through all slave interfaces (m_axil)
for {set i 0} {$i < $NUMBER_SLAVE} {incr i} {
    add wave -divider "Slave $i"
    
    # Group slave write signals
    add wave -group "Slave_${i}_Write" -radix hex \
        axil_interconnect_tb/m_axil\[$i\]/awaddr \
        axil_interconnect_tb/m_axil\[$i\]/awvalid \
        axil_interconnect_tb/m_axil\[$i\]/awready \
        axil_interconnect_tb/m_axil\[$i\]/wdata \
        axil_interconnect_tb/m_axil\[$i\]/wstrb \
        axil_interconnect_tb/m_axil\[$i\]/wvalid \
        axil_interconnect_tb/m_axil\[$i\]/wready \
        axil_interconnect_tb/m_axil\[$i\]/bresp \
        axil_interconnect_tb/m_axil\[$i\]/bvalid \
        axil_interconnect_tb/m_axil\[$i\]/bready
    
    # Group slave read signals
    add wave -group "Slave_${i}_Read" -radix hex \
        axil_interconnect_tb/m_axil\[$i\]/araddr \
        axil_interconnect_tb/m_axil\[$i\]/arvalid \
        axil_interconnect_tb/m_axil\[$i\]/arready \
        axil_interconnect_tb/m_axil\[$i\]/rdata \
        axil_interconnect_tb/m_axil\[$i\]/rresp \
        axil_interconnect_tb/m_axil\[$i\]/rvalid \
        axil_interconnect_tb/m_axil\[$i\]/rready
}

# Run the simulation for the specified time
run 1ms

# Zoom out to show all waveform data
wave zoom full