// --------------------------------------------------------------------------------------------------------------------
// IP Block    : MESH
// Function    : SwitchControl
// Module name : MESH_SwitchControl
// Description : Simple controller for a 5 port CrossBar switch.  Flow control is valid/enable.
// Uses        : MESH_IterativeArbiter.sv
// Notes       : Untested
// --------------------------------------------------------------------------------------------------------------------

`include "MESH_Config.sv"

module MESH_SwitchControl

#(parameter RADIX)

 (input  logic clk,
  input  logic reset_n,
  
  input  logic             i_en           [0:RADIX-1],   // hold ports signal from downstream router
  input  logic [0:RADIX-1] i_output_req   [0:RADIX-1],   // each local input unit requests [c,n,e,s,w] output port
  
  output logic [0:RADIX-1] o_output_grant [0:RADIX-1]);  // Each output grants the [c,n,e,s,w] input 
  
         logic [0:RADIX-1] l_req_matrix   [0:RADIX-1];   // Packed requests for the [c,n,e,s,w] output
  
  // Populate request matrix.  The input is 5, 5-bit words.  Each word corresponds to an input port, each bit
  // corresponds to the requested output port.  This is transposed so that each word corresponds to an output port, and
  // each bit corresponds to an input that requested it.  Output port requests will not be made if the corresponding 
  // enable is low.
  // ------------------------------------------------------------------------------------------------------------------
  always_comb begin
    for (int i=0; i<RADIX; i++) begin
      for (int j=0; j<RADIX; j++) begin
        l_req_matrix[i][j] = i_output_req[j][i] && i_en[i];
      end
    end
  end
  
  // Arbitrate the request matrix
  // ------------------------------------------------------------------------------------------------------------------
  
  `ifdef VC
  
    // Virtual Channels are used, each input can request multiple outputs, need to arbitrate input and output using an
    // allocator
    // ----------------------------------------------------------------------------------------------------------------
    LIB_Allocator_InputFirst #(.N(RADIX), .M(RADIX))
      inst_LIB_Allocator_InputFirst (.clk,
                                     .reset_n,
                                     .i_request(l_req_matrix),
                                     .o_grant(o_output_grant));
  
  `else
    
    // No virtual channels, each input can only request a single output, only need to arbitrate for the output port
    // ----------------------------------------------------------------------------------------------------------------
    generate
      for (genvar i=0; i<RADIX; i++) begin
        LIB_PPE_RoundRobin #(.N(RADIX)) gen_LIB_PPE_RoundRobin (.clk,
                                                                .reset_n,
                                                                .i_request(l_req_matrix[i]),
                                                                .o_grant(o_output_grant[i]));
      end
    endgenerate
  
  `endif
  
endmodule
  
