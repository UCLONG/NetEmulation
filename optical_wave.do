onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Top Level Signals}
add wave -noupdate /net_emulation/rst
add wave -noupdate /net_emulation/clk
add wave -noupdate -radix unsigned -childformat {{{/net_emulation/pkt_in[0]} -radix unsigned} {{/net_emulation/pkt_in[1]} -radix unsigned} {{/net_emulation/pkt_in[2]} -radix unsigned -childformat {{{/net_emulation/pkt_in[2].data} -radix unsigned} {{/net_emulation/pkt_in[2].source} -radix unsigned} {{/net_emulation/pkt_in[2].dest} -radix unsigned} {{/net_emulation/pkt_in[2].seq} -radix unsigned} {{/net_emulation/pkt_in[2].valid} -radix unsigned}}} {{/net_emulation/pkt_in[3]} -radix unsigned}} -expand -subitemconfig {{/net_emulation/pkt_in[0]} {-height 16 -radix unsigned} {/net_emulation/pkt_in[1]} {-height 16 -radix unsigned} {/net_emulation/pkt_in[2]} {-height 16 -radix unsigned -childformat {{{/net_emulation/pkt_in[2].data} -radix unsigned} {{/net_emulation/pkt_in[2].source} -radix unsigned} {{/net_emulation/pkt_in[2].dest} -radix unsigned} {{/net_emulation/pkt_in[2].seq} -radix unsigned} {{/net_emulation/pkt_in[2].valid} -radix unsigned}} -expand} {/net_emulation/pkt_in[2].data} {-height 16 -radix unsigned} {/net_emulation/pkt_in[2].source} {-height 16 -radix unsigned} {/net_emulation/pkt_in[2].dest} {-height 16 -radix unsigned} {/net_emulation/pkt_in[2].seq} {-height 16 -radix unsigned} {/net_emulation/pkt_in[2].valid} {-height 16 -radix unsigned} {/net_emulation/pkt_in[3]} {-height 16 -radix unsigned}} /net_emulation/pkt_in
add wave -noupdate -radix unsigned -childformat {{{/net_emulation/pkt_out[0]} -radix unsigned} {{/net_emulation/pkt_out[1]} -radix unsigned} {{/net_emulation/pkt_out[2]} -radix unsigned} {{/net_emulation/pkt_out[3]} -radix unsigned -childformat {{{/net_emulation/pkt_out[3].data} -radix unsigned} {{/net_emulation/pkt_out[3].source} -radix unsigned} {{/net_emulation/pkt_out[3].dest} -radix unsigned} {{/net_emulation/pkt_out[3].seq} -radix unsigned} {{/net_emulation/pkt_out[3].valid} -radix unsigned}}}} -expand -subitemconfig {{/net_emulation/pkt_out[0]} {-height 16 -radix unsigned} {/net_emulation/pkt_out[1]} {-height 16 -radix unsigned} {/net_emulation/pkt_out[2]} {-height 16 -radix unsigned} {/net_emulation/pkt_out[3]} {-height 16 -radix unsigned -childformat {{{/net_emulation/pkt_out[3].data} -radix unsigned} {{/net_emulation/pkt_out[3].source} -radix unsigned} {{/net_emulation/pkt_out[3].dest} -radix unsigned} {{/net_emulation/pkt_out[3].seq} -radix unsigned} {{/net_emulation/pkt_out[3].valid} -radix unsigned}} -expand} {/net_emulation/pkt_out[3].data} {-height 16 -radix unsigned} {/net_emulation/pkt_out[3].source} {-height 16 -radix unsigned} {/net_emulation/pkt_out[3].dest} {-height 16 -radix unsigned} {/net_emulation/pkt_out[3].seq} {-height 16 -radix unsigned} {/net_emulation/pkt_out[3].valid} {-height 16 -radix unsigned}} /net_emulation/pkt_out
add wave -noupdate /net_emulation/sinks/input_fifo_error
add wave -noupdate /net_emulation/sinks/net_full
add wave -noupdate /net_emulation/sinks/dest_error
add wave -noupdate /net_emulation/source_on
add wave -noupdate /net_emulation/measure
add wave -noupdate -radix unsigned /net_emulation/timestamp
add wave -noupdate -divider Measurements
add wave -noupdate -radix unsigned -childformat {{{/net_emulation/sinks/pkt_count_rx[0]} -radix unsigned} {{/net_emulation/sinks/pkt_count_rx[1]} -radix unsigned} {{/net_emulation/sinks/pkt_count_rx[2]} -radix unsigned} {{/net_emulation/sinks/pkt_count_rx[3]} -radix unsigned}} -expand -subitemconfig {{/net_emulation/sinks/pkt_count_rx[0]} {-radix unsigned} {/net_emulation/sinks/pkt_count_rx[1]} {-radix unsigned} {/net_emulation/sinks/pkt_count_rx[2]} {-radix unsigned} {/net_emulation/sinks/pkt_count_rx[3]} {-radix unsigned}} /net_emulation/sinks/pkt_count_rx
add wave -noupdate -radix unsigned -childformat {{{/net_emulation/sinks/pkt_count_tx[0]} -radix unsigned} {{/net_emulation/sinks/pkt_count_tx[1]} -radix unsigned} {{/net_emulation/sinks/pkt_count_tx[2]} -radix unsigned} {{/net_emulation/sinks/pkt_count_tx[3]} -radix unsigned}} -expand -subitemconfig {{/net_emulation/sinks/pkt_count_tx[0]} {-radix unsigned} {/net_emulation/sinks/pkt_count_tx[1]} {-radix unsigned} {/net_emulation/sinks/pkt_count_tx[2]} {-radix unsigned} {/net_emulation/sinks/pkt_count_tx[3]} {-radix unsigned}} /net_emulation/sinks/pkt_count_tx
add wave -noupdate -radix unsigned /net_emulation/sinks/latency
add wave -noupdate -radix unsigned /net_emulation/sinks/pkts_using_buffer
add wave -noupdate -divider {Transmitter Signals}
add wave -noupdate -childformat {{{/net_emulation/inst_net/genblk1[2]/inst_txs/req.port} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/req.seq} -radix unsigned}} -expand -subitemconfig {{/net_emulation/inst_net/genblk1[2]/inst_txs/req.port} {-height 15 -radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/req.seq} {-height 15 -radix unsigned}} {/net_emulation/inst_net/genblk1[2]/inst_txs/req}
add wave -noupdate -childformat {{{/net_emulation/inst_net/genblk1[2]/inst_txs/dout.data} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/dout.source} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/dout.dest} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/dout.seq} -radix unsigned}} -expand -subitemconfig {{/net_emulation/inst_net/genblk1[2]/inst_txs/dout.data} {-height 16 -radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/dout.source} {-height 16 -radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/dout.dest} {-height 16 -radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/dout.seq} {-height 16 -radix unsigned}} {/net_emulation/inst_net/genblk1[2]/inst_txs/dout}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/full}
add wave -noupdate -childformat {{{/net_emulation/inst_net/genblk1[2]/inst_txs/din.data} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/din.source} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/din.dest} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/din.seq} -radix unsigned}} -subitemconfig {{/net_emulation/inst_net/genblk1[2]/inst_txs/din.data} {-height 16 -radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/din.source} {-height 16 -radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/din.dest} {-height 16 -radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/din.seq} {-height 16 -radix unsigned}} {/net_emulation/inst_net/genblk1[2]/inst_txs/din}
add wave -noupdate -childformat {{{/net_emulation/inst_net/genblk1[2]/inst_txs/grant.port} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/grant.seq} -radix unsigned}} -expand -subitemconfig {{/net_emulation/inst_net/genblk1[2]/inst_txs/grant.port} {-height 15 -radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/grant.seq} {-height 15 -radix unsigned}} {/net_emulation/inst_net/genblk1[2]/inst_txs/grant}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/clk}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/rst}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/full_int}
add wave -noupdate -subitemconfig {{/net_emulation/inst_net/genblk1[2]/inst_txs/fifo_out[0]} -expand} {/net_emulation/inst_net/genblk1[2]/inst_txs/fifo_out}
add wave -noupdate -expand -subitemconfig {{/net_emulation/inst_net/genblk1[2]/inst_txs/din_with_seq[3]} {-childformat {{data -radix unsigned} {source -radix unsigned} {dest -radix unsigned} {seq -radix unsigned}} -expand} {/net_emulation/inst_net/genblk1[2]/inst_txs/din_with_seq[3].data} {-radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/din_with_seq[3].source} {-radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/din_with_seq[3].dest} {-radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/din_with_seq[3].seq} {-radix unsigned}} {/net_emulation/inst_net/genblk1[2]/inst_txs/din_with_seq}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/empty}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/nearly_empty}
add wave -noupdate -childformat {{{/net_emulation/inst_net/genblk1[2]/inst_txs/grant_buf.port} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/grant_buf.seq} -radix unsigned}} -expand -subitemconfig {{/net_emulation/inst_net/genblk1[2]/inst_txs/grant_buf.port} {-radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/grant_buf.seq} {-radix unsigned}} {/net_emulation/inst_net/genblk1[2]/inst_txs/grant_buf}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/we}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/re}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/nearly_full}
add wave -noupdate -childformat {{{/net_emulation/inst_net/genblk1[2]/inst_txs/seq_counters[0]} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/seq_counters[1]} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/seq_counters[2]} -radix unsigned} {{/net_emulation/inst_net/genblk1[2]/inst_txs/seq_counters[3]} -radix unsigned}} -expand -subitemconfig {{/net_emulation/inst_net/genblk1[2]/inst_txs/seq_counters[0]} {-height 16 -radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/seq_counters[1]} {-height 16 -radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/seq_counters[2]} {-height 16 -radix unsigned} {/net_emulation/inst_net/genblk1[2]/inst_txs/seq_counters[3]} {-height 16 -radix unsigned}} {/net_emulation/inst_net/genblk1[2]/inst_txs/seq_counters}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/ce}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/fifo_req}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/fifo_grant}
add wave -noupdate -radix unsigned {/net_emulation/inst_net/genblk1[2]/inst_txs/fifo_grant_bin}
add wave -noupdate -radix unsigned {/net_emulation/inst_net/genblk1[2]/inst_txs/count}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/dout}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/full}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/empty}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/nearly_empty}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/clk}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/we}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/din}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/seq_in}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/seq_valid}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/ce}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/rst}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/mem}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/status_int}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/bufs_in_win}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/next_adrs}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/next_adrs_1h}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/deq_adrs}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/adrs_out_1h}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/sr}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/sr2}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/next_sr2}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/next_sr2_req}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/tx_win}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/deq_adrs_valid}
add wave -noupdate {/net_emulation/inst_net/genblk1[2]/inst_txs/genblk1[3]/input_queues/z1}
add wave -noupdate -divider {Allocator Signals}
add wave -noupdate /net_emulation/inst_net/inst_alloc/grant
add wave -noupdate -expand /net_emulation/inst_net/inst_alloc/grant_switch
add wave -noupdate -expand /net_emulation/inst_net/inst_alloc/req
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
add wave -noupdate -divider Switch
add wave -noupdate /net_emulation/inst_net/inst_switch/dout
add wave -noupdate /net_emulation/inst_net/inst_switch/grant_out
add wave -noupdate /net_emulation/inst_net/inst_switch/req_out
add wave -noupdate /net_emulation/inst_net/inst_switch/din
add wave -noupdate /net_emulation/inst_net/inst_switch/grant_in
add wave -noupdate /net_emulation/inst_net/inst_switch/req_in
add wave -noupdate /net_emulation/inst_net/inst_switch/switch_config
add wave -noupdate /net_emulation/inst_net/inst_switch/clk
add wave -noupdate /net_emulation/inst_net/inst_switch/gy
add wave -noupdate /net_emulation/inst_net/inst_switch/switch_dout
add wave -noupdate /net_emulation/inst_net/inst_switch/switch_din
add wave -noupdate {/net_emulation/source_loop[2]/pkts/dest}
add wave -noupdate {/net_emulation/source_loop[2]/pkts/r32}
add wave -noupdate {/net_emulation/source_loop[2]/pkts/seed}
add wave -noupdate {/net_emulation/source_loop[2]/pkts/r32_seed}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {103500 ps} 0} {{Cursor 2} {134519 ps} 0} {{Cursor 3} {510459 ps} 0}
quietly wave cursor active 3
configure wave -namecolwidth 405
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
WaveRestoreZoom {351547 ps} {445246 ps}
