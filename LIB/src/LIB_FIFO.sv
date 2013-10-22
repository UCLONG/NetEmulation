// --------------------------------------------------------------------------------------------------------------------
// IP Block    : LIB
// Function    : FIFO
// Module name : LIB_FIFO
// Description : Synchronous FIFO created using memory array.  Each location in memory has an associated pointer store
//             : for both the read and write and write pointer.  The pointers are each a single bit which rotate
//             : around the different pointer stores according to read and write requests.
// Notes       : FIFO can be any size and depth.
// --------------------------------------------------------------------------------------------------------------------

module LIB_FIFO

#(parameter WIDTH = 8,
  parameter DEPTH = 4)

 (input  logic clk, reset_n,
  
  input  logic [WIDTH-1:0] i_data,            // Packed input data to be stored into the FIFO
  input  logic             i_data_val,        // Validates the data on i_data.  If high, i_data will be sampled.
  input  logic             i_en,              // Inputs an enable, if high on a clock edge, o_data was read from memory
  
  output logic [WIDTH-1:0] o_data,            // Packed output data to be sent from the FIFO
  output logic             o_data_val,        // Validates the data on o_data, held high until input enable received
  output logic             o_en,              // Outputs an enable, if high, i_data is written to memory
  
  output logic             o_full, o_empty);  // Control Flags
  
  typedef struct{logic rd_ptr, wr_ptr;} ptr;
  
         ptr               l_mem_ptr       [DEPTH-1:0];
         logic [WIDTH-1:0] l_mem           [DEPTH-1:0];

    
  always_ff@(posedge clk) begin
    
    if(~reset_n) begin
      for(int i=0; i<DEPTH; i++) begin
        l_mem[i]              <= 0;
      end
      l_mem_ptr[0].rd_ptr     <= 1;
      l_mem_ptr[0].wr_ptr     <= 1;     
      for(int i=1; i<DEPTH; i++) begin
        l_mem_ptr[i].rd_ptr   <= 0;
        l_mem_ptr[i].wr_ptr   <= 0;
      end
      o_data                  <= 0;
      o_data_val              <= 0;
      o_full                  <= 0;
      o_empty                 <= 1;
      o_en                    <= 1;          
    end
 
    else begin
      
      // Memory Write
      // --------------------------------------------------------------------------------------------------------------
      if(i_data_val && (~o_full || i_en)) begin
        // Write Data to memory location indicated by the write pointer
        for(int i=0; i<DEPTH; i++) begin
          l_mem[i] <= l_mem_ptr[i].wr_ptr ? i_data : l_mem[i];
        end
        // Increment the write pointer to the next memory location
        for(int i=0; i<DEPTH-1; i++) begin
          l_mem_ptr[i+1].wr_ptr <= l_mem_ptr[i].wr_ptr;
        end
        l_mem_ptr[0].wr_ptr <= l_mem_ptr[DEPTH-1].wr_ptr;
      end
     
      // Output Write
      // --------------------------------------------------------------------------------------------------------------
      if(i_en && ~o_empty) begin       
        // Data was read from memory.  Load next data into output.
        for(int i=0; i<DEPTH; i++) begin
          if (l_mem_ptr[i].rd_ptr) begin
            if(i<DEPTH-1) begin
              o_data <= l_mem[i+1];
            end else begin
              o_data <= l_mem[0];
            end
          end
        end
        // Increment Read Pointer.
        for(int i=0; i<DEPTH-1; i++) begin
          l_mem_ptr[i+1].rd_ptr <= l_mem_ptr[i].rd_ptr;
        end
        l_mem_ptr[0].rd_ptr <= l_mem_ptr[DEPTH-1].rd_ptr;
      end else if(o_empty && i_data_val) begin
        // Data was written into empty memory, output should be updated instantly.
        o_data <= i_data;
      end else begin
        // Data was not read from memory.  Keep output data the same.
        for(int i=0; i<DEPTH; i++) begin
          if(l_mem_ptr[i].rd_ptr) o_data <= l_mem[i];
        end
      end

      // Full Flag and Output Enable.  Note, enable is NOT simply the inverse of full.  The FIFO can still accept data
      // when full, provided data will be read in the same cycle.
      // --------------------------------------------------------------------------------------------------------------
      if (~o_full) begin
        if(i_data_val && ~i_en) begin
          for(int i=0; i<DEPTH; i++) begin
            if(l_mem_ptr[i].wr_ptr) begin
              o_full <= (i<DEPTH-1) ? l_mem_ptr[i+1].rd_ptr : l_mem_ptr[0].rd_ptr;
            end
          end
        end      
      end else if (o_full) begin
        o_full <= (~i_data_val && i_en) ? 0 : 1;       
      end
      
      assign o_en = (~o_full || i_en);
    
      // Empty Flag and Output Valid.  Note, valid is simply the inverse of empty.
      // --------------------------------------------------------------------------------------------------------------
      if (~o_empty) begin
        if(~i_data_val && i_en) begin
          for(int i=0; i<DEPTH; i++) begin
            if(l_mem_ptr[i].rd_ptr) begin
              o_empty <= (i<DEPTH-1) ? l_mem_ptr[i+1].wr_ptr : l_mem_ptr[0].wr_ptr;
            end
          end
        end      
      end else if (o_empty) begin
        o_empty <= (i_data_val) ? 0 : 1;       
      end 
      
      assign o_data_val = ~o_empty;
      
    end 
  end 
endmodule