// --------------------------------------------------------------------------------------------------------------------
// IP Block    : MESH
// Function    : SwitchControl
// Module name : MESH_SwitchControl
// Description : Simple controller for a 5 port CrossBar switch.  Flow control is valid/enable.
// Uses        : MESH_IterativeArbiter.sv
// Notes       : Untested
// --------------------------------------------------------------------------------------------------------------------

module MESH_SwitchControl

 (input  logic clk,
  input  logic reset_n,
  
  input  logic       i_en           [0:4],  // hold ports signal from downstream router
  input  logic [0:4] i_output_req   [0:4],  // each local input unit requests [c,n,e,s,w] output port using packed bits
  
  output logic [2:0] o_sel          [0:4],  // Output ports select an input port using a 3 bit packed unsigned number
  output logic       o_en           [0:4],  // Indicate to [c,n,e,s,w] local input unit that data will be read
  output logic       o_val          [0:4]); // Indicate to [c,n,e,s,w] downstream input unit that data should be read
  
         logic [0:4] l_req_matrix   [0:4];  // Packed requests for the [c,n,e,s,w] output
         logic [0:4] l_grant_matrix [0:4];  // Packed grants for the [c,n,e,s,w] output 
  
  // Populate request matrix.  Output port requests will not be made if the corresponding enable is low.
  // ------------------------------------------------------------------------------------------------------------------
  always_comb begin
    for (int i=0; i<5; i++) begin
      for (int j=0; j<5; j++) begin
        l_req_matrix[i][j] = i_output_req[j][i] && i_en[i];
      end
    end
  end
  
  // Arbitrate the request matrix
  // ------------------------------------------------------------------------------------------------------------------
  generate
    for (genvar i=0; i<5; i++) begin
      LIB_PPE_RoundRobin #(.M(5)) gen_LIB_PPE_RoundRobin (.clk,
                                                          .reset_n,
                                                          .i_request(l_req_matrix[i]),
                                                          .o_grant(l_grant_matrix[i]));
    end
  endgenerate
  
  // indicate o_enable and o_valid according to arbitration results
  // ------------------------------------------------------------------------------------------------------------------
  always_comb begin
    for (int i=0; i<5; i++) begin
      o_en[i]   = |{l_grant_matrix[0][i], 
                    l_grant_matrix[1][i], 
                    l_grant_matrix[2][i], 
                    l_grant_matrix[3][i], 
                    l_grant_matrix[4][i]};
 
      o_val[i]  = |l_grant_matrix[i];
    end
  end
  
  // indicate selection control for crossbar
  // ------------------------------------------------------------------------------------------------------------------
  always_comb begin
    for (int i = 0; i < 5; i++) begin
      unique casez (l_grant_matrix[i])
        5'b00001 : o_sel[i] = 100; // input 4
        5'b0001? : o_sel[i] = 011; // input 3
        5'b001?? : o_sel[i] = 010; // input 2
        5'b01??? : o_sel[i] = 001; // input 1
        5'b1???? : o_sel[i] = 000; // input 0
        default  : o_sel[i] = 'z;
      endcase
    end      
  end
  
endmodule
  
