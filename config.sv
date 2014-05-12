// File: config.sv
// Philip Watts, University College London, June 2012
//
// This file defines the top level parameters for FPGA emulation
// of networks on chip

`include "functions.sv"

// Network parameters 
`define PORTS       4        // Currently only works with power of 2 : to be fixed
`define FIFO_DEPTH  8
`define FIFO_DEPTH_RECIR  8
`define PAYLOAD     512   // Packet payload in bits
`define PKT_SIZE    (`PAYLOAD+(2*log2(`PORTS))+1)

// Optical timing parameters
`define SLOT_SIZE   10         // For fixed slot size networks, in clock cycles
`define TOF         10
`define SERIAL      4
`define SPECULATIVE_DELAY 3

// Simulation timing parameters
`define CLK_PERIOD      1ns
`define WARMUP_PERIOD   0ns
`define MEASURE_PERIOD  1000000us
`define COOLDOWN_PERIOD 0ns

// Load parameters
`define SEED        13649
`define LOAD        10      // in %

//`define RATE        (4294967295/(100*`SLOT_SIZE))*`LOAD    // This is for a time slotted optical network
`define RATE        (2147483647/(100*`SLOT_SIZE))*`LOAD
                                                           // Max load is 2^32-1 = 4294967295 (1 pkt per port per clock cycle)
// Add rate calculations for other networks and (un)comment as required

// Traffic type (only one should be uncommented)
//`define UNIFORM
//`define HOTSPOT
// Also should parameterise the hotspot - currently sends to middle cores in
// a mesh network
//`define STREAM
//`define STREAMRATE `RATE*(110/100) // Rate of the stream test
//`define STREAM_SOURCE 5  //Source of hot spot
//`define STREAM_DEST  1   //Destination of hot spot (if the number of destination port is greater than the number of source port, than minus one when you put this number. eg. STREAM_DEST 4 means actually reach port 5.)
// Could also parameterise stream ports - currently hard coded to 1 - 10
`define TRACE

// Arbiter implementation parameters
`define LOOKAHEAD 4   // Removed from the instantiation in simple_alloc - add instead directly in arbiter code
                      // (as not all arbiter types require this parameter)

// Coment this out if the network is in SystemVerilog
//`define VHDL

// Comment this out for simulation
//`define SYNTHESIS

// Optical Network Parameters
//`define VC        // Implements virtual channel queues and separable allocator
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
