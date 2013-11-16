// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Function    : RouteCalculator
// Module name : ENoC_RouteCalculator
// Description : Calculates which output port is required by comparing the current location of the packet with its
//             : destination.  Currently, only oblivious Dimension ordered routing is used.
// Notes       : Danny Ly has prepared an adaptive routing mechanism that will be added in the next version.
//             : Untested
// --------------------------------------------------------------------------------------------------------------------

`include "ENoC_Config.sv"

module ENoC_RouteCalculator

#(parameter X_NODES,
  parameter Y_NODES,
  parameter X_LOC,
  parameter Y_LOC)
  
 (input  logic [log2(X_NODES)-1:0] i_x_dest, // Packet destination on the x axis
  input  logic [log2(Y_NODES)-1:0] i_y_dest, // Packet destination on the Y axis
  input  logic                     i_val,    // Valid destination
  
  output logic               [0:4] o_output_req); // One-hot request for the [c,n,e,s,w] output port
  

  
  `ifdef TORUS
  
    `ifdef ADAPTIVE
  
      // DEFINE ADAPTIVE TORUS ROUTING ALGORITHMS HERE
      
    `else
    
      // Torus Dimension Ordered Routing
      // ----------------------------------------------------------------------------------------------------------------
      always_comb begin
        o_output_req = '0;
        if(i_val) begin
          if(i_x_dest == X_LOC) begin
            if(i_y_dest == Y_LOC) begin
              o_output_req = 5'b10000; // Local Core
            
            end else if(i_y_dest > Y_LOC) begin
              o_output_req = 5'b01000; // North
            end else begin
              o_output_req = 5'b00010; // South
            end
            
          end else if(i_x_dest > X_LOC) begin
            o_output_req = 5'b00100; // East
          end else begin
            o_output_req = 5'b00001; // West
          end
        end else begin
          o_output_req = 5'b00000; // No request
        end
      end  
      
    `endif
  
  `else
  
    `ifdef ADAPTIVE
    
      // DEFINE ADAPTIVE MESH ROUTING ALGORITHM HERE
    
    `else

      // 2D Mesh Dimension Ordered Routing
      // ----------------------------------------------------------------------------------------------------------------
      always_comb begin
        o_output_req = '0;
        if(i_val) begin
          if(i_x_dest == X_LOC) begin
            if(i_y_dest == Y_LOC) begin
              o_output_req = 5'b10000; // Local Core
            end else if(i_y_dest > Y_LOC) begin
              o_output_req = 5'b01000; // North
            end else begin
              o_output_req = 5'b00010; // South
            end
          end else if(i_x_dest > X_LOC) begin
            o_output_req = 5'b00100;   // East
          end else begin
            o_output_req = 5'b00001;   // West
          end
        end else begin
          o_output_req = 5'b00000;     // No request
        end
      end      

    `endif
  
  `endif

endmodule