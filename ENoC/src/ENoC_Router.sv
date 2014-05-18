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

`include "ENoC_Config.sv"   // Instructs whether or not Virtual Output Queues and Load Balancing are used.

module ENoC_Router

#(`ifdef TORUS
    parameter integer X_NODES,         // Total number of nodes on the X axis of the Mesh
    parameter integer Y_NODES,         // Total number of nodes on the Y axis of the Mesh
    parameter integer Z_NODES,         // Total number of nodes on the Z axis of the Mesh
    parameter integer X_LOC,           // Current node location on the X axis of the Mesh
    parameter integer Y_LOC,           // Current node location on the Y axis of the Mesh
    parameter integer Z_LOC,           // Current node location on the Y axis of the Mesh
  `else
    parameter integer NODES,           // Total number of nodes
    parameter integer LOC,             // Current node
  `endif
  parameter integer INPUT_QUEUE_DEPTH, // Depth of input queues
  parameter integer N,                 // Number of input ports.
  parameter integer M)                 // Number of output ports.
 
 (input logic clk, reset_n,
  
  // Upstream Bus.
  // ------------------------------------------------------------------------------------------------------------------
  input  packet_t [0:N-1] i_data,     // Input data from upstream [core, north, east, south, west]
  input  logic    [0:N-1] i_data_val, // Validates data from upstream [core, north, east, south, west]
  output logic    [0:M-1] o_en,       // Enables data from upstream [core, north, east, south, west]
  
  // Downstream Bus
  // ------------------------------------------------------------------------------------------------------------------
  output packet_t [0:M-1] o_data,     // Outputs data to downstream [core, north, east, south, west]
  output logic    [0:M-1] o_data_val, // Validates output data to downstream [core, north, east, south, west]
  input  logic    [0:N-1] i_en);      // Enables output to downstream [core, north, east, south, west]
  
  // Local Signals common to all definitions
  // ------------------------------------------------------------------------------------------------------------------

         // Load balancing.  Shorted if LOAD_BALANCE is not defined
         packet_t        [0:N-1] l_i_data;       // Output of the input crossbar
         logic           [0:N-1] l_i_data_val;   // Output of the input crossbar
         logic           [0:N-1] l_o_en;         // Enable of the input crossbar
         
         // Connections between input queues and switch etc.
         packet_t        [0:N-1] l_data;         // Connects FIFO data outputs to switch
         logic    [0:N-1][0:M-1] l_output_req;   // Request sent to SwitchControl
         logic    [0:M-1][0:N-1] l_output_grant; // Grant from SwitchControl, used to control switch and FIFOs
         
         // Clock Enable.  For those modules that require it.
         logic                   ce;
 
  assign ce = 1'b1;

  `ifdef LOAD_BALANCE
  
         logic    [0:N-1][0:N-1] l_sel;          // Crossbar selection control
  
    // Load Balancing.  Input data is assigned a random router input channel by inserting a crossbar between the
    // upstream bus and the input channels.  The following code describes an NxN crossbar for each input connection.  
    // The variable i references each output of the crossbar, and the variable j references the inputs.  Each output 
    // has a onehot select vector that determines which input will be switched to the corresponding output.
    // ----------------------------------------------------------------------------------------------------------------
    always_comb begin
      l_i_data = 'z;
      l_i_data_val = '0;
      o_en = '0;
      for(int i=0; i<N; i++) begin
        for(int j=0; j<N; j++) begin
          if(l_sel[i] == (1<<(N-1)-j)) begin
            l_i_data[i]     = i_data[j];
            l_i_data_val[i] = i_data_val[j];
            o_en[j]         = l_o_en[i];
          end
        end
      end
    end
    
    // Load Balancing.  The crossbar selection ensures that each input is matched to an output (in this case the output
    // is a router input channel)
    // ----------------------------------------------------------------------------------------------------------------
    always_ff@(posedge clk) begin
      if(~reset_n) begin
        for(int i=0; i<N; i++) begin
          l_sel[i] = (1 << i);
        end
      end else begin
        for(int i=0; i<N; i++) begin
          l_sel[i] = {l_sel[i][N-1], l_sel[i][0:N-2]};
        end
      end
    end
  
  `else
  
    // No Load Balancing, connect the inputs directly to corresponding input channel
    // ----------------------------------------------------------------------------------------------------------------
  
    assign l_i_data     = i_data;
    assign l_i_data_val = i_data_val;
    assign o_en         = l_o_en;
  
  `endif

  `ifdef VOQ
  
    // Virtual Output Queue.  One input FIFO (virtual channel) for each output, at each input switch.  The route 
    // calculation is performed on the incoming packet from the upstream router, the result of this calculation is used 
    // to decide which virtual channel the incoming packet will be stored in.  The VOQ modules output a word according 
    // to which virtual channels have valid data.  This output is used by the switch control for arbitration.
    // ----------------------------------------------------------------------------------------------------------------

         logic    [0:N-1][0:M-1] l_vc_req; // Connects the output request of the Route Calc to a VOQ
         logic    [0:N-1][0:M-1] l_en;     // Connects switch control enable output to VOQs
         genvar                  i;
    
    generate
      for (i=0; i<N; i++) begin : GENERATE_ROUTE_CALCULATORS    
        ENoC_RouteCalculator #(`ifdef TORUS
                                 .X_NODES(X_NODES), .Y_NODES(Y_NODES), .Z_NODES(Z_NODES), 
                                 .X_LOC(X_LOC), .Y_LOC(Y_LOC), .Z_LOC(Z_LOC), 
                                 .M(M))
                               `else
                                 .NODES(NODES), .LOC(LOC), .M(M))
                               `endif
          gen_ENoC_RouteCalculator (`ifdef XYSWAP
                                      .clk(clk),
                                      .reset_n(reset_n),
                                    `endif
                                    `ifdef TORUS
                                      `ifdef OLD_PACKET_T
                                        // Following two lines adapt a single address into a two part address.  Will 
                                        // only work for networks where the number of nodes is a function of 2^2n where
                                        // n is a positive integer.  Only currently works for 2D networks, but the 
                                        // principle can be expanded to 3D if required.  Delete once packet_t is
                                        // synchronised between ENoC and NetEmulation
                                        .i_x_dest(l_i_data[i].dest[($clog2({1'b0,X_NODES*Y_NODES}+1)/2)-1:0]),           
                                        .i_y_dest(l_i_data[i].dest[$clog2({1'b0,X_NODES*Y_NODES}+1)-1:({1'b0,X_NODES*Y_NODES}+1)/2)]),
                                        .i_z_dest(0);
                                      `else
                                        .i_x_dest(l_i_data[i].x_dest),
                                        .i_y_dest(l_i_data[i].y_dest),
                                        .i_z_dest(l_i_data[i].z_dest),
                                      `endif
                                    `else
                                      .i_dest(l_i_data[i].dest),
                                    `endif
                                    .i_val(l_i_data_val[i]),      // From upstream router
                                    .o_output_req(l_vc_req[i]));  // To VOQ module
      end
    endgenerate
    
    generate
      for(i=0; i<N; i++) begin : GENERATE_VOQ
        LIB_VOQ #(.M(M), .DEPTH(INPUT_QUEUE_DEPTH))
          gen_LIB_VOQ (.clk,
                       .ce,
                       .reset_n,
                       .i_data(l_i_data[i]),         // Single input data from upstream router
                       .i_data_val(l_vc_req[i]),     // Valid from routecalc corresponds to required VC
                       .o_en(l_o_en[i]),             // To the upstream router, possibly via load balance
                       .o_data(l_data[i]),           // Single output data to switch
                       .o_data_val(l_output_req[i]), // Packed request word to SwitchControl
                       .i_en(l_en[i]));              // Packed grant word from SwitchControl
      end
    endgenerate 
    
  `else
  
    // No virtual Output Queues.  Five input FIFOs, with a Route Calculator attached to the packet waiting at the 
    // output of each FIFO.  The result of the route calculation is used by the switch control for arbitration.
    // ----------------------------------------------------------------------------------------------------------------

         logic            [0:N-1] l_data_val; // Connects FIFO valid output to the route calculator    
         logic            [0:N-1] l_en;       // Connects switch control enable output to FIFO
         genvar                   i;     

    generate
      for (i=0; i<N; i++) begin : GENERATE_INPUT_QUEUES
        LIB_FIFO_packet_t #(.DEPTH(INPUT_QUEUE_DEPTH))
          gen_LIB_FIFO_packet_t (.clk,
                                 .ce,
                                 .reset_n,
                                 .i_data(l_i_data[i]),         // From the upstream routers
                                 .i_data_val(l_i_data_val[i]), // From the upstream routers
                                 .i_en(l_en[i]),               // From the SwitchControl
                                 .o_data(l_data[i]),           // To the Switch
                                 .o_data_val(l_data_val[i]),   // To the route calculator
                                 .o_en(l_o_en[i]),             // To the upstream router, possibly via load balance
                                 .o_full(),                    // Not connected, not required for simple flow control
                                 .o_near_full(),               // Not connected, not required for simple flow control                  
                                 .o_empty(),                   // Not connected, not required for simple flow control
                                 .o_near_empty());             // Not connected, not required for simple flow control
      end
    endgenerate
    
    // Route calculator will output 5 packed words, each word corresponds to an input, each bit corresponds to the
    // output requested.
    // ----------------------------------------------------------------------------------------------------------------
    generate
      for (i=0; i<N; i++) begin : GENERATE_ROUTE_CALCULATORS  
        ENoC_RouteCalculator #(`ifdef TORUS
                                 .X_NODES(X_NODES), .Y_NODES(Y_NODES), .Z_NODES(Z_NODES), 
                                 .X_LOC(X_LOC),     .Y_LOC(Y_LOC),     .Z_LOC(Z_LOC), 
                                 .M(M))
                               `else
                                 .NODES(NODES), .LOC(LOC), .M(M))
                               `endif 
          gen_ENoC_RouteCalculator (`ifdef XYSWAP
                                      .clk(clk),
                                      .reset_n(reset_n),
                                    `endif
                                    `ifdef TORUS
                                      `ifdef OLD_PACKET_T
                                        // Following two lines adapt a single address into a two part address.  Will 
                                        // only work for networks where the number of nodes is a function of 2^2n where
                                        // n is a positive integer.  Only currently works for 2D networks, but the 
                                        // principle can be expanded to 3D if required.  Delete once packet_t is
                                        // synchronised between ENoC and NetEmulation
                                        .i_x_dest(l_i_data[i].dest[($clog2({1'b0,X_NODES*Y_NODES}+1)/2)-1:0]),           
                                        .i_y_dest(l_i_data[i].dest[$clog2({1'b0,X_NODES*Y_NODES}+1)-1:({1'b0,X_NODES*Y_NODES}+1)/2)]),
                                        .i_z_dest(0);
                                      `else
                                        .i_x_dest(l_i_data[i].x_dest),
                                        .i_y_dest(l_i_data[i].y_dest),
                                        .i_z_dest(l_i_data[i].z_dest),
                                      `endif
                                    `else
                                      .i_dest(l_data[i].dest),
                                    `endif
                                    .i_val(l_data_val[i]),                                      // From local FIFO
                                    .o_output_req(l_output_req[i]));                            // To Switch Control
      end
    endgenerate  
    
  `endif
 
  // Switch Control receives N, M-bit words, each word corresponds to an input, each bit corresponds to the requested
  // output.  This is combined with the enable signal from the downstream router, then arbitrated.  The result is
  // M, N-bit words each word corresponding to an output, each bit corresponding to an input (note the transposition).
  // ------------------------------------------------------------------------------------------------------------------  
  ENoC_SwitchControl #(.N(N), .M(M))
    inst_ENoC_SwitchControl (.clk,
                             .ce,
                             .reset_n,
                             .i_en(i_en),                      // From the downstream router
                             .i_output_req(l_output_req),      // From the local VCs or Route Calculator
                             .o_output_grant(l_output_grant),  // To the switch, and to the downstream router
                             .o_input_grant(l_en));            // To the local VCs or FIFOs
 
  // Switch.  Switch uses onehot input from switch control.
  // ------------------------------------------------------------------------------------------------------------------
  
  LIB_Switch_OneHot_packet_t #(.N(N), .M(M))
    inst_LIB_Switch_OneHot_packet_t (.i_sel(l_output_grant), // From the Switch Control
                                     .i_data(l_data),        // From the local FIFOs
                                     .o_data(o_data));       // To the downstream routers
  
  // Output to downstream routers that the switch data is valid.  l_output_grant[output number] is a onehot vector, thus
  // if any of the bits are high the output referenced by [output number] has valid data.
  // ------------------------------------------------------------------------------------------------------------------                      
  always_comb begin
  o_data_val = '0;
    for (int i=0; i<M; i++) begin  
      o_data_val[i]  = |l_output_grant[i];
    end
  end

endmodule
