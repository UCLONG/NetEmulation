module inputUnit

// ------------------------------------------------------------------------------------------------------------------------ 
// The X,Y location of the input unit, the number of X and Y nodes and the width and the depth of the FIFO are paramatised.  
// The input unit has two modes, mode 0 when used for a 2D Mesh and mode 1 when used for a 2D Tori and is used to
// ensure the correct routing method is used.
// ------------------------------------------------------------------------------------------------------------------------
 
  #(parameter xLocation = 0,
    parameter yLocation = 0,
    parameter X_NODES = 3,
    parameter Y_NODES = 3,
    parameter FIFO_WIDTH = 64,
    parameter FIFO_DEPTH = 4,
    parameter MODE = 0)


// ------------------------------------------------------------------------------------------------------------------------
//   I/O   Type     Packed Size        Name             Unpacked Size                            Description
// ------------------------------------------------------------------------------------------------------------------------
   
   (output logic  [FIFO_WIDTH-1:0] bufferDataOut,                           // - Data that has been read from the buffer
    output logic             [4:0] outputPortRequest,                       // - Requests for the first flit in memory
    output logic                   holdPortOut,                             // - Signals when the buffer is full
     
     input logic  [FIFO_WIDTH-1:0] bufferDataIn,                            // - Data at the input port to be written to mem
     input logic                   read, write, portHold,
     input logic                   reset, clk);
     
           logic  [FIFO_WIDTH-1:0] FIFO                 [0:FIFO_DEPTH-1];   // - Memory array of 'MEM_DEPTH', 'MEM_WIDTH' 
                                                                            // bit words.                                                                           
           logic             [4:0] xDestination;                            // - X and Y destination of the flit stored at 
           logic             [4:0] yDestination;                            // the front of the buffer.
     
  
// ------------------------------------------------------------------------------------------------------------------------
// Function to calculate an approximation of log2(n).  The result provides the amount of bits necessary to reproduce an
// integer as an unsigned binary.
// ------------------------------------------------------------------------------------------------------------------------
  
function int log2
  (input int n);
    begin
      log2 = 0;     // log2 is zero to start
      n--;          // decrement 'n'
      while (n > 0) // While n is greater than 0
        begin
          log2++;   // Increment 'log2'
          n >>= 1;  // Bitwise shift 'n' to the right by one position
        end
    end
endfunction


// ------------------------------------------------------------------------------------------------------------------------  
// Control Flags (read_ptr, write_ptr, nearly, full, empty).  The read and write pointers are calculated using a binary 
// representation for each cell.  Each pointer has one more significant bit than required.  This enables comparison to 
// check if the FIFO is full or empty. If the write and read pointers including their MSB are equal, the FIFO is empty.
// This same calculation is used to calculate if nearly full by the nearly pointer being one ahead of the write pointer
// ------------------------------------------------------------------------------------------------------------------------
  
logic [log2(FIFO_DEPTH):0] read_ptr, write_ptr, nearly_ptr;           // Note the inclusion of an extra significant bit.
  
assign nearly_ptr = write_ptr+1;
assign nearly  = ((((nearly_ptr[log2(FIFO_DEPTH)-1:0])) == read_ptr[log2(FIFO_DEPTH)-1:0]) 
                      && (nearly_ptr[log2(FIFO_DEPTH)]) ^ read_ptr[log2(FIFO_DEPTH)]);  
assign full  = ((((write_ptr[log2(FIFO_DEPTH)-1:0])) == read_ptr[log2(FIFO_DEPTH)-1:0]) 
                      && (write_ptr[log2(FIFO_DEPTH)]) ^ read_ptr[log2(FIFO_DEPTH)]);
assign empty = (write_ptr == read_ptr) || (FIFO[read_ptr[log2(FIFO_DEPTH)-1:0]][FIFO_WIDTH-1] == 0);
assign holdPortOut = (nearly || full);


// ------------------------------------------------------------------------------------------------------------------------  
// Memory Read and Write on the rising edge of the clock, with write acknowledgement commented out as not used.
// ------------------------------------------------------------------------------------------------------------------------
  
  always_ff @ (posedge clk)
    begin
 
      if (read && ~empty)                                       // If the read signal is asserted and the FIFO is not empty
        begin
        bufferDataOut <= FIFO[read_ptr[log2(FIFO_DEPTH)-1:0]];  // dataOut will be read from the memory
        // dataValid <= 1'b1;                                   // data on dataOut is valid
        read_ptr++;                                             // The read_ptr is incremented, truncating if to big.
        end
      // else
        // dataValid <= 1'b0;                                   // The read data is not valid 
      if (write && ~full)                                       // If the write signal is asserted and the FIFO is not full
        begin                             
        FIFO[write_ptr[log2(FIFO_DEPTH)-1:0]] <= bufferDataIn;  // dataIn will be written to memory
      //  write_ack <= 1'b1;                                    // A write acknowledgement signal will be asserted
        write_ptr <= write_ptr+1;                               // The write pointer is incremented, truncating if to big.
        end
      // else                                                   // Otherwise
      //  write_ack <= 1'b0;                                    // The write is not acknowledged
    end
    
// ------------------------------------------------------------------------------------------------------------------------    
// Route calculation of first bit in memory queue.  This Assuming each flit has its destination encoded into the 6 most 
// significant bits in the form of the binary x location and y location of a 2D mesh.  The bottom left node denoted
// as 000000.  This could be improved by using gray code for the node reference and including flit types.  Also, it could 
// be possible to use a generate case so that input units in the corners and edges of the mesh do not have all the 
// calculations as they have less possible directions.
// The form of routing is dimension ordered, the calculation takes place by first checking if there is data in the fifo.  
// If there is then the calculation reads the x and y destination contained in the flit header and compares this with the 
// current x and y location issuing port requests in the x direction until matched, then the y direction.  The one-hot 
// request is represented using 5 bits {Local, West, South, East, North}.  When no data is in the FIFO, no request is made.
// ------------------------------------------------------------------------------------------------------------------------
    
assign xDestination = FIFO[read_ptr[log2(FIFO_DEPTH)-1:0]][FIFO_WIDTH-2:FIFO_WIDTH-6];
assign yDestination = FIFO[read_ptr[log2(FIFO_DEPTH)-1:0]][FIFO_WIDTH-7:FIFO_WIDTH-11];
    
always_comb
  begin
        
  // Mode 0 XY routing for 2D Mesh
        
    if (~empty && (MODE==0))
      begin
        if (xDestination != xLocation)
          outputPortRequest <= (xDestination > xLocation) ? 5'b00010 : 5'b01000;
        else if (yDestination != yLocation)
          outputPortRequest <= (yDestination > yLocation) ? 5'b00001 : 5'b00100;
        else 
          outputPortRequest <= 5'b10000;
      end
          
        
  // Mode 1 XY routing for 2D Tori

    else if (~empty && (MODE == 1))
      begin
        if (xDestination != xLocation)
          begin
            if (xDestination < xLocation)
              outputPortRequest <= ((xLocation - xDestination) < ((X_NODES-xLocation)+(xDestination))) ? 5'b01000 : 5'b00010;
            if (xDestination > xLocation)
              outputPortRequest <= ((xDestination - xLocation) < ((X_NODES-xDestination)+(xLocation))) ? 5'b00010 : 5'b01000;
          end
        else if (yDestination != yLocation)
          begin
            if (yDestination < yLocation)
              outputPortRequest <= ((yLocation - yDestination) < ((Y_NODES-yLocation)+(yDestination))) ? 5'b00100 : 5'b00001;
            if (yDestination > yLocation)
              outputPortRequest <= ((yDestination - yLocation) < ((Y_NODES-yDestination)+(yLocation))) ? 5'b00001 : 5'b00100;
          end                 
        else outputPortRequest <= 5'b10000;
      end
          
        
  // When empty no port is requested
        
    else outputPortRequest <= 5'b00000;     
  end
  
  
// ------------------------------------------------------------------------------------------------------------------------
// Reset everything.
// ------------------------------------------------------------------------------------------------------------------------

always_ff@(posedge clk)
  begin
    if (reset)
      begin
        write_ptr <= 'b0;
        read_ptr <= 'b0;
        bufferDataOut <= 'b0;
        bufferDataIn <= 'b0;
        read <= 'b0;
        write <= 'b0;
      end
    end
                  
endmodule