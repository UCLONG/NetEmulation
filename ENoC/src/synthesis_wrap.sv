// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : synthesis_wrap
// Module name : synthesis_wrap
// Description : Instantiates a MESH_Network keeping top level ports to a minimum for synthesis.
// Uses        : synthesis_wrap.sv
// --------------------------------------------------------------------------------------------------------------------

`include "ENoC_Config.sv"

/*
module synthesis_wrap


 (input  logic clk, rst,
  
  input  packet_t pkt_in,
  
  output packet_t pkt_out);
  
  ENoC_Network
    inst_ENoC_Network (.clk,
                       .reset_n(rst),
                       .i_data(pkt_in),
                       .i_data_val(1'b1),
                       .o_en(),
                       .o_data(pkt_out),
                       .o_data_val(),
                       .i_en(1'b1));
endmodule
*/

module synthesis_wrap

 (input logic clk, reset_n,
  
  input packet_t i_data,
  
  output packet_t o_data);
  
logic    [0:(`X_NODES*`Y_NODES)-1] i_data_val /* synthesis noprune */;
logic    [0:(`X_NODES*`Y_NODES)-1] o_en /* synthesis noprune */;
        
logic    [0:(`X_NODES*`Y_NODES)-1] o_data_val /* synthesis noprune */;
logic    [0:(`X_NODES*`Y_NODES)-1] i_en /* synthesis noprune */;
       
  ENoC_Network
    inst_ENoC_Network (.clk(clk),
                       .reset_n(reset_n),
                       .i_data(i_data),
                       .i_data_val(1'b1),
                       .o_en(o_en),
                       .o_data(o_data),
                       .o_data_val(o_data_val),
                       .i_en(i_en));
endmodule