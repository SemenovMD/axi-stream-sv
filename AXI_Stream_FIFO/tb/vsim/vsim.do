# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the packages
vlog -sv rtl/axis_fifo_pkg_prm.sv
vlog -sv tb/axis_fifo_pkg_tb.sv

# Compile the interfaces
vlog -sv rtl/axis_if.sv

# Compile the design and testbench
vlog -sv rtl/axis_fifo.sv
vlog -sv tb/axis_fifo_tb.sv

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" axis_fifo_tb

# Add signals to the waveform window
add wave -radix binary          axis_fifo_inst/aclk
add wave -radix binary          axis_fifo_inst/aresetn

add wave -radix hexadecimal     axis_fifo_inst/m_axis/tdata
add wave -radix binary          axis_fifo_inst/m_axis/tvalid
add wave -radix binary          axis_fifo_inst/m_axis/tready

add wave -radix hexadecimal     axis_fifo_inst/s_axis/tdata
add wave -radix binary          axis_fifo_inst/s_axis/tvalid
add wave -radix binary          axis_fifo_inst/s_axis/tready

add wave -radix binary          axis_fifo_inst/fifo_empty
add wave -radix binary          axis_fifo_inst/fifo_half
add wave -radix binary          axis_fifo_inst/fifo_full

add wave -radix unsigned        axis_fifo_inst/index_rd
add wave -radix unsigned        axis_fifo_inst/index_wr
add wave -radix unsigned        axis_fifo_inst/index_rd_wr


# Run the simulation for the specified time
run 1ms

# Zoom out to show all waveform data
wave zoom full
