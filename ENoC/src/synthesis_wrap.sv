// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : synthesis_wrap
// Module name : synthesis_wrap
// Description : Instantiates a MESH_Network keeping top level ports to a minimum for synthesis.
// Uses        : synthesis_wrap.sv
// --------------------------------------------------------------------------------------------------------------------

module synthesis_wrap

 (input  logic clk, rst,
  
  input  packet_t pkt_in,
  
  output packet_t pkt_out);
  
  ENoC_Network
    inst_ENoC_Network (.clk,
                       .reset_n(rst),
                       .i_data(pkt_in),
                       .i_data_val(1'b1),
                       .o_en(),
                       .o_data(pkt_out),
                       .o_data_val(),
                       .i_en(1'b1));
endmodule