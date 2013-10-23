// --------------------------------------------------------------------------------------------------------------------
// IP Block    : MESH
// Function    : IterativeArbiter_tb
// Module name : MESH_IterativeArbiter_tb
// Uses        : MESH_IterativeArbiter.sv
// Description : Test bench for an M-bit variable priority iterative arbiter including round robin priority generation.
// --------------------------------------------------------------------------------------------------------------------

module MESH_IterativeArbiter_tb;

  logic clk;
  logic reset_n;
  
  rand logic [0:4] i_request;        // Active high Request vector
  
       logic [0:4] o_grant;          // One-hot Grant vector

  // DUT
  // ------------------------------------------------------------------------------------------------------------------       
  MESH_IterativeArbiter #(.M(5)) INST_MESH_IterativeArbiter (.*);
  
  // Clock Generation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    clk = 0;
    forever #100ps clk = ~clk;
  end

  // Reset Simulation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    reset_n = 0;
    #150ps
    reset_n = 1;
  end

  // Random Input Request Generation.
  // ------------------------------------------------------------------------------------------------------------------  
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      i_request <= 0;
    end else begin
      i_request <= $dist_uniform(i_request, 0, 32);
    end
  end

endmodule