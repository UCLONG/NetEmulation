`include "config.sv"

module sr_control #(parameter N=8) (
  output  control_t   dout,
  input   control_t   din ,
  input             clk);
  
  // Internal signals of the SR
  control_t  [N-1:1]   sr;
  
  // SR logic
  always_ff @(posedge clk)
      {sr, dout}  <=  {din, sr};
      
endmodule