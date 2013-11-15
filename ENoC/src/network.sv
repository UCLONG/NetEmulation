// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : Network Wrap
// Module name : network
// Description : Instantiates a MESH_Network suitable for connecting to NetEmulation
// Uses        : ENoC_Network.sv
// Notes       : Need better way of fitting X_NODES and Y_NODES, currently on works for perfect square.
// --------------------------------------------------------------------------------------------------------------------

module network

 (input  logic clk, rst,
  
  input  packet_t pkt_in       [0:`PORTS],
  
  output packet_t pkt_out      [0:`PORTS],
  output logic    net_full     [0:`PORTS]);
  
         logic    l_i_data_val [0:`PORTS];
  
  always_comb begin
    for(int i=0; i<`PORTS; i++) begin
      l_i_data_val = pkt_in.valid;
      l_o_data_val = pkt_out.valid;
    end
  end
  
  ENoC_Network #(.X_NODES($sqrt(`PORTS)), Y_NODES($sqrt(`PORTS)))
    inst_ENoC_Network (.clk,
                       .reset_n(~rst),
                       .i_data(pkt_in),
                       .i_data_val(l_i_data_val),
                       .o_en(),
                       .o_data(pkt_out),
                       .o_data_val(l_o_data_val),
                       .i_en(1'b1));
endmodule