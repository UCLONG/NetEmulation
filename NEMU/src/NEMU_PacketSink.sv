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
  output logic [15:0] o_pkt_count_tx [0:`PORTS-1][0:`PORTS-1],
  output logic [31:0] o_total_pkt_count
); 
  
  logic [`PORTS-1:0] l_dest_error;
  logic [31:0] l_total_pkts;
  logic [15:0] l_pkt_count_rx_not_measured [0:`PORTS-1][0:`PORTS-1];

  
  
  // Packet counter
  always_ff @(posedge i_clk) 
    if (reset_n) begin
	     l_dest_error <= 0;
	     for (int k=0;k<=`PORTS;k++) begin
	       for (int j=0;j<=`PORTS;j++) begin
      	   o_latency[k][j]  <= 0;
      	   o_pkt_count_rx[k][j]  <= 0;
 	         o_pkt_count_tx[k][j]  <= 0;
           l_pkt_count_rx_not_measured[k][j] <= 0;
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
      if (!i_measure) begin
        if (i_pkt_rx[k].valid)
          l_pkt_count_rx_not_measured[k][i_pkt_rx[k].dest] <= l_pkt_count_rx_not_measured[k][i_pkt_rx[k].dest] + 1;
      end
    
	end
end
 
 
 always_comb begin
    o_total_pkt_count = 0;
    for (int j=0;j<`PORTS;j++) begin
      for (int h=0;h<`PORTS;h++) begin
        o_total_pkt_count += o_pkt_count_rx[j][h] + l_pkt_count_rx_not_measured[j][h];
      end
   end      
 end
 
 
  `ifdef METRICS_ENABLE
 
 
 logic [5:0] l_batch_counter;
 logic [31:0] l_batch_number;
 logic finish;
 integer fileBatch;
 integer filePktRX;
 integer filePktTX;
 integer fileTotalLatency;
 parameter string filenameLatency ="latency.txt";
 parameter string fileNamePktRX ="pktRX.txt";
 parameter string fileNamePktTX ="pktTX.txt";
 parameter string fileNameTotalLatency = "totalLatency.txt";
 

 //Stores metrics information to .txt files, compatible with provided Matlab code
 
always_comb begin
  if (reset_n) begin
    l_batch_number = 0;
    fileBatch = $fopen(filenameLatency);
    filePktRX = $fopen(fileNamePktRX);
    filePktTX = $fopen(fileNamePktTX);
    fileTotalLatency = $fopen(fileNameTotalLatency);
  end
  
  l_batch_counter = o_total_pkt_count - l_batch_number*6'd10;
  
  if (l_batch_counter >= 6'd10) begin
    l_batch_number = l_batch_number + 1;
    $fdisplay(fileBatch, "%p", o_latency);
  end

end
`endif
`ifdef METRICS_ENABLE

 always_ff @(negedge i_measure) begin
  if(!reset_n) begin
  l_total_pkts = 0;
   $fdisplay(filePktRX, "%p", o_pkt_count_rx);
   $fdisplay(filePktTX, "%p", o_pkt_count_tx);
   $fdisplay(fileTotalLatency, "%p", o_latency);
    for (int l=0;l<`PORTS;l++) begin
      for (int m=0;m<`PORTS;m++) begin
        l_total_pkts += o_pkt_count_rx[l][m];
      end
   end    
 $write("rx_pkt_count = %d\n", l_total_pkts);
  end
 end
`endif

  //////////////////////////////////////////////////////////////////////
  /////////////////////////// CHIPSCOPE ////////////////////////////////
  //////////////////////////////////////////////////////////////////////
  `ifdef SYNTHESIS
  // Instantiate chipscope module for controlling packet generation rate and 
  // communicating latency information
  `endif

endmodule     
