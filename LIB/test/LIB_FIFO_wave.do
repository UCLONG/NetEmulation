onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /LIB_FIFO_tb/clk
add wave -noupdate /LIB_FIFO_tb/reset_n
add wave -noupdate -expand -group {Data In} -radix hexadecimal /LIB_FIFO_tb/i_data
add wave -noupdate -expand -group {Data In} /LIB_FIFO_tb/i_data_val
add wave -noupdate -expand -group {Data In} /LIB_FIFO_tb/o_en
add wave -noupdate -expand -group {Data Out} -radix hexadecimal /LIB_FIFO_tb/o_data
add wave -noupdate -expand -group {Data Out} /LIB_FIFO_tb/o_data_val
add wave -noupdate -expand -group {Data Out} /LIB_FIFO_tb/i_en
add wave -noupdate -expand -group Flags /LIB_FIFO_tb/o_empty
add wave -noupdate -expand -group Flags /LIB_FIFO_tb/o_full
add wave -noupdate -expand -group Memory -radix hexadecimal -childformat {{{/LIB_FIFO_tb/INST_LIB_FIFO/l_mem[3]} -radix hexadecimal} {{/LIB_FIFO_tb/INST_LIB_FIFO/l_mem[2]} -radix hexadecimal} {{/LIB_FIFO_tb/INST_LIB_FIFO/l_mem[1]} -radix hexadecimal} {{/LIB_FIFO_tb/INST_LIB_FIFO/l_mem[0]} -radix hexadecimal}} -subitemconfig {{/LIB_FIFO_tb/INST_LIB_FIFO/l_mem[3]} {-height 15 -radix hexadecimal} {/LIB_FIFO_tb/INST_LIB_FIFO/l_mem[2]} {-height 15 -radix hexadecimal} {/LIB_FIFO_tb/INST_LIB_FIFO/l_mem[1]} {-height 15 -radix hexadecimal} {/LIB_FIFO_tb/INST_LIB_FIFO/l_mem[0]} {-height 15 -radix hexadecimal}} /LIB_FIFO_tb/INST_LIB_FIFO/l_mem
add wave -noupdate -expand -group Memory /LIB_FIFO_tb/INST_LIB_FIFO/l_mem_ptr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {299 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 185
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
WaveRestoreZoom {0 ps} {1329 ps}
