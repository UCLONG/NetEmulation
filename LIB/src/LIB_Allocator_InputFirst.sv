// --------------------------------------------------------------------------------------------------------------------
// IP Block    : LIB
// Sub Block   : Allocator
// Function    : InputFirst
// Module name : LIB_Allocator_InputFirst
// Description : NxM Input first Separable Allocator.  Allocates N requesters (inputs) to M resources (outputs) using
//             : round robin Programmable Priority Encoders.
// Uses        : LIB_PPE_RoundRobin.sv
// --------------------------------------------------------------------------------------------------------------------

module LIB_Allocator_InputFirst

#(parameter N, // Number of requesters (inputs)
  parameter M) // Number of resources  (outputs)

 (input  logic clk,
  input  logic reset_n,
  
  input  logic [0:M-1] i_request [0:N-1],   // N, M-bit request vectors
  
  output logic [0:M-1] o_grant   [0:N-1]);  // N, M-bit Grant vectors
  
         logic [0:M-1] l_input_grant   [0:N-1];  
         logic [0:N-1] l_intermediate  [0:M-1];
         logic [0:N-1] l_output_grant  [0:M-1];
         
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
  
  // transposition for input into the Output arbitration stage.
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
      LIB_PPE #(.N(N))
        gen_LIB_PPE_RoundRobin (.clk,
                                .reset_n,
                                .i_request(l_intermediate[i]),
                                .o_grant(l_output_grant[i]));
    end
  endgenerate
  
  // transposition for output
  always_comb begin
    for(int i=0; i<N; i++) begin
      for(int j=0; j<M; j++) begin
        o_grant[i][j] = l_intermediate[j][i];
      end
    end
  end
  
endmodule