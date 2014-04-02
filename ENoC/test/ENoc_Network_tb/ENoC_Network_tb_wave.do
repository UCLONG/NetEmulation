onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Global /ENoC_Network_tb/clk
add wave -noupdate -expand -group Global /ENoC_Network_tb/f_time
add wave -noupdate -expand -group Global /ENoC_Network_tb/reset_n
add wave -noupdate -expand -group {Node out} /ENoC_Network_tb/i_data
add wave -noupdate -expand -group {Node out} /ENoC_Network_tb/i_data_val
add wave -noupdate -expand -group {Node out} /ENoC_Network_tb/o_en
add wave -noupdate -expand -group {Node in} /ENoC_Network_tb/i_en
add wave -noupdate -expand -group {Node in} /ENoC_Network_tb/o_data
add wave -noupdate -expand -group {Node in} -expand /ENoC_Network_tb/o_data_val
add wave -noupdate -expand -group {Sim Data} /ENoC_Network_tb/s_i_data
add wave -noupdate -expand -group {Sim Data} /ENoC_Network_tb/s_i_data_val
add wave -noupdate -expand -group Counters /ENoC_Network_tb/f_port_i_data_count
add wave -noupdate -expand -group Counters /ENoC_Network_tb/f_total_i_data_count
add wave -noupdate -expand -group Counters /ENoC_Network_tb/f_port_o_data_count
add wave -noupdate -expand -group Counters /ENoC_Network_tb/f_total_o_data_count
add wave -noupdate -expand -group Counters /ENoC_Network_tb/f_average_latency
add wave -noupdate -expand -group Counters /ENoC_Network_tb/f_total_latency
add wave -noupdate -expand -group Counters /ENoC_Network_tb/f_cooldown_count
add wave -noupdate -expand -group Counters /ENoC_Network_tb/f_measured_packet_count
add wave -noupdate -expand -group Counters /ENoC_Network_tb/f_routing_fail_count
add wave -noupdate -expand -group {Random Flags} /ENoC_Network_tb/f_data_val
add wave -noupdate -expand -group {Random Flags} /ENoC_Network_tb/f_x_dest
add wave -noupdate -expand -group {Random Flags} /ENoC_Network_tb/f_y_dest
add wave -noupdate -expand -group {Random Flags} /ENoC_Network_tb/f_z_dest
add wave -noupdate -expand -group {Control Flags} /ENoC_Network_tb/f_saturate
add wave -noupdate -expand -group {Control Flags} /ENoC_Network_tb/f_test_abort
add wave -noupdate -expand -group {Control Flags} /ENoC_Network_tb/f_test_complete
add wave -noupdate -expand -group {Control Flags} /ENoC_Network_tb/f_test_fail
add wave -noupdate -expand -group {Control Flags} /ENoC_Network_tb/f_txrx
add wave -noupdate -expand -group {Control Flags} /ENoC_Network_tb/f_burst_count
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {355000 ps} 0}
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
WaveRestoreZoom {318117 ps} {429753 ps}
