`include "config.sv"

module packet_source_trace(
  input logic clk,
  input logic rst,
  input logic [23:0] timestamp,
  input logic [31:0] rate,
  input logic [31:0] seed,
  input logic net_full,
  output packet_t pkt_out,
  output logic input_fifo_error,
  output logic [15:0] pkt_count,
  input logic [31:0] total_pkts_in, 
  output logic [15:0] pkt_test,
  input logic [31:0] test_total);
  
  parameter port_no = 0;
  
  // Internal signals
  logic [7:0] dest /* synthesis keep */;
  logic [31:0] r32 /* synthesis keep */;
  logic [27:0] fifo_din, fifo_dout;
  logic wr_en, rd_en, empty, full;
  //logic [15:0] pkt_count;
  int ptr = 0;
  logic [23:0] traceData [0:62000];		// Stores 24-bit values 
  
  // Generate random destination  
  always_ff @(posedge clk or posedge rst)
		if (rst)
			dest <= 8'b1;
		else	
			dest <= {dest[7:0], dest[3] ^ dest[4] ^ dest[5] ^ dest[7]};	
			
	// Generate random number for packet generation
	always_ff @(posedge clk or posedge rst)
		if (rst)
			r32 <= seed;
		else	
			r32 <= {r32[30:0], (r32[0] ^ r32[1] ^ r32[21] ^ r32[31])};		

  // Read from the trace file corresponding to the correct core number
  always_comb
    begin
      case(port_no)
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
  always_ff @(posedge clk or posedge rst)
 	  if (rst) begin
	    wr_en	<= 0;
	  end else
    if (timestamp < rate) begin
      if (traceData[ptr] == timestamp)begin // Time of packet generation = clock 
        wr_en <= 1;
        fifo_din <= {traceData[ptr+1], timestamp};
		    ptr = ptr + 2; // Check the next time value after matching
	    end else 
	      wr_en <= 0;
	  end
  // -----------------------------------------------------------------------------
	 
	 // Output FIFO (store just the destination and timestamp - generate full packet structure at output)
	 `ifdef SYNTHESIS
	 
	 // Xilinx BRAM FIFO
	 
	 `else
	 
	 fifo #(512, 28, 1) input_fifo (fifo_din, wr_en, rd_en, fifo_dout, full, empty, , clk, rst);
	 
	 `endif
	 
	 //Comb logic at output of FIFO
	 always_comb
	 begin
      pkt_out.dest = fifo_dout[23+log2(`PORTS):24];
      pkt_out.valid = (!net_full) && (!empty);
      pkt_out.source = port_no;
      pkt_out.data = fifo_dout[23:0];
      pkt_out.hopCount = 'b0;
      pkt_out.reroute = `UNPRODUCTIVE;
      //if (total_pkts_in > 2000 && test_total < 22000) // Warm-up & Drain conditions
        pkt_out.measure = 'b1;
      //else
      //  pkt_out.measure = 'b0;
      rd_en = (!net_full) && (!empty); 
      input_fifo_error = full;
   end   
   
   //Packet counter
   always_ff @(posedge clk)
      if (rst)
          begin
            pkt_count <= 0;
            pkt_test <= 0;
          end
      else if (pkt_out.valid)
          begin
            pkt_count <= pkt_count + 1;
            if (pkt_out.measure == 1) // Count packets passing Warm-up & Drain conditions
              pkt_test <= pkt_test + 1;
          end
                      
endmodule	       