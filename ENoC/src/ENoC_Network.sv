// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : Network
// Module name : ENoC_Network
// Description : Instantiates an Electronic Network of routers
// Uses        : ENoC_Router.sv
// --------------------------------------------------------------------------------------------------------------------

`include "ENoC_Config.sv"    // Defines parameters and topology
`include "ENoC_Functions.sv" // Defines log2 function.  Should only be included in one file per scope.

module ENoC_Network

#(`ifdef XY
    parameter X_NODES = `X_NODES,           // Number of node columns
    parameter Y_NODES = `Y_NODES,           // Number of node rows
    parameter NODES   = `X_NODES*`Y_NODES,  // Total number of nodes
  `else
    parameter NODES = `NODES,               // Total number of nodes
  `endif
  parameter INPUT_QUEUE_DEPTH = `INPUT_QUEUE_DEPTH) // Depth of input buffering

 (input  logic    clk, reset_n,
  
  // Router Read.  Valid/Enable protocol.
  // ------------------------------------------------------------------------------------------------------------------
  input  packet_t [0:NODES-1] i_data,     // Input data from the nodes to the network
  input  logic    [0:NODES-1] i_data_val, // Validates the input data from the nodes.
  output logic    [0:NODES-1] o_en,       // Enables the node to send data to the network.
  
  // Router Write.  Valid/Enable protocol.
  // ------------------------------------------------------------------------------------------------------------------
  output packet_t [0:NODES-1] o_data,     // Output data from the network to the nodes
  output logic    [0:NODES-1] o_data_val, // Validates the output data to the nodes
  input  logic    [0:NODES-1] i_en);      // Enables the network to send data to the node
  
  // Local Logic, connections between routers.
  // ------------------------------------------------------------------------------------------------------------------

  `ifdef XY
  
         // Router Read
         packet_t [0:NODES-1][0:4] l_datain;
         logic    [0:NODES-1][0:4] l_datain_val;
         logic    [0:NODES-1][0:4] l_o_en;
         
         // Router Write
         packet_t [0:NODES-1][0:4] l_dataout;
         logic    [0:NODES-1][0:4] l_dataout_val;
         logic    [0:NODES-1][0:4] l_i_en;
  
  `else
  
         // ENTER OTHER NETWORK TYPE CONNECTIONS HERE
  
  `endif
  
  // Router and Node Input connections
  // ------------------------------------------------------------------------------------------------------------------         
  
  `ifdef MESH
    
    // 2D Mesh without wraparound Torus links
    // ----------------------------------------------------------------------------------------------------------------
    always_comb begin
      for(int i=0; i<NODES; i++) begin
      
        // Router input data 
        // Taken from upstream router output data and upstream node output data
        l_datain[i][0] = i_data[i];                                                  // Local input
        l_datain[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_dataout[i+X_NODES][3] : 'z; // North Input
        l_datain[i][2] = (((i + 1)% X_NODES) == 0) ? 'z : l_dataout[i+1][4];         // East Input
        l_datain[i][3] = (i > (X_NODES-1)) ? l_dataout[i-X_NODES][1] : 'z;           // South Input
        l_datain[i][4] = ((i % X_NODES) == 0) ? 'z : l_dataout[i-1][2];              // West Input
        
        // Router input data valid
        // Taken from upstream router output data valid and upstream node output data valid
        l_datain_val[i][0] = i_data_val[i];                                                  // Local input
        l_datain_val[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_dataout_val[i+X_NODES][3] : 'z; // North Input
        l_datain_val[i][2] = (((i + 1)% X_NODES) == 0) ? 'z : l_dataout_val[i+1][4];         // East Input
        l_datain_val[i][3] = (i > (X_NODES-1)) ? l_dataout_val[i-X_NODES][1] : 'z;           // South Input
        l_datain_val[i][4] = ((i % X_NODES) == 0) ? 'z : l_dataout_val[i-1][2];              // West Input      
    
        // Enable from upstream router
        // Taken from upstream router output data enable and upstream node output data enable
        l_i_en[i][0] = i_en[i];                                                 // Local input
        l_i_en[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_o_en[i+X_NODES][3] : 'z; // North Input
        l_i_en[i][2] = (((i + 1)% X_NODES) == 0) ? 'z : l_o_en[i+1][4];         // East Input
        l_i_en[i][3] = (i > (X_NODES-1)) ? l_o_en[i-X_NODES][1] : 'z;           // South Input
        l_i_en[i][4] = ((i % X_NODES) == 0) ? 'z : l_o_en[i-1][2];              // West Input      
      
        // Node inputs
        o_data[i]     = l_dataout[i][0];
        o_data_val[i] = l_dataout_val[i][0];
        o_en[i]       = l_o_en[i][0];
    
      end
    end
  
  `elsif TORUS

    // 2D Mesh with wraparound Torus Links
    // --------------------------------------------------------------------------------------------------------------
    always_comb begin
      for(int i=0; i<NODES; i++) begin
      
        // Router input data 
        // Taken from upstream router output data and upstream node output data
        l_datain[i][0] = i_data[i];                                                           // Local input
        l_datain[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_dataout[i+X_NODES][3]                // North Input
                                                     : l_dataout[i-(X_NODES*(Y_NODES-1))][3]; // North Input Wrap
        l_datain[i][2] = (((i + 1)% X_NODES) == 0)   ? l_dataout[i-(X_NODES-1)][4]            // East Input Wrap 
                                                     : l_dataout[i+1][4];                     // East Input
        l_datain[i][3] = (i > (X_NODES-1))           ? l_dataout[i-X_NODES][1]                // South Input
                                                     : l_dataout[i+(X_NODES*Y_NODES)][1];     // South Input Wrap
        l_datain[i][4] = ((i % X_NODES) == 0)        ? l_dataout[i+(X_NODES-1)][2]            // West Input Wrap
                                                     : l_dataout[i-1][2]                      // West Input
        
        // Router input data valid
        // Taken from upstream router output data valid and upstream node output data valid
        l_datain_val[i][0] = i_data_val[i];                                                           // Local input
        l_datain_val[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_dataout_val[i+X_NODES][3]                // North Input
                                                         : l_dataout_val[i-(X_NODES*(Y_NODES-1))][3]; // North Input Wrap
        l_datain_val[i][2] = (((i + 1)% X_NODES) == 0)   ? l_dataout_val[i-(X_NODES-1)][4]            // East Input Wrap 
                                                         : l_dataout_val[i+1][4];                     // East Input
        l_datain_val[i][3] = (i > (X_NODES-1))           ? l_dataout_val[i-X_NODES][1]                // South Input
                                                         : l_dataout_val[i+(X_NODES*Y_NODES)][1];     // South Input Wrap
        l_datain_val[i][4] = ((i % X_NODES) == 0)        ? l_dataout_val[i+(X_NODES-1)][2]            // West Input Wrap
                                                         : l_dataout_val[i-1][2]                      // West Input    
    
        // Enable from upstream router
        // Taken from upstream router output data enable and upstream node output data enable
        l_i_en[i][0] = i_en[i];                                                          // Local input
        l_i_en[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_o_en[i+X_NODES][3]                // North Input
                                                   : l_o_en[i-(X_NODES*(Y_NODES-1))][3]; // North Input Wrap
        l_i_en[i][2] = (((i + 1)% X_NODES) == 0)   ? l_o_en[i-(X_NODES-1)][4]            // East Input Wrap 
                                                   : l_o_en[i+1][4];                     // East Input
        l_i_en[i][3] = (i > (X_NODES-1))           ? l_o_en[i-X_NODES][1]                // South Input
                                                   : l_o_en[i+(X_NODES*Y_NODES)][1];     // South Input Wrap
        l_i_en[i][4] = ((i % X_NODES) == 0)        ? l_o_en[i+(X_NODES-1)][2]            // West Input Wrap
                                                   : l_o_en[i-1][2]                      // West Input    
      
        // Node inputs
        o_data[i]     = l_dataout[i][0];
        o_data_val[i] = l_dataout_val[i][0];
        o_en[i]       = l_o_en[i][0];
    
      end
    end
  
  `endif
  
  // Generate Routers
  // ------------------------------------------------------------------------------------------------------------------

  `ifdef XY
  
    genvar y, x;
    generate
    for (y=0; y<Y_NODES; y++) begin : GENERATE_Y_ROUTERS
      for(x=0; x<X_NODES; x++) begin : GENERATE_X_ROUTERS
        ENoC_Router #(.X_NODES(X_NODES),
                      .Y_NODES(Y_NODES),
                      .X_LOC(x),.Y_LOC(y),
                      .INPUT_QUEUE_DEPTH(INPUT_QUEUE_DEPTH),
                      .N(5),
                      .M(5))
          gen_ENoC_Router (.clk(clk),
                           .reset_n(clk),
                           .i_data(l_datain[(y*X_NODES)+x]),          // From the upstream routers and nodes
                           .i_data_val(l_datain_val[(y*X_NODES)+x]),  // From the upstream routers and nodes
                           .o_en(l_o_en[(y*X_NODES)+x]),              // To the upstream routers
                           .o_data(l_dataout[(y*X_NODES)+x]),         // To the downstream routers
                           .o_data_val(l_dataout_val[(y*X_NODES)+x]), // To the downstream routers
                           .i_en(l_i_en[(y*X_NODES)+x]));             // From the downstream routers
      end
    end
    endgenerate
  
  `else
  
    // INSERT OTHER NETWORK TYPE DECLARATIONS HERE
  
  `endif
  
endmodule

