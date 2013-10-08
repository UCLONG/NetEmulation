`include "config.sv"

module inputUnit
  // The X, Y location of the input unit, the number of X and Y nodes and the width and depth of the FIFO are parameterised.
  #(parameter xLocation = 0,
    parameter yLocation = 0,
    parameter X_NODES = 2,
    parameter Y_NODES = 2,
    parameter FIFO_WIDTH = 64,
    parameter FIFO_DEPTH = 4)
    
  // I/O   Type        Packet Size                Name                   Description
   (output packet_mesh                           bufferDataOut,         // Data that has been read from the buffer
    output logic       [4:0]                     outputPortRequest,     // Requests for the first flit in memory
    output logic                                 holdPortOut,           // Signals when the buffer is full
    output logic                                 unproductive,          // Flag to show an unproductive path was chosen
    output logic       [log2(`DEADLOCK_LIMIT):0] wait_count,            // Deadlock counter
    
    input  packet_mesh                           bufferDataIn,          // Data at the input port to be written to memory
    input  logic                                 read, write,
    input  logic                                 reset, clk,
    input  logic       [4:0]                     writeRequest_OUT,      // Write enable of the router
    input  logic       [4:0]                     readEnable_Adjacent);  // Read enable of the adjacent router    

           logic       [log2(`MESH_WIDTH)-1:0]   xDestination;          // X and Y destination of the flit stored at the front 
           logic       [log2(`MESH_WIDTH)-1:0]   yDestination;          // of the buffer.
           logic       [log2(`UNPRODUCTIVE):0]   misroute;              // Misroute constant
  
  fifo_pkt #(FIFO_DEPTH, 0) input_fifo (bufferDataIn, write, read, bufferDataOut, full, empty, wait_count, clk, reset);
           
  // Function to calculate an approximation of log2(n). The result provides the amount of bits necessary to reproduce an
  // integer as an unsiged binary.
  function int log2
    (input int n);
      begin
        log2 = 0;     // Initialise log2 with zero
        n--;          // Decrement n
        while (n > 0)
          begin
            log2++;   // Increment log2
            n >>= 1;  // Bitwise shift n to the right by one position
          end  
      end
  endfunction
    
  assign holdPortOut = full; // Signals when the buffer is full
  assign xDestination = bufferDataOut.xdest;
  assign yDestination = bufferDataOut.ydest;
  assign misroute = bufferDataOut.reroute;
  
  routing_algorithm #(xLocation, yLocation, X_NODES, Y_NODES, FIFO_DEPTH) adaptive_routing (
   .outputPortRequest(outputPortRequest), 
   .unproductive(unproductive), 
   .empty(empty), 
   .writeEnable(writeRequest_OUT), 
   .readEnable(readEnable_Adjacent), 
   .xdest(xDestination), 
   .ydest(yDestination), 
   .misroute(misroute), 
   .clk(clk), 
   .rst(reset));
endmodule
