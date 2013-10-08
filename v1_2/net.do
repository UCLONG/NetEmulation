# File: net.do
# Philip Watts, UCL, June 2012
#
# Network emulation simulation script for modelsim
vlib work

###############################################################
# Compile generic components
###############################################################
vlog fifo.sv
vlog fifo_pkt.sv
vlog packet_source.sv
vlog packet_sink.sv
vlog ppe.sv
vlog sr_packet.sv

###############################################################
# Compile arbiter
# Uncomment only one of these network options
###############################################################
vlog arbiters/matrix_arbiter.sv
#vlog arbiters/round_robin_arbiter.sv

###############################################################
# Compile specific network code 
# Uncomment only one of these network options
###############################################################

# SIMPLE OPTICAL NETWORK
vlog simple_optical/tx_simple.sv
vlog simple_optical/alloc_simple.sv
vlog simple_optical/network.sv
vlog simple_optical/photonic_switch.sv

# UCL MESH NETWORK - add submodules
# See note on wiki mesh page about adding wrapper
#vlog mesh/
#vlog mesh/
#vlog mesh/
#vlog mesh/network.sv

# ADD ANOTHER NETWORK HERE
#vlog other_network/submodule.sv
#vlog other_network/network.sv


################################################################
# Networks written in VHDL
# uncomment the `define VHDL line in the config file and add 
# submodules here
################################################################
#vcom <submodule.vhdl>
#vcom network.vhdl

################################################################
# Compile top level code and start simulation
################################################################
vlog net_emulation.sv
vsim -t 1ps -novopt net_emulation

################################################################
# Setup wave window and top level signals
################################################################
do optical_wave.do


#############################################################
# Run simulation to completion
#############################################################

run -all

