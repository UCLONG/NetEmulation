// Simple tx with single FIFO
// Philip Watts 26/3/2013

`include "config.sv"

module tx_simple (
  output  req_t                     req,
  output  packet_t                      dout,
  output  logic                         full,
  input   packet_t                      din,
  input   grant_t                     grant,
  input   logic                         clk,
  input   logic                         rst);
  
  /////////////////////////////////////////////////
  // Start definition of Virtual Channel Tx
  /////////////////////////////////////////////////
  `ifdef VC  
  
  // Internal signals
  logic       [`PORTS-1:0]    full_int;
  packet_t    [`PORTS-1:0]    fifo_out;
  logic       [`PORTS-1:0]    empty;      // Empty signal not needed!?
  grant_t                   grant_buf;
  logic       [`PORTS-1:0]    we;
  logic       [`PORTS-1:0]    re;
  logic       [`PORTS-1:0]    nearly_full;
  
  // generate FIFOs for VC queues
  generate
      for (genvar h=0;h<`PORTS;h++) begin
          fifo_pkt #(`FIFO_DEPTH, 0) input_fifos (  // is 0 correct?
            .din(din),
            .wr_en(we[h]),
            .rd_en(re[h]),
            .dout(fifo_out[h]),
            .full(full_int[h]),
            .empty(empty[h]),          // Empty signal not needed!?
            .nearly_empty(),
            .nearly_full(nearly_full[h]),
            .clk(clk),
            .reset(rst));
      end
  endgenerate
  
  // FIFO Control Logic
  always_comb begin      
    we = 0;
    re = 0; 
    //full = 1; 
    for (int k=0;k<`PORTS;k++) begin
      // FIFO write enable logic
      if (din.valid && (din.dest==k))// && (!full_int[din.dest])) begin
        we[k] = 1;
        //full = 0;
      //end
      
      // FIFO read enable logic
      if (grant_buf.valid && (grant_buf.port==k))
        re[k] = 1;
    
    end //for
  end//always_comb
  
  // FIFO full control
 always_comb begin
    full = 0;
    if (full_int[din.dest])
      full = 1;
 end
  
  // Request Logic
  always_ff @(posedge clk)
    if (rst) 
      req.valid <= 0;
    else begin
      req.valid <= (din.valid && (!full_int[din.dest]));
      req.port  <= din.dest;
    end
    
  // Grant Logic
  always_ff @(posedge clk)
    if (rst) begin
      dout.data <= 0;
      dout.valid <= 0;
      dout.dest <= 0;
      dout.source <= 0;
    end else if (grant_buf.valid) begin
      dout <= fifo_out[grant_buf.port];
      dout.valid <= 1;
    end else
      dout.valid <= 0; 
  
  // Buffer grant signal
  always_ff @(posedge clk)
    if (rst)
      grant_buf <= 0;
    else
      grant_buf <= grant;
  
  /////////////////////////////////////////////////
  // Start definition of Single FIFO Tx
  /////////////////////////////////////////////////
  `else
  
  // Internal signals
  logic       full_int;
  packet_t    fifo_out;
  logic       empty;
  logic       empty_buf;
  logic       grant_buf;
  logic       re, we;
  logic       nearly_full;
  

  // Input FIFO
  fifo_pkt #(`FIFO_DEPTH, 0) input_fifo (
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
    end else if (grant.valid) begin
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
    req.port = fifo_out.dest;
  end
        
  // Transfer internal to external signals
  assign full = full_int; 
  assign re = grant.valid;
  assign we = din.valid;  // && (!full_int); Don't think this is necessary!
  
`endif  // End definition of single FIFO Tx

endmodule
