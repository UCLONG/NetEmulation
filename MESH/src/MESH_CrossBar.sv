// IP Block    : MESH
// Function    : CrossBar
// Module name : MESH_CrossBar
// Description : 5x5 packet_mesh CrossBar.  

`include "config.sv"

module MESH_CrossBar

  input  logic       [2:0] i_sel  [0:4] // Input ports select an output port using a 3 bit unsigned number
  input  packet_mesh       i_data [0:4] // Data in
  output packet_mesh       o_data [0:4] // Data out

  always_comb begin

    // Output 0
    case (sel[0])
      3'b000  : o_data[0] = i_data[0];
      3'b001  : o_data[0] = i_data[1];
      3'b010  : o_data[0] = i_data[2];
      3'b011  : o_data[0] = i_data[3];
      3'b100  : o_data[0] = i_data[4];
      default : o_data[0] = z;
    endcase
  
    // Output 1
    case (sel[1])
      3'b000  : o_data[1] = i_data[0];
      3'b001  : o_data[1] = i_data[1];
      3'b010  : o_data[1] = i_data[2];
      3'b011  : o_data[1] = i_data[3];
      3'b100  : o_data[1] = i_data[4];
      default : o_data[1] = z;
    endcase

    // Output 2
    case (sel[2])
      3'b000  : o_data[2] = i_data[0];
      3'b001  : o_data[2] = i_data[1];
      3'b010  : o_data[2] = i_data[2];
      3'b011  : o_data[2] = i_data[3];
      3'b100  : o_data[2] = i_data[4];
      default : o_data[2] = z;
    endcase

    // Output 3
    case (sel[3])
      3'b000  : o_data[3] = i_data[0];
      3'b001  : o_data[3] = i_data[1];
      3'b010  : o_data[3] = i_data[2];
      3'b011  : o_data[3] = i_data[3];
      3'b100  : o_data[3] = i_data[4];
      default : o_data[3] = z;
    endcase

    // Output 4
    case (sel[4])
      3'b000  : o_data[4] = i_data[0];
      3'b001  : o_data[4] = i_data[1];
      3'b010  : o_data[4] = i_data[2];
      3'b011  : o_data[4] = i_data[3];
      3'b100  : o_data[4] = i_data[4];
      default : o_data[4] = z;
    endcase
  
  end
  
endmodule