// --------------------------------------------------------------------------------------------------------------------
// IP Block    : MESH
// Function    : Switch
// Module name : MESH_Switch
// Description : 5x5 packet_t CrossBar Switch. 
//             : Untested.
// -------------------------------------------------------------------------------------------------------------------- 

`include "config.sv"

module MESH_Switch

#(parameter N, // Number of inputs
  parameter M) // Number of outputs

 (input  logic    [0:N-1] i_sel  [0:M-1],  // Output ports select an input port according to a 5 bit packed number
  input  packet_t         i_data [0:N-1],  // Data in
  
  output packet_t         o_data [0:M-1]); // Data out

  // Crossbar Switch.  Mux selection is onehot.  
  // ------------------------------------------------------------------------------------------------------------------
  always_comb begin
    for(int i=0; i<M; i++) begin
      o_data[i] = 'z;
    end
    for(int i=0; i<M; i++) begin
      for(int j=0; j<N; j++) begin
        if(i_sel[i] == (1<<(N-1)-j)) o_data[i] = i_data[j];
      end
    end
  end
  
/*

  DELETE ONCE OTHER CODE IS PROVED.

  // Cross Bar Switch.
  // ------------------------------------------------------------------------------------------------------------------
  always_comb begin  
  
    // Output 0
    case (i_sel[0])
      5'b00001 : o_data[0] = i_data[4];
      5'b00010 : o_data[0] = i_data[3];
      5'b00100 : o_data[0] = i_data[2];
      5'b01000 : o_data[0] = i_data[1];
      5'b10000 : o_data[0] = i_data[0];
      default : o_data[0] = 'z;
    endcase
  
    // Output 1
    case (i_sel[1])
      5'b00001 : o_data[1] = i_data[4];
      5'b00010 : o_data[1] = i_data[3];
      5'b00100 : o_data[1] = i_data[2];
      5'b01000 : o_data[1] = i_data[1];
      5'b10000 : o_data[1] = i_data[0];
      default : o_data[1] = 'z;
    endcase

    // Output 2
    case (i_sel[2])
      5'b00001 : o_data[2] = i_data[4];
      5'b00010 : o_data[2] = i_data[3];
      5'b00100 : o_data[2] = i_data[2];
      5'b01000 : o_data[2] = i_data[1];
      5'b10000 : o_data[2] = i_data[0];
      default : o_data[2] = 'z;
    endcase

    // Output 3
    case (i_sel[3])
      5'b00001 : o_data[3] = i_data[4];
      5'b00010 : o_data[3] = i_data[3];
      5'b00100 : o_data[3] = i_data[2];
      5'b01000 : o_data[3] = i_data[1];
      5'b10000 : o_data[3] = i_data[0];
      default : o_data[3] = 'z;
    endcase

    // Output 4
    case (i_sel[4])
      5'b00001 : o_data[4] = i_data[4];
      5'b00010 : o_data[4] = i_data[3];
      5'b00100 : o_data[4] = i_data[2];
      5'b01000 : o_data[4] = i_data[1];
      5'b10000 : o_data[4] = i_data[0];
      default : o_data[4] = 'z;
    endcase
  
  end

  */

endmodule