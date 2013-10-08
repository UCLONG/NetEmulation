`include "config.sv"

module packet_sink (
  input logic clk, 
  input logic rst, 
  input packet_t pkt_rx,
  input logic [15:0] timestamp, 
  output logic [23:0] latency,
  output logic [15:0] pkt_count,
  output logic pkt_error);
  
  parameter port_no = 0;
  
  always_ff @(posedge clk) 
    if (rst) begin
      pkt_error  <= 0;
      latency    <= 0;
      pkt_count  <= 0;
    end else if (pkt_rx.valid) begin
        latency <= latency + (timestamp - pkt_rx.data[15:0]);
        pkt_count <= pkt_count + 1;
        if (pkt_rx.dest != port_no)
            pkt_error <= 1;
    end
   
endmodule      
            
