// Delays control signals in optical network
// Philip Watts, UCL
// 4th April 2013
`include "config.sv"

module delay_control #(parameter DELAY = 1) (
  output  packet_t    dout,
  input   packet_t    din,
  input               clk,
  input               rst);
  
  // If transport delay is 1 clock cycle, it is not necessary 
  // to introduce extra delay here
  generate if (DELAY == 1)
    assign dout = din;
  endgenerate
  
endmodule
    
  
