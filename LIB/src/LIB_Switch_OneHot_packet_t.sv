// --------------------------------------------------------------------------------------------------------------------
// IP Block    : LIB
// Sub Block   : Switch
// Function    : OneHot_packet_t
// Module name : LIB_Switch_OneHot_packet_t
// Description : NxM packet_t CrossBar Switch. 
// -------------------------------------------------------------------------------------------------------------------- 

module LIB_Switch_OneHot_packet_t

#(parameter N, // Number of inputs
  parameter M) // Number of outputs

 (input  logic    [0:M-1][0:N-1] i_sel,   // Output ports select an input port according to a 5 bit packed number
  input  packet_t        [0:N-1] i_data,  // Data in
  
  output packet_t        [0:M-1] o_data); // Data out

  // Crossbar Switch.  Mux selection is onehot.  
  // ------------------------------------------------------------------------------------------------------------------
  always_comb begin
    o_data = 'z;
    for(int i=0; i<M; i++) begin
      for(int j=0; j<N; j++) begin
        if(i_sel[i] == (1<<(N-1)-j)) o_data[i] = i_data[j];
      end
    end
  end

endmodule