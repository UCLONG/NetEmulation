// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : Config
// Module name : ENoC_Config
// Description : Configuration file for Electronic Network on Chip.  See individual headers for information.
// --------------------------------------------------------------------------------------------------------------------

 // Defines log2 function.  Should only be included in one file per scope.  Will screw up
                             // simulation or synthesis

// --------------------------------------------------------------------------------------------------------------------
// Network Design Constants.  Sets parameter values which can be overridden when modules are instantiated.
// --------------------------------------------------------------------------------------------------------------------
`define NODES   64          // Total number of nodes - not considered for mesh/torus
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
// Router Pipeline Stages. Uncomment to add stage.
// --------------------------------------------------------------------------------------------------------------------

// `define PIPE_LINE_RC // adds a register stage after route calculation
// `define PIPE_LINE_VA // adds a register stage after virtual channel allocation
// `define PIPE_LINE_SA // adds a register stage after switch allocation
// `define PIPE_LINE_ST // adds a register stage after the crossbar switch at the router output

// Crude 'or' function.  Configurations that use pipeline can ifdef PIPE_LINE
`ifdef PIPE_LINE_RC 
  `define PIPE_LINE 
`endif
`ifdef PIPE_LINE_VA 
  `define PIPE_LINE
`endif
`ifdef PIPE_LINE_SA 
  `define PIPE_LINE
`endif
`ifdef PIPE_LINE_ST 
  `define PIPE_LINE
`endif

// --------------------------------------------------------------------------------------------------------------------
// Type Definitions.
// --------------------------------------------------------------------------------------------------------------------

/* Commented because NetEmulation doesn't distinguish between network types yet
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
*/
  // Network packet type for simple addressed designs
  typedef struct packed {
    logic [`PAYLOAD-1:0] data;
    logic [log2(`NODES)-1:0] source;
    logic [log2(`NODES)-1:0] dest;
    logic valid;
  } packet_t;
/*
`endif
*/
`ifdef PIPE_LINE

  // Pipeline Control type, can be used for state machine, clock control etc
  typedef struct packed {
  `ifdef PIPE_LINE_RC  
    logic RC; // Route calculation
  `endif 
  `ifdef PIPE_LINE_VA  
    logic VA; // Virtual Channel Allocation
  `endif 
  `ifdef PIPE_LINE_SA
    logic SA; // Switch Allocation
  `endif 
  `ifdef PIPE_LINE_ST  
    logic ST; // Switch Traversal
  `endif 
  } pipe_line;
  
`endif