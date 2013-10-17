// IP Block    : MESH
// Function    : Allocator
// Module name : MESH_Allocator
// Description : 
// Uses        :

`include "config.sv"

module MESH_Allocator

  input  logic clk;
  input  logic reset_n;
  
  input  logic [0:4] i_stop;               // hold ports signal from downstream router
  input  logic [0:4] i_req_output   [0:4]; // each local input unit requests [c,n,e,s,w] output port using packed bits
  
  output logic [2:0] o_sel          [0:4]; // Input ports select an output port using a 3 bit packed unsigned number
  output logic       o_enable       [0:4]; // Indicate to the [c,n,e,s,w] local input unit that the data will be read
  output logic       o_valid        [0:4]; // Indicate to the [c,n,e,s,w] downstream input unit that the data should be read
  
         logic [0:4] l_req_matrix   [0:4]; // Packed requests for the [c,n,e,s,w] output
         logic [0:4] l_grant_matrix [0:4]; // Packed grants for the [c,n,e,s,w] output 
  
  // Populate request matrix.  Output port requests will not be made if the corresponding stop is asserted.
  always_comb begin
    for (int i=0; i<5; i++) begin
      for (int j=0; j<5; j++) begin
        l_req_matrix[i][j] = i_req_output[i][j] && ~ i_stop[j];
      end
    end
  end
  
  // Arbitrate the request matrix
  generate
    for (genvar i=0; i<5; i++)
      MESH_IterativeArbiter gen_IterativeArbiter (.clk,
                                                  .reset_n,
                                                  .i_request(l_req_matrix[i]),
                                                  .o_grant(l_grant_matrix[i]));
    end
  endgenerate
  
  // indicate o_enable and o_valid according to arbitration results
  always_comb begin
    for (int i=0; i<5; i++) begin
      o_valid[i]   = |{o_grant[0][i], o_grant[1][i], o_grant[2][i], o_grant[3][i], o_grant[4][i]};
      o_enable[i]  = |o_grant[i];
    end
  end
  
  // indicate selection control for crossbar
  always_comb begin
    for (int i = 0; i < 5; i++) begin
      unique casez (grantMatrix[i])
        5'b00001 : sel[i] = 100; // input 4
        5'b0001? : sel[i] = 011; // input 3
        5'b001?? : sel[i] = 010; // input 2
        5'b01??? : sel[i] = 001; // input 1
        5'b1???? : sel[i] = 000; // input 0
        default  : sel[i] = z;
      endcase
    end      
  end
  
endmodule
  
