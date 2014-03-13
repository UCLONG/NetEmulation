onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Global Signals} /ENoC_Router_tb/clk
add wave -noupdate -expand -group {Global Signals} /ENoC_Router_tb/reset_n
add wave -noupdate -expand -group {Global Signals} -radix unsigned /ENoC_Router_tb/f_time
add wave -noupdate -expand -group {DUT Upstream Bus} /ENoC_Router_tb/i_data
add wave -noupdate -expand -group {DUT Upstream Bus} /ENoC_Router_tb/i_data_val
add wave -noupdate -expand -group {DUT Upstream Bus} /ENoC_Router_tb/o_en
add wave -noupdate -expand -group {DUT Downstream Bus} /ENoC_Router_tb/i_en
add wave -noupdate -expand -group {DUT Downstream Bus} /ENoC_Router_tb/o_data
add wave -noupdate -expand -group {DUT Downstream Bus} /ENoC_Router_tb/o_data_val
add wave -noupdate -expand -group {Simulated Upstream Routers} /ENoC_Router_tb/s_i_data
add wave -noupdate -expand -group {Simulated Upstream Routers} /ENoC_Router_tb/s_i_data_val
add wave -noupdate -expand -group {Random Flags} /ENoC_Router_tb/f_data_val
add wave -noupdate -expand -group {Random Flags} /ENoC_Router_tb/f_x_dest
add wave -noupdate -expand -group {Random Flags} /ENoC_Router_tb/f_y_dest
add wave -noupdate -expand -group {Control Flags} /ENoC_Router_tb/f_total_i_data_count
add wave -noupdate -expand -group {Control Flags} /ENoC_Router_tb/f_total_o_data_count
add wave -noupdate -expand -group {Control Flags} /ENoC_Router_tb/f_measured_packet_count
add wave -noupdate -expand -group {Control Flags} /ENoC_Router_tb/f_total_latency
add wave -noupdate -expand -group {Control Flags} /ENoC_Router_tb/f_average_latency
add wave -noupdate -expand -group {Control Flags} /ENoC_Router_tb/f_saturate
add wave -noupdate -expand -group {Control Flags} /ENoC_Router_tb/f_routing_fail_count
add wave -noupdate -expand -group {Control Flags} /ENoC_Router_tb/f_cooldown_count
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Queue 6} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Queue 5} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Queue 4} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Queue 3} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Queue 2} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Queue 1} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Queue 0} {/ENoC_Router_tb/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -divider DUT
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/X_NODES
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/Y_NODES
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/Z_NODES
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/X_LOC
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/Y_LOC
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/Z_LOC
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/INPUT_QUEUE_DEPTH
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/N
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/M
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/clk
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/reset_n
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/i_data
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/i_data_val
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/o_en
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/o_data
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/o_data_val
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/i_en
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/l_i_data
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/l_i_data_val
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/l_o_en
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/l_data
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/l_output_req
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/l_output_grant
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/ce
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/l_data_val
add wave -noupdate -group {Router Top} /ENoC_Router_tb/DUT_ENoC_Router/l_en
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Port 6} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[6]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Port 5} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[5]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Port 4} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[4]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Port 3} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[3]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Port 2} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[2]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Port 1} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate -group {Input Port 0} {/ENoC_Router_tb/DUT_ENoC_Router/GENERATE_INPUT_QUEUES[0]/gen_LIB_FIFO_packet_t/l_mem}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {38109 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 296
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {111636 ps}
