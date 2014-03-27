# File: net.do
# Boris Dosen

# Network emulation script
vlib work

#Compile generic components
vlog LIB/src/NEMU_fifo.sv
vlog LIB/src/LIB_FIFO.sv
vlog LIB/src/LIB_FIFO_packet_t.sv
vlog LIB/src/LIB_PPE.sv
vlog LIB/src/LIB_PPE_RoundRobin.sv
vlog LIB/src/LIB_Switch_OneHot_packet_t.sv
vlog LIB/src/LIB_VOQ.sv

vlog NEMU/src/NEMU_PacketSink.sv
vlog NEMU/src/NEMU_PacketSource.sv
vlog NEMU/src/NEMU_RandomNoGen.sv
vlog NEMU/src/NEMU_SerialPortOutput.sv
vlog NEMU/src/NEMU_SerialPortWrapper.sv
vlog NEMU/src/NEMU_SrPacket.sv

# Allocators
vlog LIB/src/LIB_Allocator_InputFirst_iSLIP.sv
vlog LIB/src/LIB_Allocator_InputFirst_RoundRobin

# Mesh Network
vlog ENoC/src/ENoC_RouteCalculator.sv
vlog ENoC/src/ENoC_Router.sv
vlog ENoC/src/ENoC_SwitchControl.sv
vlog ENoC/src/network.sv