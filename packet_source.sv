`include "config.sv"

module packet_source(
  input logic clk,
  input logic rst,
  input logic [29:0] timestamp,
  input logic net_full,
  output packet_t pkt_out,
  output logic input_fifo_error);
  //output logic [29:0] timeEndFinal,
  //output logic [29:0] timeStartFinal);
  //output int ptr,
  //output logic [29:0] traceData [0:933397]);
  
  parameter port_no = 0;
  
  // Internal signals
  logic [7:0] dest /* synthesis keep */;
  logic [31:0] r32 /* synthesis keep */;
  logic [39:0] fifo_din, fifo_dout;
  logic wr_en, rd_en, empty, full;
  integer seed = (port_no+1) *5;
  integer r32_seed = (port_no+1) *`SEED;
  integer r;
  int ptr = 0;
  //logic timeEnd, timeStart;
  logic [29:0] traceData [0:933397]; // allows 30 bit inputs of the 466699 entries in the trace file together with 2 address bits
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
			r32 <= 0;//(2^32)-(`SEED * (port_no+1));
			dest <= 0;
		end else begin	
			//r32 <= {r32[30:0], (r32[0] ^ r32[1] ^ r32[21] ^ r32[31])};	
			r32 <= $dist_uniform(r32_seed, 0, 2147483647);	
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
         if (port_no == `STREAM_SOURCE && timestamp > 600) // Stream between nodes 1 and 10
           begin
             if (r32 < `STREAMRATE) // Rate can be modified in config.sv
               begin
                 wr_en <= 1;
                 fifo_din <= {`STREAM_DEST, timestamp}; // Destination set as router 10, source 1
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
               wr_en <= 0;Bring pipelined speculative back into NetEmulation  
           end
       end
`endif

`ifdef TRACE

  //Danny Ly's trace generation code
  // Read from the trace file corresponding to the correct core number
  always_comb
      begin
        case(port_no)
          0  : $readmemb("nodeZero.txt", traceData);
          1  : $readmemb("nodeOne.txt", traceData);
          2  : $readmemb("nodeTwo.txt", traceData);
          3  : $readmemb("nodeThree.txt", traceData);
        endcase
      end
      
  // Trace file packet generation ------------------------------------------------
  always_ff @(posedge clk or posedge rst)
      if (rst)
        begin
          wr_en	<= 0;
        end 
      else // if (timestamp <`RATE) 
        begin
            if (traceData[ptr] == timestamp)
              begin // Time of packet generation = clock 
                wr_en <= 1;
                fifo_din <= {traceData[ptr+1], timestamp};
                ptr = ptr + 2; // Check the next time value after matching
                //timeStart <= traceData[ptr];
                //timeEnd <= traceData[ptr-2];                
              end 
            else 
              begin
                  wr_en <= 0;
                  //if (traceData[ptr-2] > timeEnd)
                  //    timeEnd <= traceData[ptr-2];
                  //if (traceData[ptr] < timeStart)
                  //    timeStart <= traceData[ptr];
              end
        end
  // -----------------------------------------------------------------------------

`endif
	 
	 
	 // Output FIFO (store just the destination and timestamp - generate full packet structure at output)
	 `ifdef SYNTHESIS
	 
	 // Xilinx BRAM FIFO
	 
	 `else
	 
	 fifo #(512, 40, 0) input_fifo (fifo_din, wr_en, rd_en, fifo_dout, full, empty, , clk, rst);
	 
	 `endif
	 
	 //always_comb
	 //begin
	 //	   for (int i=0;i<`PORTS;i++) begin
	 //	     if (timeEnd[i] > timeEndFinal)
	 //	       timeEndFinal <= timeEnd[i];
	 //	     if (timeStart[i] < timeStartFinal)
	 //	       timeStartFinal <= timeStart[i];
	 //	   end
	 //end	       
	   
	 
	 //Comb logic at output of FIFO
	 always_comb
	 begin
	    // Generate packet structure
	    if (fifo_dout[29+log2(`PORTS):30]>=port_no)
        pkt_out.dest = fifo_dout[29+log2(`PORTS):30]+1;
      else
        pkt_out.dest = fifo_dout[29+log2(`PORTS):30];
      rd_en = (!net_full) && (!empty);
      pkt_out.source = port_no;
      pkt_out.data = fifo_dout[29:0];
      pkt_out.valid = (!empty) && (!net_full); 
      
      //pkt_out.measure = 'b1;
      // Set input FIFO read enable bit
      rd_en = (!empty) && (!net_full); 

      // Set input fifo full flag
      input_fifo_error = full;
   end   
   
   // Packet Counter
//    always_ff @(posedge clk)
//         if (rst)
//             begin
//               pkt_count <= 0;
//               pkt_test <= 0;
//             end
//         else if (pkt_out.valid)
//             begin
//               pkt_count <= pkt_count + 1;
//               if (pkt_out.measure == 1) // Count packets passing Warm-up & Drain conditions
//                 pkt_test <= pkt_test + 1;
//             end         
         
endmodule	         
	     	
