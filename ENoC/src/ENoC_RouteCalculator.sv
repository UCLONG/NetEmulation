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
    parameter integer Z_NODES, // Number of node layers
    parameter integer X_LOC,   // Current location on the X axis
    parameter integer Y_LOC,   // Current location on the Y axis
    parameter integer Z_LOC    // Current location on the Z axis
  `else
    parameter integer NODES,   // Number of nodes
    parameter integer LOC      // Current location
  `endif
  )
  
 (`ifdef XYSWAP
    input logic clk,
    input logic reset_n,
  `endif
 
  `ifdef TORUS
    input  logic [log2(X_NODES)-1:0] i_x_dest,      // Packet destination on the x axis
    input  logic [log2(Y_NODES)-1:0] i_y_dest,      // Packet destination on the Y axis
    input  logic [log2(Z_NODES)-1:0] i_z_dest,      // Packet destination on the Z axis
  `else
    input  logic [log2(NODES)-1:0]   i_dest,        // Packet destination
  `endif
  
    input  logic                     i_val,         // Valid destination
  
    output logic               [0:6] o_output_req); // One-hot request for the [c,n,e,s,w] output port
  
  `ifdef XYSWAP

    `ifdef MESH

      // 3D Mesh Dimension Ordered Routing with alternating XY order
      // --------------------------------------------------------------------------------------------------------------
    
      logic f_xy;
    
      always_ff@(posedge clk) begin
        if(~reset_n) begin
          f_xy <= 0;
        end else begin
          f_xy <= ~f_xy;
        end
      end

      always_comb begin
        o_output_req = '0;
        if(i_val) begin
          if(f_xy == 0) begin
            if      (i_x_dest != X_LOC) o_output_req = (i_x_dest > X_LOC) ? 7'b0010000 : 7'b0000100;
            else if (i_y_dest != Y_LOC) o_output_req = (i_y_dest > Y_LOC) ? 7'b0100000 : 7'b0001000;
            else if (i_z_dest != Z_LOC) o_output_req = (i_z_dest > Z_LOC) ? 7'b0000001 : 7'b0000010;        
            else                        o_output_req = 7'b1000000;
          end else begin
            if      (i_y_dest != Y_LOC) o_output_req = (i_y_dest > Y_LOC) ? 7'b0100000 : 7'b0001000;
            else if (i_x_dest != X_LOC) o_output_req = (i_x_dest > X_LOC) ? 7'b0010000 : 7'b0000100;
            else if (i_z_dest != Z_LOC) o_output_req = (i_z_dest > Z_LOC) ? 7'b0000001 : 7'b0000010;        
            else                        o_output_req = 7'b1000000;
          end
        end
      end      
    
    `elsif CUBE
       
      // 3D Cube Dimension Ordered Routing with alternating XYZ order
      // --------------------------------------------------------------------------------------------------------------   
      
      logic [5:0] f_xyz;
    
      always_ff@(posedge clk) begin
        if(~reset_n) begin
          f_xyz <= 6'b000001;
        end else begin
          f_xyz <= {f_xyz[5], f_xyz[0:4]};
        end
      end
      
      always_comb begin
        o_output_req = '0;
        if(i_val) begin
          if(f_xy == 5'b000001) begin
            if (i_x_dest != X_LOC) begin
              if (i_x_dest < X_LOC) o_output_req = ((X_LOC-i_x_dest)<=(X_NODES-1-(X_LOC-i_x_dest))) ? 7'b0000100 : 7'b0010000; 
              if (i_x_dest > X_LOC) o_output_req = ((i_x_dest-X_LOC)<=(X_NODES-1-(i_x_dest-X_LOC))) ? 7'b0010000 : 7'b0000100;
            end else if (i_y_dest != Y_LOC) begin
              if (i_y_dest < Y_LOC) o_output_req = ((Y_LOC-i_y_dest)<=(Y_NODES-1-(Y_LOC-i_y_dest))) ? 7'b0001000 : 7'b0100000;
              if (i_y_dest > Y_LOC) o_output_req = ((i_y_dest-Y_LOC)<=(Y_NODES-1-(i_y_dest-Y_LOC))) ? 7'b0100000 : 7'b0001000;
            end else if (i_z_dest != Z_LOC) begin
              if (i_z_dest < Z_LOC) o_output_req = ((Z_LOC-i_z_dest)<=(Z_NODES-1-(Z_LOC-i_z_dest))) ? 7'b0000010 : 7'b0000001;
              if (i_z_dest > Z_LOC) o_output_req = ((i_z_dest-Z_LOC)<=(Z_NODES-1-(i_z_dest-Z_LOC))) ? 7'b0000001 : 7'b0000010;
            end else o_output_req = 7'b1000000;
          end else if(f_xy == 5b'000010) begin
            if (i_x_dest != X_LOC) begin
              if (i_x_dest < X_LOC) o_output_req = ((X_LOC-i_x_dest)<=(X_NODES-1-(X_LOC-i_x_dest))) ? 7'b0000100 : 7'b0010000; 
              if (i_x_dest > X_LOC) o_output_req = ((i_x_dest-X_LOC)<=(X_NODES-1-(i_x_dest-X_LOC))) ? 7'b0010000 : 7'b0000100;
            end else if (i_z_dest != Z_LOC) begin
              if (i_z_dest < Z_LOC) o_output_req = ((Z_LOC-i_z_dest)<=(Z_NODES-1-(Z_LOC-i_z_dest))) ? 7'b0000010 : 7'b0000001;
              if (i_z_dest > Z_LOC) o_output_req = ((i_z_dest-Z_LOC)<=(Z_NODES-1-(i_z_dest-Z_LOC))) ? 7'b0000001 : 7'b0000010;
            end else if (i_y_dest != Y_LOC) begin
              if (i_y_dest < Y_LOC) o_output_req = ((Y_LOC-i_y_dest)<=(Y_NODES-1-(Y_LOC-i_y_dest))) ? 7'b0001000 : 7'b0100000;
              if (i_y_dest > Y_LOC) o_output_req = ((i_y_dest-Y_LOC)<=(Y_NODES-1-(i_y_dest-Y_LOC))) ? 7'b0100000 : 7'b0001000;
            end else o_output_req = 7'b1000000;          
          end else if(f_xy == 5b'000100) begin
            if (i_z_dest != Z_LOC) begin
              if (i_z_dest < Z_LOC) o_output_req = ((Z_LOC-i_z_dest)<=(Z_NODES-1-(Z_LOC-i_z_dest))) ? 7'b0000010 : 7'b0000001;
              if (i_z_dest > Z_LOC) o_output_req = ((i_z_dest-Z_LOC)<=(Z_NODES-1-(i_z_dest-Z_LOC))) ? 7'b0000001 : 7'b0000010;
            end else if (i_x_dest != X_LOC) begin
              if (i_x_dest < X_LOC) o_output_req = ((X_LOC-i_x_dest)<=(X_NODES-1-(X_LOC-i_x_dest))) ? 7'b0000100 : 7'b0010000; 
              if (i_x_dest > X_LOC) o_output_req = ((i_x_dest-X_LOC)<=(X_NODES-1-(i_x_dest-X_LOC))) ? 7'b0010000 : 7'b0000100;
            end else if (i_y_dest != Y_LOC) begin
              if (i_y_dest < Y_LOC) o_output_req = ((Y_LOC-i_y_dest)<=(Y_NODES-1-(Y_LOC-i_y_dest))) ? 7'b0001000 : 7'b0100000;
              if (i_y_dest > Y_LOC) o_output_req = ((i_y_dest-Y_LOC)<=(Y_NODES-1-(i_y_dest-Y_LOC))) ? 7'b0100000 : 7'b0001000;
            end else o_output_req = 7'b1000000;          
          end else if(f_xy == 5b'001000) begin
            if (i_z_dest != Z_LOC) begin
              if (i_z_dest < Z_LOC) o_output_req = ((Z_LOC-i_z_dest)<=(Z_NODES-1-(Z_LOC-i_z_dest))) ? 7'b0000010 : 7'b0000001;
              if (i_z_dest > Z_LOC) o_output_req = ((i_z_dest-Z_LOC)<=(Z_NODES-1-(i_z_dest-Z_LOC))) ? 7'b0000001 : 7'b0000010;
            end else if (i_y_dest != Y_LOC) begin
              if (i_y_dest < Y_LOC) o_output_req = ((Y_LOC-i_y_dest)<=(Y_NODES-1-(Y_LOC-i_y_dest))) ? 7'b0001000 : 7'b0100000;
              if (i_y_dest > Y_LOC) o_output_req = ((i_y_dest-Y_LOC)<=(Y_NODES-1-(i_y_dest-Y_LOC))) ? 7'b0100000 : 7'b0001000;
            end else if (i_x_dest != X_LOC) begin
              if (i_x_dest < X_LOC) o_output_req = ((X_LOC-i_x_dest)<=(X_NODES-1-(X_LOC-i_x_dest))) ? 7'b0000100 : 7'b0010000; 
              if (i_x_dest > X_LOC) o_output_req = ((i_x_dest-X_LOC)<=(X_NODES-1-(i_x_dest-X_LOC))) ? 7'b0010000 : 7'b0000100;
            end else o_output_req = 7'b1000000;          
          end else if(f_xy == 5b'010000) begin
            if (i_y_dest != Y_LOC) begin
              if (i_y_dest < Y_LOC) o_output_req = ((Y_LOC-i_y_dest)<=(Y_NODES-1-(Y_LOC-i_y_dest))) ? 7'b0001000 : 7'b0100000;
              if (i_y_dest > Y_LOC) o_output_req = ((i_y_dest-Y_LOC)<=(Y_NODES-1-(i_y_dest-Y_LOC))) ? 7'b0100000 : 7'b0001000;
            end else if (i_z_dest != Z_LOC) begin
              if (i_z_dest < Z_LOC) o_output_req = ((Z_LOC-i_z_dest)<=(Z_NODES-1-(Z_LOC-i_z_dest))) ? 7'b0000010 : 7'b0000001;
              if (i_z_dest > Z_LOC) o_output_req = ((i_z_dest-Z_LOC)<=(Z_NODES-1-(i_z_dest-Z_LOC))) ? 7'b0000001 : 7'b0000010;
            end else if (i_x_dest != X_LOC) begin
              if (i_x_dest < X_LOC) o_output_req = ((X_LOC-i_x_dest)<=(X_NODES-1-(X_LOC-i_x_dest))) ? 7'b0000100 : 7'b0010000; 
              if (i_x_dest > X_LOC) o_output_req = ((i_x_dest-X_LOC)<=(X_NODES-1-(i_x_dest-X_LOC))) ? 7'b0010000 : 7'b0000100;
            end else o_output_req = 7'b1000000;          
          end else if(f_xy == 5b'100000) begin
            if (i_y_dest != Y_LOC) begin
              if (i_y_dest < Y_LOC) o_output_req = ((Y_LOC-i_y_dest)<=(Y_NODES-1-(Y_LOC-i_y_dest))) ? 7'b0001000 : 7'b0100000;
              if (i_y_dest > Y_LOC) o_output_req = ((i_y_dest-Y_LOC)<=(Y_NODES-1-(i_y_dest-Y_LOC))) ? 7'b0100000 : 7'b0001000;
            end else if (i_x_dest != X_LOC) begin
              if (i_x_dest < X_LOC) o_output_req = ((X_LOC-i_x_dest)<=(X_NODES-1-(X_LOC-i_x_dest))) ? 7'b0000100 : 7'b0010000; 
              if (i_x_dest > X_LOC) o_output_req = ((i_x_dest-X_LOC)<=(X_NODES-1-(i_x_dest-X_LOC))) ? 7'b0010000 : 7'b0000100;
            end else if (i_z_dest != Z_LOC) begin
              if (i_z_dest < Z_LOC) o_output_req = ((Z_LOC-i_z_dest)<=(Z_NODES-1-(Z_LOC-i_z_dest))) ? 7'b0000010 : 7'b0000001;
              if (i_z_dest > Z_LOC) o_output_req = ((i_z_dest-Z_LOC)<=(Z_NODES-1-(i_z_dest-Z_LOC))) ? 7'b0000001 : 7'b0000010;
            end else o_output_req = 7'b1000000;          
          end
        end
      end
    
    `endif
    
  `else
  
    `ifdef MESH

      // 3D Mesh Dimension Ordered Routing
      // --------------------------------------------------------------------------------------------------------------
      always_comb begin
        o_output_req = '0;
        if(i_val) begin
          if      (i_x_dest != X_LOC) o_output_req = (i_x_dest > X_LOC) ? 7'b0010000 : 7'b0000100;
          else if (i_y_dest != Y_LOC) o_output_req = (i_y_dest > Y_LOC) ? 7'b0100000 : 7'b0001000;
          else if (i_z_dest != Z_LOC) o_output_req = (i_z_dest > Z_LOC) ? 7'b0000001 : 7'b0000010;        
          else                        o_output_req = 7'b1000000;
        end
      end      
    
    `elsif CUBE
      
      // 3D Cube Dimension Ordered Routing.
      // --------------------------------------------------------------------------------------------------------------
      always_comb begin
        o_output_req = '0;
        if(i_val) begin
          if (i_x_dest != X_LOC) begin
            if (i_x_dest < X_LOC) o_output_req = ((X_LOC-i_x_dest)<=(X_NODES-1-(X_LOC-i_x_dest))) ? 7'b0000100 : 7'b0010000; 
            if (i_x_dest > X_LOC) o_output_req = ((i_x_dest-X_LOC)<=(X_NODES-1-(i_x_dest-X_LOC))) ? 7'b0010000 : 7'b0000100;
          end else if (i_y_dest != Y_LOC) begin
            if (i_y_dest < Y_LOC) o_output_req = ((Y_LOC-i_y_dest)<=(Y_NODES-1-(Y_LOC-i_y_dest))) ? 7'b0001000 : 7'b0100000;
            if (i_y_dest > Y_LOC) o_output_req = ((i_y_dest-Y_LOC)<=(Y_NODES-1-(i_y_dest-Y_LOC))) ? 7'b0100000 : 7'b0001000;
          end else if (i_z_dest != Z_LOC) begin
            if (i_z_dest < Z_LOC) o_output_req = ((Z_LOC-i_z_dest)<=(Z_NODES-1-(Z_LOC-i_z_dest))) ? 7'b0000010 : 7'b0000001;
            if (i_z_dest > Z_LOC) o_output_req = ((i_z_dest-Z_LOC)<=(Z_NODES-1-(i_z_dest-Z_LOC))) ? 7'b0000001 : 7'b0000010;
          end else o_output_req = 7'b1000000;
        end
      end
    
    `endif
    
  `endif

endmodule