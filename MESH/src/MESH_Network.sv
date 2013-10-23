// --------------------------------------------------------------------------------------------------------------------
// IP Block    : MESH
// Function    : Network
// Module name : MESH_Network
// Description : Instantiates a 2D Mesh Network of routers
// Uses        : MESH_Router.sv
// --------------------------------------------------------------------------------------------------------------------

`include "config.sv"

module MESH_Network

#(parameter X_NODES,
  parameter Y_NODES)

 (input  logic    clk, reset_n,
  
  // Router Read.  Valid/Enable protocol.
  // ------------------------------------------------------------------------------------------------------------------
  input  packet_t i_data     [0:(X_NODES*Y_NODES)-1],   // Input data from the nodes to the network
  input  packet_t i_data_val [0:(X_NODES*Y_NODES)-1],   // Validates the input data from the nodes.
  output logic    o_en       [0:(X_NODES*Y_NODES)-1],   // Enables the node to send data to the network.
  
  // Router Write.  Valid/Enable protocol.
  // ------------------------------------------------------------------------------------------------------------------
  output packet_t o_data     [0:(X_NODES*Y_NODES)-1],   // Output data from the network to the nodes
  ouptut logic    o_data_val [0:(X_NODES*Y_NODES)-1],   // Validates the output data to the nodes
  input  logic    i_en       [0:(X_NODES*Y_NODES)-1]);  // Enables the network to send data to the node
  
  // Local Logic, connections between routers.
  // ------------------------------------------------------------------------------------------------------------------
         
         // Router Read
         packet_t l_datain     [0:(X_NODES*Y_NODES)-1][0:4];
         logic    l_datain_val [0:(X_NODES*Y_NODES)-1][0:4];
         logic    l_o_en       [0:(X_NODES*Y_NODES)-1][0:4];
         
         // Router Write
         packet_t l_dataout     [0:(X_NODES*Y_NODES)-1][0:4];
         logic    l_dataout_val [0:(X_NODES*Y_NODES)-1][0:4];
         logic    l_i_en        [0:(X_NODES*Y_NODES)-1][0:4];
  
  // Router and Node Input connections
  // ------------------------------------------------------------------------------------------------------------------         
  always_comb begin
    for(int i=0; i<(X_NODES*Y_NODES); i++) begin
    
      // Router input data 
      // Taken from upstream router output data and upstream node output data
      l_datain[i][0] = i_data[i];                                                 // Local input
      l_datain[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_dataout[i+X_NODES][3] : z; // North Input
      l_datain[i][2] = (((i + 1)% X_NODES) == 0) ? z : l_dataout[i+1][4];         // East Input
      l_datain[i][3] = (i > (X_NODES-1)) ? l_dataout[i-X_NODES][1] : z;           // South Input
      l_datain[i][4] = ((nodeNumber % X_NODES) == 0) ? z : l_dataout[i-1][2]      // West Input
      
      // Router input data valid
      // Taken from upstream router output data valid and upstream node output data valid
      l_datain_val[i][0] = i_data_val[i];                                                 // Local input
      l_datain_val[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_dataout_val[i+X_NODES][3] : z; // North Input
      l_datain_val[i][2] = (((i + 1)% X_NODES) == 0) ? z : l_dataout_val[i+1][4];         // East Input
      l_datain_val[i][3] = (i > (X_NODES-1)) ? l_dataout_val[i-X_NODES][1] : z;           // South Input
      l_datain_val[i][4] = ((nodeNumber % X_NODES) == 0) ? z : l_dataout_val[i-1][2]      // West Input      
  
      // Enable from upstream router
      // Taken from upstream router output data enable and upstream node output data enable
      l_i_en[i][0] = i_en[i];                                                // Local input
      l_i_en[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_o_en[i+X_NODES][3] : z; // North Input
      l_i_en[i][2] = (((i + 1)% X_NODES) == 0) ? z : l_o_en[i+1][4];         // East Input
      l_i_en[i][3] = (i > (X_NODES-1)) ? l_o_en[i-X_NODES][1] : z;           // South Input
      l_i_en[i][4] = ((nodeNumber % X_NODES) == 0) ? z : l_o_en[i-1][2]      // West Input      
    
      // Node inputs
      o_data[i]     = l_o_data[0];
      o_data_val[i] = l_o_data_val[0];
      o_en[i]       = l_o_en[0];
  
    end
  end
  
  // Generate Routers
  // ------------------------------------------------------------------------------------------------------------------
  generate
  for (genvar y=0; y<Y_NODES; i++) begin
    for(genvar x=0; x<X_NODES; x++) begin
      MESH_ROUTER #(.X_NODES, .Y_NODES, .X_LOC(x), .Y_LOC(y))
        gen_MESH_ROUTER (.clk,
                         .reset_n,
                         .i_data(l_datain[i]),         // From the upstream routers and nodes
                         .i_data_val(l_datain_val[i]), // From the upstream routers and nodes
                         .o_en(l_o_en[i]),             // To the upstream routers
                         .o_data(l_o_data[i]),         // To the downstream routers
                         .o_data_val(l_data_val[i]),   // To the downstream routers
                         .i_en(l_o_en[i]));            // From the downstream routers
    end
  end
  endgenerate
  
endmodule

