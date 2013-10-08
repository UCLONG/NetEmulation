`include "config.sv"

module packet_sink (
  input logic clk, 
  input logic rst, 
  input packet_t pkt_rx [0:`PORTS-1],
  input packet_t pkt_tx [0:`PORTS-1],
  input logic [31:0] timestamp,
  input logic [`PORTS-1:0] input_fifo_error, 
  input logic [`PORTS-1:0] net_full,
  input logic measure
);
  
  logic [23:0] latency [0:`PORTS-1][0:`PORTS-1];
  logic [15:0] pkt_count_rx [0:`PORTS-1][0:`PORTS-1];
  logic [15:0] pkt_count_tx [0:`PORTS-1][0:`PORTS-1];
  logic [`PORTS-1:0] dest_error;
  logic [31:0] total_pkts;
  
  // Packet counter
  always_ff @(posedge clk) 
    if (rst) begin
	     dest_error <= 0;
	     for (int k=0;k<=`PORTS;k++) begin
	       for (int j=0;j<=`PORTS;j++) begin
      	   latency[k][j]  <= 0;
      	   pkt_count_rx[k][j]  <= 0;
 	        pkt_count_tx[k][j]  <= 0;
	       end
	     end
    end else begin
	for (int k=0;k<`PORTS;k++) begin
	   // Count Rx packets and latency
	   if (measure) begin
	     if (pkt_rx[k].valid) begin
        	latency[pkt_rx[k].source][k] <= latency[pkt_rx[k].source][k] + (timestamp - pkt_rx[k].data[31:0]);
        	pkt_count_rx[pkt_rx[k].source][k] <= pkt_count_rx[pkt_rx[k].source][k] + 1;
        	if (pkt_rx[k].dest != k)
            	   dest_error[k] <= 1;
	     end
	     if (pkt_tx[k].valid)
          	pkt_count_tx[k][pkt_tx[k].dest] <= pkt_count_tx[k][pkt_tx[k].dest] + 1;
   	end
	end
end
 
 always_ff @(negedge measure) begin
   total_pkts = 0;
    for (int j=0;j<`PORTS;j++) begin
      for (int h=0;h<`PORTS;h++) begin
        total_pkts += pkt_count_rx[j][h];
      end
   end    
 $write("rx_pkt_count = %d\n", total_pkts);
 end
 

  //////////////////////////////////////////////////////////////////////
  /////////////////////////// CHIPSCOPE ////////////////////////////////
  //////////////////////////////////////////////////////////////////////
  `ifdef SYNTHESIS
  // Instantiate chipscope module for controlling packet generation rate and 
  // communicating latency information
  `endif

endmodule      
            
