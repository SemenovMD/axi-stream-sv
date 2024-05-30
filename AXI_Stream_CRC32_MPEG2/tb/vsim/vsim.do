# Enable transcript logging
transcript on

# Create the work library
vlib work

# Compile the packages
vlog -sv rtl/axis_crc32_mpeg2_pkg_prm.sv
vlog -sv tb/axis_crc32_mpeg2_pkg_tb.sv

# Compile the interfaces
vlog -sv rtl/axis_crc32_mpeg2_if.sv

# Compile the design and testbench
vlog -sv rtl/axis_crc32_mpeg2.sv
vlog -sv tb/axis_crc32_mpeg2_tb.sv

# Simulate the testbench
vsim -t 1ns -L altera_mf_ver -voptargs="+acc" axis_crc32_mpeg2_tb

# Add signals to the waveform window
add wave -radix binary          axis_crc32_mpeg2_inst/aclk
add wave -radix binary          axis_crc32_mpeg2_inst/aresetn

add wave -radix hexadecimal     axis_crc32_mpeg2_inst/m_axis/tdata
add wave -radix binary          axis_crc32_mpeg2_inst/m_axis/tvalid
add wave -radix binary          axis_crc32_mpeg2_inst/m_axis/tready

add wave -radix hexadecimal     axis_crc32_mpeg2_inst/s_axis/tdata
add wave -radix binary          axis_crc32_mpeg2_inst/s_axis/tvalid
add wave -radix binary          axis_crc32_mpeg2_inst/s_axis/tready

add wave -radix binary          axis_crc32_mpeg2_inst/crc_done

add wave -radix hexadecimal     axis_crc32_mpeg2_inst/crc_buf
add wave -radix hexadecimal     axis_crc32_mpeg2_tb/crc_expected

# Run the simulation for the specified time
run 1ms

# Zoom out to show all waveform data
wave zoom full
