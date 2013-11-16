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
  input  logic reset_n,
  
  input  logic [0:N-1][0:M-1] i_request, // N, M-bit request vectors.
  
  output logic [0:M-1][0:N-1] o_grant);  // M, N-bit Grant vectors
  
         logic [0:N-1][0:M-1] l_input_priority; // Input priority vector - rotated only when output grant served
         logic [0:N-1][0:M-1] l_input_grant;    // Result from input arbitration
         logic [0:M-1][0:N-1] l_intermediate;   // Transpose of input grant result for output arbitration
         
  // Input Arbitration
  // ------------------------------------------------------------------------------------------------------------------
  genvar i;
  generate
    for(i=0; i<N; i++) begin : INPUT_ARBITRATION
      LIB_PPE #(.N(M))
        gen_LIB_PPE (.i_request(i_request[i]),
                     .i_priority(l_input_priority[i]),
                     .o_grant(l_input_grant[i]));
    end
  endgenerate
  
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
  generate 
    for(i=0; i<M; i++) begin : OUTPUT_ARBITRATION
      LIB_PPE_RoundRobin #(.N(N))
        gen_LIB_PPE_RoundRobin (.clk,
                                .reset_n,
                                .i_request(l_intermediate[i]),
                                .o_grant(o_grant[i]));
    end
  endgenerate
  
  // iSLIP priority generation.  Updates the priority of the input arbiters only if that input was successful in
  //  the last round of output arbitration.
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<N; i++) begin
        l_input_priority[i][0] <= 1'b1;
        l_input_priority[i][1:M-1] <= 0;
      end
    end else begin
      for(int i=0; i<N; i++) begin
        for(int j=0; j<M; j++) begin
          l_input_priority[i] <= |o_grant[j][i] ? {l_input_priority[i][N-1], l_input_priority[i][0:N-2]} 
                                                : l_input_priority[i];
        end
      end
    end
  end
  
endmodule