//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit : Router                                     *
//  *  File Name   : router.sv                                  *
//  *  Description : A 5x5 crossbar input buffered Router       *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1 - 12/02/2012                             *
//  *  Notes       : The router has five input units consisting *
//  *                of FIFO buffers and route calculators,     *
//  *                which generate output port requests when   *
//  *                they contain data to move from the router  *
//  *                and hold port signals when they are full.  *
//  *                The output port requests are fed to an     *
//  *                arbitration module which upon granting an  *
//  *                input buffer to an output port sends a     *
//  *                read request to the buffer, a write        *
//  *                request to the network and selects the     *
//  *                appropriate switch on the crossbar module  *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module router
  
  // The router location and the width and depth of the FIFO are paramatised
  
  #(parameter xLocation = 0,
    parameter yLocation = 0,
    parameter X_NODES = 3,
    parameter Y_NODES = 3,
    parameter FIFO_WIDTH = 32,
    parameter FIFO_DEPTH = 4,
    parameter MODE = 0)
    
    
    // Outputs and inputs
    
    (output logic [FIFO_WIDTH-1:0] routerDataOut [0:4],
     output logic [4:0] holdPorts_OUT, writeRequest_OUT,
      input logic [FIFO_WIDTH-1:0] routerDataIn [0:4],
      input logic [4:0] holdPorts_IN, writeRequest_IN,
      input logic reset, clk);
  
   
    // Internal Logic, essentially this is just connections.
    
    logic [FIFO_WIDTH-1:0] bufferDataOut [0:4];
    logic [4:0] outputPortRequest [0:4];
    logic [4:0] readRequest;
    logic [2:0] sel [0:4];
    
   
    // Generate 5 input units
  
    genvar j;
    generate 
      for ( j = 0; j< 5; j++ )
        inputUnit #(xLocation, yLocation, X_NODES, Y_NODES, FIFO_WIDTH, FIFO_DEPTH, MODE) inputUnit (bufferDataOut[j], outputPortRequest[j], holdPorts_OUT[j], routerDataIn[j], readRequest[j], writeRequest_IN[j], holdPorts_IN[j], reset, clk);
    endgenerate
    
    
    // Instantiate switch allocator and switch
    
    switchAllocator switchAllocator (sel, readRequest, writeRequest_OUT, outputPortRequest, holdPorts_IN, reset, clk);
    switch #(5,5,FIFO_WIDTH) switch (routerDataOut, bufferDataOut, sel);
    
    
endmodule
