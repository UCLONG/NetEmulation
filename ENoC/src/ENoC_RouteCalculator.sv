// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : RouteCalculator
// Module name : ENoC_RouteCalculator
// Description : Calculates which output port is required by comparing the current location of the packet with its
//             : destination.  Currently, only oblivious Dimension ordered routing is used.
// Notes       : Danny Ly has prepared an adaptive routing mechanism that will be added in the next version.
//             : Untested
// --------------------------------------------------------------------------------------------------------------------

`include "ENoC_Functions.sv"
`include "ENoC_Config.sv" // Defines topology and whether or not routing should be adaptive

module ENoC_RouteCalculator

#(`ifdef TORUS
    parameter integer X_NODES, // Number of node columns
    parameter integer Y_NODES, // Number of node rows
    parameter integer X_LOC,   // Current location on the X axis
    parameter integer Y_LOC    // Current location on the Y axis
  `else
    parameter integer NODES,   // Number of nodes
    parameter integer LOC      // Current location
  `endif
  )
  
 (`ifdef TORUS
    input  logic [log2(X_NODES)-1:0] i_x_dest,      // Packet destination on the x axis
    input  logic [log2(Y_NODES)-1:0] i_y_dest,      // Packet destination on the Y axis
  `else
    input  logic [log2(NODES)-1:0]   i_dest,        // Packet destination
  `endif
    
    input  logic                     i_val,         // Valid destination
  
    output logic               [0:4] o_output_req); // One-hot request for the [c,n,e,s,w] output port
  
  `ifdef MESH

    // 2D Mesh Dimension Ordered Routing
    // --------------------------------------------------------------------------------------------------------------
    always_comb begin
      o_output_req = '0;
      if(i_val) begin
        if      (i_x_dest != X_LOC) o_output_req = (i_x_dest > X_LOC) ? 5'b0010000 : 5'b0000100;
        else if (i_y_dest != Y_LOC) o_output_req = (i_y_dest > Y_LOC) ? 5'b0100000 : 5'b0001000;
        else if (i_z_dest != Z_LOC) o_output_req = (i_z_dest > Z_LOC) ? 5'b0000001 : 5'b0000010;        
        else                        o_output_req = 5'b1000000;
      end
    end      
  
  `elsif CUBE
    
    // 2D Cube Dimension Ordered Routing.
    // --------------------------------------------------------------------------------------------------------------
    always_comb begin
      o_output_req = '0;
      if(i_val) begin
        if (i_x_dest != X_LOC) begin
          if (i_x_dest < X_LOC) o_output_req = ((X_LOC-i_x_dest)=<(X_NODES-(X_LOC-i_x_dest))) ? 5'b0000100 : 5'b0010000;
          if (i_x_dest > X_LOC) o_output_req = ((i_x_dest-X_LOC)=<(X_NODES-(i_x_dest-X_LOC))) ? 5'b0010000 : 5'b0000100;
        end else if (i_y_dest != Y_LOC) begin
          if (i_y_dest < Y_LOC) o_output_req = ((Y_LOC-i_y_dest)=<(Y_NODES-(Y_LOC-i_y_dest))) ? 5'b0001000 : 5'b0100000;
          if (i_y_dest > Y_LOC) o_output_req = ((i_y_dest-Y_LOC)=<(Y_NODES-(i_y_dest-Y_LOC))) ? 5'b0100000 : 5'b0001000;
        end else if (i_z_dest != Z_LOC) begin
          if (i_z_dest < Z_LOC) o_output_req = ((Z_LOC-i_z_dest)=<(Z_NODES-(Z_LOC-i_z_dest))) ? 5'b0000010 : 5'b0000001;
          if (i_z_dest > Z_LOC) o_output_req = ((i_z_dest-Z_LOC)=<(Z_NODES-(i_z_dest-Z_LOC))) ? 5'b0000001 : 5'b0000010;
        end else o_output_req = 5'b1000000;
      end
    end
  
  `endif

endmodule