// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : RouteCalculator
// Module name : ENoC_RouteCalculator
// Description : Calculates which output port is required by comparing the current location of the packet with its
//             : destination.  Currently, only oblivious Dimension ordered routing is used.
// Notes       : Danny Ly has prepared an adaptive routing mechanism that will be added in the next version.
//             : Untested
// --------------------------------------------------------------------------------------------------------------------

`include "ENoC_Config.sv" // Defines topology and whether or not routing should be adaptive

module ENoC_RouteCalculator

#(parameter X_NODES, // Number of node columns
  parameter Y_NODES, // Number of node rows
  parameter X_LOC,   // Current location on the X axis
  parameter Y_LOC)   // Current location on the Y axis
  
 (input  logic [log2(X_NODES)-1:0] i_x_dest, // Packet destination on the x axis
  input  logic [log2(Y_NODES)-1:0] i_y_dest, // Packet destination on the Y axis
  input  logic                     i_val,    // Valid destination
  
  output logic               [0:4] o_output_req); // One-hot request for the [c,n,e,s,w] output port
  
  `ifdef TORUS
  
    `ifdef ADAPTIVE
  
      // DEFINE ADAPTIVE TORUS ROUTING ALGORITHMS HERE
      
    `else
    
      // Torus Dimension Ordered Routing. WRONG
      // --------------------------------------------------------------------------------------------------------------
      always_comb begin
        o_output_req = '0;
        if(i_val) begin
          if (i_x_dest != X_LOC) begin
            if (i_x_dest < X_LOC) o_output_req = ((X_LOC-i_x_dest)=<(X_NODES-(X_LOC-i_x_dest))) ? 5'b00001 : 5'b00100;
            if (i_x_dest > X_LOC) o_output_req = ((i_x_dest-X_LOC)=<(X_NODES-(i_x_dest-X_LOC))) ? 5'b00100 : 5'b00001;
          end else if (i_y_dest != Y_LOC) begin
            if (i_y_dest < Y_LOC) o_output_req = ((Y_LOC-i_y_dest)=<(Y_NODES-(Y_LOC-i_y_dest))) ? 5'b00010 : 5'b01000;
            if (i_y_dest > Y_LOC) o_output_req = ((i_y_dest-Y_LOC)=<(Y_NODES-(i_y_dest-Y_LOC))) ? 5'b01000 : 5'b00010;
          end else o_output_req = 5'b10000;
        end
      end
      
    `endif
  
  `else
  
    `ifdef ADAPTIVE
    
      // DEFINE ADAPTIVE MESH ROUTING ALGORITHM HERE
    
    `else

      // 2D Mesh Dimension Ordered Routing
      // --------------------------------------------------------------------------------------------------------------
      always_comb begin
        o_output_req = '0;
        if(i_val) begin
          if      (i_x_dest != X_LOC) o_output_req = (i_x_dest > X_LOC) ? 5'b00100 : 5'b00001;
          else if (i_y_dest != Y_LOC) o_output_req = (i_y_dest > Y_LOC) ? 5'b01000 : 5'b00010;
          else                        o_output_req = 5'b10000;
        end
      end      

    `endif
  
  `endif

endmodule