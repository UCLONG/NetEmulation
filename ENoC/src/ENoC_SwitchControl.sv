// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : SwitchControl
// Module name : ENoC_SwitchControl
// Description : Simple controller for a CrossBar switch.  Flow control is valid/enable.
// Uses        : LIB_PPE_RoundRobin.sv, LIB_Allocator_InputFirst_RoundRobin.sv, LIB_Allocator_InputFirst_iSLIP.sv 
// --------------------------------------------------------------------------------------------------------------------

`include "ENoC_Config.sv" // Defines whether or not VOQs are used, and whether or not to use iSLIP

module ENoC_SwitchControl

#(parameter integer N, // Number of inputs
  parameter integer M) // Number of outputs

 (input  logic clk,
  input  logic ce,
  input  logic reset_n,
  
  input  logic        [0:M-1] i_en,            // signal from downstream router that indicates if it is available
  input  logic [0:N-1][0:M-1] i_output_req,    // N local input units requests up to M output ports
  
  output logic [0:M-1][0:N-1] o_output_grant,  // Each of the M outputs are granted to the N inputs
  `ifdef VOQ
  output logic [0:N-1][0:M-1] o_input_grant);  // Each of the N inputs has M VOQs.  Only one queue is granted an output.
  `else
  output logic        [0:N-1] o_input_grant);  // Each of the N inputs has a single input queue that can be granted
  `endif
  
         logic [0:N-1][0:M-1] l_req_matrix;    // N Packed requests for M available output ports
  
  `ifdef VOQ

    // Virtual Output Queues are used, each input can request multiple outputs, need to arbitrate input and output 
    // using an allocator.  The input 'output_req' is N, M-bit words.  Each word corresponds to an input port, each bit 
    // corresponds to the requested output port.  First block ensures VCs will not request an input port if the output
    // port it requires is unavailable.  This is then fed into either a round robin allocator or an iSLIP allocator.
    // ----------------------------------------------------------------------------------------------------------------
    always_comb begin
      l_req_matrix = '0;
      for (int i=0; i<N; i++) begin
        for (int j=0; j<M; j++) begin
          l_req_matrix[i][j] = i_output_req[i][j] && i_en[j];
        end
      end
    end
    
    `ifdef iSLIP

      LIB_Allocator_InputFirst_iSLIP #(.N(N), .M(M))
        inst_LIB_Allocator_InputFirst_iSLIP (.clk,
                                             .ce,
                                             .reset_n,
                                             .i_request(l_req_matrix),
                                             .o_o_grant(o_output_grant),
                                             .o_i_grant(o_input_grant));
    
    `else

      LIB_Allocator_InputFirst_RoundRobin #(.N(N), .M(M))
        inst_LIB_Allocator_InputFirst_RoundRobin (.clk,
                                                  .ce,
                                                  .reset_n,
                                                  .i_request(l_req_matrix),
                                                  .o_o_grant(o_output_grant),
                                                  .o_i_grant(o_input_grant));
    `endif

  `else

    // No virtual Output Queues, each input can only request a single output, only need to arbitrate for the output 
    // port. The input 'output_req' is N, M-bit words.  Each word corresponds to an input port, each bit corresponds to 
    // the requested output port.  This is transposed so that each word corresponds to an output port, and each bit 
    // corresponds to an input that requested it.  This also ensures that output port requests will not be made if the 
    // corresponding output enable is low.  This is then fed into M round robin arbiters.
    // ----------------------------------------------------------------------------------------------------------------
    always_comb begin
      l_req_matrix = '0;
      for (int i=0; i<M; i++) begin
        for (int j=0; j<N; j++) begin
          l_req_matrix[i][j] = i_output_req[j][i] && i_en[i];
        end
      end
    end
  
    genvar i;
    generate
      for (i=0; i<M; i++) begin : OUTPUT_ARBITRATION
        LIB_PPE_RoundRobin #(.N(N)) gen_LIB_PPE_RoundRobin (.clk,
                                                            .ce,
                                                            .reset_n,
                                                            .i_request(l_req_matrix[i]),
                                                            .o_grant(o_output_grant[i]));
      end
    endgenerate
    
    // indicate to input FIFOs, according to arbitration results, that data will be read. Enable is high if any of the 
    // output_grants indicate they have accepted an input.  This creates one N bit word, which is the logical 'or' of
    // all the output_grants, as each output_grant is an N-bit onehot vector representing a granted input.
    // ----------------------------------------------------------------------------------------------------------------
    always_comb begin
      o_input_grant = '0;
      for(int i=0; i<N; i++) begin
        o_input_grant |= o_output_grant[i];
        // if this fails to synthesize, this is equivalent to: l_en[0:N-1] = l_en[0:N-1] | l_output_grant[i][0:N-1];
      end
    end 

  `endif

endmodule
