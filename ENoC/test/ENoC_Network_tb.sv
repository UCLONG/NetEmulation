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
// Test Bench
// --------------------------------------------------------------------------------------------------------------------

module ENoC_Network_tb 

#(parameter   integer SEED               = 0,
  parameter           CLK_PERIOD         = 5ns,
  parameter   integer PACKET_RATE        = 50,     // Offered traffic as percent of capacity
  parameter   integer WARM_UP_PACKETS    = 1000,  // Number of packets to warm-up the network
  parameter   integer MEASURE_PACKETS    = 5000,  // Number of packets to be measured
  parameter   integer DRAIN_PACKETS      = 500,    // Number of packets to drain the network
  parameter   integer DOWNSTREAM_EN_RATE = 100,    // Percent of time simulated nodes able to receive data
  parameter   integer BATCH_NUMBER       = 60,
  parameter   integer BATCH_SIZE         = 100,

  `ifdef TORUS
    parameter integer X_NODES = `X_NODES,                     // Number of node columns
    parameter integer Y_NODES = `Y_NODES,                     // Number of node rows
    parameter integer Z_NODES = `Z_NODES,                     // Number of node layers
    parameter integer NODES   = `X_NODES*`Y_NODES*`Z_NODES,   // Total number of nodes
    parameter integer ROUTERS = `X_NODES*`Y_NODES*`Z_NODES,   // Total number of routers
  `else
    parameter integer NODES   = `NODES,                       // Total number of nodes
    parameter integer ROUTERS = `ROUTERS,                     // Total number of routers
  `endif
  parameter   integer N       = `N,                           // Number of inputs per router
  parameter   integer M       = `M,  
  parameter   integer INPUT_QUEUE_DEPTH = `INPUT_QUEUE_DEPTH,  
  parameter   integer NODE_QUEUE_SIZE = `INPUT_QUEUE_DEPTH*4);

  logic clk, reset_n;
  
  // Node Input Bus.
  // ------------------------------------------------------------------------------------------------------------------
  packet_t [0:NODES-1] i_data;     // Input data to network from upstream nodes
  logic    [0:NODES-1] i_data_val; // Validates input data from upstream nodes
  logic    [0:NODES-1] o_en;       // Enables input data from upstream nodes to network
  
  // Node Output Bus
  // ------------------------------------------------------------------------------------------------------------------
  logic    [0:NODES-1] i_en;       // Enables output data from network to downstream nodes
  packet_t [0:NODES-1] o_data;     // Outputs data from network to downstream nodes
  logic    [0:NODES-1] o_data_val; // Validates output data to downstream nodes
  
  // Input Queue FIFO signals
  // ------------------------------------------------------------------------------------------------------------------
  packet_t [0:NODES-1] s_i_data;     // Input data from upstream [core, north, east, south, west]
  logic    [0:NODES-1] s_i_data_val; // Validates data from upstream [core, north, east, south, west]
  logic    [0:NODES-1] f_saturate;
  
  // Random Flags
  // ------------------------------------------------------------------------------------------------------------------  
  integer f_random_init;
  
  // Updating any value with $urandom(SEED) will change the sequence of all randomly generated numbers that use the
  // $urandom or $urandom_range call.  Here, a dummy variable is initialised using the parameter SEED.  For a given 
  // seed, the patterns will be individual but repeatable.
  initial begin
    f_random_init = $urandom(SEED);
  end
  
  logic [0:NODES-1] f_data_val;
  `ifdef TORUS  
    logic [0:NODES-1][log2(X_NODES)-1:0] f_x_dest;
    logic [0:NODES-1][log2(Y_NODES)-1:0] f_y_dest;
    logic [0:NODES-1][log2(Z_NODES)-1:0] f_z_dest;
  `else
    logic [0:NODES-1][log2(NODES)-1:0] f_dest;
  `endif
  
  // Control Flags
  // ------------------------------------------------------------------------------------------------------------------  
  longint f_time;                       // Pseudo time value/clock counter
  integer f_drain_count;                // Counts cycles computer has been draining for
  
  integer f_port_i_data_count [0:NODES-1]; // Count number of transmitted packets on each port
  integer f_total_i_data_count;             // Count total number of transmitted packets
  integer f_port_o_data_count [0:NODES-1]; // Count number of received packets on each port
  integer f_total_o_data_count;             // Count total number of received packets

  real    f_total_latency;         // Counts the total amount of time all measured packets have spent in the router
  real    f_average_latency;       // Calculates the average latency of measured packets
  real    f_measured_packet_count; // Number of packets measured
  
  real    f_batch_total_latency [0:BATCH_NUMBER-1];         // Counts the total amount of time all measured packets in a batch have spent in the router
  real    f_batch_average_latency [0:BATCH_NUMBER-1];       // Calculates the average latency of measured packets in a batch
  real    f_batch_measured_packet_count [0:BATCH_NUMBER-1]; // Number of packets measured per batch
  integer f_batch_number;                                    // Used to reference batches
  
  real    f_throughput_port_o_packet_count [0:NODES-1]; // counts number of packets received over a given number of cycles
  real    f_throughput_port_i_packet_count [0:NODES-1]; // counts number of packets transmitted over a given number of cycles 
  real    f_throughput_total_o_packet_count; // counts number of packets received over a given number of cycles
  real    f_throughput_total_i_packet_count; // counts number of packets transmitted over a given number of cycles   
  real    f_throughput_cycle_count;    // counts the number of cycles f_throughput_packet_count has been counting
  real    f_throughput;                // calculates throughput
  real    f_offered;                   // calculates the actual offered traffic rate whilst throughput is being measured
  
  integer f_routing_fail_count; // Used to count the total number of routing failures
  logic   f_test_complete;      // Logic high to indicate the test process is finished
  logic   f_test_abort;         // Logic high to indicate the test process was aborted
  logic   f_test_fail;          // Logic high to indicate the test process failed
  logic   f_txrx;               // Logic high to indicate all transmitted packets were received
  
  integer resultstxt;     // Used for control of output results file
  integer resultstxt_pos; // Used to find current position in output file
  
  // DUT
  // ------------------------------------------------------------------------------------------------------------------       

  ENoC_Network
    DUT_ENoC_Network (.*);
  
  // SIMULATION:  System Clock and Time
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    clk = 1;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end
  
  initial begin
    f_time = 0;
    forever #(CLK_PERIOD) f_time = f_time + 1;
  end  
  
  // SIMULATION:  System Reset
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    reset_n = 0;
    #((CLK_PERIOD)+3*(CLK_PERIOD/4))
    reset_n = 1;
  end

  // SIMULATION:  Node RX
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<NODES; i++) begin
        i_en[i] <= 0;
      end
    end else begin
      for(int i=0; i<NODES; i++) begin
        i_en[i] <= ($urandom_range(100,1) <= DOWNSTREAM_EN_RATE) ? 1 : 0;
      end
    end
  end
  
  // SIMULATION:  Node TX
  // ------------------------------------------------------------------------------------------------------------------
  genvar i;
  generate
    for (i=0; i<NODES; i++) begin : GENERATE_INPUT_QUEUES
      LIB_FIFO_packet_t #(.DEPTH(WARM_UP_PACKETS+DRAIN_PACKETS+MEASURE_PACKETS))
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
      for(int i=0; i<NODES; i++) begin
        `ifdef TORUS
          f_x_dest[i] <= 0;
          f_y_dest[i] <= 0;
          f_z_dest[i] <= 0;
        `else
          f_dest[i] <= 0;     
        `endif
      end
    end else begin
      for(int i=0; i<NODES; i++) begin
        `ifdef TORUS
          f_x_dest[i] <= $urandom_range(X_NODES-1, 0);
          f_y_dest[i] <= $urandom_range(Y_NODES-1, 0);
          f_z_dest[i] <= $urandom_range(Z_NODES-1, 0);
        `else
          f_dest[i] <= $urandom_range(NODES-1, 0);
        `endif
      end
    end
  end
  
  // RANDOM FLAG:  Valid (Bernoulli)
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<NODES; i++) begin
        f_data_val[i] <= 0;
      end
    end else begin
      for(int i=0; i<NODES; i++) begin
        f_data_val[i] = ($urandom_range(100,1) <= PACKET_RATE) ? 1 : 0;
      end
    end
  end  
  
  // Populate input data
  // ------------------------------------------------------------------------------------------------------------------  
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for (int z=0; z<Z_NODES; z++) begin
        for (int y=0; y<Y_NODES; y++) begin
          for (int x=0; x<X_NODES; x++) begin
            s_i_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].data      <= 1; // Data field used to number packets
            s_i_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].x_source  <= x; // Source field used to declare which input port packet was presented to
            s_i_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].y_source  <= y; // Source field used to declare which input port packet was presented to
            s_i_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].z_source  <= z; // Source field used to declare which input port packet was presented to        
            s_i_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].x_dest    <= 0; // Destination field indicates where packet is to be routed to
            s_i_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].y_dest    <= 0; // Destination field indicates where packet is to be routed to 
            s_i_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].z_dest    <= 0; // Destination field indicates where packet is to be routed to         
            s_i_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].valid     <= 0; // Valid field indicates if the packet is valid or not
            s_i_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].timestamp <= 0; // Timestamp field used to indicate when packet was generated
            s_i_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].measure   <= 0; // Measure field used to indicate if packet should be measured           
          end
        end
      end
    end else begin
      for(int i=0; i<NODES; i++) begin
        s_i_data[i].data      <= s_i_data[i].valid ? s_i_data[i].data  + 1 : s_i_data[i].data;
        s_i_data[i].x_dest    <= f_x_dest[i];
        s_i_data[i].y_dest    <= f_y_dest[i];
        s_i_data[i].z_dest    <= f_z_dest[i];
        s_i_data[i].valid     <= (f_total_i_data_count < (WARM_UP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS)) ? f_data_val[i] : 0;
        s_i_data[i].timestamp <= f_time + 1; // +1 so that the cycle used writing to the input queue is ignored
        s_i_data[i].measure   <= (f_total_i_data_count > WARM_UP_PACKETS) && (f_total_i_data_count < (WARM_UP_PACKETS+MEASURE_PACKETS)) ? 1 : 0;
      end
    end
  end

  // packet_t carries a valid in the packet, the mesh flow control uses its own valid/enable protocol and flag gen.
  // for simplicity they are just connected here.
  // ------------------------------------------------------------------------------------------------------------------   
  always_comb begin
    for(int i=0; i<NODES; i++) begin
      s_i_data_val[i] = s_i_data[i].valid;
    end
  end
  
  // TEST FUNCTION:  Packet Counters and throughput measurement
  // ------------------------------------------------------------------------------------------------------------------ 
  always_ff@(negedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<NODES; i++) begin
        f_port_i_data_count[i] <= 0;
        f_port_o_data_count[i] <= 0;
        f_throughput_port_o_packet_count[i] <= 0;
        f_throughput_port_i_packet_count[i] <= 0; 
      end     
      f_throughput_cycle_count  <= 0;      
    end else begin
      for(int i=0; i<NODES; i++) begin
        f_port_i_data_count[i]  <= s_i_data[i].valid ? f_port_i_data_count[i] + 1 : f_port_i_data_count[i];
        f_port_o_data_count[i]  <= o_data[i].valid   ? f_port_o_data_count[i] + 1 : f_port_o_data_count[i];
        f_throughput_port_o_packet_count[i] <= ((o_data[i].valid) && (f_total_i_data_count > WARM_UP_PACKETS) && (f_total_i_data_count < (WARM_UP_PACKETS+MEASURE_PACKETS))) ? f_throughput_port_o_packet_count[i] + 1 : f_throughput_port_o_packet_count[i]; 
        f_throughput_port_i_packet_count[i] <= ((i_data[i].valid) && (f_total_i_data_count > WARM_UP_PACKETS) && (f_total_i_data_count < (WARM_UP_PACKETS+MEASURE_PACKETS))) ? f_throughput_port_i_packet_count[i] + 1 : f_throughput_port_i_packet_count[i];
        f_throughput_cycle_count    <= ((f_total_i_data_count > WARM_UP_PACKETS) && (f_total_i_data_count < (WARM_UP_PACKETS+MEASURE_PACKETS))) ? f_throughput_cycle_count + 1 : f_throughput_cycle_count; 
      end
    end
  end
  
  always_comb begin
    f_total_i_data_count = 0;
    f_total_o_data_count = 0;
    f_throughput_total_o_packet_count <= 0;
    f_throughput_total_i_packet_count <= 0;
    f_throughput = 0;
    f_offered = 0;
    for (int i=0; i<NODES; i++) begin
      f_total_i_data_count = f_port_i_data_count[i] + f_total_i_data_count;
      f_total_o_data_count = f_port_o_data_count[i] + f_total_o_data_count;
      f_throughput_total_o_packet_count = f_throughput_port_o_packet_count[i] + f_throughput_total_o_packet_count;
      f_throughput_total_i_packet_count = f_throughput_port_i_packet_count[i] + f_throughput_total_o_packet_count;      
    end
    if (f_throughput_total_o_packet_count != 0) begin
      f_throughput = f_throughput_total_o_packet_count/(f_throughput_cycle_count*NODES);
      f_offered = f_throughput_total_i_packet_count/(f_throughput_cycle_count*NODES);
    end
  end

  // TEST FUNCTION: Latency of Measure Packets
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    f_total_latency         = 0;
    f_average_latency       = 0;
    f_measured_packet_count = 0;
    forever @(negedge clk) begin
      for (int i=0; i<NODES; i++) begin
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

  // TEST FUNCTION: Batch Latency of all packets
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    for(int i=0; i<BATCH_NUMBER; i++) begin
      f_batch_total_latency[i]         = 0;
      f_batch_average_latency[i]       = 0;
      f_batch_measured_packet_count[i] = 0;
    end
    f_batch_number = 0;
    forever @(negedge clk) begin
      for (int i=0; i<NODES; i++) begin
        if ((o_data_val[i] == 1) && (f_batch_measured_packet_count[f_batch_number] < BATCH_SIZE)) begin
          f_batch_total_latency[f_batch_number] = f_batch_total_latency[f_batch_number] + (f_time - o_data[i].timestamp);
          f_batch_measured_packet_count[f_batch_number] = f_batch_measured_packet_count[f_batch_number] + 1;
        end else if ((o_data_val[i] == 1) && (f_batch_measured_packet_count[f_batch_number] == BATCH_SIZE)) begin
          f_batch_total_latency[f_batch_number+1] = f_batch_total_latency[f_batch_number+1] + (f_time - o_data[i].timestamp);
          f_batch_measured_packet_count[f_batch_number+1] = f_batch_measured_packet_count[f_batch_number+1] + 1;
          f_batch_number = f_batch_number + 1;
        end
      end
      for(int i=0; i<BATCH_NUMBER; i++) begin
        if (f_batch_total_latency[i] != 0) begin
          f_batch_average_latency[i] = f_batch_total_latency[i]/f_batch_measured_packet_count[i];
        end
      end
    end
  end
  
  // TEST FUNCTION: Saturation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    forever @(negedge clk) begin
      `ifdef TORUS
        for (int z=0; z<Z_NODES; z++) begin
          for (int y=0; y<Y_NODES; y++) begin
            for (int x=0; x<X_NODES; x++) begin
              if (f_saturate[(z*X_NODES*Y_NODES)+(y*X_NODES)+x] == 0) begin
                $display("ABORT:  Input port %g (xyz)=(%g,%g,%g) saturated at time %g", (z*X_NODES*Y_NODES)+(y*X_NODES)+x, x, y, z, f_time);
                $display("");
                f_test_complete = 1;
                f_test_abort = 1;
                f_test_fail = 1;
              end
            end
          end
        end
      `else
        for (int i=0; i<NODES; i++) begin
          if (f_saturate[i] == 0) begin
            $display("ABORT:  Input port %g saturated at time %g", (i, f_time);
            $display("");
            f_test_complete = 1;
            f_test_abort = 1;
            f_test_fail = 1;
          end
        end      
      `endif
    end
  end
  
  // TEST FUNCTION: Routing
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    f_routing_fail_count = 0;
    forever @(negedge clk) begin    
      `ifdef TORUS
        for (int z=0; z<Z_NODES; z++) begin
          for (int y=0; y<Y_NODES; y++) begin
            for (int x=0; x<X_NODES; x++) begin
              if (o_data_val[(z*X_NODES*Y_NODES)+(y*X_NODES)+x] == 1) begin
                if ((o_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].x_dest != x) || (o_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].y_dest != y) || (o_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].z_dest != z)) begin
                  $display ("Routing error number %g at time %g.  The packet output to node %g (x,y,z) = (%g,%g,%g) should have been sent to node (x,y,z) = (%g,%g,%g)", f_routing_fail_count + 1, f_time, (z*X_NODES*Y_NODES)+(y*X_NODES)+x, x, y, z, o_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].x_dest, o_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].y_dest, o_data[(z*X_NODES*Y_NODES)+(y*X_NODES)+x].z_dest);
                  $display("");
                  f_routing_fail_count = f_routing_fail_count + 1;
                  f_test_fail  = 1;
                end
              end
            end
          end
        end    
      `else
        for (int i=0; i<NODES; i++) begin
          if (o_data_val[i] == 1) begin
            if ((o_data[i].dest != i) begin
              $display ("Routing error number %g at time %g.  The packet output to node %g should have been sent to node %g", f_routing_fail_count + 1, f_time, i, o_data[i].dest);
              $display("");
              f_routing_fail_count = f_routing_fail_count + 1;
              f_test_fail  = 1;              
            end            
          end          
        end        
      `endif
    end
  end
  
  // TEST FUNCTION: Comparing packets in and out.  In this case, every packet is accounted for, not just the ones for
  // which latency will be measured
  // ------------------------------------------------------------------------------------------------------------------ 
  initial begin
    f_drain_count = 0;
    forever @(negedge clk) begin
      if (f_total_o_data_count >= ((WARM_UP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS)) && (f_total_o_data_count != f_total_i_data_count)) begin
        if (f_drain_count < 100) begin
          f_drain_count = f_drain_count + 1;
        end else begin
          f_txrx = 0;
          f_test_complete = 1;
          f_test_fail = 1;
          f_test_abort = 1;
          $display("ABORT:  Received %g more packets than intended to send!", f_total_o_data_count-(WARM_UP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS));
          $display(""); 
        end
      end else if ((f_total_o_data_count >= (WARM_UP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS)) && (f_total_o_data_count == f_total_i_data_count)) begin
        if (f_drain_count < 100) begin
          f_drain_count = f_drain_count + 1;
        end else begin
          f_txrx = 1;
          f_test_complete = 1;
        end
      end else if (o_data_val == 0) begin
        if (f_drain_count <100) begin
          f_drain_count = f_drain_count + 1;
        end else begin
          f_txrx = 0;
          f_test_complete = 1;
          f_test_fail = 1;
          f_test_abort = 1;
          $display("ABORT:  No received packets for 100 cycles");
          $display("");     
        end
      end else begin
        f_drain_count = 0;           
      end
    end
  end

  // TEST CONTROL
  // ------------------------------------------------------------------------------------------------------------------   
  initial begin
    $display("");
    $display("approximately %g packets will be sent and measured at an offered traffic ratio of %g%%", WARM_UP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS, PACKET_RATE);
    if (WARM_UP_PACKETS > 0) begin
    $display("To ensure the network is steady, %g warm up packets will be sent", WARM_UP_PACKETS);
    end
    if (DRAIN_PACKETS > 0) begin
    $display("To ensure the network remains steady whilst finishing measurements, %g drain packets will be sent", DRAIN_PACKETS);
    end
    $display("The simulated nodes will accept data %g%% of the time", DOWNSTREAM_EN_RATE);
    $display("");
    $display("TEST LOG");
    $display("--------");
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
          $display("Test Failed!  See test log above for details.");
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
        $display("OFFERED TRAFFIC:  %g%%", f_offered);
        $display("THROUGHPUT: %g%%", f_throughput);
        $display("AVERAGE LATENCY: %g cycles", f_average_latency);
        $display("");
        
        resultstxt = $fopen("results.txt","r");
        if (resultstxt == 0) begin
          resultstxt = $fopen("results.txt","a");          
          $fwrite(resultstxt, "STATUS, Network Type, Nodes, X Nodes, Y Nodes, Z Nodes, Input Queue Depth, VOQ, iSLIP, Load Balancing, Packet Rate, Warm-up Packets, Measure Packets, Drain Packets, Offered Traffic, Throughput, Average Latency, ,Number of Batches, Packets Per Batch, ");
          for (int i=0; i<BATCH_NUMBER; i++) begin
            $fwrite(resultstxt, "Batch %g, ", i);
          end
          $fdisplay(resultstxt, "END OF DATA, ");
          $fclose(resultstxt);
        end else begin
          $fclose(resultstxt);
        end
        resultstxt = $fopen("results.txt","a");
        if (f_test_fail) begin
          $fwrite(resultstxt, "FAIL, ");
        end else begin
          $fwrite(resultstxt, "PASS, ");
        end 
        `ifdef TORUS  
          `ifdef MESH
            $fwrite(resultstxt, "MESH, %g, %g, %g, %g, %g, ", NODES, X_NODES, Y_NODES, Z_NODES, INPUT_QUEUE_DEPTH);
          `elsif CUBE
            $fwrite(resultstxt, "CUBE, %g, %g, %g, %g, %g, ", NODES, X_NODES, Y_NODES, Z_NODES, INPUT_QUEUE_DEPTH);         
          `endif
          `ifdef VOQ
            $fwrite(resultstxt, "YES, ");
          `else
            $fwrite(resultstxt, "NO, ");  
          `endif
          `ifdef iSLIP
            $fwrite(resultstxt, "YES, ");
          `else
            $fwrite(resultstxt, "NO, ");  
          `endif 
          `ifdef LOAD_BALANCE
            $fwrite(resultstxt, "YES, ");
          `else
            $fwrite(resultstxt, "NO, ");  
          `endif 
        `else
          $fwrite(resultstxt, "OTHER, %g, N/A, N/A, N/A, %g, N/A, N/A, N/A, ", NODES, INPUT_QUEUE_DEPTH);
        `endif
        $fwrite(resultstxt, "%g, %g, %g, %g, %g, %g, %g, , %g, %g, ", PACKET_RATE, WARM_UP_PACKETS, MEASURE_PACKETS, DRAIN_PACKETS, f_offered, f_throughput, f_average_latency, BATCH_NUMBER, BATCH_SIZE);
        for (int i=0; i<BATCH_NUMBER; i++) begin
          $fwrite(resultstxt, "%g, ", f_batch_average_latency[i]);
        end
        $fdisplay(resultstxt, "END OF DATA, ");
        $fclose(resultstxt); 
        $stop(1);
      end
    end
  end
 
endmodule
  