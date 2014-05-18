// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : Config
// Module name : ENoC_Config
// Description : Configuration file for Electronic Network on Chip.  See individual headers for information.
// --------------------------------------------------------------------------------------------------------------------

// --------------------------------------------------------------------------------------------------------------------
// Network Design Constants.  Sets parameter values which can be overridden when modules are instantiated.
// --------------------------------------------------------------------------------------------------------------------
`define NODES   64          // Total number of nodes
`define X_NODES 8           // k(x,y,z)-ary.  Number of node columns - only considered for Torus (must be > 0)
`define Y_NODES 8           // k(x,y,z)-ary.  Number of node rows - only considered for Torus (must be > 0)
`define Z_NODES 1           // k(x,y,z)-ary.  Number of node layers (must be > 0)
`define PAYLOAD 512         // Size of the data packet
`define INPUT_QUEUE_DEPTH 4 // Globally set packet depth for input queues
`define TIME_STAMP_SIZE 32
`define OLD_PACKET_T        // Delete this directive and associated typedef once packet_t is standardised

// --------------------------------------------------------------------------------------------------------------------
// Network Topology.  Only uncomment a single type.
// --------------------------------------------------------------------------------------------------------------------
`define MESH
//`define CUBE

// Other network types should be defined here eg clos and butterfly

// Crude 'or' function.  Configurations common to both MESH and TORUS can ifdef TORUS
`ifdef MESH  
  `define TORUS 
  `define DEGREE 5
  `define N 5
  `define M 5
`endif
`ifdef CUBE 
  `define TORUS 
  `define DEGREE 5
  `define N 5
  `define M 5
`endif

// --------------------------------------------------------------------------------------------------------------------
// Router Architecture. Uncomment to add functionality.
// --------------------------------------------------------------------------------------------------------------------

// `define LOAD_BALANCE // adds a rotating crossbar between the input ports of the router, and the input channels
// `define VOQ          // adds virtual output queues
// `define iSLIP        // Standard VOQ allocation is Round Robin, uncomment for iSLIP.
// `define XYSWAP       // Changes the order of routing precedence for the XYZ dimension each cycle
`define DECOUPLE_EN     // Decouples the o_en of the FIFO from its i_en to prevent combinational loops

// --------------------------------------------------------------------------------------------------------------------
// Test Functions. Uncomment to add functionality.
// --------------------------------------------------------------------------------------------------------------------
//`define ROUTER_TB // Uncomment to change routing algorithm for router_tb

// --------------------------------------------------------------------------------------------------------------------
// Type Definitions.  Old NetEmulation definition, and two new types that depend on how the the packet is addressed
// --------------------------------------------------------------------------------------------------------------------

`ifdef OLD_PACKET_T

  `ifndef PACKET_T
  
  // Original NetEmulation packet type
  typedef struct packed {
    logic [`PAYLOAD-1:0] data;
    logic [$clog2(`NODES)-1:0]          source;
    logic [$clog2(`NODES)-1:0]          dest;
    logic                valid;
  } packet_t;
  
  `define PACKET_T
  `endif

 `elsif TORUS

  `ifndef PACKET_T
  
  // Network packet type for testing TORUS addressed designs (Mesh/Torus)
  typedef struct packed {
    logic [`PAYLOAD-1:0]           data;
    logic [$clog2(`X_NODES)-1:0] x_source;
    logic [$clog2(`Y_NODES)-1:0] y_source; 
    logic [$clog2(`Z_NODES)-1:0] z_source;    
    logic [$clog2(`X_NODES)-1:0] x_dest;
    logic [$clog2(`Y_NODES)-1:0] y_dest; 
    logic [$clog2(`Z_NODES)-1:0] z_dest;    
    logic                          valid;
    logic [`TIME_STAMP_SIZE-1:0]   timestamp;
    logic                          measure;
  } packet_t; 

  `define PACKET_T
  `endif
  
`else

  `ifndef PACKET_T

  // Network packet type for simple addressed designs
  typedef struct packed {
    logic [`PAYLOAD-1:0]         data;
    logic [$clog2(`NODES)-1:0] source;
    logic [$clog2(`NODES)-1:0] dest;
    logic                        valid;
    logic [`TIME_STAMP_SIZE-1:0] timestamp;
    logic                        measure;
  } packet_t;
  
  `define PACKET_T
  `endif
  
`endif