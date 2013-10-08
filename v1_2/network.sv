// File: network.sv
// Philip Watts, UCL, June 2012
//
// An example of a network structure in SystemVerilog to interface
// with the top level code 'net_emulation'

`include "config.sv"

module network (
  input logic clk,
  input logic rst,
  input packet_t flit_in [0:`PORTS-1],
  output packet_t flit_out [0:`PORTS-1],
  output logic [`PORTS-1:0] full);
  
  `ifdef ISLIP
    logic [0:`ROUTER_RADIX-1][`ROUTER_RADIX-1:0] req;
    logic [0:`ROUTER_RADIX-1][`ROUTER_RADIX-1:0] req_buf;
    //logic [0:`ROUTER_RADIX-1][`ROUTER_RADIX-1:0] grant ; 
    //logic [0:`ROUTER_RADIX-1][`ROUTER_RADIX-1:0] grant_buf ;
    
    alloc_islip inst_alloc (
      .bclk(bclk), 
      .ce(ce),
      .arb_cycles(),
      .req(req), 
      .grant(grant),
      .grant_switch(grant_switch),	
      .rst(rst));
  
      //Instantiate txs
      for (k=0;k<`ROUTER_RADIX;k++) begin
        photonic_tx2 inst_txs (
        .clk(bclk), 
        .ce(ce), 
        .din(din[k]), 
        .we(we[k]), 
        .dout(dout_tx[k]), 
        .reqs(req[k]), 
        .grants(grant[k]),
        .full(full[k]), 
        .rst(rst),
        .power_req();
      end
      
      always @(posedge bclk)
        if (ce) begin
          dout <= dout_tx2;
          dout_tx2 <= dout_tx;
          req_buf <= req;
          grant_buf <= grant;
        end
        
    photonic_switch #(4) inst_switch(
      .bclk(clk), 
      .ce(ce), 
      .din(dout_tx), 
      .dout(flit_out), 
      .grant(grant_switch), 
      .rst(rst));	
          
  `endif
      
 endmodule   