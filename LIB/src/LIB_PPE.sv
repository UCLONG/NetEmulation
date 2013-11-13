// --------------------------------------------------------------------------------------------------------------------
// IP Block    : LIB
// Sub Block   : PPE
// Module name : LIB_PPE
// Description : M-bit Programmable Priority Encoder.
// Notes       : Netlist was used as the wrap around logic was causing problems during simulation.  Based on Dally and
//               Towles Principles and Practices of Interconnection Networks p354
// --------------------------------------------------------------------------------------------------------------------

module LIB_PPE

#(parameter N) // Number of requesters

 (input  logic [0:N-1] i_request,         // Active high Request vector
  input  logic [0:N-1] i_priority,        // One-hot Priority vector
  
  output logic [0:N-1] o_grant);          // One-hot Grant vector
  
         logic [0:N-1] l_priority;        // One-hot Priority selection vector
         logic [0:N-1] l_carry;           // Carry-bit between arbiter slices
         logic [0:N-1] l_intermediate;    // Intermediate wire inside arbiter slice

  // Variable priority iterative arbiter slice generation.  Final slice carry loops round.
  // ------------------------------------------------------------------------------------------------------------------
  generate
    for (genvar i=0; i<N-1; i++) begin
      or  gate1  (l_intermediate[i], l_carry[i], l_priority[i]);
      and gate2  (o_grant[i], l_intermediate[i], i_request[i]);
      and gate3  (l_carry[i+1], l_intermediate[i], ~i_request[i]);
    end
    or  gate1  (l_intermediate[N-1], l_carry[N-1], l_priority[N-1]);
    and gate2  (o_grant[N-1], l_intermediate[N-1], i_request[N-1]);
    and gate3  (l_carry[0], l_intermediate[N-1], ~i_request[N-1]);   
  endgenerate
  
endmodule