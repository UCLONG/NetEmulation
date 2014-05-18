// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : Network Wrap
// Module name : network
// Description : Instantiates a MESH_Network suitable for connecting to NetEmulation
// Uses        : ENoC_Network.sv
// Notes       : Need better way of fitting X_NODES and Y_NODES, currently on works for perfect square.
// --------------------------------------------------------------------------------------------------------------------

`include "config.sv"

module network

  // Standard Port List for NetEmulation
  
 (input  logic clk, rst,
  
  input  packet_t              pkt_in   [0:`PORTS-1],
  
  output packet_t              pkt_out  [0:`PORTS-1],
  output logic    [0:`PORTS-1] net_full,
  output logic    [0:`PORTS-1] nearly_full  );
  
         // NetEmulation packs all data, ENoC doesn't.  Unpacked and packed ports can not be connected.  The following 
         // local logic is used to pack and unpack data as required to interface between NetEmulation and ENoC ports.
         packet_t [0:`PORTS-1] l_pkt_in;
         packet_t [0:`PORTS-1] l_pkt_out;
         
         // NetEmulation sends the valid with the packet, ENoC has separate data/flow control.  The following Local 
         // logic is used to connect the valid as required to interface between NetEmulation and ENoC.
         logic    [0:`PORTS-1] l_i_data_val;
         logic    [0:`PORTS-1] l_o_data_val;
         
         // NetEmulation requires a logic high when the network is full, ENoC uses a valid/enable protocol that sets
         // the enable as high when it will receive data.  Thus, the enable needs to be inverted.  Further, when
         // using Virtual Output Queues, ENoC requires the nodes to first check if an enable exists before asserting a
         // valid.  This is because, due to the nature of the VOQ, the output enable will be low if only one of the
         // virtual channels is full.  If the channel that would receive the packet is not full, and the TX valid is
         // high it will accept the packet, but the TX side will believe it has not been sent as the output enable is 
	       // low. The following local logic is used to ensure this and allows the net_full signal to be inverted.
         logic    [0:`PORTS-1] l_o_en;
  
  // Perform connections as described above.
  always_comb begin
    for(int i=0; i<`PORTS; i++) begin
      l_pkt_in[i]     = pkt_in[i];
      pkt_out[i]      = l_pkt_out[i];
      net_full[i]     = ~l_o_en[i];
      net_full[i]     = 0; // Not used by ENoC, but could be easily added if required (FIFOs provide required signal)
      l_i_data_val[i] = pkt_in[i].valid && l_o_en[i];
    end
  end
  
  // Instantiate the network.  NetEmulation currently only provides `PORTS.  The obvious is to choose an integer square
  ENoC_Network #(.X_NODES($sqrt(`PORTS)), .Y_NODES($sqrt(`PORTS)), .Z_NODES(1), .N(5), .M(5), .INPUT_QUEUE_DEPTH(4))
    inst_ENoC_Network (.clk,
                       .reset_n(~rst),
                       .i_data(l_pkt_in),
                       .i_data_val(l_i_data_val),
                       .o_en(l_o_en),
                       .o_data(l_pkt_out),
                       .o_data_val(l_o_data_val),
                       .i_en('1)); // NetEmulation will always be able to receive the packet.
endmodule