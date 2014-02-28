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
// --------------------------------------------------------------------------------------------------------------------

`include "ENoC_Functions.sv"
`include "ENoC_Config.sv"

// --------------------------------------------------------------------------------------------------------------------
// Torus specific test parameters
// --------------------------------------------------------------------------------------------------------------------
`define DEGREE 5
`define X_LOC 4
`define Y_LOC 4
// `define X_HOTSPOT
// `define Y_HOTSPOT
 
// -------------------------------------------------------------------------------------------------------------------- 
// Non-torus specific test parameters
// --------------------------------------------------------------------------------------------------------------------
`define INPUTS 10
`define OUTPUTS 4
// `define HOTSPOT

// --------------------------------------------------------------------------------------------------------------------
// General test parameters
// --------------------------------------------------------------------------------------------------------------------
`define CLK_PERIOD 5ns
`define PACKETS_PER_PORT 5
// `define HOTSPOT_IN

// --------------------------------------------------------------------------------------------------------------------
// Traffic types
// --------------------------------------------------------------------------------------------------------------------
`define BERNOULLI 10
// `define BURST


module ENoC_Router_tb;

  logic clk, reset_n;
  
  // Upstream Bus.
  // ------------------------------------------------------------------------------------------------------------------
  packet_t [0:4] i_data;     // Input data from upstream [core, north, east, south, west]
  logic    [0:4] i_data_val; // Validates data from upstream [core, north, east, south, west]
  logic    [0:4] o_en;       // Enables data from upstream [core, north, east, south, west]
  
  // Downstream Bus
  // ------------------------------------------------------------------------------------------------------------------
  logic    [0:4] i_en;       // Enables output to downstream [core, north, east, south, west]
  packet_t [0:4] o_data;     // Outputs data to downstream [core, north, east, south, west]
  logic    [0:4] o_data_val; // Validates output data to downstream [core, north, east, south, west]
  
  logic    [0:4][2:0]  l_data_count;  // Used to count how many packets have been transmitted
  logic         [31:0] l_time;        // Used as a for time stamping
  
  // DUT
  // ------------------------------------------------------------------------------------------------------------------       

  `ifdef TORUS

  ENoC_Router #(.X_NODES(`X_NODES), 
                .Y_NODES(`Y_NODES),
                .X_LOC(`X_LOC),
                .Y_LOC(`Y_LOC),
                .INPUT_QUEUE_DEPTH(`INPUT_QUEUE_DEPTH),
                .N(5),
                .M(5))
    DUT_ENoC_Router (.*);
    
  `else
  
  ENoC_Router #(.NODES(`NODES), .LOC(`LOC), .INPUT_QUEUE_DEPTH(`INPUT_QUEUE_DEPTH), .N(`INPUTS), .M(`OUTPUTS))
    DUT_ENoC_Router (.*);  
  
  `endif
  
  // Clock Generation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    clk = 1;
    forever #(`CLK_PERIOD/2) clk = ~clk;
  end
  
  // Time Generation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    l_time = 0;
    forever #(`CLK_PERIOD) l_time = l_time + 1;
  end  
  
  // Reset Simulation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    reset_n = 0;
    #((`CLK_PERIOD)+3*(`CLK_PERIOD/4))
    reset_n = 1;
  end

  // Random Input Packet Generation.
  // ------------------------------------------------------------------------------------------------------------------  
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<`DEGREE; i++) begin
        l_data_count[i]  <= 0;
        i_en[i]          <= 0;        
        i_data[i].data   <= 1;
        i_data[i].source <= i;
        i_data[i].dest   <= 0;
        i_data[i].valid  <= 0;
      end
    end else begin
      for(int i=0; i<`DEGREE; i++) begin
        
        // Counter counts packets input to each port
        l_data_count[i] <= i_data[i].valid ? l_data_count[i] + 1 : l_data_count[i];
        
        // Simulate downstream routers enabling write permission 50% of the time. 
        i_en[i]         <= $urandom_range(1);
        
        // -- Populate input packets --

        // Packets declared valid randomly according to an offered traffic percentage, until a given number have been sent
        i_data[i].valid <= (l_data_count[i] < `PACKETS_PER_PORT) ? $urandom_range(1) : 0;          
        
        // each valid packets will be given a number, starting from 1.
        i_data[i].data  <= i_data[i].valid ? i_data[i].data  + 1 : i_data[i].data;
        
        // Packets given a destination, equal chance to be any node destination
        `ifdef TORUS
          i_data[i].dest  <= $urandom_range(`NODES-1);        
          // i_data[i].x_dest <= $urandom_range(`X_NODES-1);
          // i_data[i].y_dest <= $urandom_range(`Y_NODES-1);
        `else
          i_data[i].dest  <= $urandom_range(`NODES-1);
        `endif

      end
    end
  end
 
  // packet_t carries a valid in the packet, the mesh flow control uses its own valid/enable protocol and flag gen.
  // for simplicity they are just connected here.
  // ------------------------------------------------------------------------------------------------------------------   
  always_comb begin
    for(int i=0; i<`DEGREE; i++) begin
      i_data_val[i] = i_data[i].valid;
    end
  end
  
  // Test functions
  // ------------------------------------------------------------------------------------------------------------------ 
  initial begin
    $display("Test starting. %d packets will be sent at an offered traffic ratio of %d", `PACKETS_PER_PORT*5, `LOAD);
  end
  
endmodule
  