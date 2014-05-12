// Simple oeo buffer (the same as scheme 1)
// Asumes a single FIFO in adapter - therefore grants are single bit
// This fifo works in scheduling modes
// Add ful and nearly full signal
// Shiyun Liu  10/2013

`include "config.sv"

module oeo_buffer (dout, req, full, nearly_full, din, clk,rst, grant);

  output  packet_t                       dout;
  output  req_t                          req;
  output  logic                          full;
  output  logic                   nearly_full;
  input  packet_t                         din; 
  input  logic                            clk;
  input  logic                            rst;
  input   grant_t                         grant;

// Internal signals
  logic       full_int;
  packet_t    fifo_out;
  logic       empty;
  logic       empty_buf;
  logic       grant_buf;
  logic       re, we;
 // packet_t  dout_int;
  
  // Swithch FIFO
  fifo_pkt #(`FIFO_DEPTH, 0) switch_fifo (
        .din(din),
        .wr_en(we),
        .rd_en(re),
        .dout(fifo_out),
        .full(full_int),
        .empty(empty),
        .nearly_empty(),
        .nearly_full(nearly_full),
        .clk(clk),
        .reset(rst));
  
  // Register output data
  always_ff @(posedge clk)
    if (rst) begin
      dout.data <= 0;
      dout.valid <= 0;
      dout.dest <= 0;
      dout.source <= 0;
    end else if (grant) begin
      dout <= fifo_out;
      dout.valid <= 1;
    end else
      dout.valid <= 0;  
  
  // Register full and grant signals
  always_ff @(posedge clk)
    if (rst) begin
      empty_buf  <= 0;
      grant_buf <= 0;
    end else begin
      empty_buf  <= empty;
      grant_buf <= grant.valid;
    end
    
  // Generate requests
  always_comb begin
    req.valid = (grant_buf && (!empty))||(empty_buf && (!empty));
    req.port  =  fifo_out.dest;
  end
        
  // Transfer internal to external signals
  assign full = full_int;
  assign re = grant.valid;
  assign we = din.valid;  // && (!full_int); Don't think this is necessary!
      
endmodule
