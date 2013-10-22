// IP Block    : NEMU
// Function    : 
// Module name : NEMU_PacketSourceTrace.sv
// Description : 
// Uses        : config.sv

`include "config.sv"

module packet_source_trace(
  input logic clk,
  input logic reset_n,
  input logic [23:0] i_timestamp,
  input logic [31:0] i_rate,
  input logic [31:0] i_seed,
  input logic i_net_full,
  output packet_t o_pkt_out,
  output logic o_input_fifo_error,
  output logic [15:0] o_pkt_count,
  input logic [31:0] i_total_pkts_in, 
  output logic [15:0] o_pkt_test,
  input logic [31:0] i_test_total);
  
  parameter PORT_NO = 0;
  
  // Internal signals
  logic [7:0] l_dest /* synthesis keep */;
  logic [31:0] l_r32 /* synthesis keep */;
  logic [27:0] l_fifo_din, l_fifo_dout;
  logic l_wr_en, l_rd_en, l_empty, l_full;
  //logic [15:0] pkt_count;
  int l_ptr = 0;
  logic [23:0] traceData [0:62000];		// Stores 24-bit values 
  
  // Generate random destination  
  always_ff @(posedge clk or posedge reset_n)
		if (reset_n)
			l_dest <= 8'b1;
		else	
			l_dest <= {l_dest[7:0], l_dest[3] ^ l_dest[4] ^ l_dest[5] ^ l_dest[7]};	
			
	// Generate random number for packet generation
	always_ff @(posedge clk or posedge reset_n)
		if (reset_n)
			l_r32 <= seed;
		else	
			l_r32 <= {l_r32[30:0], (l_r32[0] ^ l_r32[1] ^ l_r32[21] ^ l_r32[31])};		

  // Read from the trace file corresponding to the correct core number
  always_comb
    begin
      case(PORT_NO)
        0  : $readmemb("nodeZero.txt", traceData);
        1  : $readmemb("nodeOne.txt", traceData);
        2  : $readmemb("nodeTwo.txt", traceData);
        3  : $readmemb("nodeThree.txt", traceData);
        4  : $readmemb("nodeFour.txt", traceData);
        5  : $readmemb("nodeFive.txt", traceData);
        6  : $readmemb("nodeSix.txt", traceData);
        7  : $readmemb("nodeSeven.txt", traceData);
        8  : $readmemb("nodeEight.txt", traceData);
        9  : $readmemb("nodeNine.txt", traceData);
        10 : $readmemb("nodeTen.txt", traceData);
        11 : $readmemb("nodeEleven.txt", traceData);
        12 : $readmemb("nodeTwelve.txt", traceData);
        13 : $readmemb("nodeThirteen.txt", traceData);
        14 : $readmemb("nodeFourteen.txt", traceData);
        15 : $readmemb("nodeFifteen.txt", traceData);
      endcase
    end

	// Trace file packet generation ------------------------------------------------
  always_ff @(posedge clk or posedge reset_n)
 	  if (reset_n) begin
	    l_wr_en	<= 0;
	  end else
    if (i_timestamp < i_rate) begin
      if (traceData[l_ptr] == i_timestamp)begin // Time of packet generation = clock 
        l_wr_en <= 1;
        l_fifo_din <= {traceData[l_ptr+1], i_timestamp};
		    l_ptr = l_ptr + 2; // Check the next time value after matching
	    end else 
	      l_wr_en <= 0;
	  end
  // -----------------------------------------------------------------------------
	 
	 // Output FIFO (store just the destination and timestamp - generate full packet structure at output)
	 `ifdef SYNTHESIS
	 
	 // Xilinx BRAM FIFO
	 
	 `else
	 
	 fifo #(512, 28, 1) input_fifo (l_fifo_din, l_wr_en, l_rd_en, fifo_dout, full, l_empty, , clk, reset_n);
	 
	 `endif
	 
	 //Comb logic at output of FIFO
	 always_comb
	 begin
      o_pkt_out.dest = fifo_dout[23+log2(`PORTS):24];
      o_pkt_out.valid = (!i_net_full) && (!l_empty);
      o_pkt_out.source = PORT_NO;
      o_pkt_out.data = fifo_dout[23:0];
      o_pkt_out.hopCount = 'b0;
      o_pkt_out.reroute = `UNPRODUCTIVE;
      //if (i_total_pkts_in > 2000 && i_test_total < 22000) // Warm-up & Drain conditions
        o_pkt_out.measure = 'b1;
      //else
      //  o_pkt_out.measure = 'b0;
     l_rd_en = (!i_net_full) && (!l_empty); 
      o_input_fifo_error = full;
   end   
   
   //Packet counter
   always_ff @(posedge clk)
      if (reset_n)
          begin
            o_pkt_count <= 0;
            o_pkt_test <= 0;
          end
      else if (o_pkt_out.valid)
          begin
            o_pkt_count <= o_pkt_count + 1;
            if (o_pkt_out.measure == 1) // Count packets passing Warm-up & Drain conditions
              o_pkt_test <= o_pkt_test + 1;
		   end
endmodule

			  
			  
			  