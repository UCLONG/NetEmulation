// IP Block    : NEMU
// Function    :
// Module name : NEMU_PacketSource.sv
// Description : A SystemVerilog code that produces packets of data used for testing of a NoC
// Uses        : config.sv

`include "config.sv";

module packet_source(
  input logic         clk,
  input logic         reset_n,
  input logic [31:0]  i_timestamp,
  input logic         i_net_full, //prevents generation of packets if network is full
  output packet_t     o_pkt_out, 
  output logic        i_fifo_error);
  
  parameter PORT_NO_X = 0;  //assigns a port_number which will be stored in o_pkt_out.source
  parameter PORT_NO_Y = 0;
  
  // Internal signals
  logic [7:0]         l_dest /* synthesis keep */; /*pocket destination*/
  logic [31:0]        l_r32 /* synthesis keep */;  /*random number used to determine if a pocket should be generated. Pockets generated if random number < 'RATE (set in configure.sv) */
  logic [39:0]        l_fifo_din, l_fifo_dout; 
  logic               l_wr_en, l_rd_en, l_empty, l_full; //fifo control - error reporting
  integer             l_seed = ({PORT_NO_X, PORT_NO_Y}+1) *5; /*new seed for random numbers generated each iteration - the initial seed, which is used in case of reset_n=1 is set in config.sv */
  integer             l_r; 

  

	always_ff @(posedge clk or posedge reset_n)
		if (reset_n) begin
			l_r32 <= (2^32)-(`SEED * ({PORT_NO_X, PORT_NO_Y}+1));
			l_dest <= 0;
		end else begin	
			l_r32 <= {l_r32[30:0], (l_r32[0] ^ l_r32[1] ^ l_r32[21] ^ l_r32[31])};		
			l_dest <= $dist_uniform(l_seed, 0, `PORTS-2);
		end

`ifdef UNIFORM		
	// Check for packet generation
	always_ff @(posedge clk or posedge reset_n)
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
  always_ff @(posedge clk or posedge reset_n)
    if (reset_n) begin
      l_wr_en	<= 0;
    end else
      if (l_r32<`RATE && i_timestamp > 600) begin
        if (random == 1 || random == 4) // No. of sequences = 2^n-1 = 2^3-1 = 7 => 2/7 ~= 30% 
        begin
          if (middle == 4 || middle == 2 || middle == 6 || middle == 7 && port_no != 9)
            begin
              l_wr_en <= 1;
              l_fifo_din <= {9, i_timestamp}; // Packet destination core 9
            end
          else if (PORT_NO != 10)
            begin
              wl_r_en <= 1;
              l_fifo_din <= {10, i_timestamp}; // Packet destination core 10
            end
          else
            begin
              l_wr_en <= 1;
              l_fifo_din <= {9, i_timestamp}; // Packet destination core 9
            end  
        end
        else
          begin
            l_wr_en <= 1;
            l_fifo_din <= {l_dest, i_timestamp}; // Random destination
          end     
      end else 
        l_wr_en <= 0;

`endif

`ifdef STREAM 
  // Check for packet generation - create a stream between router 1 and 10 and random uniform traffic over the rest of the network
  always_ff @(posedge clk or posedge reset_n)
     if (reset_n) 
       begin
         l_wr_en	<= 0;
       end 
     else
       begin
         if (PORT_NO == 1 && i_timestamp > 600) // Stream between nodes 1 and 10
           begin
             if (l_r32 < `STREAMRATE*`RATE) // Rate can be modified in config.sv
               begin
                 l_wr_en <= 1;
                 l_fifo_din <= {10, i_timestamp}; // Destination set as router 10, source 1
               end
             else 
               l_wr_en <= 0;
           end
         else // Random traffic on the rest of the network
           begin
             if (l_r32<`RATE && i_timestamp > 600)
               begin
                 l_wr_en <= 1;
                 l_fifo_din <= {l_dest, i_timestamp};
               end
             else 
               l_wr_en <= 0;
           end
       end
`endif

`ifdef TRACE

// Add Danny Ly's trace generation code

`endif


	 // Output FIFO (store just the destination and i_timestamp - generate full packet structure at output)
	 `ifdef SYNTHESIS

	 // Xilinx BRAM FIFO

	 `else

	 fifo #(512, 40, 0) input_fifo (l_fifo_din, l_wr_en, l_rd_en, l_fifo_dout, l_full, l_empty, , clk, rst);

	 `endif

	 //Comb logic at output of FIFO
	 always_comb
	 begin
	    // Generate packet structure
	    if (l_fifo_dout[31+log2AndRoundUp(`X_PORTS):32]>=PORT_NO_X)
        o_pkt_out.dest_x = l_fifo_dout[31+log2AndRoundUp(`X_PORTS):32]+1;
      else
        o_pkt_out.dest_x = l_fifo_dout[31+log2AndRoundUp(`X_PORTS):32];
        
      if (l_fifo_dout[31+log2AndRoundUp(`X_PORTS)+log2AndRoundUp(`Y_PORTS):32]>=PORT_NO_Y)
        o_pkt_out.dest_y = l_fifo_dout[31+log2AndRoundUp(`X_PORTS)+log2AndRoundUp(`Y_PORTS):32]+1;
      else
        o_pkt_out.dest_y = l_fifo_dout[31+log2AndRoundUp(`X_PORTS)+log2AndRoundUp(`Y_PORTS):32];
        
      l_rd_en = (!i_net_full) && (!l_empty);
      o_pkt_out.source_x = PORT_NO_X;
      o_pkt_out.source_y = PORT_NO_Y;
      o_pkt_out.data = l_fifo_dout[31:0];
      o_pkt_out.valid = (!l_empty) && (!i_net_full); 
      
      // Set input FIFO read enable bit
        l_rd_en = (!l_empty) && (!i_net_full); 

      // Set input fifo full flag
        i_fifo_error = l_full;
   end   
             
         
endmodule	       