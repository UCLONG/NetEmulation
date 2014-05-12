`include "config.sv"

module packet_sink (
  input logic clk, 
  input logic rst, 
  input packet_t pkt_rx [0:`PORTS-1],
  input packet_t pkt_tx [0:`PORTS-1],
  input logic [31:0] timestamp,
  input logic [`PORTS-1:0] input_fifo_error, 
  input logic [`PORTS-1:0] net_full,
  input logic [`PORTS-1:0] nearly_full,
  input logic measure);
  
  logic [23:0] latency [0:`PORTS-1][0:`PORTS-1];
  logic [15:0] pkt_count_rx [0:`PORTS-1][0:`PORTS-1];
  logic [15:0] pkt_count_tx [0:`PORTS-1][0:`PORTS-1];
  logic [15:0] pkts_using_buffer [0:`PORTS-1];
  logic [`PORTS-1:0] dest_error;
  logic [31:0] total_pkts;
  logic [31:0] total_tx_pkts;
  logic [31:0] total_using_buffer;
  logic [46:0] total_latency;
  real average_latency;
  logic [16:0] full_count [`PORTS-1:0];
  logic [16:0] nearly_full_count [`PORTS-1:0];
  logic [32:0] total_full;
  logic [32:0] total_nearly_full;
  
  
  // Packet counter
  always_ff @(posedge clk) 
    if (rst) begin
	     dest_error <= 0;
	     for (int k=0;k<=`PORTS;k++) begin
	       full_count [k] <= 0;
	       nearly_full_count [k] <= 0;
	       pkts_using_buffer[k] <= 0;
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
            	   dest_error[pkt_rx[k].source] <= 1;
	       else                        // Comment out if permanent dest errors are required
	           dest_error[pkt_rx[k].source] <= 0;
    	    if(pkt_rx[k].data[32]==1)
    	       pkts_using_buffer[k] <= pkts_using_buffer[k] + 1;
	     end
	     if (pkt_tx[k].valid)
          	pkt_count_tx[k][pkt_tx[k].dest] <= pkt_count_tx[k][pkt_tx[k].dest] + 1;
     	 if (net_full[k])
     	   full_count[k] <= full_count[k] + 1;  //count full signals
  	    if(nearly_full[k])
         nearly_full_count[k] <= nearly_full_count[k] + 1;	 //count nearly full signals
   	end
	end   
end
 
 // count the total number
 always_ff @(negedge measure) begin
   total_pkts = 0;
   total_tx_pkts = 0;
   total_latency = 0;
   total_full = 0;
   total_nearly_full = 0;
   total_using_buffer = 0;
    for (int j=0;j<`PORTS;j++) begin
      total_full += full_count[j];
      total_nearly_full += nearly_full_count[j];
      total_using_buffer += pkts_using_buffer[j];
      for (int h=0;h<`PORTS;h++) begin
        total_pkts += pkt_count_rx[j][h];
	total_tx_pkts += pkt_count_tx[j][h];
        total_latency += latency[j][h];
      end
   end  
   average_latency = total_latency / total_pkts;  
 $write("rx_pkt_count = %d\n", total_pkts);
 $write("tx_pkt_count = %d\n", total_tx_pkts);
 $write("total_latency = %d\n", total_latency);
 $write("average_latency = %f\n", average_latency);
 $write("full_count = %d\n", total_full);
 $write("nearly_full_count = %d\n", total_nearly_full);
 $write("using buffer = %d\n", total_using_buffer);
 end
 

  //////////////////////////////////////////////////////////////////////
  /////////////////////////// CHIPSCOPE ////////////////////////////////
  //////////////////////////////////////////////////////////////////////
  `ifdef SYNTHESIS
  // Instantiate chipscope module for controlling packet generation rate and 
  // communicating latency information
  `endif

endmodule      
            
