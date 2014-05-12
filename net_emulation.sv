`include "config.sv"
//`timescale 10ps/1ps

/////////////////////////////////////////////
///////// MODULE DEF FOR SYNTHESIS //////////
/////////////////////////////////////////////
`ifdef SYNTHESIS
module net_emulation (
  input logic clkp, clkn,
  input rst,
  output logic [`PORTS-1:0] input_fifo_error,
  output logic [`PORTS-1:0] dest_error);
  
  // Internal signals specific to synthesis
  // Chipscope signals
  
  
    
 
/////////////////////////////////////////////
//////// MODULE DEF FOR SIMULATION ////////// 
///////////////////////////////////////////// 
`else  
module net_emulation ();
  
  // Internal signals specific to simulation
  logic rst;
  logic [`PORTS-1:0] input_fifo_error;
  //logic [`PORTS-1:0] dest_error;

`endif
 
/////////////////////////////////////////////
//////// COMMON SIGNALS FOR SYNTH/SIM /////// 
/////////////////////////////////////////////  
  
  logic clk;
  logic [31:0] timestamp;
  logic measure;
  logic source_on;
  packet_t pkt_in [0:`PORTS-1] /* synthesis keep */; 
  packet_t pkt_out [0:`PORTS-1] /* synthesis keep */;
  logic [`PORTS-1:0] net_full /* synthesis keep */;
  logic [`PORTS-1:0] nearly_full;
  //logic [15:0] pkt_count_source [0:`PORTS-1] /* synthesis keep */;
  //logic [15:0] pkt_count_dest [0:`PORTS-1] /* synthesis keep */;
  //logic [23:0] latency [0:`PORTS-1] /* synthesis keep */;
  genvar i;
  `ifdef VHDL
    logic [`PKT_SIZE*`PORTS-1:0] pkt_in_vhdl /* synthesis keep */;
    logic [`PKT_SIZE*`PORTS-1:0] pkt_out_vhdl /* synthesis keep */;
    integer k;
  `endif
  

  
  //////////////////////////////////////////////////////////////////////
  ////////////// COMMON CODE FOR SIM AND SYNTH /////////////////////////
  //////////////////////////////////////////////////////////////////////  
      
  
  // Instantiate pkt_sources
   generate for (i=0;i<`PORTS;i++)
      begin: source_loop
         packet_source #(i) pkts (clk, (rst | (!source_on)), timestamp, net_full[i], pkt_in[i], input_fifo_error[i]);
      end
   endgenerate
  
  // Instantiate pkt sink
  packet_sink sinks (clk, rst, pkt_out, pkt_in, timestamp, input_fifo_error, net_full,nearly_full, measure);  
  
  // Timestamp counter
  always_ff @(posedge clk)
    if (rst)
       timestamp <= 0;
    else
        timestamp <= timestamp + 1; 
  
  //////////////////////////////////////////////////////////////////////
  ////////////////////// INSTANTIATE NETWORK ///////////////////////////
  //////////////////////////////////////////////////////////////////////
  `ifdef VHDL
  
  // VHDL network model
  generate for (i=0;i<`PORTS;i++) begin
    always_comb begin
      pkt_in_vhdl[(i+1)*`PKT_SIZE-1:i*`PKT_SIZE] = {pkt_in[i].data, pkt_in[i].source, pkt_in[i].dest, pkt_in[i].valid};
      pkt_out[i].data    = pkt_out_vhdl[(i+1)*`PKT_SIZE-1:i*`PKT_SIZE+(2*log2(`PORTS))+1];
      pkt_out[i].source  = pkt_out_vhdl[i*`PKT_SIZE+(2*log2(`PORTS)):i*`PKT_SIZE+log2(`PORTS)+1];
      pkt_out[i].dest    = pkt_out_vhdl[i*`PKT_SIZE+log2(`PORTS):i*`PKT_SIZE+1];
      pkt_out[i].valid   = pkt_out_vhdl[i*`PKT_SIZE];
    end
  end
  endgenerate
  
  network #(`PORTS, log2(`PORTS), `FIFO_DEPTH, `PAYLOAD) inst_net(clk, rst, pkt_in_vhdl, pkt_out_vhdl, full, nearly_full);
  
  `else
  
  // SystemVerilog network model
  network inst_net(clk, rst, pkt_in, pkt_out, net_full, nearly_full);
  
  `endif
  
/////////////////////////////////////////////
////////// CODE SPECIFIC TO SYNTH /////////// 
///////////////////////////////////////////// 
`ifdef SYNTHESIS  

  // Generate system clock  
	assign clk = clkp;
	
  // Set rate via chipscope
  
  // Simulation timing control
  
/////////////////////////////////////////////
/////////// CODE SPECIFIC TO SIM //////////// 
///////////////////////////////////////////// 
`else

  //Generate clock
  initial begin
    clk = 0;
    forever #(`CLK_PERIOD/2) clk = ~clk;
  end
  
  // Generate reset
  initial begin
    rst = 1;
    measure = 0;
    source_on = 1;
    
      `ifdef VCD_PATH    // Open VCD file
	   $display("Setting up VCD file\n");
        $dumpfile("synth/vcd/netemulation.vcd");
        $dumpvars(0,`VCD_PATH);
      `endif
      
    #(100ns)
    rst = 0;
    #(`WARMUP_PERIOD) 
    $display("Starting measurement period at simulation time %t.\n", $realtime);
    measure = 1;
    
    `ifdef VCD      // Start VCD dump
      $dumpon;
    `endif  
    
    #(`MEASURE_PERIOD)
    $display("Ending measurement period at simulation time %t.\n", $realtime);
    source_on = 0;
    
    `ifdef VCD_FILE      // End VCD dump
      $dumpoff;
    `endif
    
    #(`COOLDOWN_PERIOD)
    measure = 0;
    #100ns
          
    $finish;
  end
  
`endif
  
endmodule
	    
	 
