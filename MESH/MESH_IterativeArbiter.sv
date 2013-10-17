// IP Block    : MESH
// Function    : Allocator
// Module name : MESH_IterativeArbiter
// Description : 5 bit variable priority iterative arbiter.
// Notes       : Netlist was used as the wrap around logic was causing problems during simulation
//               Based on Dally and Towles Principles and Practices of Interconnection Networks p354

`include "config.sv"

module MESH_IterativeArbiter

  input  logic clk;
  input  logic reset_n;
  
  input  logic [0:4] i_request;
  
  output logic [0:4] o_grant;
  
         logic [0:4] l_priority;
         logic [0:4] l_carry;
         logic [0:4] l_intermediate;

  // Variable priority iterative arbiter slice generation.  Final slice loops carry round.
  generate
    for (genvar i=0; i<4; i++) begin
      or  gate1  (l_intermediate[i], l_carry[i], l_priority[i]);
      and gate2  (o_grant[i], l_intermediate[i], i_request[i]);
      and gate3  (l_carry[i+1], l_intermediate[i], ~i_request[i]);
    end
    or  gate1  (l_intermediate[5], l_carry[5], l_priority[5]);
    and gate2  (o_grant[5], l_intermediate[5], i_request[5]);
    and gate3  (l_carry[0], l_intermediate[5], ~i_request[5]);   
  endgenerate
  
  // Round-Robin priority generation
  always_ff@(posedge clk) begin
    if(~reset_n)
      l_priority <= 5'b10000
    else begin
      l_priority <= |o_grant ? {o_grant[4], o_grant[0:3]} : l_priority;
    end
  end