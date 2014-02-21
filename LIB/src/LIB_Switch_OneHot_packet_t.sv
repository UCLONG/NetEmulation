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

 (`ifdef PIPE_LINE_ST
    input  logic clk,
    input  logic ce,
    input  logic reset_n,
  `endif
  input  logic    [0:M-1][0:N-1] i_sel,   // Output ports select an input port according to a 5 bit packed number
  input  packet_t        [0:N-1] i_data,  // Data in
  
  output packet_t        [0:M-1] o_data); // Data out
  
         packet_t        [0:M-1] l_data;  // Used for pipe lining

  // Crossbar Switch.  Input selection is onehot.  
  // ------------------------------------------------------------------------------------------------------------------
  always_comb begin
    l_data = 'z;
    for(int i=0; i<M; i++) begin
      // compare i_sel with a one hot word to determine which input is required
      for(int j=0; j<N; j++) begin
        if(i_sel[i] == (1<<(N-1)-j)) l_data[i] = i_data[j];
      end
    end
  end
  
  // Pipe line control.
  // ------------------------------------------------------------------------------------------------------------------
  `ifdef PIPE_LINE_ST
  
    always_ff@(posedge clk) begin
      if(~reset_n) begin
        o_data <= 0;
      end else begin
        if(ce) begin
          o_data <= l_data;
        end
      end
    end
  
  `else
  
    assign o_data = l_data;
  
  `endif

endmodule