`include "config.sv"

module packet_source(
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

logic [2:0] random, middle;
  
	 // Generate random number to resolve equal port traffic decision
	 always_ff @(posedge clk or posedge rst)
		 begin
		 if (rst)
			 random <= 3'b1;
		 else	
			 random <= {random[1:0], (random[1] ^ random[2])};		
     end

	 // Generate random number to resolve equal port traffic decision
	 always_ff @(posedge clk or posedge rst)
		 begin
		 if (rst)
			 middle <= 3'b1;
		 else	
			 middle <= {middle[1:0], (middle[1] ^ middle[2])};		
     end

`ifdef UNIFORM
	// Check for packet generation - Uniform random traffic
	always_ff @(posedge clk or posedge rst)
	   if (rst) begin
	     wr_en	<= 0;
	   end else
	     if (r32<rate && timestamp > 600) begin // > 600 required to minimise random errors at start up
          wr_en <= 1;
          fifo_din <= {dest, timestamp};
	     end else 
	       wr_en <= 0;
`endif
	       
`ifdef HOTSPOT	
	// Check for packet generation - 30% Hotspot to middle cores
	always_ff @(posedge clk or posedge rst)
	  if (rst) begin
	    wr_en	<= 0;
	  end else
	    if (r32<rate && timestamp > 600) begin
	      if (random == 1 || random == 4) // No. of sequences = 2^n-1 = 2^3-1 = 7 => 2/7 ~= 30% 
        begin
          if (middle == 4 || middle == 2 || middle == 6 || middle == 7 && port_no != 9)
            begin
              wr_en <= 1;
              fifo_din <= {9, timestamp}; // Packet destination core 9
            end
          else if (port_no != 10)
            begin
              wr_en <= 1;
              fifo_din <= {10, timestamp}; // Packet destination core 10
            end
          else
            begin
              wr_en <= 1;
              fifo_din <= {9, timestamp}; // Packet destination core 9
            end  
        end
        else
          begin
            wr_en <= 1;
            fifo_din <= {dest, timestamp}; // Random destination
          end     
	    end else 
	      wr_en <= 0;

`endif

`ifdef STREAM 
	// Check for packet generation - create a stream between router 1 and 10 and random uniform traffic over the rest of the network
	always_ff @(posedge clk or posedge rst)
	   if (rst) 
	     begin
	       wr_en	<= 0;
	     end 
	   else
	     begin
	       if (port_no == 1 && timestamp > 600) // Stream between nodes 1 and 10
	         begin
	           if (r32 < `STREAMRATE*rate) // Rate can be modified in config.sv
	             begin
                 wr_en <= 1;
                 fifo_din <= {10, timestamp}; // Destination set as router 10, source 1
	             end
	           else 
	             wr_en <= 0;
	         end
	       else // Random traffic on the rest of the network
	         begin
	           if (r32<rate && timestamp > 600)
	             begin
                 wr_en <= 1;
                 fifo_din <= {dest, timestamp};
	             end
	           else 
	             wr_en <= 0;
	         end
	     end
`endif
	     
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
      `ifdef STREAM
        if (total_pkts_in > 2000 && test_total < 22000 && port_no == 1) // Warm-up & Drain conditions and only measure core 1 streaming packets
          pkt_out.measure = 'b1;
        else
          pkt_out.measure = 'b0;
      `else
        if (total_pkts_in > 2000 && test_total < 22000) // Warm-up & Drain conditions
          pkt_out.measure = 'b1;
        else
          pkt_out.measure = 'b0;
      `endif
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
