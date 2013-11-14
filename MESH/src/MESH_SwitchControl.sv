// --------------------------------------------------------------------------------------------------------------------
// IP Block    : MESH
// Function    : SwitchControl
// Module name : MESH_SwitchControl
// Description : Simple controller for a CrossBar switch.  Flow control is valid/enable.
// Uses        : LIB_PPE_RoundRobin.sv, LIB_Allocator_InputFirst_RoundRobin.sv, LIB_Allocator_InputFirst_iSLIP.sv 
// --------------------------------------------------------------------------------------------------------------------

`include "MESH_Config.sv"

module MESH_SwitchControl

#(parameter N, // Number of inputs
  parameter M) // Number of outputs

 (input  logic clk,
  input  logic reset_n,
  
  input  logic         i_en           [0:M-1],   // hold ports signal from downstream router
  input  logic [0:M-1] i_output_req   [0:N-1],   // each local input unit requests [c,n,e,s,w] output port
  
  output logic [0:N-1] o_output_grant [0:M-1]);  // Each output grants the [c,n,e,s,w] input 
  
         logic [0:N-1] l_req_matrix   [0:M-1];   // Packed requests for the [c,n,e,s,w] output
  
  `ifdef VC

    // Virtual Channels are used, each input can request multiple outputs, need to arbitrate input and output using an
    // allocator.  The input 'output_req' is N, M-bit words.  Each word corresponds to an input port, each bit 
    // corresponds to the requested output port.  First block ensures VCs will not request an input port if the output
    // port it requires is unavailable.  This is then fed into either a round robin allocator or an iSLIP allocator.
    // ----------------------------------------------------------------------------------------------------------------
    always_comb begin
      for (int i=0; i<N; i++) begin
        for (int j=0; j<M; j++) begin
          l_req_matrix[i][j] = i_output_req[i][j] && i_en[j];
        end
      end
    end
    
    `ifdef iSLIP

      LIB_Allocator_InputFirst_iSLIP #(.N(N), .M(M))
        inst_LIB_Allocator_InputFirst_iSLIP (.clk,
                                             .reset_n,
                                             .i_request(l_req_matrix),
                                             .o_grant(o_output_grant));
    
    `else

      LIB_Allocator_InputFirst_RoundRobin #(.N(N), .M(M))
        inst_LIB_Allocator_InputFirst_RoundRobin (.clk,
                                                  .reset_n,
                                                  .i_request(l_req_matrix),
                                                  .o_grant(o_output_grant));

    `endif

  `else

    // No virtual channels, each input can only request a single output, only need to arbitrate for the output port.
    // The input 'output_req' is N, M-bit words.  Each word corresponds to an input port, each bit corresponds to the 
    // requested output port.  This is transposed so that each word corresponds to an output port, and each bit 
    // corresponds to an input that requested it.  This also ensures that output port requests will not be made if the 
    // corresponding output enable is low.  This is then fed into M round robin arbiters.
    // ----------------------------------------------------------------------------------------------------------------
    always_comb begin
      for (int i=0; i<M; i++) begin
        for (int j=0; j<N; j++) begin
          l_req_matrix[i][j] = i_output_req[j][i] && i_en[i];
        end
      end
    end
  
    generate
      for (genvar i=0; i<M; i++) begin
        LIB_PPE_RoundRobin #(.N(N)) gen_LIB_PPE_RoundRobin (.clk,
                                                            .reset_n,
                                                            .i_request(l_req_matrix[i]),
                                                            .o_grant(o_output_grant[i]));
      end
    endgenerate

  `endif

endmodule
