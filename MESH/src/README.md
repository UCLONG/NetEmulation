### MESH_Network.sv

    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : MESH
    // Function    : Network
    // Module name : MESH_Network
    // Description : Instantiates a 2D Mesh Network of routers
    // Uses        : MESH_Router.sv
    // --------------------------------------------------------------------------------------------------------------------

### MESH_RouteCalculator

    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : MESH
    // Function    : RouteCalculator
    // Module name : MESH_RouteCalculator
    // Description : Calculates which output port is required by comparing the current location of the packet with its
    //             : destination.  Currently, only oblivious Dimension ordered routing is used.
    // Notes       : Danny Ly has prepared an adaptive routing mechanism that will be added in the next version.
    //             : Untested
    // --------------------------------------------------------------------------------------------------------------------

### MESH_Router

    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : MESH
    // Function    : Router
    // Module name : MESH_Router
    // Description : Connects various modules together to create a 5 port, input buffered router
    // Uses        : config.sv, LIB_PKTFIFO.sv, MESH_RouteCalculator.sv, MESH_Switch.sv, MESH_SwitchControl.sv
    // Notes       : Uses the packet_t typedef from config.sv.  packet_t contains node destination information as a single
    //             : number encoded as logic.  If `PORTS is a function of 2^n this will not cause problems as the logic
    //             : can simply be split in two, each half representing either the X or Y direction.  This will not work
    //             : otherwise.
    // --------------------------------------------------------------------------------------------------------------------
    
### MESH_SwitchControl.sv

    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : MESH
    // Function    : SwitchControl
    // Module name : MESH_SwitchControl
    // Description : Simple controller for a CrossBar switch.  Flow control is valid/enable.
    // Uses        : LIB_PPE_RoundRobin.sv, LIB_Allocator_InputFirst_RoundRobin.sv, LIB_Allocator_InputFirst_iSLIP.sv 
    // --------------------------------------------------------------------------------------------------------------------

### network.sv
    
    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : MESH
    // Function    : Network Wrap
    // Module name : network
    // Description : Instantiates a MESH_Network suitable for connecting to NetEmulation
    // Uses        : MESH_Network.sv
    // Notes       : Need better way of fitting X_NODES and Y_NODES, currently on works for perfect square.
    // --------------------------------------------------------------------------------------------------------------------