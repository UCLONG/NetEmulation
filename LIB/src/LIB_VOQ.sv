// --------------------------------------------------------------------------------------------------------------------
// IP Block    : LIB
// Function    : VOQ
// Module name : LIB_VOQ
// Description : Virtual Output Queue.  Instantiates an independent FIFO for each output port.  Stores input data to   
//             : single FIFO according to a onehot input valid.  Multiplexes the output data to a single port according 
//             : to a onehot enable input
// Uses        : LIB_FIFO_packet_t.sv,
// --------------------------------------------------------------------------------------------------------------------

`include "ENoC_Config.sv" // Change this config file to wherever packet_t is declared

module LIB_VOQ

#(parameter M,     // Number of outputs requiring virtual channel
  parameter DEPTH) // Depth of the virtual channels
  
 (input logic clk, 
  input logic ce,
  input logic reset_n,
  
  // Upstream Bus.
  // ------------------------------------------------------------------------------------------------------------------
  input  packet_t         i_data,     // Input data from upstream router
  input  logic    [0:M-1] i_data_val, // Validates data and indicates required output (thus which VC is required)
  output logic            o_en,       // Enables data from upstream router, depends on which VC is requested
  
  // Downstream Bus.
  // ------------------------------------------------------------------------------------------------------------------
  output packet_t         o_data,     // Outputs data from a single FIFO to Switch according to i_en
  output logic    [0:M-1] o_data_val, // Validates output data to Arbiter
  input  logic    [0:M-1] i_en);      // Enables output to switch
  
  // Local Signals
  // ------------------------------------------------------------------------------------------------------------------
         packet_t [0:M-1] l_o_data;
         logic    [0:M-1] l_o_en;
  
  // Virtual Channnels
  // ------------------------------------------------------------------------------------------------------------------
  genvar i;
  generate
    for (i=0; i<M; i++) begin : VIRTUAL_CHANNELS
      LIB_FIFO_packet_t #(.DEPTH(DEPTH))
        gen_LIB_FIFO_packet_t (.clk,
                               .ce,
                               .reset_n,
                               .i_data(i_data),            // Each FIFO is connected to the same input data
                               .i_data_val(i_data_val[i]), // Each FIFO has an individual i_data_valid
                               .i_en(i_en[i]),             // From the Arbiter
                               .o_data(l_o_data[i]),       // Needs multiplexing to a single output dependent upon i_en
                               .o_data_val(o_data_val[i]), // To the Arbiter
                               .o_en(l_o_en[i]),           // Output to downstream router dependent upon request
                               .o_full(),                  // Not connected, o_en used for flow control.
                               .o_empty(),                 // Not connected, not required for simple flow control
                               .o_near_empty());           // Not connected, not required for simple flow control
    end
  endgenerate
  
  // Multiplex output data and output enable from each virtual channel to the single channel according to i_en and
  // i_data_val respectively.  As i_en and i_data_val are onehot, with position 0 being at the far left, the shift left
  //  operation compares the values with another onehot value.
  // ------------------------------------------------------------------------------------------------------------------
  always_comb begin
    o_data = 'z;
    o_en   =  0;
    for(int i=0; i<M; i++) begin
      if(i_en == (1<<(M-1)-i))       o_data = l_o_data[i];
      if(i_data_val == (1<<(M-1)-i)) o_en   = l_o_en[i];
    end
  end
  
endmodule