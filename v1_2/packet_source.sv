`include "config.sv"

module packet_source(
  input logic clk,
  input logic rst,
  input logic [31:0] timestamp,
  input logic net_full,
  output packet_t pkt_out,
  output logic input_fifo_error);
  
  parameter port_no = 0;
  
  // Internal signals
  logic [7:0] dest /* synthesis keep */;
  logic [31:0] r32 /* synthesis keep */;
  logic [39:0] fifo_din, fifo_dout;
  logic wr_en, rd_en, empty, full;
  integer seed = (port_no+1) *5;
  integer r;
  //logic [15:0] pkt_count;
  
// Generate random destination using a shift regsister.  This was originally written 
// so that it could be synthesised, but it has issues, so the current version uses
// SV's test bench random generators    
/*  always_ff @(posedge clk or posedge rst)
		if (rst)
			dest <= 8'b1;
		else	
			dest <= {dest[6:0], dest[3] ^ dest[4] ^ dest[5] ^ dest[7]};	*/
			
	// Generate random numbers for packet generation
	always_ff @(posedge clk or posedge rst)
		if (rst) begin
			r32 <= (2^32)-(`SEED * (port_no+1));
			dest <= 0;
		end else begin	
			r32 <= {r32[30:0], (r32[0] ^ r32[1] ^ r32[21] ^ r32[31])};		
			dest <= $dist_uniform(seed, 0, `PORTS-2);
		end

`ifdef UNIFORM		
	// Check for packet generation
	always_ff @(posedge clk or posedge rst)
	   if (rst) begin
	     wr_en	<= 0;
	   end else
	     if (r32< `RATE) begin  // constant is 2^32, maximum vale of 32-bit shift register
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
      if (r32<`RATE && timestamp > 600) begin
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
             if (r32 < `STREAMRATE*`RATE) // Rate can be modified in config.sv
               begin
                 wr_en <= 1;
                 fifo_din <= {10, timestamp}; // Destination set as router 10, source 1
               end
             else 
               wr_en <= 0;
           end
         else // Random traffic on the rest of the network
           begin
             if (r32<`RATE && timestamp > 600)
               begin
                 wr_en <= 1;
                 fifo_din <= {dest, timestamp};
               end
             else 
               wr_en <= 0;
           end
       end
`endif

`ifdef TRACE

// Add Danny Ly's trace generation code

`endif
	 
	 
	 // Output FIFO (store just the destination and timestamp - generate full packet structure at output)
	 `ifdef SYNTHESIS
	 
	 // Xilinx BRAM FIFO
	 
	 `else
	 
	 fifo #(512, 40, 0) input_fifo (fifo_din, wr_en, rd_en, fifo_dout, full, empty, , clk, rst);
	 
	 `endif
	 
	 //Comb logic at output of FIFO
	 always_comb
	 begin
	    // Generate packet structure
	    if (fifo_dout[31+log2(`PORTS):32]>=port_no)
        pkt_out.dest = fifo_dout[31+log2(`PORTS):32]+1;
      else
        pkt_out.dest = fifo_dout[31+log2(`PORTS):32];
      rd_en = (!net_full) && (!empty);
      pkt_out.source = port_no;
      pkt_out.data = fifo_dout[31:0];
      pkt_out.valid = (!empty) && (!net_full); 
      
      // Set input FIFO read enable bit
      rd_en = (!empty) && (!net_full); 

      // Set input fifo full flag
      input_fifo_error = full;
   end   
             
         
endmodule	         
	     	
