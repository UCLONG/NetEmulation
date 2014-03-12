// File: config.sv
// Philip Watts, University College London, June 2012
//
// This file defines the top level parameters for FPGA emulation
// of networks on chip

`include "functions.sv"

// Network parameters 
`define PORTS       16        // Currently only works with power of 2 : to be fixed
`define FIFO_DEPTH  8
`define PAYLOAD     32        // Packet payload in bits
`define PKT_SIZE    (`PAYLOAD+(2*log2(`PORTS))+1)
`define PORT_BITS   log2(`PORTS)

// Optical timing parameters
`define SLOT_SIZE   8         // For fixed slot size networks, in clock cycles
`define TOF         2
`define SERIAL      4

// Simulation timing parameters
`define CLK_PERIOD      5ns
`define WARMUP_PERIOD_PKT   100 //in pkts
`define MEASURE_PERIOD_PKT  5000 //in pkts
`define COOLDOWN_PERIOD 1000 //in clock cycles 

// Load parameters
`define SEED        13649
//`define LOAD        80           // in %

`define RATE        (4294967295/(100*`SLOT_SIZE))*`LOAD    // This is for a time slotted optical network
                                                           // Max load is 2^32-1 = 4294967295 (1 pkt per port per clock cycle)
// Add rate calculations for other networks and (un)comment as required

// Traffic type (only one should be uncommented)
`define UNIFORM
//`define HOTSPOT
// Also should parameterise the hotspot - currently sends to middle cores in
// a mesh network
//`define STREAM
//`define STREAMRATE 1.4 // Rate of the stream test
// Could also parameterise stream ports - currently hard coded to 1 - 10
//`define TRACE

// Arbiter implementation parameters
`define LOOKAHEAD 4   // Removed from the instantiation in simple_alloc - add instead directly in arbiter code
                      // (as not all arbiter types require this parameter)

// Coment this out if the network is in SystemVerilog
//`define VHDL

// Comment this out for simulation
//`define SYNTHESIS
`define METRICS_ENABLE //should be defined when simulating 
`define BATCH_ANALYSIS_ENABLE //only defined if batch analysis is to be performed

// Optical Network Parameters
`define VC        // Implements virtula channel queues and separable allocator
                  // otherwise you get a single input FIFO and arbiter per port

// VCD File Generation (for power analysis)
//`define VCD_PATH "inst_net/inst_alloc"

// Define the packet structure
typedef struct packed {
	 logic [`PAYLOAD-1:0] data;
	 logic [log2(`PORTS)-1:0] source;
	 logic [log2(`PORTS)-1:0] dest;
	 logic valid;
	 //logic parity;   // to be implemented later
	     } packet_t;

// Derived parameters (do not change)
