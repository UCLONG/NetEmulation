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
  output logic [`PORTS-1:0] full,
  output logic [`PORTS-1:0] nearly_full_buf);
    
    // Internal Signals
    packet_t    dout_tx [0:`PORTS-1];
    logic [0:`PORTS-1][`PORTS-1:0]      grant_switch;
    req_t   req   [0:`PORTS-1];
    req_t   req_delayed [0:`PORTS-1];
    grant_t   grant [0:`PORTS-1];
    grant_t   grant_delayed [0:`PORTS-1]; 
    
    // Instantiate allocator
    alloc_simple inst_alloc (
      .req(req_delayed),
      .grant(grant),
      .grant_switch(grant_switch),
      .clk(clk),
      .rst(rst));

    //Instantiate txs
    generate for (genvar k=0;k<`PORTS;k++)
          tx_simple inst_txs (
            .req(req[k]),
            .dout(dout_tx[k]),
            .full(full[k]),
            .din(flit_in[k]),
            .grant(grant_delayed[k]),
            .clk(clk),
            .rst(rst));
    endgenerate
      
    // Instantiate optical switch including delays    
    photonic_switch inst_switch(
      .dout(flit_out),  
      .grant_out (grant_delayed),
      .req_out(req_delayed),    
      .din(dout_tx), 
      .grant_in(grant),
      .req_in(req),
      .switch_config(grant_switch),
      .clk(clk));	
          
      
endmodule   
