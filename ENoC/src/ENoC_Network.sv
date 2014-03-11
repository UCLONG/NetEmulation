// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : Network
// Module name : ENoC_Network
// Description : Instantiates an Electronic Network of routers.  Each IO from the network has an IO of packet_t, and
//               single bits for a valid/enable protocol.  If enable was high whilst a node had its valid high, data
//               was sampled on that cycle.
// Uses        : ENoC_Router.sv
// --------------------------------------------------------------------------------------------------------------------

`include "ENoC_Config.sv"    // Defines parameters and topology
`include "ENoC_Functions.sv"

module ENoC_Network

#(`ifdef TORUS
    parameter integer X_NODES = `X_NODES,                    // Number of node columns
    parameter integer Y_NODES = `Y_NODES,                    // Number of node rows
    parameter integer Z_NODES = `Z_NODES,                    // Number of node layers
    parameter integer NODES   = `X_NODES*`Y_NODES*`Z_NODES,  // Total number of nodes
    parameter integer ROUTERS = `X_NODES*`Y_NODES*`Z_NODES,  // Total number of routers
    parameter integer DEGREE  = 5,
  `else
    parameter integer NODES   = `NODES,              // Total number of nodes
    parameter integer ROUTERS = `ROUTERS,
    parameter integer DEGREE  = `DEGREE,
  `endif
  parameter integer INPUT_QUEUE_DEPTH = `INPUT_QUEUE_DEPTH) // Depth of input buffering

 (input  logic    clk, reset_n,
  
  // Network Read from Nodes.  Valid/Enable protocol.
  // ------------------------------------------------------------------------------------------------------------------
  input  packet_t [0:NODES-1] i_data,     // Input data from the nodes to the network
  input  logic    [0:NODES-1] i_data_val, // Validates the input data from the nodes.
  output logic    [0:NODES-1] o_en,       // Enables the node to send data to the network.
  
  // Network Write to Nodes.  Valid/Enable protocol.
  // ------------------------------------------------------------------------------------------------------------------
  output packet_t [0:NODES-1] o_data,     // Output data from the network to the nodes
  output logic    [0:NODES-1] o_data_val, // Validates the output data to the nodes
  input  logic    [0:NODES-1] i_en);      // Enables the network to send data to the node
  
  // Local Logic network, define the network connections to which nodes and routers will write, and from which routers
  // and nodes will read.
  // ------------------------------------------------------------------------------------------------------------------
  
  // For example, a Mesh network.  Each Node has a router.  Each router has 5 IO, one to its local node, and four to  
  // the surrounding routers.  These are referenced as connection_type[router number][IO number].  Router numbers are 
  // inclusive of 0, and correspond with the number of its local node.  IO ports are numbered 0 = local node,  
  // 1 = North Router, 2 = East Router, 3 = South Router, 4 = West Router.  

  // Network connections from which routers will read
  packet_t [0:ROUTERS-1][0:DEGREE-1] l_datain;
  logic    [0:ROUTERS-1][0:DEGREE-1] l_datain_val;
  logic    [0:ROUTERS-1][0:DEGREE-1] l_o_en;

  // Network connections to which routers will write
  packet_t [0:ROUTERS-1][0:DEGREE-1] l_dataout;
  logic    [0:ROUTERS-1][0:DEGREE-1] l_dataout_val;
  logic    [0:ROUTERS-1][0:DEGREE-1] l_i_en;
  
  
  // Define the shape of the local logic network.
  // ------------------------------------------------------------------------------------------------------------------         

  // The local logic network is connected by determining where each router or node input connection should read its data 
  // from.  Router inputs are read either from the output of a node, or from the output of a router at another point in
  // the network.  Node inputs are read only from the output of its local router.  Because of this local logic network, 
  // routers and nodes can simply connect to the local logic network rather than trying to individually connect each 
  // router and node.  
  
  `ifdef MESH
    
    // 2D Mesh without wraparound Torus links.  
    // ----------------------------------------------------------------------------------------------------------------
    
    always_comb begin
    
      for (int i=0; i<(X_NODES*Y_NODES)*(Z_NODES-1); i + (X_NODES*Y_NODES)) begin      
        for(int j=0; j<X_NODES*Y_NODES; j++) begin
        
          // Router input 'data' 
          //   -- Taken from upstream router output data and upstream node output data
          l_datain[i+j][0] = i_data[i+j];                                                  // Local input
          l_datain[i+j][1] = (j < (X_NODES*(Y_NODES-1))) ? l_dataout[i+j+X_NODES][3] : '0; // North Input
          l_datain[i+j][2] = (((j + 1)% X_NODES) == 0) ? '0 : l_dataout[i+j+1][4];         // East Input
          l_datain[i+j][3] = (j > (X_NODES-1)) ? l_dataout[i+j-X_NODES][1] : '0;           // South Input
          l_datain[i+j][4] = ((j % X_NODES) == 0) ? '0 : l_dataout[i+j-1][2];              // West Input
          l_datain[i+j][5] =
          l_datain[i+j][6] =
          
          // Router input 'data valid'
          //   -- Taken from upstream router output data valid and upstream node output data valid
          l_datain_val[i+j][0] = i_data_val[i+j];                                                  // Local input
          l_datain_val[i+j][1] = (j < (X_NODES*(Y_NODES-1))) ? l_dataout_val[i+j+X_NODES][3] : '0; // North Input
          l_datain_val[i+j][2] = (((j + 1)% X_NODES) == 0) ? '0 : l_dataout_val[i+j+1][4];         // East Input
          l_datain_val[i+j][3] = (j > (X_NODES-1)) ? l_dataout_val[i+j-X_NODES][1] : '0;           // South Input
          l_datain_val[i+j][4] = ((j % X_NODES) == 0) ? '0 : l_dataout_val[i+j-1][2];              // West Input  
          l_datain_val[i+j][5] =
          l_datain_val[i+j][6] =
          
          // Router input 'enable'
          //   -- Taken from upstream router output data enable and upstream node output data enable
          l_i_en[i+j][0] = i_en[i+j];                                                 // Local input
          l_i_en[i+j][1] = (j < (X_NODES*(Y_NODES-1))) ? l_o_en[i+j+X_NODES][3] : '0; // North Input
          l_i_en[i+j][2] = (((j + 1)% X_NODES) == 0) ? '0 : l_o_en[i+j+1][4];         // East Input
          l_i_en[i+j][3] = (j > (X_NODES-1)) ? l_o_en[i+j-X_NODES][1] : '0;           // South Input
          l_i_en[i+j][4] = ((j % X_NODES) == 0) ? '0 : l_o_en[i+j-1][2];              // West Input
          l_i_en[i+j][5] =
          l_i_en[i+j][6] =        
        
          // Node inputs, i.e network outputs
          o_data[i+j]     = l_dataout[i+j][0];
          o_data_val[i+j] = l_dataout_val[i+j][0];
          o_en[i+j]       = l_o_en[i+j][0];
      
        end
      end
    end
  
  `elsif CUBE

    // 2D Cube
    // --------------------------------------------------------------------------------------------------------------
    always_comb begin
      for(int i=0; i<NODES; i++) begin
      
        // Router input 'data' 
        //   -- Taken from upstream router output data and upstream node output data
        l_datain[i][0] = i_data[i];                                                           // Local input
        l_datain[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_dataout[i+X_NODES][3]                // North Input
                                                     : l_dataout[i-(X_NODES*(Y_NODES-1))][3]; // North Input Wrap
        l_datain[i][2] = (((i + 1)% X_NODES) == 0)   ? l_dataout[i-(X_NODES-1)][4]            // East Input Wrap 
                                                     : l_dataout[i+1][4];                     // East Input
        l_datain[i][3] = (i > (X_NODES-1))           ? l_dataout[i-X_NODES][1]                // South Input
                                                     : l_dataout[i+(X_NODES*Y_NODES)][1];     // South Input Wrap
        l_datain[i][4] = ((i % X_NODES) == 0)        ? l_dataout[i+(X_NODES-1)][2]            // West Input Wrap
                                                     : l_dataout[i-1][2]                      // West Input
        
        // Router input 'data valid'
        //   -- Taken from upstream router output data valid and upstream node output data valid
        l_datain_val[i][0] = i_data_val[i];                                                           // Local input
        l_datain_val[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_dataout_val[i+X_NODES][3]                // North Input
                                                         : l_dataout_val[i-(X_NODES*(Y_NODES-1))][3]; // North Input Wrap
        l_datain_val[i][2] = (((i + 1)% X_NODES) == 0)   ? l_dataout_val[i-(X_NODES-1)][4]            // East Input Wrap 
                                                         : l_dataout_val[i+1][4];                     // East Input
        l_datain_val[i][3] = (i > (X_NODES-1))           ? l_dataout_val[i-X_NODES][1]                // South Input
                                                         : l_dataout_val[i+(X_NODES*Y_NODES)][1];     // South Input Wrap
        l_datain_val[i][4] = ((i % X_NODES) == 0)        ? l_dataout_val[i+(X_NODES-1)][2]            // West Input Wrap
                                                         : l_dataout_val[i-1][2]                      // West Input    
    
        // Router input 'enable'
        //   -- Taken from upstream router output data enable and upstream node output data enable
        l_i_en[i][0] = i_en[i];                                                          // Local input
        l_i_en[i][1] = (i < (X_NODES*(Y_NODES-1))) ? l_o_en[i+X_NODES][3]                // North Input
                                                   : l_o_en[i-(X_NODES*(Y_NODES-1))][3]; // North Input Wrap
        l_i_en[i][2] = (((i + 1)% X_NODES) == 0)   ? l_o_en[i-(X_NODES-1)][4]            // East Input Wrap 
                                                   : l_o_en[i+1][4];                     // East Input
        l_i_en[i][3] = (i > (X_NODES-1))           ? l_o_en[i-X_NODES][1]                // South Input
                                                   : l_o_en[i+(X_NODES*Y_NODES)][1];     // South Input Wrap
        l_i_en[i][4] = ((i % X_NODES) == 0)        ? l_o_en[i+(X_NODES-1)][2]            // West Input Wrap
                                                   : l_o_en[i-1][2]                      // West Input    
      
        // Node inputs, i.e network outputs
        o_data[i]     = l_dataout[i][0];
        o_data_val[i] = l_dataout_val[i][0];
        o_en[i]       = l_o_en[i][0];
    
      end
    end
  
  `endif
  
  // Generate Routers
  // ------------------------------------------------------------------------------------------------------------------

  `ifdef TORUS
  
    // Generate routers numbered from 0 to X_NODES-1 in the X direction, from 0 to Y_NODES-1 in the Y direction.
    // For connection to the local network, routers are referenced starting from zero and counting up along the x axis
    // then incrementing on the y axis, and continuing counting along the x axis from x=0.  i.e
    // router number = 0         at (x,y) = (0,0)
    // router number = X_NODES-1 at (x,y) = (X_NODES-1, 0)
    // router number = X_NODES   at (x,y) = (0,1)
  
    genvar y, x;
    generate
    for (y=0; y<Y_NODES; y++) begin : GENERATE_Y_ROUTERS
      for(x=0; x<X_NODES; x++) begin : GENERATE_X_ROUTERS
        ENoC_Router #(.X_NODES(X_NODES),
                      .Y_NODES(Y_NODES),
                      .X_LOC(x),.Y_LOC(y),
                      .INPUT_QUEUE_DEPTH(INPUT_QUEUE_DEPTH),
                      .N(DEGREE),
                      .M(DEGREE))
          gen_ENoC_Router (.clk(clk),
                           .reset_n(reset_n),
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