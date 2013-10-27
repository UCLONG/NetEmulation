// IP Block    : NEMU
// Function    : 
// Module name : NEMU_PacketSink.sv
// Description : Packet_sink is attached to each port, records number of packets sent, number of pockets received, and latency
// Uses        : config.sv

`include "config.sv";

module packet_sink (
  input logic clk, 
  input logic reset_n, 
  input packet_t i_pkt_rx [0:`PORTS-1], //pockets received at the port
  input packet_t i_pkt_tx [0:`PORTS-1], //pockets sent at the port
  input logic [31:0] i_timestamp,
  input logic [`PORTS-1:0] i_fifo_error, 
  input logic [`PORTS-1:0] i_net_full,
  input logic i_measure  //enable latency measure, on negedge adds up the total number of packets - set to 1 after the warm up period
);
  
  logic [23:0] l_latency [0:`PORTS-1][0:`PORTS-1];
  logic [15:0] l_pkt_count_rx [0:`PORTS-1][0:`PORTS-1];
  logic [15:0] l_pkt_count_tx [0:`PORTS-1][0:`PORTS-1];
  logic [`PORTS-1:0] l_dest_error;
  logic [31:0] l_total_pkts;
  
  // Packet counter
  always_ff @(posedge clk) 
    if (reset_n) begin
	     l_dest_error <= 0;
	     for (int k=0;k<=`PORTS;k++) begin
	       for (int j=0;j<=`PORTS;j++) begin
      	   l_latency[k][j]  <= 0;
      	   l_pkt_count_rx[k][j]  <= 0;
 	       l_pkt_count_tx[k][j]  <= 0;
	       end
	     end
    end else begin
	for (int k=0;k<`PORTS;k++) begin
	   // Count Rx packets and i_latency
	   if (i_measure) begin
	     if (i_pkt_rx[k].valid) begin
        	l_latency[{i_pkt_rx[k].source_x,i_pkt_rx[k].source_y}][k] <= l_latency[{i_pkt_rx[k].source_x,i_pkt_rx[k].source_y}][k] + (i_timestamp - i_pkt_rx[k].data[31:0]);
        	l_pkt_count_rx[{i_pkt_rx[k].source_x,i_pkt_rx[k].source_y}][k] <= l_pkt_count_rx[{i_pkt_rx[k].source_x,i_pkt_rx[k].source_y}][k] + 1;
        	if ({i_pkt_rx[k].dest_x,i_pkt_rx[k].dest_y} != k)
            	   l_dest_error[k] <= 1;
	     end
		 //this is to count how many pockets have been sent from a node
	     if (i_pkt_tx[k].valid)
          	l_pkt_count_tx[k][{i_pkt_tx[k].dest_x,i_pkt_tx[k].dest_y}] <= l_pkt_count_tx[k][{i_pkt_tx[k].dest_x,i_pkt_tx[k].dest_y}] + 1;
   	end
	end
end
 
 always_ff @(negedge i_measure) begin
   l_total_pkts = 0;
    for (int j=0;j<`PORTS;j++) begin
      for (int h=0;h<`PORTS;h++) begin
        l_total_pkts += l_pkt_count_rx[j][h];
      end
   end
 end

 

endmodule 
            
