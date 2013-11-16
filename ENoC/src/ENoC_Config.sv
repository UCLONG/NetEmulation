// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : Config
// Module name : ENoC_Config
// Description : Configuration file for Electronic Network on Chip.  See individual headers for information.
// --------------------------------------------------------------------------------------------------------------------

// Network Size.  Sets default values.  Can be overridden when module is instantiated.
// --------------------------------------------------------------------------------------------------------------------
`define X_NODES 3 // Number of node columns
`define Y_NODES 3 // Number of node rows

// Packet type
// --------------------------------------------------------------------------------------------------------------------
typedef struct packed {
  logic [32-1:0] data;
  logic [log2(`X_NODES)-1:0] x_source;
  logic [log2(`Y_NODES)-1:0] y_source;
  logic [log2(`X_NODES)-1:0] x_dest;
  logic [log2(`Y_NODES)-1:0] y_dest;
  logic valid;
} packet_t;

// Input Queue Depth.  Sets default values, can be overridden when module is instantiated
// --------------------------------------------------------------------------------------------------------------------
`define INPUT_QUEUE_DEPTH 8

// Network Topology.  Standard is a 2D Mesh, uncomment TORUS to add wrap around links.
// --------------------------------------------------------------------------------------------------------------------
//`define TORUS

// Load Balancing.  Uncomment LOAD_BALANCE to instantiate a crossbar between the input ports of the router, and the 
// input channels.  The input crossbar selection rotates ensuring input data is spread across input channels. 
// --------------------------------------------------------------------------------------------------------------------
`define LOAD_BALANCE

// Adaptive Routing.  NOT DONE!
// --------------------------------------------------------------------------------------------------------------------
// `define ADAPTIVE

// Virtual Output Queue.  Standard is single input queue.  Uncomment VOQ to instantiate Virtual Output Queues.
// --------------------------------------------------------------------------------------------------------------------
// `define VOQ

// iSLIP.  Standard is a Round Robin Allocator, uncomment for iSLIP.
// --------------------------------------------------------------------------------------------------------------------
// `define iSLIP

// Link Delay.  Increasing the link delay increases the number of clock cycles between the output of one router and the 
// input of the next.  Note, This sets a default value in ENoC_Network.sv and thus can be overridden.  NOT DONE!
// --------------------------------------------------------------------------------------------------------------------
// `define LINK_DELAY = 0;