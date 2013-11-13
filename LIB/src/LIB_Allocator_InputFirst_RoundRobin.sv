// --------------------------------------------------------------------------------------------------------------------
// IP Block    : LIB
// Sub Block   : Allocator
// Function    : InputFirst_RoundRobin
// Module name : LIB_Allocator_InputFirst_RoundRobin
// Description : NxM Input first Separable Allocator.  Allocates N requesters (inputs) to M resources (outputs) using
//             : round robin Programmable Priority Encoders.
// Uses        : LIB_PPE_RoundRobin.sv
// Notes       : Untested
// --------------------------------------------------------------------------------------------------------------------

module LIB_Allocator_InputFirst

#(parameter N, // Number of requesters (inputs)
  parameter M) // Number of resources  (outputs)

 (input  logic clk,
  input  logic reset_n,
  
  input  logic [0:M-1] i_request [0:N-1],  // N, M-bit request vectors.
  
  output logic [0:N-1] o_grant   [0:M-1]); // M, N-bit Grant vectors
  
         logic [0:M-1] l_input_grant   [0:N-1]; // Result from input arbitration
         logic [0:N-1] l_intermediate  [0:M-1]; // Transpose of input grant result for output arbitration
         
  // Input Arbitration
  // ------------------------------------------------------------------------------------------------------------------
  generate
    for(genvar i=0; i<N; i++) begin
      LIB_PPE_RoundRobin #(.N(M))
        gen_LIB_PPE_RoundRobin (.clk,
                                .reset_n,
                                .i_request(i_request[i]),
                                .o_grant(l_input_grant[i]));
    end
  endgenerate
  
  // transposition of the input arbitration grant for input into the Output arbitration stage.
  always_comb begin
    for(int i=0; i<M; i++) begin
      for(int j=0; j<N; j++) begin
        l_intermediate[i][j] = l_input_grant[j][i];
      end
    end
  end
  
  // Output Arbitration
  // ------------------------------------------------------------------------------------------------------------------
  generate
    for(genvar i=0; i<M; i++) begin
      LIB_PPE_RoundRobin #(.N(N))
        gen_LIB_PPE_RoundRobin (.clk,
                                .reset_n,
                                .i_request(l_intermediate[i]),
                                .o_grant(l_output_grant[i]));
    end
  endgenerate
  
endmodule