module testRouter;
  
  // Test to show info moving through router.  Run for 1800ps.
  
 // Create Reset and Clock pulse
  
  logic reset, clk;
  
  initial
    begin
    clk = 1;
    forever #50ps clk = ~clk; // ~ is bitwise negation
    end
  
  
  // Instantiate router

  logic [32-1:0] routerDataOut [0:4];
  logic [4:0] holdPorts_OUT, writeRequest_OUT;
  logic [32-1:0] routerDataIn [0:4];
  logic [4:0] holdPorts_IN, writeRequest_IN;
  logic [32-1:0] routerDataInQueue [0:4][$];

  router #(1,1,9,9,32,4,0) routerTest (routerDataOut, holdPorts_OUT, writeRequest_OUT,routerDataIn,holdPorts_IN,writeRequest_IN,reset,clk);
  
  initial
    begin
      reset = 1'b1;
      #75ps
      reset= 1'b0;
      holdPorts_IN = 5'b11111;
      routerDataInQueue[2] = {32'b10000100010111111111111111111111,
                              32'b10001000001111111111111111111111,
                              32'b10000100000101111111111111111111,
                              32'b10000000001111111111111111111111,
                              32'b10000100001111011111111111111111,
                              32'b10000100010111111111111111111111,
                              32'b10001000001111111111111111111111,
                              32'b10000100000101111111111111111111,
                              32'b10000000001111111111111111111111,
                              32'b100001000011110111111111111111};
      #1000ps
      holdPorts_IN = 5'b00000;
    end
    
  always_ff@(posedge clk)
    begin
      for (int i = 0; i < 5; i++)
        begin
          if ((routerDataInQueue[i].size() != 0) && (holdPorts_OUT[i] != 1))
            begin
              writeRequest_IN[i] <= 1'b1;
              routerDataIn[i] <= routerDataInQueue[i].pop_front();
            end
          else writeRequest_IN[i] <= 1'b0;
        end
     end                           
                           
                           
    
endmodule