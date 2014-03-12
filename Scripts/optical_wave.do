onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Top Level Signals}
add wave -noupdate /NEMU_NetEmulation/rst
add wave -noupdate /NEMU_NetEmulation/clk
add wave -noupdate -radix unsigned -subitemconfig {{/NEMU_NetEmulation/pkt_in[0]} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[0].data} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[0].source} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[0].dest} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[1]} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[1].data} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[1].source} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[1].dest} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[2]} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[2].data} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[2].source} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[2].dest} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[3]} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[3].data} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[3].source} {-radix unsigned} {/NEMU_NetEmulation/pkt_in[3].dest} {-radix unsigned}} /NEMU_NetEmulation/pkt_in
add wave -noupdate -radix unsigned -subitemconfig {{/NEMU_NetEmulation/pkt_out[0]} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[0].data} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[0].source} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[0].dest} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[1]} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[1].data} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[1].source} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[1].dest} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[2]} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[2].data} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[2].source} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[2].dest} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[3]} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[3].data} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[3].source} {-radix unsigned} {/NEMU_NetEmulation/pkt_out[3].dest} {-radix unsigned}} /NEMU_NetEmulation/pkt_out
add wave -noupdate /NEMU_NetEmulation/sinks/i_input_fifo_error
add wave -noupdate /NEMU_NetEmulation/sinks/i_net_full
add wave -noupdate /NEMU_NetEmulation/sinks/l_dest_error
add wave -noupdate /NEMU_NetEmulation/source_on
add wave -noupdate /NEMU_NetEmulation/measure
add wave -nonupdate /NEMU_NetEmulation/timecounter
add wave -nonupdate /NEMU_NetEmulation/sendData
add wave -noupdate -radix unsigned /NEMU_NetEmulation/timestamp
add wave -noupdate -divider Measurements
add wave -noupdate -radix unsigned /NEMU_NetEmulation/sinks/o_pkt_count_rx
add wave -noupdate -radix unsigned /NEMU_NetEmulation/sinks/o_pkt_count_tx
add wave -noupdate -radix unsigned /NEMU_NetEmulation/sinks/o_latency
add wave -nonupdate -radix unsigned /NEMU_NetEmulation/sinks/o_pkt_count_tx_not_measured
add wave -nonupdate -radix unsigned /NEMU_NetEmulation/total_pkt_count
add wave -nonupdate -radix unsigned /NEMU_NetEmulation/sinks/l_batch_number
add wave -nonupdate -radix unsigned /NEMU_NetEmulation/sinks/l_batch_counter

add wave -nonupdate  sim:/NEMU_NetEmulation/source_loop[0]/pkts/l_dest
add wave -nonupdate  sim:/NEMU_NetEmulation/source_loop[1]/pkts/l_dest
//testing purposes
add wave -noupdate   sim:/NEMU_NetEmulation/wrap/o_done
add wave -noupdate   sim:/NEMU_NetEmulation/wrap/data
add wave -noupdate   sim:/NEMU_NetEmulation/wrap/m
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/n
add wave -noupdate   sim:/NEMU_NetEmulation/wrap/k
add wave -noupdate  -radix usnigned 28  sim:/NEMU_NetEmulation/wrap/i_latency
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/i_SendSerial
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/enable
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/data1
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/data2
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/data3
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/data4
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/data5
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/data6
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/data7
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/testSignalLatency
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/testSignalRx
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/testSignalTx
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/beginning
add wave -noupdate -divider {SerialPort}
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/serial/o_serialTX
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/serial/l_serialData
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/serial/o_serialFifoEmpty
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/serial/i_data
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/serial/i_wrEn
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/serial/l_counter
add wave -noupdate  sim:/NEMU_NetEmulation/wrap/serial/l_state
//end of testing
add wave -noupdate -divider {Transmitter Signals}
add wave -noupdate {/NEMU_NetEmulation/source_loop[2]/pkts/i_net_full}
add wave -noupdate {/NEMU_NetEmulation/source_loop[2]/pkts/l_wr_en}
add wave -noupdate {/NEMU_NetEmulation/source_loop[2]/pkts/l_rd_en}
add wave -noupdate {/NEMU_NetEmulation/source_loop[2]/pkts/l_fifo_dout}
add wave -noupdate {/NEMU_NetEmulation/source_loop[2]/pkts/l_empty}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/req}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/dout}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/full}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/din}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/grant}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/clk}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/rst}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/full_int}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/fifo_out}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/we}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/re}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/empty}
add wave -noupdate {/NEMU_NetEmulation/inst_net/genblk1[2]/inst_txs/grant_buf}
add wave -noupdate -divider {Allocator Signals}
add wave -noupdate /NEMU_NetEmulation/inst_net/inst_alloc/grant
add wave -noupdate /NEMU_NetEmulation/inst_net/inst_alloc/grant_switch
add wave -noupdate /NEMU_NetEmulation/inst_net/inst_alloc/req
add wave -noupdate /NEMU_NetEmulation/inst_net/inst_alloc/clk
add wave -noupdate /NEMU_NetEmulation/inst_net/inst_alloc/rst
add wave -noupdate /NEMU_NetEmulation/inst_net/inst_alloc/ry
add wave -noupdate /NEMU_NetEmulation/inst_net/inst_alloc/gy
add wave -noupdate /NEMU_NetEmulation/inst_net/inst_alloc/grant_int
add wave -noupdate /NEMU_NetEmulation/inst_net/inst_alloc/grant_switch_int_x
add wave -noupdate /NEMU_NetEmulation/inst_net/inst_alloc/grant_switch_int_y
add wave -noupdate -radix unsigned /NEMU_NetEmulation/inst_net/inst_alloc/req_int
add wave -noupdate -radix unsigned /NEMU_NetEmulation/inst_net/inst_alloc/grant_counters
add wave -noupdate -radix unsigned /NEMU_NetEmulation/inst_net/inst_alloc/grant_ports
add wave -noupdate -divider {ENoC Wrapper}
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/clk 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/rst 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/pkt_in 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/pkt_out 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/net_full
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/l_pkt_in 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/l_pkt_out 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/l_i_data_val 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/l_o_data_val 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/l_o_en
add wave -noupdate -divider {ENoC Network}
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/X_NODES 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/Y_NODES 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/NODES 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/ROUTERS 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/DEGREE 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/INPUT_QUEUE_DEPTH 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/clk 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/reset_n 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/i_data 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/i_data_val 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/o_en 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/o_data 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/o_data_val 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/i_en 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/l_datain 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/l_datain_val 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/l_o_en 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/l_dataout 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/l_dataout_val 
add wave -noupdate sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/l_i_en 
add wave -noupdate -divider {ENoC Router}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/X_NODES}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/Y_NODES}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/X_LOC}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/Y_LOC}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/INPUT_QUEUE_DEPTH}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/N}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/M}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/clk}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/reset_n}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/i_data}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/i_data_val}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/o_en}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/o_data}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/o_data_val}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/i_en}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/l_i_data}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/l_i_data_val}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/l_o_en}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/l_sel}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/l_data}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/l_output_req}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/l_output_grant}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/ce}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/l_data_val}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/l_en}
add wave -noupdate -divider {ENoC Route Calculator}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_ROUTE_CALCULATORS[1]/gen_ENoC_RouteCalculator/X_NODES}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_ROUTE_CALCULATORS[1]/gen_ENoC_RouteCalculator/Y_NODES}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_ROUTE_CALCULATORS[1]/gen_ENoC_RouteCalculator/X_LOC}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_ROUTE_CALCULATORS[1]/gen_ENoC_RouteCalculator/Y_LOC}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_ROUTE_CALCULATORS[1]/gen_ENoC_RouteCalculator/i_x_dest}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_ROUTE_CALCULATORS[1]/gen_ENoC_RouteCalculator/i_y_dest}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_ROUTE_CALCULATORS[1]/gen_ENoC_RouteCalculator/i_val}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_ROUTE_CALCULATORS[1]/gen_ENoC_RouteCalculator/o_output_req}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_ROUTE_CALCULATORS[1]/gen_ENoC_RouteCalculator/l_output_req}
add wave -noupdate -divider {ENoC FIFO}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/DEPTH}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/clk}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/ce}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/reset_n}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/i_data}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/i_data_val}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/i_en}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_data}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_data_val}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_en}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_full}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_empty}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/o_near_empty}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/l_mem_ptr}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/GENERATE_INPUT_QUEUES[1]/gen_LIB_FIFO_packet_t/l_mem}
add wave -noupdate -divider {ENoC Switch Control}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_ENoC_SwitchControl/N}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_ENoC_SwitchControl/M}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_ENoC_SwitchControl/clk}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_ENoC_SwitchControl/ce}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_ENoC_SwitchControl/reset_n}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_ENoC_SwitchControl/i_en}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_ENoC_SwitchControl/i_output_req}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_ENoC_SwitchControl/o_output_grant}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_ENoC_SwitchControl/l_output_grant}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_ENoC_SwitchControl/l_req_matrix}
add wave -noupdate -divider {ENoC Switch}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_LIB_Switch_OneHot_packet_t/N}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_LIB_Switch_OneHot_packet_t/M}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_LIB_Switch_OneHot_packet_t/i_sel}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_LIB_Switch_OneHot_packet_t/i_data}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_LIB_Switch_OneHot_packet_t/o_data}
add wave -noupdate {sim:/NEMU_NetEmulation/inst_net/inst_ENoC_Network/GENERATE_Y_ROUTERS[3]/GENERATE_X_ROUTERS[3]/gen_ENoC_Router/inst_LIB_Switch_OneHot_packet_t/l_data}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 346
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
WaveRestoreZoom {0 ps} {199140 ps}
