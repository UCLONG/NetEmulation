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
`define N 5
`define M 5
// `define HOTSPOT

// --------------------------------------------------------------------------------------------------------------------
// General test parameters
// --------------------------------------------------------------------------------------------------------------------
`define CLK_PERIOD 5ns

// `define HOTSPOT_IN

// --------------------------------------------------------------------------------------------------------------------
// Traffic
// --------------------------------------------------------------------------------------------------------------------
`define PACKETS_PER_PORT 3
`define PACKET_RATE 50 // Integer number between 1 and 100, representing percent of offered traffic
`define BURST_SIZE 1

// --------------------------------------------------------------------------------------------------------------------
// Test Bench
// --------------------------------------------------------------------------------------------------------------------

module ENoC_Router_tb;

  logic clk, reset_n;
  
  // Upstream Router Bus.
  // ------------------------------------------------------------------------------------------------------------------
  packet_t [0:`N-1] i_data;     // Input data from upstream [core, north, east, south, west]
  logic    [0:`N-1] i_data_val; // Validates data from upstream [core, north, east, south, west]
  logic    [0:`N-1] o_en;       // Enables data from upstream [core, north, east, south, west]
  
  // Downstream Router Bus
  // ------------------------------------------------------------------------------------------------------------------
  logic    [0:`M-1] i_en;       // Enables output to downstream [core, north, east, south, west]
  packet_t [0:`M-1] o_data;     // Outputs data to downstream [core, north, east, south, west]
  logic    [0:`M-1] o_data_val; // Validates output data to downstream [core, north, east, south, west]
  
  // FIFO signals
  // ------------------------------------------------------------------------------------------------------------------
  packet_t [0:`N-1] s_i_data;     // Input data from upstream [core, north, east, south, west]
  logic    [0:`N-1] s_i_data_val; // Validates data from upstream [core, north, east, south, west]
  logic    [0:`N-1] f_saturate;
  
  // Packet Generation Flags
  // ------------------------------------------------------------------------------------------------------------------  
  logic [0:`N-1] f_data_val;
  logic [0:`N-1] f_measure;
  `ifdef TORUS  
    logic [0:`N-1][log2(`X_NODES)-1:0] f_x_dest;
    logic [0:`N-1][log2(`Y_NODES)-1:0] f_y_dest;
  `else
    logic [0:`N-1][log2(`NODES)-1:0] f_dest;
  `endif
  
  // Control Flags
  // ------------------------------------------------------------------------------------------------------------------  
  logic    [0:`N-1][2:0]  f_burst_count;  // Used to count how many packets have been transmitted
  logic    [0:`N-1][2:0]  f_port_i_data_count;  // Used to count how many packets have been transmitted
  logic            [31:0] f_total_i_data_count; // Used to count how many packets have been transmitted
  logic    [0:`N-1][2:0]  f_port_o_data_count;  // Used to count how many packets have been received
  logic            [31:0] f_total_o_data_count; // Used to count how many packets have been received
  logic            [31:0] f_time;             // Used as a for time stamping
  
  // DUT
  // ------------------------------------------------------------------------------------------------------------------       

  `ifdef TORUS

  ENoC_Router #(.X_NODES(`X_NODES), 
                .Y_NODES(`Y_NODES),
                .X_LOC(`X_LOC),
                .Y_LOC(`Y_LOC),
                .INPUT_QUEUE_DEPTH(`INPUT_QUEUE_DEPTH),
                .N(`N),
                .M(`M))
    DUT_ENoC_Router (.*);
    
  `else
  
  ENoC_Router #(.NODES(`NODES),
                .LOC(`LOC),
                .INPUT_QUEUE_DEPTH(`INPUT_QUEUE_DEPTH),
                .N(`INPUTS),
                .M(`OUTPUTS))
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
    f_time = 0;
    forever #(`CLK_PERIOD) f_time = f_time + 1;
  end  
  
  // Reset Simulation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    reset_n = 0;
    #((`CLK_PERIOD)+3*(`CLK_PERIOD/4))
    reset_n = 1;
  end

  // Downstream Router simulation
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<`M; i++) begin
        i_en[i] <= 0;
      end
    end else begin
      for(int i=0; i<`M; i++) begin
        i_en[i] <= $urandom_range(1); // Simulates downstream routers enabling write permission 50% of the time. 
      end
    end
  end
  
  // Node Simulation
  // ------------------------------------------------------------------------------------------------------------------
  genvar i;
  generate
    for (i=0; i<`N; i++) begin : GENERATE_INPUT_QUEUES
      LIB_FIFO_packet_t #(.DEPTH(`INPUT_QUEUE_DEPTH))
        gen_LIB_FIFO_packet_t (.clk,
                               .ce(1'b1),
                               .reset_n,
                               .i_data(s_i_data[i]),         // From the simulated input data
                               .i_data_val(s_i_data_val[i]), // From the simulated input data
                               .i_en(o_en[i]),               // From the Router
                               .o_data(i_data[i]),           // To the Router
                               .o_data_val(i_data_val[i]),   // To the Router
                               .o_en(f_saturate[i]),         // Used to indicate router saturation
                               .o_full(),                    // Not connected, o_en used for flow control
                               .o_empty(),                   // Not connected, not required for simple flow control
                               .o_near_empty());             // Not connected, not required for simple flow control
    end
  endgenerate
  
  // Packet Counters.
  // ------------------------------------------------------------------------------------------------------------------
  
  // These counters are clocked, so the value during a given clock cycle does not account for what is happening that
  // cycle.  This must be considered carefully when using the value for control.
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<`N; i++) begin
        f_port_i_data_count[i] <= 0;
        f_port_o_data_count[i] <= 0;        
      end   
    end else begin
      for(int i=0; i<`N; i++) begin
        f_port_i_data_count[i]  <= s_i_data[i].valid ? f_port_i_data_count[i] + 1 : f_port_i_data_count[i];
        f_port_o_data_count[i]  <= o_data[i].valid   ? f_port_o_data_count[i] + 1 : f_port_o_data_count[i];
      end
    end
  end
  
  always_comb begin
    f_total_i_data_count = 0;
    f_total_o_data_count = 0;
    for(int i=0; i<`N; i++) begin  
      f_total_i_data_count = f_port_i_data_count[i] + f_total_i_data_count;
      f_total_o_data_count = f_port_o_data_count[i] + f_total_o_data_count;
    end
  end
        
  // Destination Flag Generation
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<`N; i++) begin
      `ifdef TORUS
        f_x_dest[i] <= 0;
        f_y_dest[i] <= 0;
      `else
        f_dest[i] <= 0;
      `endif
      end
    end else begin
      for(int i=0; i<`N; i++) begin
      `ifdef TORUS
        f_x_dest[i] <= $urandom_range(`X_NODES-1);
        f_y_dest[i] <= $urandom_range(`Y_NODES-1);
      `else
        f_dest[i] <= $urandom_range(`NODES-1);
      `endif
      end
    end
  end
  
  // Measure Flag Generation
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<`N; i++) begin
        f_measure[i] <= 0;
      end
    end else begin
      for(int i=0; i<`N; i++) begin
        f_measure[i] <= 1;
      end
    end
  end
  
  // Valid Flag Generation
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<`N; i++) begin
        f_data_val[i] <= 0;
        f_burst_count[i] <= 0;
      end
    end else begin
      for(int i=0; i<`N; i++) begin
        if ($urandom_range((100/`PACKET_RATE)*`BURST_SIZE,1) == 1) begin
          f_data_val[i]    <= 1;
          f_burst_count[i] <= `BURST_SIZE-1 + f_burst_count[i];
          // f_burst_count[i] <= $urandom_range((`BURST_SIZE*2)-1,0) + f_burst_count[i];            
        end else if (f_burst_count[i] > 0) begin
          f_data_val[i]    <= 1;
          f_burst_count[i] <= f_burst_count[i] - 1;
        end else begin
          f_data_val[i]    <= 0;
          f_burst_count[i] <= 0;
        end
      end
    end
  end  
  
  // Populate input data
  // ------------------------------------------------------------------------------------------------------------------  
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<`N; i++) begin
        s_i_data[i].data      <= 1; // Data field used to number packets
        `ifdef TORUS
        s_i_data[i].x_source  <= i;
        s_i_data[i].y_source  <= i;
        s_i_data[i].x_dest    <= 0;
        s_i_data[i].y_dest    <= 0;        
        `else
        s_i_data[i].source    <= i; // Source field used to indicate which input port the data was sent
        s_i_data[i].dest      <= 0; // Route calculation is performed on the destination field.
        `endif
        s_i_data[i].valid     <= 0; // Valid field indicates if the packet is valid or not
        s_i_data[i].timestamp <= 0; // Timestamp field used to indicate when packet was generated
        s_i_data[i].measure   <= 0; // Measure field used to indicate if packet should be measured      
      end
    end else begin
      for(int i=0; i<`N; i++) begin
        s_i_data[i].data      <= s_i_data[i].valid ? s_i_data[i].data  + 1 : s_i_data[i].data;       
        `ifdef TORUS
        s_i_data[i].x_dest    <= f_x_dest[i];
        s_i_data[i].y_dest    <= f_y_dest[i];
        `else
        s_i_data[i].dest      <= f_dest[i];
        `endif
        // s_i_data[i].valid uses a count flag, the count flag doesn't consider what is happening during the current
        // cycle, so when comparing with the flag, it needs to be checked that all packets have been counted.
        s_i_data[i].valid     <= (f_port_i_data_count[i] < `PACKETS_PER_PORT - 1) 
                                 || ((f_port_i_data_count[i] < `PACKETS_PER_PORT) && (s_i_data[i].valid != 1)) 
                                 ? f_data_val[i] : 0;
        s_i_data[i].timestamp <= f_time + 1;
        s_i_data[i].measure   <= f_measure[i];
      end
    end
  end
 
  // packet_t carries a valid in the packet, the mesh flow control uses its own valid/enable protocol and flag gen.
  // for simplicity they are just connected here.
  // ------------------------------------------------------------------------------------------------------------------   
  always_comb begin
    for(int i=0; i<`N; i++) begin
      s_i_data_val[i] = s_i_data[i].valid;
    end
  end
  
  // Test functions
  // ------------------------------------------------------------------------------------------------------------------ 
  initial begin
    $display("Test starting. %5d packets will be sent at an offered traffic ratio of %5d", `PACKETS_PER_PORT*`N, `PACKET_RATE);
    forever @(negedge clk) begin
      if (f_total_o_data_count == `PACKETS_PER_PORT*`N) begin
        $display("Recieved all %5d packets", `PACKETS_PER_PORT*`N);
        $finish;
      end
    end
  end
  
endmodule
  