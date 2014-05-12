`include "config.sv"

module sr_req #(parameter N=8) (
  output  req_t   dout,
  input   req_t   din ,
  input             clk);
  
  // Internal signals of the SR
  req_t  [N-1:1]   sr;
  
  // SR logic
  always_ff @(posedge clk)
      {sr, dout}  <=  {din, sr};
      
endmodule