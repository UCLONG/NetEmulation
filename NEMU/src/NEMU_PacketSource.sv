// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : PacketSource
// Module name : NEMU_PacketSource
// Description : PacketSource is instantiated at each core. Creates packets send through the network (packet structure
//             : define in config.sv). Able to create uniform, hotspot and stream traffic patterns.
// Uses        : config.sv, LIB_FIFO, NEMU_RandomNoGen
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------

`include "config.sv"

module NEMU_PacketSource(
  input logic i_clk,
  input logic reset_n,
  input logic [31:0] i_timestamp,
  input logic i_net_full,
  output packet_t o_pkt_out,
  output logic o_input_fifo_error);
  
  parameter PORT_NO = 0;
  
  // Internal signals
  logic [7:0] l_dest /* synthesis keep */;
  logic [`PORT_BITS-1:0] l_destRand;
  logic [31:0] l_r32 /* synthesis keep */;
  logic [39:0] l_fifo_din, l_fifo_dout;
  logic l_wr_en, l_rd_en, l_empty, l_full;
  integer SEED = (PORT_NO+1) *5;
  integer R;
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
  
  NEMU_RandomNoGen random(i_clk, reset_n, l_destRand);
  
	always_ff @(posedge i_clk or posedge reset_n)
		if (reset_n) begin
			l_r32 <= (2^32)-(`SEED * (PORT_NO+1));
			l_dest <= 0;
		end else begin	
			l_r32 <= {l_r32[30:0], (l_r32[0] ^ l_r32[1] ^ l_r32[21] ^ l_r32[31])};		
		  //l_dest <= $dist_uniform(SEED, 0, `PORTS-2);
      l_dest <= l_destRand;
		end

`ifdef UNIFORM		
	// Check for packet generation
	always_ff @(posedge i_clk or posedge reset_n)
	   if (reset_n) begin
	     l_wr_en	<= 0;
	   end else
	     if (l_r32< `RATE) begin  // constant is 2^32, maximum vale of 32-bit shift register
          l_wr_en <= 1;
          l_fifo_din <= {l_dest, i_timestamp};
	     end else 
	       l_wr_en <= 0;
`endif	 

`ifdef HOTSPOT	
  // Check for packet generation - 30% Hotspot to middle cores
  always_ff @(posedge l_clk or posedge reset_n)
    if (reset_n) begin
      l_wr_en	<= 0;
    end else
      if (l_r32<`RATE && l_timestamp > 600) begin
        if (random == 1 || random == 4) // No. of sequences = 2^n-1 = 2^3-1 = 7 => 2/7 ~= 30% 
        begin
          if (middle == 4 || middle == 2 || middle == 6 || middle == 7 && port_no != 9)
            begin
              l_wr_en <= 1;
              l_fifo_din <= {9, l_timestamp}; // Packet destination core 9
            end
          else if (PORT_NO != 10)
            begin
              l_wr_en <= 1;
              l_fifo_din <= {10, l_timestamp}; // Packet destination core 10
            end
          else
            begin
              l_wr_en <= 1;
              l_fifo_din <= {9, l_timestamp}; // Packet destination core 9
            end  
        end
        else
          begin
            l_wr_en <= 1;
            l_fifo_din <= {l_dest, l_timestamp}; // Random destination
          end     
      end else 
        l_wr_en <= 0;

`endif

`ifdef STREAM 
  // Check for packet generation - create a stream between router 1 and 10 and random uniform traffic over the rest of the network
  always_ff @(posedge l_clk or posedge reset_n)
     if (reset_n) 
       begin
         l_wr_en	<= 0;
       end 
     else
       begin
         if (PORT_NO == 1 && l_timestamp > 600) // Stream between nodes 1 and 10
           begin
             if (l_r32 < `STREAMRATE*`RATE) // Rate can be modified in config.sv
               begin
                 l_wr_en <= 1;
                 l_fifo_din <= {10, l_timestamp}; // Destination set as router 10, source 1
               end
             else 
               l_wr_en <= 0;
           end
         else // Random traffic on the rest of the network
           begin
             if (l_r32<`RATE && l_timestamp > 600)
               begin
                 l_wr_en <= 1;
                 l_fifo_din <= {l_dest, l_timestamp};
               end
             else 
               l_wr_en <= 0;
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
	 
	 fifo #(512, 40, 0) input_fifo (l_fifo_din, l_wr_en, l_rd_en, l_fifo_dout, l_full, l_empty, ,i_clk, reset_n);
	 
	 `endif
	 
	 //Comb logic at output of FIFO
	 always_comb
	 begin
	    // Generate packet structure
	    if (l_fifo_dout[31+log2(`PORTS):32]>=PORT_NO)
        o_pkt_out.dest = l_fifo_dout[31+log2(`PORTS):32]+1;
      else
      o_pkt_out.dest = l_fifo_dout[31+log2(`PORTS):32];
      l_rd_en = (!i_net_full) && (!l_empty);
      o_pkt_out.source = PORT_NO;
      o_pkt_out.data = l_fifo_dout[31:0];
      o_pkt_out.valid = (!l_empty) && (!i_net_full); 
      
      // Set input FIFO read enable bit
      l_rd_en = (!l_empty) && (!i_net_full); 

      // Set input fifo full flag
      o_input_fifo_error = l_full;
   end   
             
         
endmodule	         
	     	
