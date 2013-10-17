module arbiter_tb;
  logic [5-1:0] portGrant;
  logic [5-1:0] portRequest;
  logic [5-1:0] portHold;
  logic         reset, clk;
  
  arbiter a (portGrant, portRequest,  reset, clk);
  
  initial
    begin
    clk = 1;
    forever #50ps clk = ~clk;
    end
    
  initial
    begin
      reset       = 1'b1;
      portRequest = 5'b00000;
      #200ps 
      reset       = 1'b0;
      #100ps
      portRequest = 5'b00110;
      portHold    = 5'b00000;
    end

endmodule
  
  
