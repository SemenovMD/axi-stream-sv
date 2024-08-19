# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the design and testbench
vlog -sv    rtl/axis_if.sv
vlog -sv    rtl/axis_asyn_fifo.sv

vlog -sv    tb/tb_axis_asyn_fifo.sv

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" tb_axis_asyn_fifo

# Add signals to the waveform window
add wave -radix binary          tb_axis_asyn_fifo/axis_asyn_fifo_inst/aclk_wr
add wave -radix binary          tb_axis_asyn_fifo/axis_asyn_fifo_inst/aresetn_wr

add wave -radix binary          tb_axis_asyn_fifo/axis_asyn_fifo_inst/aclk_rd
add wave -radix binary          tb_axis_asyn_fifo/axis_asyn_fifo_inst/aresetn_rd

add wave -radix hexadecimal     tb_axis_asyn_fifo/axis_asyn_fifo_inst/m_axis/tdata
add wave -radix binary          tb_axis_asyn_fifo/axis_asyn_fifo_inst/m_axis/tvalid
add wave -radix binary          tb_axis_asyn_fifo/axis_asyn_fifo_inst/m_axis/tready

add wave -radix hexadecimal     tb_axis_asyn_fifo/axis_asyn_fifo_inst/s_axis/tdata
add wave -radix binary          tb_axis_asyn_fifo/axis_asyn_fifo_inst/s_axis/tvalid
add wave -radix binary          tb_axis_asyn_fifo/axis_asyn_fifo_inst/s_axis/tready

add wave -radix binary          tb_axis_asyn_fifo/axis_asyn_fifo_inst/fifo_empty
add wave -radix binary          tb_axis_asyn_fifo/axis_asyn_fifo_inst/fifo_full

add wave -radix unsigned        tb_axis_asyn_fifo/axis_asyn_fifo_inst/bin_index_rd
add wave -radix unsigned        tb_axis_asyn_fifo/axis_asyn_fifo_inst/bin_index_wr

# Run the simulation for the specified time
run 1ms

# Zoom out to show all waveform data
wave zoom full
