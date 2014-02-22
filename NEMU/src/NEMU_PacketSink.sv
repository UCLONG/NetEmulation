// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : PacketSink
// Module name : NEMU_PacketSink
// Description : PacketSink is instantiated at each network node. It receives arriving packets, reads data carried in
//             : packets (timestamp) to determine their latency and counts the number of sent and received packets
//             : at each core.
// Uses        : config.sv
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------



`include "config.sv"

module NEMU_PacketSink (
  input logic i_clk, 
  input logic reset_n, 
  input packet_t i_pkt_rx [0:`PORTS-1],
  input packet_t i_pkt_tx [0:`PORTS-1],
  input logic [31:0] i_timestamp,
  input logic [`PORTS-1:0] i_input_fifo_error, 
  input logic [`PORTS-1:0] i_net_full,
  input logic i_measure,
  output logic [23:0] o_latency [0:`PORTS-1][0:`PORTS-1],
  output logic [15:0] o_pkt_count_rx [0:`PORTS-1][0:`PORTS-1],
  output logic [15:0] o_pkt_count_tx [0:`PORTS-1][0:`PORTS-1] 
); 
  
  logic [`PORTS-1:0] l_dest_error;
  logic [31:0] l_total_pkts;
  
  // Packet counter
  always_ff @(posedge i_clk) 
    if (reset_n) begin
	     l_dest_error <= 0;
	     for (int k=0;k<=`PORTS;k++) begin
	       for (int j=0;j<=`PORTS;j++) begin
      	   o_latency[k][j]  <= 0;
      	   o_pkt_count_rx[k][j]  <= 0;
 	        o_pkt_count_tx[k][j]  <= 0;
	       end
	     end
    end else begin
	for (int k=0;k<`PORTS;k++) begin
	   // Count Rx packets and latency
	   if (i_measure) begin
	     if (i_pkt_rx[k].valid) begin
        	o_latency[i_pkt_rx[k].source][k] <= o_latency[i_pkt_rx[k].source][k] + (i_timestamp - i_pkt_rx[k].data[31:0]);
        	o_pkt_count_rx[i_pkt_rx[k].source][k] <= o_pkt_count_rx[i_pkt_rx[k].source][k] + 1;
        	if (i_pkt_rx[k].dest != k)
            	   l_dest_error[k] <= 1;
	     end
	     if (i_pkt_tx[k].valid)
          	o_pkt_count_tx[k][i_pkt_tx[k].dest] <= o_pkt_count_tx[k][i_pkt_tx[k].dest] + 1;
   	end
	end
end
 
/*Simulation only
 
 always_ff @(negedge i_measure) begin
   l_total_pkts = 0;
    for (int j=0;j<`PORTS;j++) begin
      for (int h=0;h<`PORTS;h++) begin
        l_total_pkts += o_pkt_count_rx[j][h];
      end
   end    
 $write("rx_pkt_count = %d\n", l_total_pkts);
 end
 
*/
  //////////////////////////////////////////////////////////////////////
  /////////////////////////// CHIPSCOPE ////////////////////////////////
  //////////////////////////////////////////////////////////////////////
  `ifdef SYNTHESIS
  // Instantiate chipscope module for controlling packet generation rate and 
  // communicating latency information
  `endif

endmodule      
            
