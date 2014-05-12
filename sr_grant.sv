`include "config.sv"

module sr_grant #(parameter N=8) (
  output  grant_t   dout,
  input   grant_t   din ,
  input             clk);
  
  // Internal signals of the SR
  grant_t  [N-1:1]   sr;
  
  // SR logic
  always_ff @(posedge clk)
      {sr, dout}  <=  {din, sr};
      
endmodule