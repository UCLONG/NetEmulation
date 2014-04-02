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

module ENoC_Network_tb 

// --------------------------------------------------------------------------------------------------------------------
// PARAMETERS
// --------------------------------------------------------------------------------------------------------------------
// Many parameters are taken directly from the configuration file, however entering them this way enables control of
// the parameters using TCL scripts.
// --------------------------------------------------------------------------------------------------------------------

#(parameter   integer SEED               = 0,
  parameter           CLK_PERIOD         = 5ns,
  parameter   integer PACKET_RATE        = 100,     // Offered traffic as percent of capacity
  parameter   integer WARMUP_PACKETS     = 1000,  // Number of packets to warm-up the network
  parameter   integer MEASURE_PACKETS    = 5000,  // Number of packets to be measured
  parameter   integer DRAIN_PACKETS      = 3000,    // Number of packets to drain the network
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
  parameter   integer NODE_QUEUE_SIZE = `INPUT_QUEUE_DEPTH*8);

// --------------------------------------------------------------------------------------------------------------------
// SIGNALS
// --------------------------------------------------------------------------------------------------------------------  
  
  logic clk, reset_n;
 
  // SIGNALS:  Node Input Bus.
  // ------------------------------------------------------------------------------------------------------------------
  packet_t [0:NODES-1] i_data;     // Input data to network from upstream nodes
  logic    [0:NODES-1] i_data_val; // Validates input data from upstream nodes
  logic    [0:NODES-1] o_en;       // Enables input data from upstream nodes to network
  
  // SIGNALS:  Node Output Bus
  // ------------------------------------------------------------------------------------------------------------------
  logic    [0:NODES-1] i_en;       // Enables output data from network to downstream nodes
  packet_t [0:NODES-1] o_data;     // Outputs data from network to downstream nodes
  logic    [0:NODES-1] o_data_val; // Validates output data to downstream nodes
  
  // SIGNALS:  Input Queue FIFO signals
  // ------------------------------------------------------------------------------------------------------------------
  packet_t [0:NODES-1] s_i_data;     // Input data from upstream [core, north, east, south, west]
  logic    [0:NODES-1] s_i_data_val; // Validates data from upstream [core, north, east, south, west]
  logic    [0:NODES-1] l_i_data_val; // Used to create i_data_val depending on the value of o_en
  logic    [0:NODES-1] f_full;       // Indicates that the node queue is saturated
  
// --------------------------------------------------------------------------------------------------------------------
// FLAGS
// --------------------------------------------------------------------------------------------------------------------   
  
  // FLAGS:  Random
  // ------------------------------------------------------------------------------------------------------------------   
  logic [0:NODES-1] f_data_val;
  `ifdef TORUS  
    logic [0:NODES-1][log2(X_NODES)-1:0] f_x_dest;
    logic [0:NODES-1][log2(Y_NODES)-1:0] f_y_dest;
    logic [0:NODES-1][log2(Z_NODES)-1:0] f_z_dest;
  `else
    logic [0:NODES-1][log2(NODES)-1:0] f_dest;
  `endif
  
  // FLAGS:  Control
  // ------------------------------------------------------------------------------------------------------------------  
  longint f_time;                       // Pseudo time value/clock counter
  integer f_drain_count;                // Counts cycles computer has been draining for
  
  integer f_burst_count [0:NODES-1];
  
  integer f_port_s_i_data_count [0:NODES-1]; // Count number of packets simulated and added to the node queues
  integer f_total_s_i_data_count;            // Count total number of simulated packets
  integer f_port_i_data_count [0:NODES-1];   // Count number of packets that left the node, transmitted on each port
  integer f_total_i_data_count;              // Count total number of transmitted packets
  integer f_port_o_data_count [0:NODES-1];   // Count number of received packets on each port
  integer f_total_o_data_count;              // Count total number of received packets
  
  logic   [0:NODES-1][999:0] f_tx_packet;
  logic   [0:NODES-1][999:0] f_rx_packet;
  
  real    f_total_latency;            // Counts the total amount of time all measured packets have spent in the router
  real    f_average_latency;          // Calculates the average latency of measured packets
  real    f_measured_packet_count;    // Number of packets measured
  integer f_max_latency;              // The longest measured frequency
  integer f_latency_frequency [0:99]; // The amount of times a single latency occurs
  
  real    f_batch_total_latency [0:BATCH_NUMBER-1];         // Counts the total amount of time all measured packets in a batch have spent in the router
  real    f_batch_average_latency [0:BATCH_NUMBER-1];       // Calculates the average latency of measured packets in a batch
  real    f_batch_measured_packet_count [0:BATCH_NUMBER-1]; // Number of packets measured per batch
  integer f_batch_number;                                    // Used to reference batches
  
  real    f_throughput_port_o_packet_count [0:NODES-1]; // counts number of packets received over a given number of cycles
  real    f_throughput_total_o_packet_count;            // counts number of packets received over a given number of cycles  
  real    f_throughput_port_i_packet_count [0:NODES-1]; // counts number of packets sent over a given number of cycles
  real    f_throughput_total_i_packet_count;            // counts number of packets simulated over a given number of cycles
  real    f_throughput_port_s_packet_count [0:NODES-1]; // counts number of packets simulated over a given number of cycles
  real    f_throughput_total_s_packet_count;            // counts number of packets sent over a given number of cycles
  real    f_throughput_cycle_count;                     // counts the number of cycles f_throughput_packet_count has been counting
  real    f_throughput;                                 // calculates throughput during the measure period
  real    f_throughput_offered;                         // Calculates the offered traffic during the measure period
  real    f_throughput_simulated;                       // Calculates the simulated traffic during the measure period
  
  integer f_routing_fail_count; // Used to count the total number of routing failures
  integer f_test_saturated;     // Indicate the network saturated for latency measurements
  logic   f_test_complete;      // Logic high to indicate the test process is finished
  logic   f_test_abort;         // Logic high to indicate the test process was aborted
  logic   f_test_fail;          // Logic high to indicate the test process failed
  logic   f_test_txrx;          // Logic high to indicate all transmitted packets were received
  
  integer resultstxt;     // Used for control of output results file
  integer resultstxt_pos; // Used to find current position in output file

// --------------------------------------------------------------------------------------------------------------------  
// DUT
// --------------------------------------------------------------------------------------------------------------------       

  `ifdef TORUS
  
     ENoC_Network
      DUT_ENoC_Network (.*);
    
  `endif
  
  `ifdef SO
  
    packet_t             l_flit_in  [0:NODES-1];
    packet_t             l_flit_out [0:NODES-1];
    logic    [NODES-1:0] l_full;
    
    // SO Network uses unpacked collection of packet_t whereas the test bench uses packed.  Swap.
    always_comb begin
      for(int i=0; i<NODES; i++) begin
        l_flit_in[i] = i_data[i];
        o_data[i]    = l_flit_out[i];
        o_en[i]      = ~l_full[i];
      end
    end
    
    // DUT SO
    network
      DUT_network (.clk(clk),
                   .rst(~reset_n),
                   .flit_in(l_flit_in),
                   .flit_out(l_flit_out),
                   .full(l_full));
    
    // SO Network contains valid in packet_t and does not provide any other valid signal.  That valid is connected
    // to the one the test bench looks for here.  
    always_comb begin
      o_data_val = 0;
      for(int i=0; i<NODES; i++) begin
        o_data_val[i] = o_data[i].valid;
      end
    end
  
  `endif

// --------------------------------------------------------------------------------------------------------------------
// SIMULATION
// --------------------------------------------------------------------------------------------------------------------
// In this section, a system clock is generated and a pseudo time value called f_time.   f_time is used for debugging
// but also to calculate latency and throughput.  A reset is initially set, and lifts quickly.
// Network nodes are simulated in two parts, a transmit side and receive side.  The transmit side is a FIFO.  The fifo
// the FIFO output is connected directly to the network.  If data is sent to the FIFO, it will try and enter the
// network at the soonest possible time.  To control the rate at which traffic is offered to the network, the rate at
// which traffic is offered to the FIFO must be controlled.  The receive side simply simulates an enable signal.  This
// means that the node can be busy, and refuse network traffic if so required.
// --------------------------------------------------------------------------------------------------------------------

  // SIMULATION:  System Clock
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    clk = 1;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // SIMULATION:  System Time
  // ------------------------------------------------------------------------------------------------------------------
  
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
      LIB_FIFO_packet_t #(.DEPTH(NODE_QUEUE_SIZE))
        gen_LIB_FIFO_packet_t (.clk,
                               .ce(1'b1),
                               .reset_n,
                               .i_data(s_i_data[i]),         // From the simulated input data
                               .i_data_val(s_i_data_val[i]), // From the simulated input data
                               .i_en(o_en[i]),               // From the Router
                               .o_data(i_data[i]),           // To the Router
                               .o_data_val(l_i_data_val[i]),   // To the Router
                               .o_en(f_full[i]),             // Used to indicate router saturation
                               .o_full(),                    // Not connected, o_en used for flow control
                               .o_near_full(),
                               .o_empty(),                   // Not connected, not required for simple flow control
                               .o_near_empty());             // Not connected, not required for simple flow control
    end
  endgenerate
  
  // Check for an output enable before raising valid
  always_comb begin
    i_data_val = '0;
    for(int i=0; i<NODES; i++) begin
      i_data_val[i] = l_i_data_val[i] && o_en[i];
    end
  end  
    
// --------------------------------------------------------------------------------------------------------------------
// RANDOM DATA GENERATION
// --------------------------------------------------------------------------------------------------------------------
// The random data generation consists of two parts, random flag generation, and the population of the data.  A valid
// bit and random node address are generated each cycle as flags.  When populating input data, these flags can be
// sampled as and when required.  The data generation has been split this way to enable easier editing of the composite
// parts.  For example, creating a new random traffic pattern would require only the valid bit to be worked on, and the
// rest can remain the same.
// --------------------------------------------------------------------------------------------------------------------
  
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
  
  // RANDOM FLAG:  Valid (Bernoulli) and bursty (fixed burst size)
  // ------------------------------------------------------------------------------------------------------------------ 
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<NODES; i++) begin
        f_data_val[i] <= 0;
      end
    end else begin
      for(int i=0; i<NODES; i++) begin
        f_data_val[i] <= ($urandom_range(100,1) <= PACKET_RATE) ? 1'b1 : 1'b0;
      end
    end
  end
  
  
  // RANDOM DATA GENERATION:  Populate input data
  // ------------------------------------------------------------------------------------------------------------------  
  `ifdef TORUS
  
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
          s_i_data[i].valid     <= (f_total_i_data_count < (WARMUP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS)) ? f_data_val[i]: 0;
          s_i_data[i].timestamp <= f_time + 1; // +1 so that the cycle used writing to the input queue is ignored
          s_i_data[i].measure   <= (f_total_i_data_count > WARMUP_PACKETS) && (f_total_i_data_count < (WARMUP_PACKETS+MEASURE_PACKETS)) ? 1 : 0;
        end
      end
    end
  
  `else
  
    always_ff@(posedge clk) begin
      if(~reset_n) begin
        for (int i=0; i<NODES; i++) begin
          s_i_data[i].data      <= 1; // Data field used to number packets
          s_i_data[i].source    <= i; // Source field used to declare which input port packet was presented to         
          s_i_data[i].dest      <= 0; // Destination field indicates where packet is to be routed to         
          s_i_data[i].valid     <= 0; // Valid field indicates if the packet is valid or not
          s_i_data[i].timestamp <= 0; // Timestamp field used to indicate when packet was generated
          s_i_data[i].measure   <= 0; // Measure field used to indicate if packet should be measured           
        end
      end else begin
        for(int i=0; i<NODES; i++) begin
          s_i_data[i].data      <= s_i_data[i].valid ? s_i_data[i].data  + 1 : s_i_data[i].data;
          s_i_data[i].dest      <= f_dest[i];
          s_i_data[i].valid     <= (f_total_i_data_count < (WARMUP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS)) ? f_data_val[i] : 0;
          s_i_data[i].timestamp <= f_time + 1; // +1 so that the cycle used writing to the input queue is ignored
          s_i_data[i].measure   <= (f_total_i_data_count > WARMUP_PACKETS) && (f_total_i_data_count < (WARMUP_PACKETS+MEASURE_PACKETS)) ? 1 : 0;
        end
      end
    end
  
  `endif

  // packet_t carries a valid in the packet, the some flow controls, such as that used by LIB_FIFO_packet_t use separate
  // valid/enable protocol and flag gen.  For simplicity, they are just connected here. 
  always_comb begin
    for(int i=0; i<NODES; i++) begin
      s_i_data_val[i] = s_i_data[i].valid;
    end
  end

// --------------------------------------------------------------------------------------------------------------------
// TEST FUNCTIONS
// --------------------------------------------------------------------------------------------------------------------
  
  // TEST FUNCTION:  Throughput measurement.
  // ------------------------------------------------------------------------------------------------------------------ 
  // Uses the count of the simulated input data so that even if the network is saturated and packets are being dropped
  // throughput measurement will still take place
  // ------------------------------------------------------------------------------------------------------------------  
  always_ff@(negedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<NODES; i++) begin
        f_throughput_port_o_packet_count[i] <= 0;
        f_throughput_port_i_packet_count[i] <= 0;  
        f_throughput_port_s_packet_count[i] <= 0;           
      end     
      f_throughput_cycle_count  <= 0;      
    end else begin
      for(int i=0; i<NODES; i++) begin
        f_throughput_port_o_packet_count[i] <= ((o_data_val[i]) 
                                               && (f_total_s_i_data_count > WARMUP_PACKETS) 
                                               && (f_total_s_i_data_count < (WARMUP_PACKETS+MEASURE_PACKETS))) 
                                               ? f_throughput_port_o_packet_count[i] + 1 
                                               : f_throughput_port_o_packet_count[i];
        f_throughput_port_i_packet_count[i] <= ((i_data_val[i]) 
                                               && (f_total_s_i_data_count > WARMUP_PACKETS) 
                                               && (f_total_s_i_data_count < (WARMUP_PACKETS+MEASURE_PACKETS))) 
                                               ? f_throughput_port_i_packet_count[i] + 1 
                                               : f_throughput_port_i_packet_count[i];                                               
        f_throughput_port_s_packet_count[i] <= ((s_i_data_val[i]) 
                                               && (f_total_s_i_data_count > WARMUP_PACKETS) 
                                               && (f_total_s_i_data_count < (WARMUP_PACKETS+MEASURE_PACKETS))) 
                                               ? f_throughput_port_s_packet_count[i] + 1 
                                               : f_throughput_port_s_packet_count[i]; 
        f_throughput_cycle_count    <= ((f_total_s_i_data_count > WARMUP_PACKETS) 
                                    && (f_total_s_i_data_count < (WARMUP_PACKETS+MEASURE_PACKETS))) 
                                    ? f_throughput_cycle_count + 1 
                                    : f_throughput_cycle_count;    
     end
    end
  end
  
  always_comb begin
    f_throughput_total_i_packet_count = 0;
    f_throughput_total_o_packet_count = 0;
    f_throughput_total_s_packet_count = 0;
    f_throughput = 0;
    f_throughput_offered = 0;
    f_throughput_simulated = 0;
    for (int i=0; i<NODES; i++) begin
      f_throughput_total_o_packet_count = f_throughput_port_o_packet_count[i] + f_throughput_total_o_packet_count;
      f_throughput_total_i_packet_count = f_throughput_port_i_packet_count[i] + f_throughput_total_i_packet_count;            
      f_throughput_total_s_packet_count = f_throughput_port_s_packet_count[i] + f_throughput_total_s_packet_count;
    end
    if (f_throughput_total_o_packet_count != 0) begin
      f_throughput = (f_throughput_total_o_packet_count/(f_throughput_cycle_count*NODES))*100;
    end
    if (f_throughput_total_i_packet_count !=0) begin
      f_throughput_offered = (f_throughput_total_i_packet_count/(f_throughput_cycle_count*NODES))*100;
    end
    if (f_throughput_total_s_packet_count !=0) begin
      f_throughput_simulated = (f_throughput_total_s_packet_count/(f_throughput_cycle_count*NODES))*100;
    end
  end
  
  // TEST FUNCTION:  TX and RX Packet Counters
  // ------------------------------------------------------------------------------------------------------------------ 
  always_ff@(negedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<NODES; i++) begin
        f_port_s_i_data_count[i] <= 0;
        f_port_i_data_count[i]   <= 0;
        f_port_o_data_count[i]   <= 0;
      end          
    end else begin
      for(int i=0; i<NODES; i++) begin
        f_port_s_i_data_count[i] <= s_i_data[i].valid        ? f_port_s_i_data_count[i] + 1 : f_port_s_i_data_count[i];
        f_port_i_data_count[i]   <= i_data_val[i] && o_en[i] ? f_port_i_data_count[i]   + 1 : f_port_i_data_count[i];
        f_port_o_data_count[i]   <= o_data_val[i]            ? f_port_o_data_count[i]   + 1 : f_port_o_data_count[i];
     end
    end
  end
  
  always_comb begin
    f_total_s_i_data_count = 0;   
    f_total_i_data_count   = 0;
    f_total_o_data_count   = 0;
    for (int i=0; i<NODES; i++) begin
      f_total_s_i_data_count = f_port_s_i_data_count[i] + f_total_s_i_data_count;
      f_total_i_data_count   = f_port_i_data_count[i]   + f_total_i_data_count;
      f_total_o_data_count   = f_port_o_data_count[i]   + f_total_o_data_count;    
    end
  end

  // TEST FUNCTION:  TX and RX Packet identification
  // ------------------------------------------------------------------------------------------------------------------

  always_ff@(negedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<NODES; i++) begin
        f_tx_packet[i] <= '0;
        f_rx_packet[i] <= '0;
      end
    end else begin
      for(int i=0; i<NODES; i++) begin
        if(i_data_val[i] && o_en[i]) begin 
          `ifdef TORUS
            f_tx_packet[i][i_data[i].data] <= 1; 
          `else
            f_tx_packet[i][i_data[i].data] <= 1;  
          `endif          
        end
        if(o_data_val[i]) begin
          `ifdef TORUS
            f_rx_packet[(o_data[i].z_source*X_NODES*Y_NODES)+(o_data[i].y_source*X_NODES)+o_data[i].x_source][o_data[i].data] <= 1;
          `else
            f_rx_packet[o_data[i].source][o_data[i].data] <= 1;         
          `endif
        end
      end
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
      if ((f_total_latency != 0) && (f_test_saturated != 1))begin
        f_average_latency = f_total_latency/f_measured_packet_count;
      end else begin
        f_average_latency = 10000;
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
        if ((f_batch_total_latency[i] != 0) && (f_test_saturated != 1)) begin
          f_batch_average_latency[i] = f_batch_total_latency[i]/f_batch_measured_packet_count[i];
        end else begin
          f_batch_average_latency[i] = 10000;          
        end
      end
    end
  end
  
  // TEST FUNCTION: Longest Packet Latency
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(negedge clk) begin
    if(~reset_n) begin
      f_max_latency <= '0;  
    end else begin
      for(int i=0; i<NODES; i++) begin
        if(((f_time - o_data[i].timestamp) > f_max_latency) && (o_data_val[i] == 1)) begin
          f_max_latency <= (f_time - o_data[i].timestamp);
        end else begin
          f_max_latency <= f_max_latency;
        end
      end
    end
  end
  
  // TEST FUNCTION: Latency Frequency
  // ------------------------------------------------------------------------------------------------------------------
  always_ff@(negedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<100; i++) begin
        f_latency_frequency[i] <= 0; 
      end        
    end else begin
      for(int i=0; i<NODES; i++) begin
        if(o_data[i].valid == 1) begin
          f_latency_frequency[(f_time - o_data[i].timestamp)] <= f_latency_frequency[(f_time - o_data[i].timestamp)] + 1;
        end else begin
          f_latency_frequency[(f_time - o_data[i].timestamp)] <= f_latency_frequency[(f_time - o_data[i].timestamp)];
        end
      end
    end
  end
  
  // TEST FUNCTION: Saturation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    f_test_saturated = 0;
    forever @(negedge clk) begin
      `ifdef TORUS
        for (int z=0; z<Z_NODES; z++) begin
          for (int y=0; y<Y_NODES; y++) begin
            for (int x=0; x<X_NODES; x++) begin
              if ((f_full[(z*X_NODES*Y_NODES)+(y*X_NODES)+x] == 0) && (f_test_saturated !=1)) begin
                $display("WARNING:  Input port %g, (xyz)=(%g,%g,%g), saturated at f_time %g", (z*X_NODES*Y_NODES)+(y*X_NODES)+x, x, y, z, f_time);
                $display("");
                f_test_saturated = 1;
                f_test_fail = 1;
              end
            end
          end
        end
      `else
        for (int i=0; i<NODES; i++) begin
          if ((f_full[i] == 0) && (f_test_saturated !=1)) begin
            $display("WARNING:  Input port %g saturated at f_time %g", i, f_time);
            $display("");
            f_test_saturated = 1;
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
            if (o_data[i].dest != i) begin
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
    f_test_txrx = 0;
    f_drain_count = 0;
    forever @(negedge clk) begin
      if (f_total_o_data_count >= ((WARMUP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS)) && (f_total_o_data_count != f_total_i_data_count)) begin
        if (f_drain_count < 2000) begin
          f_drain_count = f_drain_count + 1;
        end else begin
          f_test_txrx = 0;
          f_test_complete = 1;
          f_test_fail = 1;
          f_test_abort = 1;
          $display("ABORT:  Received %g more packets than intended to send!", f_total_o_data_count-(WARMUP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS));
          $display("ABORT:  This might be a simulator, rather than a network, fault!", f_total_o_data_count-(WARMUP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS));
          $display("ABORT:  Simulated %g packets.  Transmitted %g packets.  Received %g packets", f_total_s_i_data_count, f_total_i_data_count, f_total_o_data_count);          
          $display(""); 
        end
      end else if ((f_total_o_data_count >= (WARMUP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS)) && (f_total_o_data_count == f_total_i_data_count)) begin
        if (f_drain_count < 2000) begin
          f_drain_count = f_drain_count + 1;
        end else begin
          f_test_txrx = 1;
          f_test_complete = 1;        
        end
      end else if (f_test_saturated) begin
        if (f_drain_count < 2000) begin
          f_drain_count = f_drain_count + 1;
        end else begin
          f_test_txrx = 0;
          f_test_complete = 1;
        end
      end else if (o_data_val == 0) begin
        if (f_drain_count <2000) begin
          f_drain_count = f_drain_count + 1;
        end else begin
          f_test_txrx = 0;
          f_test_complete = 1;
          f_test_fail = 1;
          f_test_abort = 1;
          $display("ABORT:  No received packets for 100 cycles");
          if(f_test_saturated) begin
            $display("ABORT:  The network saturated so some packets will have been dropped");
          end
          $display("ABORT:  Simulated %g packets.  Transmitted %g packets.  Received %g packets", f_total_s_i_data_count, f_total_i_data_count, f_total_o_data_count);          
          $display("");     
        end
      end else begin
        f_drain_count = 0;           
      end
    end
  end

  // RESULTS CONTROL
  // ------------------------------------------------------------------------------------------------------------------   
  initial begin
    $display("");
    $display("approximately %g packets will be sent and measured at an offered traffic ratio of %g%%", WARMUP_PACKETS+MEASURE_PACKETS+DRAIN_PACKETS, PACKET_RATE);
    if (WARMUP_PACKETS > 0) begin
    $display("To ensure the network is steady, %g warm up packets will be sent", WARMUP_PACKETS);
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
      if(f_time%100 == 0) begin
        $display("f_time %g:  Transmitted %g packets, Received %g packets", f_time, f_total_i_data_count, f_total_o_data_count);
      end
      if (f_test_complete) begin
			  for(int i=0; i<NODES; i++) begin
          for(int j=0; j<1000; j++) begin
            if(f_rx_packet[i][j] != f_tx_packet[i][j]) begin
            $display("It appears that packet number %g, transmitted on port %g, was never received", j, i);
            end
          end
        end  
        if (f_test_abort) begin
          $display(" ");
          $display("Test aborted after %g cycles", f_time);
        end else begin
          $display("Test completed after %g cycles", f_time);
        end
        $display("");
        $display("TEST SUMMARY");
        $display("------------");
        if (f_test_fail) begin
          $display("");
          $display("Test Failed!  Check test log above for messages.");
        end else begin
          $display("");
          $display("All Tests Passed!");
        end
        $display("");        
        if(f_test_txrx == 1) begin
          $display("TXRX PASS: Transmitted %g packets, received %g packets", f_total_i_data_count, f_total_o_data_count);
        end else begin
          $display("TXRX FAIL: Transmitted %g packets, received %g packets", f_total_i_data_count, f_total_o_data_count);        
        end
        if(f_routing_fail_count > 0) begin
          $display("ROUTING FAIL: %g routing failures", f_routing_fail_count);
        end else begin
          $display("ROUTING PASS: no output packets were misrouted");
        end	
        $display("REQUESTED TRAFFIC RATE:  %g%%", PACKET_RATE);
        $display("SIMULATED TRAFFIC RATE: %g%%", f_throughput_simulated);
        $display("ACTUAL TRAFFIC RATE: %g%% (note that the actual traffic rate depends on the output enable from the network, so should roughly be equal to the throughput)", f_throughput_offered);
        $display("THROUGHPUT: %g%%", f_throughput);
        $display("AVERAGE LATENCY: %g cycles", f_average_latency);
        $display("");
        
        // Write results to file
        //--------------------------------------------------------------------------------------------------------------
        
        resultstxt = $fopen("results.txt","r");
        if(resultstxt == 0) begin
          resultstxt = $fopen("results.txt","a");          
          $fwrite(resultstxt, "STATUS, Network Type, Nodes, X Nodes, Y Nodes, Z Nodes, Input Queue Depth, VOQ, iSLIP, Load Balancing, XYZSWAP, Packet Rate, Warm-up Packets, Measure Packets, Drain Packets, Offered Traffic, Actual Offered Traffic, Throughput, Average Latency, Max Latency, ,Number of Batches, Packets Per Batch, ");
          for(int i=0; i<BATCH_NUMBER; i++) begin
            $fwrite(resultstxt, "Batch %g, ", i);
          end
          $fwrite(resultstxt, ", ");
          for(int i=0; i<100; i++) begin
            $fwrite(resultstxt, "Freq %g, ", i);
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
          `ifdef XYZSWAP
            $fwrite(resultstxt, "YES, ");
          `elsif XYSWAP
            $fwrite(resultstxt, "YES, "); 
          `else
            $fwrite(resultstxt, "NO, ");  
          `endif 
        `else
          $fwrite(resultstxt, "OTHER, %g, N/A, N/A, N/A, %g, N/A, N/A, N/A, ", NODES, INPUT_QUEUE_DEPTH);
        `endif
        $fwrite(resultstxt, "%g, %g, %g, %g, %g, %g, %g, %g, %g, , %g, %g, ", PACKET_RATE, WARMUP_PACKETS, MEASURE_PACKETS, DRAIN_PACKETS, PACKET_RATE, f_throughput_simulated, f_throughput, f_average_latency, f_max_latency, BATCH_NUMBER, BATCH_SIZE);
        for (int i=0; i<BATCH_NUMBER; i++) begin
          $fwrite(resultstxt, "%g, ", f_batch_average_latency[i]);
        end
        $fwrite(resultstxt, " , ");
        for (int i=0; i<100; i++) begin
          $fwrite(resultstxt, "%g, ", f_latency_frequency[i]);
        end        
        $fdisplay(resultstxt, "END OF DATA, ");
        $fclose(resultstxt); 
        $stop(1);
      end
    end
  end
 
endmodule
  