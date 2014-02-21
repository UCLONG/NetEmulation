// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : Network Wrap
// Module name : network
// Description : Instantiates a MESH_Network suitable for connecting to NetEmulation
// Uses        : ENoC_Network.sv
// Notes       : Need better way of fitting X_NODES and Y_NODES, currently on works for perfect square.
// --------------------------------------------------------------------------------------------------------------------

`include "ENoC_Config.sv"

module network

 (input  logic clk, rst,
  
  input  packet_t              pkt_in  [0:`NODES-1],
  
  output packet_t              pkt_out [0:`NODES-1],
  output logic    [0:`NODES-1] net_full);
  
         // local logic to unpack data  
         packet_t [0:`NODES-1] l_pkt_in;
         packet_t [0:`NODES-1] l_pkt_out;
         
         // Local logic to read/set valid packet
         logic    [0:`NODES-1] l_i_data_val;
         logic    [0:`NODES-1] l_o_data_val;
         
         // Local logic to allow the net_full signal to be populated
         logic    [0:`NODES-1] l_o_en;
			
  always_comb begin
    for(int i=0; i<`NODES; i++) begin
      l_pkt_in[i] = pkt_in[i];
      pkt_out[i] = l_pkt_out;
      l_i_data_val[i] = pkt_in[i].valid;
      net_full[i] = ~l_o_en[i];
    end
  end
  
  ENoC_Network #(.X_NODES($sqrt(`NODES)), .Y_NODES($sqrt(`NODES)))
    inst_ENoC_Network (.clk,
                       .reset_n(~rst),
                       .i_data(l_pkt_in),
                       .i_data_val(l_i_data_val),
                       .o_en(l_o_en),
                       .o_data(l_pkt_out),
                       .o_data_val(l_o_data_val),
                       .i_en('1));
endmodule