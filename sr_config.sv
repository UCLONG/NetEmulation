`include "config.sv"

module sr_config #(parameter N=8) (
  output  logic [0:`PORTS-1][`PORTS-1:0]  dout,
  input   logic [0:`PORTS-1][`PORTS-1:0]  din,
  input             clk);
  
  // Internal signals of the SR
logic  [N-1:1][0:`PORTS-1][`PORTS-1:0]    sr;
  
  // SR logic
  always_ff @(posedge clk)
      {sr, dout}  <=  {din, sr};
      
endmodule
