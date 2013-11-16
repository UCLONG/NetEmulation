// --------------------------------------------------------------------------------------------------------------------
// IP Block    : LIB
// Sub Block   : PPE
// Function    : RoundRobin
// Module name : LIB_PPE_RoundRobin
// Description : M-bit Programmable Priority Encoder including round robin priority generation.
// Notes       : Netlist was used as the wrap around logic was causing problems during simulation.  Based on Dally and
//               Towles Principles and Practices of Interconnection Networks p354
// --------------------------------------------------------------------------------------------------------------------

module LIB_PPE_RoundRobin

#(parameter N) // Number of requesters

 (input  logic clk,
  input  logic reset_n,
  
  input  logic [0:N-1] i_request,         // Active high Request vector
  
  output logic [0:N-1] o_grant);          // One-hot Grant vector
  
         logic [0:N-1] l_priority;        // One-hot Priority selection vector
         logic [0:N-1] l_carry;           // Carry-bit between arbiter slices
         logic [0:N-1] l_intermediate;    // Intermediate wire inside arbiter slice

  // Variable priority iterative arbiter slice generation.  Final slice carry loops round.
  // ------------------------------------------------------------------------------------------------------------------
  genvar i;
  generate
    for (i=0; i<N-1; i++) begin : PPE_SLICES
      or  gate1  (l_intermediate[i], l_carry[i], l_priority[i]);
      and gate2  (o_grant[i], l_intermediate[i], i_request[i]);
      and gate3  (l_carry[i+1], l_intermediate[i], ~i_request[i]);
    end
    or  gate1  (l_intermediate[N-1], l_carry[N-1], l_priority[N-1]);
    and gate2  (o_grant[N-1], l_intermediate[N-1], i_request[N-1]);
    and gate3  (l_carry[0], l_intermediate[N-1], ~i_request[N-1]);   
  endgenerate
  
  // Round-Robin priority generation.
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      l_priority[0] <= 1'b1;
      l_priority[1:N-1] <= 0;
    end else begin
      l_priority <= |o_grant ? {o_grant[N-1], o_grant[0:N-2]} : l_priority;
    end
  end
  
endmodule