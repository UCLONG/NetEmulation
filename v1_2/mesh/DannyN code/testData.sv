//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit : Test Bench                                 *
//  *  File Name   : testData.sv                                *
//  *  Description : Test Bench for Network-on-Chip             *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1 - 12/02/2012                             *
//  *  Notes       : A simple test bench to input one 32 bit    *
//  *                word that can be followed as it traverses  *
//  *                the network                                *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module testData
  #(parameter X_NODES = 3,
    parameter Y_NODES = 3,
    parameter FIFO_WIDTH = 32,
    parameter FIFO_DEPTH = 4,
    parameter MODE = 1);
  
  // Create Reset and Clock pulse
  
  logic reset, clk;
  
  initial
    begin
    clk = 0;
    forever #100ps clk = ~clk; // ~ is bitwise negation
    end
  
  
  // Instantiate 2D Network
  
  logic [FIFO_WIDTH-1:0] networkToNodeDataTest [(X_NODES*Y_NODES)];
  logic networkToNodeWriteRequestTest          [(X_NODES*Y_NODES)];
  logic networkToNodeHoldRequestTest           [(X_NODES*Y_NODES)];
  logic [FIFO_WIDTH-1:0] nodeToNetworkDataTest [(X_NODES*Y_NODES)]; 
  logic nodeToNetworkWriteRequestTest          [(X_NODES*Y_NODES)];
  logic nodeToNetworkHoldRequestTest           [(X_NODES*Y_NODES)];
  
  network #(X_NODES, Y_NODES, FIFO_WIDTH, FIFO_DEPTH, MODE) networktest (networkToNodeDataTest, networkToNodeWriteRequestTest, networkToNodeHoldRequestTest, nodeToNetworkDataTest, nodeToNetworkWriteRequestTest, nodeToNetworkHoldRequestTest, reset, clk);

  initial
    begin
      reset = 1'b1;
      for (int i = 0; i<X_NODES*Y_NODES; i++)
        begin
          nodeToNetworkHoldRequestTest[i] = 0;
          nodeToNetworkWriteRequestTest[i] = 0;
        end
      #125ps
      reset= 1'b0;
      #200ps
      
      
      // This is where the fun begins.
        
      nodeToNetworkWriteRequestTest[8] = 1'b1;
      nodeToNetworkDataTest[8] = 32'b10000001111111111111111111111111;
      #200ps
      nodeToNetworkWriteRequestTest[8] = 1'b0;
    end

endmodule