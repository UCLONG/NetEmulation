// --------------------------------------------------------------------------------------------------------------------
// IP Block    : MESH
// Function    : Switch_tb
// Module name : MESH_Switch_tb
// Description : Tests the switch module as a five port instance.
// Uses        : MESH_Switch.sv
// Notes       : As in the router design, l_output_grant is a onehot grant vector used as a switch command.  In the
//             : test bench this is copied into packet_t.dest for ease of debug.  However, if the definition in the 
//             : config.sv file doesn't ensure packet_t.dest is five bits this might cause problems.
// --------------------------------------------------------------------------------------------------------------------

`include "config.sv"

module LIB_Switch_OneHot_packet_t_tb;

  logic clk, reset_n;
  
  packet_t i_data     [0:4];  // Input data from upstream [core, north, east, south, west]  
  packet_t o_data     [0:4];  // Outputs data to downstream [core, north, east, south, west]
  
  logic    [0:4] l_output_grant [0:4]; // Simulates arbitration results
  int i, j;

  
  // DUT
  // ------------------------------------------------------------------------------------------------------------------       
  LIB_Switch_OneHot_packet_t #(.RADIX(5))
    inst_LIB_Switch_OneHot_packet_t (.i_sel(l_output_grant), // From the Switch Control
                                     .i_data(i_data),        // From the local FIFOs
                                     .o_data(o_data));       // To the downstream routers
  
  // Clock Generation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    clk = 0;
    forever #100ps clk = ~clk;
  end

  // Reset Simulation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    reset_n = 0;
    #150ps
    reset_n = 1;
  end
 
  // Systematic switching.  Starting with input 0, switch to output 0 through to 5, increment input and repeat.
  // ------------------------------------------------------------------------------------------------------------------  
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int in=0; in<5; in++) begin
        i_data[in].data    <= 1;
        i_data[in].source  <= in; // Stores the number of the input (0 through 5)
        i_data[in].dest    <= 0;
        i_data[in].valid   <= 0;
        l_output_grant[in] <= 0;
        i <= 0;
        j <= 0;
      end
    end else begin
      if(i<4) begin
        if(j<4) begin
          i_data[i].data    <= j;
          i_data[i].dest    <= (1<<4-j);
          l_output_grant[i] <= (1<<4-j);
          i_data[i].valid   <= 1;
          if(i>0) begin 
            i_data[i-1].valid <= 0;
            l_output_grant[i-1] <= 0;
          end else begin
            i_data[4].valid <= 0;
            l_output_grant[4] <= 0;
          end            
          j <= j+1;
        end else begin
          i_data[i].data    <= i;
          i_data[i].dest    <= (1<<4-j);
          l_output_grant[i] <= (1<<4-j);
          i_data[i].valid   <= 1;
          if(i>0) begin 
            i_data[i-1].valid <= 0;
            l_output_grant[i-1] <= 0;
          end else begin
            i_data[4].valid <= 0;
            l_output_grant[4] <= 0;
          end   
          j <= 0;
          i <= i+1;
        end
      end else begin
        if(j<4) begin
          i_data[i].data    <= i;
          i_data[i].dest    <= (1<<4-j);
          l_output_grant[i] <= (1<<4-j);
          i_data[i].valid   <= 1;
          if(i>0) begin 
            i_data[i-1].valid <= 0;
            l_output_grant[i-1] <= 0;
          end
          j <= j+1;
        end else begin
          i_data[i].data    <= i;
          i_data[i].dest    <= (1<<4-j);
          l_output_grant[i] <= (1<<4-j);
          i_data[i].valid   <= 1;
          if(i>0) begin 
            i_data[i-1].valid <= 0;
            l_output_grant[i-1] <= 0;
          end else begin
            i_data[4].valid <= 0;
            l_output_grant[4] <= 0;
          end   
          j <= 0;
          i <= 0;
        end 
      end
    end
  end
  
endmodule