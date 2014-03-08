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
 
// -------------------------------------------------------------------------------------------------------------------- 
// Non-torus specific test parameters
// --------------------------------------------------------------------------------------------------------------------
`define N 5
`define M 5

// --------------------------------------------------------------------------------------------------------------------
// General test parameters
// --------------------------------------------------------------------------------------------------------------------
`define CLK_PERIOD 5ns

// --------------------------------------------------------------------------------------------------------------------
// Traffic
// --------------------------------------------------------------------------------------------------------------------
`define PACKET_RATE 30      // Integer number between 1 and 100, representing percent of offered traffic
`define PACKETS_PER_PORT 100
`define PACKET_BURST_SIZE 1
`define WARM_UP_PACKETS_PER_PORT 30
`define DOWNSTREAM_EN_RATE 100

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
  
  // Random Flags
  // ------------------------------------------------------------------------------------------------------------------  
  logic [0:`N-1] f_data_val;
  `ifdef TORUS  
    logic [0:`N-1][log2(`X_NODES)-1:0] f_x_dest;
    logic [0:`N-1][log2(`Y_NODES)-1:0] f_y_dest;
  `else
    logic [0:`N-1][log2(`NODES)-1:0] f_dest;
  `endif
  
  // Control Flags
  // ------------------------------------------------------------------------------------------------------------------  
  integer f_burst_count [0:`N-1] ;      // Used to count how many packets have been transmitted
  integer f_port_i_data_count [0:`N-1]; // Used to count how many packets have been transmitted
  integer f_total_i_data_count;         // Used to count how many packets have been transmitted
  integer f_port_o_data_count [0:`N-1]; // Used to count how many packets have been received
  integer f_total_o_data_count;         // Used to count how many packets have been received
  longint f_time;                       // Used as a for time stamping
  real    f_total_latency;              // Counts the total amount of time all packets have spent in the router
  integer f_cooldown_count;             // Used to ensure router has finished outputting packets
  real    f_average_latency;            // Calculates the average latency of measured packets
  real    f_measured_packet_count;      // Number of packets measured
  integer f_routing_fail_count;         // Used to count the total number of routing failures
  logic   f_test_complete;
  logic   f_test_abort;
  logic   f_test_fail;
  logic   f_txrx;
  
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
  
  // SIMULATION: Clock and Time
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    clk = 1;
    forever #(`CLK_PERIOD/2) clk = ~clk;
  end
  
  initial begin
    f_time = 0;
    forever #(`CLK_PERIOD) f_time = f_time + 1;
  end  
  
  // SIMULATION:  Reset
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    reset_n = 0;
    #((`CLK_PERIOD)+3*(`CLK_PERIOD/4))
    reset_n = 1;
  end

  // SIMULATION:  Downstream Router
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<`M; i++) begin
        i_en[i] <= 0;
      end
    end else begin
      for(int i=0; i<`M; i++) begin
        i_en[i] <= ($urandom_range(100,1) <= `DOWNSTREAM_EN_RATE) ? 1 : 0;
      end
    end
  end
  
  // SIMULATION:  Upstream Routers and Node
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
        
  // RANDOM FLAG:  Destination
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
  
  // RANDOM FLAG:  Valid
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<`N; i++) begin
        f_data_val[i] <= 0;
        f_burst_count[i] <= 0;
      end
    end else begin
      for(int i=0; i<`N; i++) begin
        if ($urandom_range((100/`PACKET_RATE)*`PACKET_BURST_SIZE,1) == 1) begin
          f_data_val[i]    <= 1;
          f_burst_count[i] <= `PACKET_BURST_SIZE-1 + f_burst_count[i];           
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
        s_i_data[i].x_source  <= i; // Source field used to declare which input port packet was presented to
        s_i_data[i].y_source  <= i; // Source field used to declare which input port packet was presented to
        s_i_data[i].x_dest    <= 0; // Destination field indicates where packet is to be routed to
        s_i_data[i].y_dest    <= 0; // Destination field indicates where packet is to be routed to      
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
        s_i_data[i].valid     <= (f_port_i_data_count[i] < `PACKETS_PER_PORT) ? f_data_val[i] : 0;
        s_i_data[i].timestamp <= f_time + 1;
        s_i_data[i].measure   <= (f_port_i_data_count[i] > `WARM_UP_PACKETS_PER_PORT) ? 1 : 0;
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
  
  // Packet Counters.
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(negedge clk) begin
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
    
  // TEST FUNCTION: Latency
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    f_total_latency         = 0;
    f_average_latency       = 0;
    f_measured_packet_count = 0;
    forever @(negedge clk) begin
      for (int i=0; i<`M; i++) begin
        if ((o_data_val[i] == 1) && (o_data[i].measure == 1)) begin
          f_total_latency = f_total_latency + (f_time - o_data[i].timestamp);
          f_measured_packet_count = f_measured_packet_count + 1;
        end
      end
      if (f_total_latency != 0) begin
        f_average_latency = f_total_latency/f_measured_packet_count;
      end
    end
  end
  
  // TEST FUNCTION: Saturation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    forever @(negedge clk) begin
      for (int i=0; i<`N; i++) begin
        if (f_saturate[i] == 0) begin
          $display("ABORT:  Input port %g saturated", i);
          $display("");
          f_test_complete = 1;
          f_test_abort = 1;
          f_test_fail = 1;
        end
      end
    end
  end
  
  // TEST FUNCTION: Routing
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    f_routing_fail_count = 0;
    forever @(negedge clk) begin
      for (int i=0; i<`M; i++) begin
        if (o_data_val[i] == 1) begin
          if ((o_data[i].x_dest > `X_LOC) && (i != 2)) begin
            $display ("Routing error number %g at time %g.  The packet output on port %g should have left port 2", f_routing_fail_count + 1, f_time, i);
            $display("");
            f_routing_fail_count = f_routing_fail_count + 1;
            f_test_fail  = 1;
          end else if ((o_data[i].x_dest < `X_LOC) && (i != 4)) begin
            $display ("Routing error number %g at time %g.  The packet output on port %g should have left port 4", f_routing_fail_count + 1, f_time, i);
            $display("");
            f_routing_fail_count = f_routing_fail_count + 1;
            f_test_fail  = 1;
          end else if ((o_data[i].x_dest == `X_LOC) && (o_data[i].y_dest > `Y_LOC) && (i != 1)) begin
            $display ("Routing error number %g at time %g.  The packet output on port %g should have left port 1", f_routing_fail_count + 1, f_time, i);
            $display("");
            f_routing_fail_count = f_routing_fail_count + 1;
            f_test_fail  = 1;
          end else if ((o_data[i].x_dest == `X_LOC) && (o_data[i].y_dest < `Y_LOC) && (i != 3)) begin
            $display ("Routing error number %g at time %g.  The packet output on port %g should have left port 3", f_routing_fail_count + 1, f_time, i);
            $display("");
            f_routing_fail_count = f_routing_fail_count + 1;
            f_test_fail  = 1;
          end else if ((o_data[i].x_dest == `X_LOC) && (o_data[i].y_dest == `Y_LOC) && (i != 0)) begin
            $display ("Routing error number %g at time %g.  The packet output on port %g should have left port 0", f_routing_fail_count + 1, f_time, i);
            $display("");
            f_routing_fail_count = f_routing_fail_count + 1;
            f_test_fail  = 1;
          end
        end
      end
    end
  end
  
  // TEST FUNCTION: Comparing packets in and out.  In this case, every packet is accounted for, not just the ones for
  // which latency will be measured
  // ------------------------------------------------------------------------------------------------------------------ 
  initial begin
    f_cooldown_count = 0;
    forever @(negedge clk) begin
      if (f_total_o_data_count > `PACKETS_PER_PORT*`N) begin
        if (f_cooldown_count < 100) begin
          f_cooldown_count = f_cooldown_count + 1;
        end else begin
          f_txrx = 0;
          f_test_complete = 1;
          f_test_fail = 1;
        end
      end else if (f_total_o_data_count == `PACKETS_PER_PORT*`N) begin
        if (f_cooldown_count < 100) begin
          f_cooldown_count = f_cooldown_count + 1;
        end else begin
          f_txrx = 1;
          f_test_complete = 1;
        end
      end else if (o_data_val == 0) begin
        if (f_cooldown_count <100) begin
          f_cooldown_count = f_cooldown_count + 1;
        end else begin
          f_txrx = 0;
          f_test_complete = 1;
        end
      end else begin
        f_cooldown_count = 0;           
      end
    end
  end

  // TEST CONTROL
  // ------------------------------------------------------------------------------------------------------------------   
  initial begin
    $display("");
    $display("%g packets will be sent at an offered traffic ratio of %g%%", `PACKETS_PER_PORT*`N, `PACKET_RATE);
    $display("To ensure the network is steady, latency measurements will not be performed on the first %g packets sent on each port", `WARM_UP_PACKETS_PER_PORT);
    $display("The simulated downstream routers will accept data %g%% of the time", `DOWNSTREAM_EN_RATE);
    $display("");
    $display("TEST START");
    $display("----------");
    $display ("");
    forever@(posedge clk) begin
      if (f_test_complete) begin
        if (f_test_abort) begin
          $display("Test aborted after %g cycles", f_time);
        end else begin
          $display("Test completed after %g cycles", f_time);
        end
        $display("");
        $display("TEST SUMMARY");
        $display("------------");
        if (f_test_fail) begin
          $display("");
          $display("Test Failed!");
        end else begin
          $display("");
          $display("All Tests Passed!");
        end
        if (f_txrx == 1) begin
          $display("TXRX PASS: Transmitted %g packets, received %g packets", f_total_i_data_count, f_total_o_data_count);
        end else begin
          $display("TXRX FAIL: Transmitted %g packets, received %g packets", f_total_i_data_count, f_total_o_data_count);       
        end
        if (f_routing_fail_count > 0) begin
          $display("ROUTING FAIL: %g routing failures", f_routing_fail_count);
        end else begin
          $display("ROUTING PASS: no output packets were misrouted");
        end
        $display("AVERAGE LATENCY: %g cycles", f_average_latency);
        $display("");
        $finish;
      end
    end
  end
  
endmodule
  