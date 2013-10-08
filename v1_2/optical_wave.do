onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Top Level Signals}
add wave -noupdate /net_emulation/rst
add wave -noupdate /net_emulation/clk
add wave -noupdate -radix unsigned -expand -subitemconfig {{/net_emulation/pkt_in[0]} {-radix unsigned} {/net_emulation/pkt_in[0].data} {-radix unsigned} {/net_emulation/pkt_in[0].source} {-radix unsigned} {/net_emulation/pkt_in[0].dest} {-radix unsigned} {/net_emulation/pkt_in[1]} {-radix unsigned} {/net_emulation/pkt_in[1].data} {-radix unsigned} {/net_emulation/pkt_in[1].source} {-radix unsigned} {/net_emulation/pkt_in[1].dest} {-radix unsigned} {/net_emulation/pkt_in[2]} {-radix unsigned} {/net_emulation/pkt_in[2].data} {-radix unsigned} {/net_emulation/pkt_in[2].source} {-radix unsigned} {/net_emulation/pkt_in[2].dest} {-radix unsigned} {/net_emulation/pkt_in[3]} {-radix unsigned} {/net_emulation/pkt_in[3].data} {-radix unsigned} {/net_emulation/pkt_in[3].source} {-radix unsigned} {/net_emulation/pkt_in[3].dest} {-radix unsigned}} /net_emulation/pkt_in
add wave -noupdate -radix unsigned -expand -subitemconfig {{/net_emulation/pkt_out[0]} {-radix unsigned} {/net_emulation/pkt_out[0].data} {-radix unsigned} {/net_emulation/pkt_out[0].source} {-radix unsigned} {/net_emulation/pkt_out[0].dest} {-radix unsigned} {/net_emulation/pkt_out[1]} {-radix unsigned} {/net_emulation/pkt_out[1].data} {-radix unsigned} {/net_emulation/pkt_out[1].source} {-radix unsigned} {/net_emulation/pkt_out[1].dest} {-radix unsigned} {/net_emulation/pkt_out[2]} {-radix unsigned} {/net_emulation/pkt_out[2].data} {-radix unsigned} {/net_emulation/pkt_out[2].source} {-radix unsigned} {/net_emulation/pkt_out[2].dest} {-radix unsigned} {/net_emulation/pkt_out[3]} {-radix unsigned} {/net_emulation/pkt_out[3].data} {-radix unsigned} {/net_emulation/pkt_out[3].source} {-radix unsigned} {/net_emulation/pkt_out[3].dest} {-radix unsigned}} /net_emulation/pkt_out
add wave -noupdate /net_emulation/sinks/input_fifo_error
add wave -noupdate /net_emulation/sinks/net_full
add wave -noupdate /net_emulation/sinks/dest_error
add wave -noupdate /net_emulation/source_on
add wave -noupdate /net_emulation/measure
add wave -noupdate -radix unsigned /net_emulation/timestamp
add wave -noupdate -divider Measurements
add wave -noupdate -radix unsigned /net_emulation/sinks/pkt_count_rx
add wave -noupdate -radix unsigned /net_emulation/sinks/pkt_count_tx
add wave -noupdate -radix unsigned /net_emulation/sinks/latency
add wave -noupdate -divider {Transmitter Signals}
add wave -noupdate {/net_emulation/source_loop[2]/pkts/net_full}
add wave -noupdate {/net_emulation/source_loop[2]/pkts/wr_en}
add wave -noupdate {/net_emulation/source_loop[2]/pkts/rd_en}
add wave -noupdate {/net_emulation/source_loop[2]/pkts/fifo_dout}
add wave -noupdate {/net_emulation/source_loop[2]/pkts/empty}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/req}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/dout}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/full}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/din}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/grant}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/clk}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/rst}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/full_int}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/fifo_out}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/we}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/re}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/empty}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/grant_buf}
add wave -noupdate -divider {Allocator Signals}
add wave -noupdate /net_emulation/inst_net/inst_alloc/grant
add wave -noupdate /net_emulation/inst_net/inst_alloc/grant_switch
add wave -noupdate /net_emulation/inst_net/inst_alloc/req
add wave -noupdate /net_emulation/inst_net/inst_alloc/clk
add wave -noupdate /net_emulation/inst_net/inst_alloc/rst
add wave -noupdate /net_emulation/inst_net/inst_alloc/ry
add wave -noupdate /net_emulation/inst_net/inst_alloc/gy
add wave -noupdate /net_emulation/inst_net/inst_alloc/grant_int
add wave -noupdate /net_emulation/inst_net/inst_alloc/grant_switch_int_x
add wave -noupdate /net_emulation/inst_net/inst_alloc/grant_switch_int_y
add wave -noupdate -radix unsigned /net_emulation/inst_net/inst_alloc/req_int
add wave -noupdate -radix unsigned /net_emulation/inst_net/inst_alloc/grant_counters
add wave -noupdate -radix unsigned /net_emulation/inst_net/inst_alloc/grant_ports
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
