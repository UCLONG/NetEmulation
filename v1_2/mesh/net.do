# File: net.do
# Philip Watts, UCL, June 2012
#
# Network emulation simulation script for modelsim

# Compile components
vlog fifo.sv
vlog fifo_pkt.sv
vlog packet_source.sv
vlog packet_source_trace.sv
vlog packet_sink.sv
vlog router.sv
vlog inputUnit.sv
vlog arbiter.sv
vlog switch.sv
vlog switchAllocator.sv
vlog routing_algorithm.sv
#vlog config.sv
#vlog functions.sv

# Add network files here
vlog base_network.sv
#vlog network.sv
#vcom network.vhdl

# Compile top level code and start simulation
vlog net_emulation.sv
vsim -t 1ps net_emulation

# Setup wave window
add wave \
{sim:/net_emulation/rst } \
{sim:/net_emulation/input_fifo_error } \
{sim:/net_emulation/dest_error } \
{sim:/net_emulation/error_total } \
{sim:/net_emulation/clk } \
{sim:/net_emulation/timestamp } \
{sim:/net_emulation/rate } \
{sim:/net_emulation/pkt_in } \
{sim:/net_emulation/pkt_source_out } \
{sim:/net_emulation/pkt_sink_in } \
{sim:/net_emulation/pkt_out } \
{sim:/net_emulation/full } \
{sim:/net_emulation/total_pkts_in } \
{sim:/net_emulation/total_pkts_out } \
{sim:/net_emulation/pkt_count_source } \
{sim:/net_emulation/pkt_count_dest } \
{sim:/net_emulation/latency } \
{sim:/net_emulation/total_latency } \
{sim:/net_emulation/average_hop } \
{sim:/net_emulation/source_loop[0]/pkts/pkt_out} \
{sim:/net_emulation/dest_loop[0]/sinks/pkt_count} \
{sim:/net_emulation/dest_loop[1]/sinks/pkt_count} \
{sim:/net_emulation/dest_loop[2]/sinks/pkt_count} \
{sim:/net_emulation/factor } \
{sim:/net_emulation/test_total }

add wave \
{sim:/net_emulation/inst_net/networkData}

add wave \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/bufferDataOut } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/routerDataOut } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/routerDataOutDec } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/holdPorts_OUT } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/writeRequest_OUT } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/readRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/routerDataIn } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/routerDataOutDec } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/holdPorts_OUT } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/writeRequest_OUT } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/readRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/routerDataIn } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/holdPorts_OUT } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/writeRequest_OUT } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/readRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/routerDataIn } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/holdPorts_IN } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/writeRequest_IN } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/readEnable_Adjacent } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/reset } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/clk } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/bufferDataOut } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/readRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[3]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[0]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[3]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[0]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[1]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[2]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[3]/router/sel } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[3]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[0]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[3]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[0]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[1]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[2]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[3]/router/unproductive } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[3]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[0]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[3]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[0]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[1]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[2]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[3]/router/rerouteDec } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/routerDataOut } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/routerDataOutDec }

add wave \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[4]/inputUnitTest/bufferDataOut } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[4]/inputUnitTest/bufferDataIn } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[4]/inputUnitTest/read } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[4]/inputUnitTest/write } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[4]/inputUnitTest/reset } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[4]/inputUnitTest/clk } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[0]/inputUnitTest/input_fifo/empty} \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[0]/inputUnitTest/input_fifo/rd_en} \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[0]/inputUnitTest/input_fifo/wait_count} \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[1]/inputUnitTest/input_fifo/wait_count} \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[2]/inputUnitTest/input_fifo/wait_count} \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[3]/inputUnitTest/input_fifo/wait_count} 

add wave \
{sim:/net_emulation/inst_net/routerToNetworkWriteRequest }

add wave \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/northFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/eastFIFO } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/southFIFO } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/westFIFO } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[0]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[1]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[2]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[0]/genblk1[3]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[0]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[1]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[2]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[3]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[3]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[3]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[1]/genblk1[3]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[0]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[0]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[0]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[0]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[1]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[2]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[3]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[3]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[3]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[2]/genblk1[3]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[0]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[0]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[0]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[0]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[0]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[1]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[1]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[1]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[1]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[1]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[2]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[2]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[2]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[2]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[2]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[3]/router/genblk1[0]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[3]/router/genblk1[1]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[3]/router/genblk1[2]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[3]/router/genblk1[3]/inputUnitTest/adaptive_routing/outputPortRequest } \
{sim:/net_emulation/inst_net/genblk1[3]/genblk1[3]/router/genblk1[4]/inputUnitTest/adaptive_routing/outputPortRequest } 