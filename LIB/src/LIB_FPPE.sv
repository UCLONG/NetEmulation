// --------------------------------------------------------------------------------------------------------------------
// IP Block    :  LIB.
// Sub Block   :  Fast PPE.
// Module name :  LIB_FPPE.
// Author      :  Paris Andreades.
// Description :  Fast Ripple Programmable Priority Encoder (PPE), with Carry-Look-Ahead, based on Ripple PPE slices.
// Uses        :  Arbiter_Slice, Arbiter, clg, PPE.
// Notes       :  see "Designing and Implementing a Fast Crossbar Scheduler" by P. Gupta and N. McKeown.
// --------------------------------------------------------------------------------------------------------------------
module LIB_FPPE #(parameter N = 16, parameter LAH = 4)(

  input   logic [N-1:0] i_request,
  input   logic [N-1:0] i_priority,
  
  output  logic [N-1:0] o_grant,
  output  logic         o_anyGnt);

  // Internal signals.
  logic [N-1:0] gnt_smpl;           // Output Grant of the "smpl_PE" sub-block.
  logic [N-1:0] gnt_not_round;      // Output Grant of the "ppe_not_round" sub-block.
  logic	[N-1:0] gnd;                // Priority input of the "smpl_PE" sub-block.
  logic         anyGnt_smpl;        // Output "anyGnt" of the "smpl_PE" sub-block.
  logic         anyGnt_not_round;   // Output "anyGnt" of the "ppe_not_round" sub-block.
  
  assign gnd = 0; // The priority input to the "smpl_PE" is a zero vector.
  
  generate
  if (LAH > 0) begin // With Look-Ahead.
   
		PPE #(N, LAH) inst_PPE_Not_Round (.i_request(i_request), .i_priority(i_priority), .i_carry(1'b1), .o_grant(gnt_not_round), .o_carry(anyGnt_not_round));
    PPE #(N, LAH) inst_simple_PE (.i_request(i_request), .i_priority(gnd), .i_carry(1'b0), .o_grant(gnt_smpl), .o_carry(anyGnt_smpl));
    
	end else begin     // Without Look-Ahead.
    Arbiter #(N) inst_PPE_Not_Round (.i_request(i_request), .i_priority(i_priority), .i_carry(1'b1), .o_grant(gnt_not_round), .o_carry(anyGnt_not_round));
    Arbiter #(N) inst_simple_PE (.i_request(i_request), .i_priority(gnd), .i_carry(1'b0), .o_grant(gnt_smpl), .o_carry(anyGnt_smpl));
  end
  endgenerate

  assign o_grant    = anyGnt_not_round ? gnt_not_round : gnt_smpl;  // Reduced Multiplexer Logic. "anyGnt_not_round" is
                                                                    // the select signal that chooses the sub-block
                                                                    // to take the output grant from.
                                                                    
  assign o_anyGnt   = anyGnt_smpl; // The "anyGnt" output of the "smpl_PE" sub-block provides the circuit's "anyGnt" output.
  
endmodule

// A Programmable Priority Encoder (PPE) using lookahead carry logic.
module PPE #(parameter N = 16, parameter LAH = 4)(

  input   [N-1:0] i_request,
  input   [N-1:0] i_priority,
  input           i_carry,
  
  output  [N-1:0] o_grant,
  output          o_carry);
  
  // Internal signals:
  logic   [N/LAH-1:0] l_carry;
	logic   [N/LAH-1:0] l_a;
	logic   [N/LAH-1:0] l_b;
	
	generate
    for (genvar k=0; k < (N/LAH)-1; k++) begin
        
      // Carry Look-ahead Generators.
      clg #(LAH) inst_clg (.i_request(i_request[k*LAH+LAH-1:k*LAH]), .i_priority(i_priority[k*LAH+LAH-1:k*LAH]),
                            .o_a(l_a[k]), .o_b(l_b[k]));
                
      // Small Arbiters making up the (fast) PPE.
      Arbiter #(LAH) inst_ppe_small (.i_request(i_request[k*LAH+LAH-1:k*LAH]), .i_priority(i_priority[k*LAH+LAH-1:k*LAH]),
                                      .i_carry(l_carry[k]), .o_grant(o_grant[k*LAH+LAH-1:k*LAH]), .o_carry());
      // Carry Logic
        always_comb begin
          l_carry[k+1] = ~l_a[k] | ~(l_b[k] & l_carry[k]);
        end      
		end
	endgenerate
  
  // Last small Arbiter.
	Arbiter #(LAH) inst_ppe_last (.i_request(i_request[N-1:N-LAH]), .i_priority(i_priority[N-1:N-LAH]),
                                  .i_carry(l_carry[(N/LAH)-1]), .o_grant(o_grant[N-1:N-LAH]), .o_carry(o_carry));
  
  always_comb begin
    l_carry[0] = i_carry;
  end
 
endmodule

// Carry-Look-Ahead Generator (CLA Generator)
module clg #(parameter LAH = 4)(

  input   [LAH-1:0] i_request,
  input   [LAH-1:0] i_priority,
  
  output            o_a,
  output            o_b);
   
  // Internal signals.
  logic [LAH-1:0] l_t;
  logic           l_b;
  logic           l_a;
   
  always_comb begin 
    l_b = & (~i_request);
    l_a = | l_t;
  end
      
  generate
    for (genvar k=0; k < LAH; k++) begin
      assign l_t[k] = & {!i_request[LAH-1:k], i_priority[k]};
    end
  endgenerate   
   
  assign o_a = l_a;
  assign o_b = l_b;
   
endmodule  
  
// The combinational circuit of the Ripple PPE. The output carry of the last slice IS NOT fed back as the input carry!
module Arbiter #(parameter N=4)(
  
  input  logic [N-1:0] i_request,    // Request vector input.
  input  logic [N-1:0] i_priority,   // Priority vector input.
  input  logic         i_carry,      // Carry single-bit input.
  
  output logic [N-1:0] o_grant,      // Grant vector output.
  output logic         o_carry);     // Carry single-bit output.
         
  logic        [N-1:1] l_carry;      // Internal carry vector signal to connect arbiter slices together.
  
  // First arbiter slice. Takes single-bit input carry signal.
  Arbiter_Slice #(N) inst_Arbiter_Slice_First (.i_request(i_request[0]), .i_priority(i_priority[0]), .i_carry(i_carry), .o_grant(o_grant[0]), .o_carry(l_carry[1]));
  
  // Intermediate arbiter slices.
  generate
    for (genvar k=1; k < N-1; k++) begin
      Arbiter_Slice #(N) inst_Arbiter_Slice (.i_request(i_request[k]), .i_priority(i_priority[k]), .i_carry(l_carry[k]), .o_grant(o_grant[k]), .o_carry(l_carry[k+1]));
    end
  endgenerate
  
  // Last arbiter slice. Produces single-bit output carry signal.
  Arbiter_Slice #(N) inst_Arbiter_Slice_Last (.i_request(i_request[N-1]), .i_priority(i_priority[N-1]), .i_carry(l_carry[N-1]), .o_grant(o_grant[N-1]), .o_carry(o_carry));

endmodule

// The combinational logic of the Ripple PPE slice.
module Arbiter_Slice # (parameter N=4) (

input   logic i_request, i_priority, i_carry,
output  logic o_grant, o_carry);

always_comb
// Ripple PPE slice.
begin
  o_grant = i_request & ~(i_carry & ~i_priority);
  o_carry = i_request |  (i_carry & ~i_priority);
end

endmodule