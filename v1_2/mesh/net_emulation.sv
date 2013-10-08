//`include "functions.sv"
`include "config.sv"

/////////////////////////////////////////////
///////// MODULE DEF FOR SYNTHESIS //////////
/////////////////////////////////////////////
`ifdef SYNTHESIS
module net_emulation (
  input logic clkp, clkn,
  input rst,
  output logic [`PORTS-1:0] input_fifo_error,
  output logic [`PORTS-1:0] dest_error);
  
  // Internal signals specific to synthesis
  // Chipscope signals
 
/////////////////////////////////////////////
//////// MODULE DEF FOR SIMULATION ////////// 
///////////////////////////////////////////// 
`else  
module net_emulation ();
  
  // Internal signals specific to simulation
  logic rst;
  logic [`PORTS-1:0] input_fifo_error;
  logic [`PORTS-1:0] dest_error;
  
`endif
 
/////////////////////////////////////////////
//////// COMMON SIGNALS FOR SYNTH/SIM /////// 
/////////////////////////////////////////////
  logic clk;
  logic [23:0] timestamp;
  logic [31:0] rate;
  packet_mesh pkt_in [0:`PORTS-1] /* synthesis keep */;
  packet_t pkt_source_out [0:`PORTS-1] /* synthesis keep */;
  packet_t pkt_sink_in [0:`PORTS-1] /* synthesis keep */;
  packet_mesh pkt_out [0:`PORTS-1] /* synthesis keep */;
  logic [`PORTS-1:0] full /* synthesis keep */;
  logic [15:0] pkt_count_source [0:`PORTS-1] /* synthesis keep */;
  logic [15:0] pkt_count_dest [0:`PORTS-1] /* synthesis keep */;
  logic [31:0] total_pkts_in /* synthesis keep */;
  logic [31:0] total_pkts_out /* synthesis keep */;
  logic [23:0] latency [0:`PORTS-1] /* synthesis keep */;
  logic [31:0] total_latency;
     
  // These output are used only for debugging with testNetwork module
  packet_mesh networkData       [0: `PORTS-1][0:4];
  packet_mesh routerInputData   [0: `PORTS-1][0:4];
      
  logic [20:0] total_hop [0:`PORTS-1];
  logic [20:0] sum_hop;
  logic [log2(2*`MESH_WIDTH + 2*`UNPRODUCTIVE)-1:0] average_hop; // Size accommodates maximum case
  logic [15:0] error [0:`PORTS-1];
  logic [15:0] error_total;
     
  genvar i;
  int factor = 1;
  int test = 1;
  int fid;
  logic [15:0] pkt_test [0:`PORTS-1];
  logic [31:0] test_total;
  
/////////////////////////////////////////////
////////// CODE SPECIFIC TO SYNTH /////////// 
///////////////////////////////////////////// 
`ifdef SYNTHESIS  

  // Generate system clock  
	assign clk = clkp;
	
  // Set rate via chipscope
  
/////////////////////////////////////////////
/////////// CODE SPECIFIC TO SIM //////////// 
///////////////////////////////////////////// 
`else

  //Generate clock
  initial begin
    clk = 0;
    forever #2.5ns clk = ~clk;
  end
  
  // Total Packets and Average Hop Count
  always_comb
    begin
      total_pkts_in = 0;
      total_pkts_out = 0;
      sum_hop = 0;
      average_hop = 0;
      total_latency = 0;
      error_total = 0;
      test_total = 0;
      for(int k=0; k<`PORTS; k++) begin
         total_pkts_in = total_pkts_in + pkt_count_source[k];
         // Used for Warm-up & Drain Batch Average Testing
         //if (total_pkts_out + pkt_count_dest[k] >= factor*50) // Batches of 50 packets
         // begin
         //    factor = factor + 1;
         // end
         total_latency = total_latency + latency[k];
         total_pkts_out = total_pkts_out + pkt_count_dest[k];
         sum_hop = sum_hop + total_hop[k];
         error_total = error_total + error[k];
         test_total = test_total + pkt_test[k];
      end
      average_hop = sum_hop/total_pkts_out;
    end
/*
// Used for Warm up & Drain Batch Testing
always_comb
  begin
    if (test != factor)
      begin
        $fdisplay(fid, "%p", total_latency);
        test = test + 1;
      end
  end
*/
  // Generate reset
  initial begin
    //fid = $fopen("test.txt"); // Writes total latency to file for batch average testing
    rate = `LOAD; // 100% load is 4e9
    rst = 1;
    #100ns
    rst = 0;
  end
  
`endif
  
  //////////////////////////////////////////////////////////////////////
  ////////////// COMMON CODE FOR SIM AND SYNTH /////////////////////////
  //////////////////////////////////////////////////////////////////////
  
  // Instantiate pkt_sources
   generate for (i=0;i<`PORTS;i++)
      begin: source_loop
         `ifdef TRACE
           packet_source_trace #(i) pkts (clk, rst, timestamp, rate, i+1, full[i], pkt_source_out[i], input_fifo_error[i], pkt_count_source[i], total_pkts_in, pkt_test[i], test_total);
         `else
           packet_source #(i) pkts (clk, rst, timestamp, rate, i+1, full[i], pkt_source_out[i], input_fifo_error[i], pkt_count_source[i], total_pkts_in, pkt_test[i], test_total);           
         `endif
      end
   endgenerate
  
  // Instantiate pkt sinks
  generate for (i=0;i<`PORTS;i++)
    begin: dest_loop
        packet_sink #(i) sinks (clk, rst, pkt_sink_in[i], timestamp, latency[i], pkt_count_dest[i], total_hop[i], dest_error[i], error[i]);
    end
  endgenerate   
  
  // Timestamp counter
  always_ff @(posedge clk)
    if (rst)
       timestamp <= 0;
    else
        timestamp <= timestamp + 1; 
  
  // Convert packet_t into packet_mesh (numbered destination into xy location)      
  always_comb
    begin
      for (int k = 0; k < `PORTS; k++)
        begin
          pkt_in[k].data = pkt_source_out[k].data;
          pkt_in[k].source = pkt_source_out[k].source;
          pkt_in[k].valid = pkt_source_out[k].valid;
          pkt_in[k].xdest = (pkt_source_out[k].dest)%(`MESH_WIDTH);
          pkt_in[k].ydest = (pkt_source_out[k].dest)/(`MESH_WIDTH);
          pkt_in[k].hopCount = pkt_source_out[k].hopCount;
          pkt_in[k].reroute = pkt_source_out[k].reroute;
          pkt_in[k].measure = pkt_source_out[k].measure;
        end
    end
  
  // Convert packet_mesh into packet_t  
  always_comb
    begin
      for (int k = 0; k < `PORTS; k++)
        begin
          pkt_sink_in[k].data = pkt_out[k].data;
          pkt_sink_in[k].source = pkt_out[k].source;
          pkt_sink_in[k].valid = pkt_out[k].valid;
          pkt_sink_in[k].dest = (pkt_out[k].ydest*`MESH_WIDTH) + (pkt_out[k].xdest);
          pkt_sink_in[k].hopCount = pkt_out[k].hopCount;
          pkt_sink_in[k].reroute = pkt_out[k].reroute;
          pkt_sink_in[k].measure = pkt_out[k].measure;
        end
    end
  
  //////////////////////////////////////////////////////////////////////
  ////////////////////// INSTANTIATE NETWORK ///////////////////////////
  //////////////////////////////////////////////////////////////////////
  `ifdef VHDL
  
  `else
  
    // SystemVerilog network model
    base_network #(4, 4, 64, `FIFO_DEPTH) inst_net (
      pkt_out,
      full, 
      networkData, 
      routerInputData, 
      pkt_in, 
      16'b0, // Resembles packet sink fifo - should be always zero to signal free to accept packets
      rst, 
      clk);
  `endif
  
  //////////////////////////////////////////////////////////////////////
  /////////////////////////// CHIPSCOPE ////////////////////////////////
  //////////////////////////////////////////////////////////////////////
  `ifdef SYNTHESIS
  // Instantiate chipscope module for controlling packet generation rate and 
  // communicating latency information
  `endif
  
endmodule
	    
	 