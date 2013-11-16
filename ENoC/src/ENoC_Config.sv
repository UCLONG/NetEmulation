// Network Topology.  Standard is a 2D Mesh, uncomment TORUS to add wrap around links.
// --------------------------------------------------------------------------------------------------------------------
//`define TORUS

// Load Balancing.  Uncomment LOAD_BALANCE to instantiate a crossbar between the input ports of the router, and the 
// input channels.  Crossbar selection rotates ensuring input data is spread across input channels. 
// --------------------------------------------------------------------------------------------------------------------
//`define LOAD_BALANCE

// Adaptive Routing.  NOT DONE!
// --------------------------------------------------------------------------------------------------------------------
// `define ADAPTIVE

// Virtual Output Queue.  Standard is single input queue.  Uncomment VOQ to instantiate Virtual Output Queues.
// --------------------------------------------------------------------------------------------------------------------
//`define VOQ

// iSLIP.  Standard is a Round Robin Allocator, uncomment for iSLIP.
// --------------------------------------------------------------------------------------------------------------------
// `define iSLIP

// Link Delay.  Increasing the link delay increases the number of clock cycles between the output of one router and the 
// input of the next.  Note, This sets a default value in ENoC_Network.sv and thus can be overridden.  NOT DONE!
// --------------------------------------------------------------------------------------------------------------------
// `define LINK_DELAY = 0;