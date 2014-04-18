// --------------------------------------------------------------------------------------------------------------------
// IP Block    :  LIB.
// Sub Block   :  Fast Round-Robin Arbiter.
// Module name :  LIB_FastRoundRobin.
// Author      :  Paris Andreades.
// Description :  Fast Round-Robin Arbiter based on a Ripple Programmable Priority Encoder (PPE).
// Uses        :  LIB_FPPE.
// Notes       :  see "Designing and Implementing a Fast Crossbar Scheduler" by P. Gupta and N. McKeown.
// --------------------------------------------------------------------------------------------------------------------
module LIB_FastRoundRobin #(parameter N = 4, parameter LAH = 0) (

  input   logic         clk, reset,
  input   logic [N-1:0] i_request,
  input   logic         ce,   // External input signal (ce) determines whether the priority pointer should be
                              // updated or not. This is required for iSLIP allocation.
  
  output  logic [N-1:0] o_grant);
  
  // Internal signals.
  logic [N-1:0] l_priority;
  logic [N-1:0] l_next_priority;
  logic [N-1:0] l_grant;
  logic         l_anyGnt;
  
  // Instantiate the Fast PPE
  LIB_FPPE #(N, LAH) inst_LIB_FPPE (.i_request(i_request), .i_priority(l_priority), .o_grant(l_grant), .o_anyGnt(l_anyGnt));
  
  always_ff @(posedge clk, posedge reset)
    if (reset)
      l_priority <= 1; // Makes l_priority equal to 0001 (if l_priority is 4-bit).
    else if (ce)
      l_priority <= l_next_priority; // Updated priority vector input to Fast PPE. 
  
  assign o_grant = l_grant;
  
  // Pointer Update Algorithm based on the Round Robin Scheme.
  assign l_next_priority = l_anyGnt ? {l_grant[N-2:0], l_grant[N-1]} : l_priority;

endmodule