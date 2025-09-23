

#add wave -noupdate -group my_uvm_tb
#add wave -noupdate -group my_uvm_tb -radix decimal /my_uvm_tb/*

add wave -noupdate -group my_uvm_tb/edge_detect_inst
add wave -noupdate -group my_uvm_tb/edge_detect_inst -radix decimal /my_uvm_tb/edge_detect_inst/*

#add wave -noupdate -group my_uvm_tb/edge_detect_inst/edge_detect_inst
#add wave -noupdate -group my_uvm_tb/edge_detect_inst/edge_detect_inst -radix decimal /my_uvm_tb/edge_detect_inst/edge_detect_inst/*

add wave -noupdate -group my_uvm_tb/edge_detect_inst/grayscale_top_inst
add wave -noupdate -group my_uvm_tb/edge_detect_inst/grayscale_top_inst -radix decimal /my_uvm_tb/edge_detect_inst/grayscale_top_inst/*

add wave -noupdate -group my_uvm_tb/edge_detect_inst/sobel_inst
add wave -noupdate -group my_uvm_tb/edge_detect_inst/sobel_inst -radix decimal /my_uvm_tb/edge_detect_inst/sobel_inst/*

add wave -noupdate -group my_uvm_tb/edge_detect_inst/fifo_out_inst
add wave -noupdate -group my_uvm_tb/edge_detect_inst/fifo_out_inst -radix decimal /my_uvm_tb/edge_detect_inst/fifo_out_inst/*

