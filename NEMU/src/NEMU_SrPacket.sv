`include "config.sv"

module sr_packet #(parameter N=8) (
  output  packet_t  dout,
  input   packet_t  din,
  input             clk);
  
  // Internal signals of the SR
  packet_t  [N-1:1]   sr;
  
  // SR logic
  always_ff @(posedge clk)
      {sr, dout}  <=  {din, sr};
      
endmodule      
  
