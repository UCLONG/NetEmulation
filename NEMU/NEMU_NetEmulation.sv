// IP Block    : NEMU
// Function    : 
// Module name : NEMU_NetEmulation.sv.bak
// Description : Top Level module
// Uses        : 

`include "config.sv";
//`timescale 10ps/1ps
 
module netEmulation ();
  
  // Internal signals specific to simulation
  logic l_reset_n;                          //once synthesised signal will be active load signal
  logic [`PORTS-1:0] l_input_fifo_error;   //logic [`PORTS-1:0] dest_error;
  logic [31:0] l_total_pkts;               //total number of pockets generated during a simulation

   
  logic l_clk;
  logic [31:0] l_timestamp;       
  logic l_measure;                //set to 1, after the warm-up period,
  logic l_source_on;              //when set to 1, triggers the start of generation of packets 
  packet_t l_pkt_in [0:`PORTS-1] /* synthesis keep */; 
  packet_t l_pkt_out [0:`PORTS-1] /* synthesis keep */;
  logic [`PORTS-1:0] l_net_full /* synthesis keep */;
  genvar i;
  
  
  // Instantiate pkt_sources
   generate for (i=0;i<`PORTS;i++)
      begin: source_loop
         packet_source #(i) pkts (l_clk, (l_reset_n | (!l_source_on)), l_timestamp, l_net_full[i], l_pkt_in[i], l_input_fifo_error[i]);
      end
   endgenerate
  
  // Instantiate pkt sink
  packet_sink sinks (l_clk, l_reset_n, l_pkt_out, l_pkt_in, l_timestamp, l_input_fifo_error, l_net_full, l_measure);  
  
  // Timestamp counter
  always_ff @(posedge l_clk)
    if (l_reset_n)
       l_timestamp <= 0;
    else
        l_timestamp <= l_timestamp + 1; 
  
  //////////////////////////////////////////////////////////////////////
  ////////////////////// INSTANTIATE NETWORK ///////////////////////////
  //////////////////////////////////////////////////////////////////////

  
  // SystemVerilog network model
  network inst_net(l_clk, l_reset_n, pkt_in, pkt_out, net_full);
  


  //Generate clock
  initial begin
    l_clk = 0;
    forever #(`CLK_PERIOD/2) l_clk = ~l_clk;
  end
  
  // Generate reset
  initial begin
    l_reset_n = 1;
    l_measure = 0;
    l_source_on = 1;
    
      `ifdef VCD_PATH    // Open VCD file
	   $display("Setting up VCD file\n");
        $dumpfile("synth/vcd/netemulation.vcd");
        $dumpvars(0,`VCD_PATH);
      `endif
      
    #(100ns)
    l_reset_n = 0;
    #(`WARMUP_PERIOD) 
    $display("Starting measurement period at simulation time %t.\n", $realtime);
    l_measure = 1;
    
    `ifdef VCD      // Start VCD dump
      $dumpon;
    `endif  
    
    #(`MEASURE_PERIOD)
    $display("Ending measurement period at simulation time %t.\n", $realtime);
    l_source_on = 0;
    
    `ifdef VCD_FILE      // End VCD dump
      $dumpoff;
    `endif
    
    #(`COOLDOWN_PERIOD)
    l_measure = 0;
    #100ns
          
    $finish;
  end
  

endmodule
	    
	 
