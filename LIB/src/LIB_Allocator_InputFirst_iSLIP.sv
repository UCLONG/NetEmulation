// --------------------------------------------------------------------------------------------------------------------
// IP Block    : LIB
// Sub Block   : Allocator
// Function    : InputFirst_iSLIP
// Module name : LIB_Allocator_InputFirst_iSLIP
// Description : NxM Input first Separable Allocator.  Allocates N requesters (inputs) to M resources (outputs) using
//             : iSLIP arbitration.
// Uses        : LIB_PPE.sv, LIB_PPE_RoundRobin.sv
// --------------------------------------------------------------------------------------------------------------------

module LIB_Allocator_InputFirst_iSLIP

#(parameter N, // Number of requesters (inputs)
  parameter M) // Number of resources  (outputs)

 (input  logic clk,
  input  logic ce,
  input  logic reset_n,
  
  input  logic [0:N-1][0:M-1] i_request, // N, M-bit request vectors.
  
  output logic [0:M-1][0:N-1] o_o_grant,   // M, N-bit Grant vectors
  output logic [0:N-1][0:M-1] o_i_grant);  // N, M-bit Grant vectors (i.e the transpose)
  
         logic [0:N-1][0:M-1] l_input_grant;    // Result from input arbitration
         logic [0:M-1][0:N-1] l_intermediate;   // Transpose of input grant result for output arbitration
         logic        [0:N-1] l_en;             // Used for PPE clock enable.
         
  // Input Arbitration
  // ------------------------------------------------------------------------------------------------------------------

  `ifdef FPPE

  genvar i;
  generate
    for(i=0; i<N; i++) begin : INPUT_ARBITRATION
      LIB_FPPE #(.N(M), LOOK_AHEAD(0))
        gen_LIB_FPPE (.i_request(i_request[i]),
                      .i_priority(l_input_priority[i]),
                      .o_grant(l_input_grant[i]));
    end
  endgenerate
  
  `else
  
  genvar i;
  generate
    for(i=0; i<N; i++) begin : INPUT_ARBITRATION
      LIB_PPE_RoundRobin #(.N(M))
        gen_LIB_PPE_RoundRobin (.clk,
                                .ce(l_en[i]),
                                .reset_n,.i_request(i_request[i]),
                                .o_grant(l_input_grant[i]));
    end
  endgenerate
  
  `endif
  
  // transposition of the input arbitration grant for input into the Output arbitration stage.
  always_comb begin
    l_intermediate = '0;
    for(int i=0; i<M; i++) begin
      for(int j=0; j<N; j++) begin
        l_intermediate[i][j] = l_input_grant[j][i];
      end
    end
  end
  
  // Output Arbitration
  // ------------------------------------------------------------------------------------------------------------------

  `ifdef FPPE
  
  generate 
    for(i=0; i<M; i++) begin : OUTPUT_ARBITRATION
      LIB_PPE_RoundRobin #(.N(N), LOOK_AHEAD(0))
        gen_LIB_PPE_RoundRobin (.clk,
                                .ce,
                                .reset_n,
                                .i_request(l_intermediate[i]),
                                .o_grant(o_o_grant[i]));
    end
  endgenerate
  
  `else

  generate 
    for(i=0; i<M; i++) begin : OUTPUT_ARBITRATION
      LIB_PPE_RoundRobin #(.N(N))
        gen_LIB_PPE_RoundRobin (.clk,
                                .ce,
                                .reset_n,
                                .i_request(l_intermediate[i]),
                                .o_grant(o_o_grant[i]));
    end
  endgenerate
  
  `endif
  
  // transposition of the output arbitration grant for indicating an enable to the requesting VCs and updating the
  // priority.
  always_comb begin
    o_i_grant = '0;
    for(int i=0; i<N; i++) begin
      for(int j=0; j<M; j++) begin
        o_i_grant[i][j] = o_o_grant[j][i];
      end
    end
  end

  always_comb begin
    l_en = '0;
    for(int i=0; i<N; i++) begin
      l_en |= o_i_grant[i];
      // if this fails to synthesize, this is equivalent to: l_en[0:N-1] = l_en[0:N-1] | l_o_i_grant[i][0:N-1];
    end
  end
  
endmodule