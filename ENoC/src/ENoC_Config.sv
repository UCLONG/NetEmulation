// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : Config
// Module name : ENoC_Config
// Description : Configuration file for Electronic Network on Chip.  See individual headers for information.
// --------------------------------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------------------------------
// Network Design Constants.  Sets parameter values which can be overridden when modules are instantiated.
// --------------------------------------------------------------------------------------------------------------------
`define NODES   64          // Total number of nodes.  Used for non Torus networks.
`define X_NODES 8           // k(y,z,x)-ary.  Number of node columns - only considered for Torus
`define Y_NODES 8           // k(y,z,x)-ary.  Number of node rows - only considered for Torus
`define PAYLOAD 8           // Size of the data packet
`define INPUT_QUEUE_DEPTH 4 // Globally set packet depth for input queues

// --------------------------------------------------------------------------------------------------------------------
// Network Topology.  Only uncomment a single type.
// --------------------------------------------------------------------------------------------------------------------
`define MESH
//`define CUBE
//`define BUTTERFLY
//`define CLOS

// Crude 'or' function.  Configurations common to both MESH and TORUS can ifdef TORUS
`ifdef MESH  
  `define TORUS 
`endif
`ifdef CUBE 
  `define TORUS 
`endif

// --------------------------------------------------------------------------------------------------------------------
// Router Architecture. Uncomment to add functionality.
// --------------------------------------------------------------------------------------------------------------------

// `define LOAD_BALANCE // adds a rotating crossbar between the input ports of the router, and the input channels
// `define VOQ          // adds virtual output queues
// `define iSLIP        // Standard VOQ allocation is Round Robin, uncomment for iSLIP.

// --------------------------------------------------------------------------------------------------------------------
// Type Definitions.  Two types of packet depending on how the the packet is addressed
// --------------------------------------------------------------------------------------------------------------------

`ifdef TORUS

  // Network packet type for TORUS addressed designs (Mesh/Torus)
  typedef struct packed {
    logic [`PAYLOAD-1:0] data;
    logic [log2(`X_NODES)-1:0] x_source;
    logic [log2(`Y_NODES)-1:0] y_source;
    logic [log2(`X_NODES)-1:0] x_dest;
    logic [log2(`Y_NODES)-1:0] y_dest;
    logic valid;
  } packet_t;

`else

  // Network packet type for simple addressed designs
  typedef struct packed {
    logic [`PAYLOAD-1:0] data;
    logic [log2(`NODES)-1:0] source;
    logic [log2(`NODES)-1:0] dest;
    logic valid;
  } packet_t;

`endif