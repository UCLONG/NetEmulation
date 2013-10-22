// --------------------------------------------------------------------------------------------------------------------
// IP Block    : MESH
// Function    : IterativeArbiter
// Module name : MESH_IterativeArbiter
// Description : M-bit variable priority iterative arbiter including round robin priority generation.
// Notes       : Netlist was used as the wrap around logic was causing problems during simulation.  Based on Dally and
//               Towles Principles and Practices of Interconnection Networks p354
//             : Basic Tests run using MESH_IterativeArbiter_tb.sv.  Working.
// --------------------------------------------------------------------------------------------------------------------

module MESH_IterativeArbiter

#(parameter M = 5) // Number of requesters

 (input  logic clk,
  input  logic reset_n,
  
  input  logic [0:M-1] i_request,        // Active high Request vector
  
  output logic [0:M-1] o_grant);         // One-hot Grant vector
  
         logic [0:M-1] l_priority;       // One-hot Priority selection vector
         logic [0:M-1] l_carry;          // Carry-bit between arbiter slices
         logic [0:M-1] l_intermediate;   // Intermediate wire inside arbiter slice

  // Variable priority iterative arbiter slice generation.  Final slice carry loops round.
  // ------------------------------------------------------------------------------------------------------------------
  generate
    for (genvar i=0; i<M-1; i++) begin
      or  gate1  (l_intermediate[i], l_carry[i], l_priority[i]);
      and gate2  (o_grant[i], l_intermediate[i], i_request[i]);
      and gate3  (l_carry[i+1], l_intermediate[i], ~i_request[i]);
    end
    or  gate1  (l_intermediate[M-1], l_carry[M-1], l_priority[M-1]);
    and gate2  (o_grant[M-1], l_intermediate[M-1], i_request[M-1]);
    and gate3  (l_carry[0], l_intermediate[M-1], ~i_request[M-1]);   
  endgenerate
  
  // Round-Robin priority generation
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      l_priority[0] <= 1'b1;
      l_priority[1:M-1] <= 0;
    end else begin
      l_priority <= |o_grant ? {o_grant[M-1], o_grant[0:M-2]} : l_priority;
    end
  end
  
endmodule