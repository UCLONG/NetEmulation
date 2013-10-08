// File: config.sv
// Philip Watts, University College London, June 2012
// Edited by: Danny Ly, Academic Term 2012/2013
//
// This file defines the top level parameters for FPGA emulation
// of networks on chip

`include "functions.sv"

// Network parameters 
`define PORTS 16          // Number of Cores, Currently only works with power of 2 : to be fixed
`define FIFO_DEPTH 4      // Size of FIFO
`define PAYLOAD 64        // Packet payload in bits
//`define PKT_SIZE (`PAYLOAD+(2*log2(`PORTS))+1)
`define MESH_WIDTH 4      // Width of mesh network, used to calculate xy location
`define THRESHOLD 3       // Buffer threshold, used in the adaptive routing algorithm
`define UNPRODUCTIVE 4    // Limit the number of unproductive reroutes/misroutes (LIVELOCK)
`define DEADLOCK_LIMIT 16 // Number of cycles to assume deadlock 
                          // constant should go into switch_allocator.sv but has been manually set, code does not handle anything > 16
`define LOAD 400000000    // Determines injection rate, 100% load is 4e9

// Coment this out if the network is in SystemVerilog
//`define VHDL

// Comment this out for simulation
//`define SYNTHESIS

// Comment this out to run fully adaptive routing algorithm
//`define DETERMINISTIC

// Comment this out for synthetic packet simulation
//`define TRACE

// Uncomment the test desired - Has no effect if TRACE uncommented
`define UNIFORM
//`define HOTSPOT // Currently ~ 30% centralised
//`define STREAM  // Currently streaming from node 1 to 10, rate defined below
    `define STREAMRATE 1.4 // Rate of the STREAM test, fraction of LOAD

// Define the packet structure
typedef struct packed {
	 logic [`PAYLOAD-1:0] data; // Packet payload
	 logic [log2(`PORTS)-1:0] source; // Source node number
	 logic [log2(`PORTS)-1:0] dest; // Destination node number
	 logic valid;
	 logic [log2(2*`MESH_WIDTH + 2*`UNPRODUCTIVE)-1:0] hopCount; // Number of hops a packet experiences
	 logic [log2(`UNPRODUCTIVE):0] reroute; // Bits used for livelock control
	 logic measure; // Logic high indicates packet passes Warm-up & Drain conditions and should be measured
	     } packet_t;
	     
// Define the packet structure for Mesh Network
typedef struct packed {
	 logic [`PAYLOAD-1:0] data; // Packet payload
	 logic [log2(`PORTS)-1:0] source; // Source node number
	 logic [log2(`MESH_WIDTH)-1:0] xdest; // Destination x address
	 logic [log2(`MESH_WIDTH)-1:0] ydest; // Destination y address
	 logic valid;
	 logic [log2(2*`MESH_WIDTH + 2*`UNPRODUCTIVE)-1:0] hopCount; // Number of hops a packet experiences
	 logic [log2(`UNPRODUCTIVE):0] reroute; // Bits used for livelock control
	 logic measure; // Logic high indicates packet passes Warm-up & Drain conditions and should be measured
	     } packet_mesh;
