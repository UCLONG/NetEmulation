`include "config.sv"

module packet_sink (
  input logic clk, 
  input logic rst, 
  input packet_t pkt_rx,
  input logic [23:0] timestamp, 
  output logic [23:0] latency,
  output logic [15:0] pkt_count,
  output logic [20:0] hop_count,
  output logic pkt_error,
  output logic [15:0] error_total);
  
  parameter port_no = 0;
  
  always_ff @(posedge clk) 
    if (rst) begin
      pkt_error  <= 0;
      latency    <= 0;
      pkt_count  <= 0;
      hop_count  <= 0;
      error_total <= 0;
    end else if (pkt_rx.valid) begin
        if (pkt_rx.measure == 1) // Only measure packets that pass Warm-up & Drain conditions
          begin
            latency <= latency + (timestamp - pkt_rx.data[`PAYLOAD-1:0]);
            pkt_count <= pkt_count + 1;
          end
        hop_count <= hop_count + pkt_rx.hopCount[log2(2*`MESH_WIDTH + 2*`UNPRODUCTIVE)-1:0];
        if (pkt_rx.dest != port_no)
          begin
            pkt_error <= 1;
            error_total <= error_total + 1;
          end
    end
   
endmodule      
            