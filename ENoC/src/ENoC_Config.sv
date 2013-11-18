// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : Config
// Module name : ENoC_Config
// Description : Configuration file for Electronic Network on Chip.  See individual headers for information.
// --------------------------------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------------------------------
// Network Design Constants.  Sets parameter values which can be overridden when modules are instantiated.
// --------------------------------------------------------------------------------------------------------------------
`define NODES   9           // Total number of nodes - not considered for mesh/torus
`define X_NODES 3           // Number of node columns - only considered for mesh/torus
`define Y_NODES 3           // Number of node rows - only considered for mesh/torus
`define PAYLOAD 32          // Size of the data packet
`define INPUT_QUEUE_DEPTH 8 // Packet depth of input queues

// --------------------------------------------------------------------------------------------------------------------
// Network Topology.  Only uncomment a single type.
// --------------------------------------------------------------------------------------------------------------------
`define MESH
//`define TORUS
//`define BUTTERFLY
//`define CLOS
//`define RING

// Crude 'or' function.  Configurations common to both MESH and TORUS can ifdef XY
`ifdef MESH
  `define XY
`endif
`ifdef TORUS
  `define XY
`endif

// --------------------------------------------------------------------------------------------------------------------
// Router Architecture. Uncomment to add functionality.
// --------------------------------------------------------------------------------------------------------------------
// `define LOAD_BALANCE // adds a rotating crossbar between the input ports of the router, and the input channels
// `define PIPE_LINE_RC // adds a register stage after route calculation
// `define PIPE_LINE_VA // adds a register stage after virtual channel allocation
// `define PIPE_LINE_SA // adds a register stage after switch allocation
// `define PIPE_LINE_ST // adds a register stage after the crossbar switch at the router output
// `define ADAPTIVE     // enables adaptive routing algorithms
// `define VOQ          // adds virtual output queues
// `define iSLIP        // Standard allocation is Round Robin, uncomment for iSLIP.

// --------------------------------------------------------------------------------------------------------------------
// Type Definitions.
// --------------------------------------------------------------------------------------------------------------------

`ifdef XY

  // Network packet type for xy addressed designs (Mesh/Torus)
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

// Pipeline Control type
typedef struct packed {
  logic RC; // Route calculation
  logic VA; // Virtual Channel Allocation
  logic SA; // Switch Allocation
  logic ST; // Switch Traversal
} pipe_line