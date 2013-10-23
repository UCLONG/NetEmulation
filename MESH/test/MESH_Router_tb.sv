// --------------------------------------------------------------------------------------------------------------------
// IP Block    : MESH
// Function    : Router_tb
// Module name : MESH_Router_tb
// Description : Tests various modules together as a 5 port, input buffered router
// Uses        : config.sv, LIB_pktFIFO.sv, MESH_RouteCalculator.sv, MESH_Switch.sv, MESH_SwitchControl.sv
// Notes       : Uses the packet_t typedef from config.sv.  packet_t contains node destination information as a single
//             : number encoded as logic.  If `PORTS is a function of 2^n this will not cause problems as the logic
//             : can simply be split in two, each half representing either the X or Y direction.  This will not work
//             : otherwise.
//             : Untested.
// --------------------------------------------------------------------------------------------------------------------

`include "C://Users//Danny//Documents//GitHub//NetEmulation//MESH//src//config.sv"

module MESH_Router_tb;

  logic clk, reset_n;
  
  // Upstream Bus.
  // ------------------------------------------------------------------------------------------------------------------
  packet_t i_data     [0:4]; // Input data from upstream [core, north, east, south, west]
  logic    i_data_val [0:4]; // Validates data from upstream [core, north, east, south, west]
  logic    o_en       [0:4]; // Enables data from upstream [core, north, east, south, west]
  
  // Downstream Bus
  // ------------------------------------------------------------------------------------------------------------------
  logic    i_en       [0:4];  // Enables output to downstream [core, north, east, south, west]
  packet_t o_data     [0:4];  // Outputs data to downstream [core, north, east, south, west]
  logic    o_data_val [0:4]; // Validates output data to downstream [core, north, east, south, west]
  
  // DUT
  // ------------------------------------------------------------------------------------------------------------------       
  MESH_Router #(.X_NODES(4), .Y_NODES(4), .X_LOC(01), .Y_LOC(01)) // inside a 16 node mesh
    inst_MESH_Router (.*);
  
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

  // Random Input Flag Generation.
  // ------------------------------------------------------------------------------------------------------------------  
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<5; i++) begin
        i_data[i].source <= i; // For ease of debug, this does not change.
        i_data[i].dest   <= 0;
        i_data[i].valid  <= 0;
        i_en[i]          <= 0;
      end
    end else begin
      for(int i=0; i<5; i++) begin
        i_data[i].dest  <= $dist_uniform(i_data[i].dest, 0, 3); // Equal chance to be any node destination
        i_data[i].valid <= $dist_uniform(i_data_val, 0, 1);     // 50% of the time input data will be valid.
        i_en[i]         <= $dist_uniform((i_data_val+5), 0, 1); // Downstream write permission 50% of the time.     
      end
    end
  end
 
  // Input Data Generation.  Input data is chosen to display a hex word dependent upon which direction it is headed.
  // ------------------------------------------------------------------------------------------------------------------   
  always_comb begin
    for(int i=0; i<5; i++) begin
      if(i_data[i].dest[1:0] == 1) begin
        if(i_data[i].dest[3:2] == 1) begin
          i_data[i].data = 16'hDEAD; // Local Core
        end else if(i_data[i].dest[3:2] > 1) begin
          i_data[i].data = 16'hBEEF; // North
        end else begin
          i_data[i].data = 16'hCAFE; // South
        end
      end else if(i_data[i].dest[1:0] > 1) begin
        i_data[i].data = 16'hB0A7; // East
      end else begin
        i_data[i].data = 16'h10AD; // West
      end
    end
    // packet_t carries a valid in the packet, the mesh flow control uses its own valid/enable protocol and flag gen.
    // for simplicity they are just connected here.
    for(int i=0; i<5; i++) begin
      i_data_val[i] = i_data[i].valid;
    end
  end
  
endmodule
  
