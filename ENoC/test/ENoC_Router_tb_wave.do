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
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1097370 ps} 0}
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
