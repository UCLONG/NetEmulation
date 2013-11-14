// --------------------------------------------------------------------------------------------------------------------
// IP Block    : LIB
// Sub Block   : Switch
// Function    : OneHot_packet_t
// Module name : LIB_Switch_OneHot_packet_t
// Description : NxM packet_t CrossBar Switch. 
// -------------------------------------------------------------------------------------------------------------------- 

`include "config.sv"

module LIB_Switch

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

endmodule