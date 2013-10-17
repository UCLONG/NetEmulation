module testTori
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
  
  // Instantiate 2D Tori Network
  
  logic [FIFO_WIDTH-1:0] networkToNodeDataTest [(X_NODES*Y_NODES)];
  logic networkToNodeWriteRequestTest          [(X_NODES*Y_NODES)];
  logic networkToNodeHoldRequestTest           [(X_NODES*Y_NODES)];
  logic [FIFO_WIDTH-1:0] nodeToNetworkDataTest [(X_NODES*Y_NODES)]; 
  logic nodeToNetworkWriteRequestTest          [(X_NODES*Y_NODES)];
  logic nodeToNetworkHoldRequestTest           [(X_NODES*Y_NODES)];
  
  networkTori #(X_NODES, Y_NODES, FIFO_WIDTH, FIFO_DEPTH, MODE) networkToriTest (networkToNodeDataTest, networkToNodeWriteRequestTest, networkToNodeHoldRequestTest, nodeToNetworkDataTest, nodeToNetworkWriteRequestTest, nodeToNetworkHoldRequestTest, reset, clk);

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
      nodeToNetworkWriteRequestTest[8] = 1'b1;
      nodeToNetworkDataTest[8] = 32'b10000001111111111111111111111111;
      #200ps
      nodeToNetworkWriteRequestTest[8] = 1'b0;
    end

endmodule
