// Net combination for speculative network(scheme 2)
// An example of a network structure in SystemVerilog to interface
// with the top level code 'net_emulation'
// Shiyun Liu  10/2013

`include "config.sv"

module network (
  input logic clk,
  input logic rst,
  input packet_t flit_in [0:`PORTS-1],
  output packet_t flit_out [0:`PORTS-1],
  output logic [`PORTS-1:0] full,
  output logic [`PORTS-1:0] nearly_full_buf);
    
    // Internal Signals
    packet_t dout_tx [0:`PORTS-1];
    logic [0:`PORTS-1][`PORTS-1:0]      grant_switch;
    logic [0:`PORTS-1][`PORTS-1:0]      grant_switch_buf;
    req_t                               req [0:`PORTS-1]; 
    req_t                               req_delayed [0:`PORTS-1];
    grant_t                             grant [0:`PORTS-1];
    grant_t                             grant_delayed [0:`PORTS-1]; 
    packet_t   dto_buf [0:`PORTS-1]  ;
    packet_t   dfrom_buf [ 0:`PORTS-1];
    req_t                               req_buf [0:`PORTS-1];
    grant_t                             grant_buf [0:`PORTS-1];
    logic [`PORTS-1:0] full_buf;
    //logic [`PORTS-1:0] nearly_full_buf;
    
    // Instantiate allocator
    alloc_recirc inst_alloc (
      .req(req_delayed),
      .grant(grant),
      .grant_switch(grant_switch),
      .grant_buf(grant_buf),
      .grant_switch_buf(grant_switch_buf),
      .clk(clk),
      .rst(rst),
      .req_buf(req_buf));

    //Instantiate txs
    generate for (genvar k=0;k<`PORTS;k++)
          tx_recirc inst_txs (
            .req(req[k]),
            .dout(dout_tx[k]),
            .full_out(full[k]),
            .din(flit_in[k]),
            .grant(grant_delayed[k]),
            .clk(clk),
            .rst(rst),
            .full_in(full_buf[k]),
            .nearly_full_in(nearly_full_buf[k]));
    endgenerate
      
    // Instantiate optical switch including delays    
    photonic_switch inst_switch(
      .dout(flit_out),  
      .grant_out (grant_delayed),
      .req_out(req_delayed), 
      .dto_buf (dto_buf),   
      .din(dout_tx), 
      .grant_in(grant),
      .req_in(req),
      .switch_config(grant_switch),
      .switch_config_buf(grant_switch_buf),
      .clk(clk),
      .dfrom_buf(dfrom_buf));	
    
    // Instantiate oeo buffer
    generate for (genvar k=0;k<`PORTS;k++)
    oeo_buffer inst_oeo_buf ( 
            .dout(dfrom_buf[k]),
            .req(req_buf[k]),
            .full(full_buf[k]),
            .nearly_full(nearly_full_buf[k]),
            .din(dto_buf[k]),
            .clk(clk),
            .rst(rst),
            .grant(grant_buf[k])); 
    endgenerate
       
endmodule   
