// --------------------------------------------------------------------------------------------------------------------
// IP Block    : MESH
// Function    : SwitchControl
// Module name : MESH_SwitchControl
// Description : Simple controller for a 5 port CrossBar switch.  Flow control is valid/enable.
// Uses        : MESH_IterativeArbiter.sv
// Notes       : Untested
// --------------------------------------------------------------------------------------------------------------------

`include MESH_Config.sv

module MESH_SwitchControl

 (input  logic clk,
  input  logic reset_n,
  
  input  logic       i_en           [0:4],  // hold ports signal from downstream router
  input  logic [0:4] i_output_req   [0:4],  // each local input unit requests [c,n,e,s,w] output port using packed bits
  
  output logic [2:0] o_sel          [0:4],  // Output ports select an input port using a 3 bit packed unsigned number
  output logic [0:4] o_output_grant [0:4],  // Packed grants for the [c,n,e,s,w] output 
  
         logic [0:4] l_req_matrix   [0:4];  // Packed requests for the [c,n,e,s,w] output
  
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
  
  `ifdef VC
  
    // Virtual Channels are used, each input can request multiple outputs, need to arbitrate input and output using an
    // allocator
    // ----------------------------------------------------------------------------------------------------------------
    LIB_Allocator_InputFirst #(.N(5), .M(5))
      inst_LIB_Allocator_InputFirst (.clk,
                                     .reset_n,
                                     .i_request(l_req_matrix),
                                     .o_grant(o_output_grant));
                                     
  `endif
  
  `else
    
    // No virtual channels, each input can only request a single output, only need to arbitrate for the output port
    // ----------------------------------------------------------------------------------------------------------------
    generate
      for (genvar i=0; i<5; i++) begin
        LIB_PPE_RoundRobin #(.M(5)) gen_LIB_PPE_RoundRobin (.clk,
                                                            .reset_n,
                                                            .i_request(l_req_matrix[i]),
                                                            .o_grant(o_output_grant[i]));
      end
    endgenerate
  
  `endif
  
  // indicate selection control for crossbar
  // ------------------------------------------------------------------------------------------------------------------
  always_comb begin
    for (int i = 0; i < 5; i++) begin
      unique casez (o_output_grant[i])
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
  
