proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/mem_stage_tb/clk
    add wave -position end sim:/mem_stage_tb/reset
    add wave -position end sim:/mem_stage_tb/ex_result
    add wave -position end sim:/mem_stage_tb/ex_dest_reg
    add wave -position end sim:/mem_stage_tb/ex_load
    add wave -position end sim:/mem_stage_tb/ex_store
    add wave -position end sim:/mem_stage_tb/wb_data
    add wave -position end sim:/mem_stage_tb/wb_dest_reg
    add wave -position end sim:/mem_stage_tb/s_mem_read_data
    add wave -position end sim:/mem_stage_tb/s_mem_waitrequest
    add wave -position end sim:/mem_stage_tb/s_mem_write
    add wave -position end sim:/mem_stage_tb/s_mem_read
    add wave -position end sim:/mem_stage_tb/s_mem_addr
    add wave -position end sim:/mem_stage_tb/s_mem_write_data
    add wave -position end sim:/mem_stage_tb/stall
	add wave -position end sim:/mem_stage_tb/cache_read
	add wave -position end sim:/mem_stage_tb/cache_write
	add wave -position end sim:/mem_stage_tb/cache_write_data
	add wave -position end sim:/mem_stage_tb/cache_read_data
	add wave -position end sim:/mem_stage_tb/cache_waitrequest

}

vlib work

;# Compile components if any
vcom mem_stage.vhd
vcom memory.vhd
vcom mem_stage_tb.vhd
vcom cache.vhd

;# Start simulation
vsim mem_stage_tb

;# Generate a clock with 1ns period
#force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

;# Add the waves
AddWaves

run 1100ns
