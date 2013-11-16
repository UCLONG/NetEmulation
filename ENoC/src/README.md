### ENoC_Network.sv

    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : ENoC
    // Function    : Network
    // Module name : ENoC_Network
    // Description : Instantiates an Electronic Network of routers
    // Uses        : ENoC_Router.sv
    // --------------------------------------------------------------------------------------------------------------------

### ENoC_RouteCalculator

    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : ENoC
    // Function    : RouteCalculator
    // Module name : ENoC_RouteCalculator
    // Description : Calculates which output port is required by comparing the current location of the packet with its
    //             : destination.  Currently, only oblivious Dimension ordered routing is used.
    // Notes       : Danny Ly has prepared an adaptive routing mechanism that will be added in the next version.
    //             : Untested
    // --------------------------------------------------------------------------------------------------------------------

### ENoC_Router

    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : ENoC
    // Function    : Router
    // Module name : ENoC_Router
    // Description : Connects various modules together to create an input buffered router
    // Uses        : config.sv, ENoC_Config.sv, LIB_FIFO_packet_t.sv, ENoC_RouteCalculator.sv,  
    //             : LIB_Switch_OneHot_packet_t.sv, ENoC_SwitchControl.sv
    // Notes       : Uses the packet_t typedef from config.sv.  packet_t contains node destination information as a single
    //             : number encoded as logic.  If `PORTS is a function of 2^n this will not cause problems as the logic
    //             : can simply be split in two, each half representing either the X or Y direction.  This will not work
    //             : otherwise.
    // --------------------------------------------------------------------------------------------------------------------
    
### ENoC_SwitchControl.sv

    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : ENoC
    // Function    : SwitchControl
    // Module name : ENoC_SwitchControl
    // Description : Simple controller for a CrossBar switch.  Flow control is valid/enable.
    // Uses        : LIB_PPE_RoundRobin.sv, LIB_Allocator_InputFirst_RoundRobin.sv, LIB_Allocator_InputFirst_iSLIP.sv 
    // --------------------------------------------------------------------------------------------------------------------

### ENoC_Functions.sv

    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : ENoC
    // Description : Declares Functions used in the Electrical Network on Chip.
    // Functions   : log2(input int n); - calculates the number of bits required to represent an integer as binary
    // --------------------------------------------------------------------------------------------------------------------
    
### network.sv
    
    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : MESH
    // Function    : Network Wrap
    // Module name : network
    // Description : Instantiates a ENoC_Network suitable for connecting to NetEmulation
    // Uses        : ENoC_Network.sv
    // Notes       : Need better way of fitting X_NODES and Y_NODES, currently on works for perfect square.
    // --------------------------------------------------------------------------------------------------------------------
    
### synthesis_wrap.sv

    // --------------------------------------------------------------------------------------------------------------------
    // IP Block    : ENoC
    // Function    : synthesis_wrap
    // Module name : synthesis_wrap
    // Description : Instantiates a MESH_Network keeping top level ports to a minimum for synthesis.
    // Uses        : synthesis_wrap.sv
    // --------------------------------------------------------------------------------------------------------------------