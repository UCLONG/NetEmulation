// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : NetEmulation
// Module name : NEMU_NetEmulation
// Description : TopModule
//           
// Uses        : config.sv, fuctions.sv, network.sv, NEMU_PacketSink, NEMU_PacketSource, NEMU_SerialPortWrapper
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------

`include "config.sv"
//`timescale 10ps/1ps

/////////////////////////////////////////////
///////// MODULE DEF FOR SYNTHESIS //////////
/////////////////////////////////////////////
`ifdef SYNTHESIS
module NEMU_NetEmulation (
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
module NEMU_NetEmulation ();
  
  // Internal signals specific to simulation
  logic rst;
  logic [`PORTS-1:0] input_fifo_error;
  //logic [`PORTS-1:0] dest_error;
  
  //needs to be moved to synthesis
  
  //move

`endif
 
/////////////////////////////////////////////
//////// COMMON SIGNALS FOR SYNTH/SIM /////// 
/////////////////////////////////////////////  
  
  logic clk;
  logic [31:0] timestamp;
  logic [31:0] timecounter;
  logic measure;
  logic source_on;
  logic sendData;
  packet_t pkt_in [0:`PORTS-1] /* synthesis keep */; 
  packet_t pkt_out [0:`PORTS-1] /* synthesis keep */;
  logic [`PORTS-1:0] net_full /* synthesis keep */;
  logic [15:0] pkt_count_rx [0:`PORTS-1][0:`PORTS-1] /* synthesis keep */;
  logic [15:0] pkt_count_tx [0:`PORTS-1][0:`PORTS-1] /* synthesis keep */;
  logic [23:0] latency [0:`PORTS-1][0:`PORTS-1] /* synthesis keep */;
  genvar i;
  logic serialTX;
  logic dataSent;
  integer file;
  logic [31:0] total_pkt_count;
  parameter SEED = 1365;
  parameter LOAD = 80; //in %
  

  

  //////////////////////////////////////////////////////////////////////
  ////////////// COMMON CODE FOR SIM AND SYNTH /////////////////////////
  //////////////////////////////////////////////////////////////////////  
      
  
  // Instantiate pkt_sources
   generate for (i=0;i<`PORTS;i++)
      begin: source_loop
         NEMU_PacketSource #(i) pkts (clk, (rst | (!source_on)), timestamp, net_full[i], SEED, LOAD, pkt_in[i], input_fifo_error[i]);
      end
   endgenerate
  

  NEMU_PacketSink sinks (clk, rst, pkt_out, pkt_in, timestamp, input_fifo_error, net_full, measure, latency, pkt_count_rx, pkt_count_tx, total_pkt_count);  
  
  `ifdef SYNTHESIS  
  NEMU_SerialPortWrapper SerialPortWrapper(clk, rst, latency, pkt_count_rx, pkt_count_tx, sendData, dataSent, serialTX); 
  `endif
  
  // Timestamp counter
  always_ff @(posedge clk)
    if (rst)
       timestamp <= 0;
    else
        timestamp <= timestamp + 1; 
      
    
  //////////////////////////////////////////////////////////////////////
  ////////////////////// INSTANTIATE NETWORK ///////////////////////////
  //////////////////////////////////////////////////////////////////////

  // SystemVerilog network model
  network inst_net(clk, rst, pkt_in, pkt_out, net_full);
  

  

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
  #(100ns)
  rst = 0;
  //file = $fopen("latency.txt");
end

always_ff @(posedge clk) begin
  if (rst) begin
    source_on <= 1;
    measure <= 0;
    sendData <= 0;
    timecounter <= 0;
  end
  if (total_pkt_count < `WARMUP_PERIOD_PKT) begin
    `ifdef BATCH_ANALYSIS_ENABLE 
    measure <= 1;
    `else
    measure <= 0;
    `endif
    sendData <= 0;
  end
  if (total_pkt_count > `WARMUP_PERIOD_PKT && total_pkt_count <= `MEASURE_PERIOD_PKT) begin
    measure <= 1;
    sendData <= 0;
  end
  if (total_pkt_count > `MEASURE_PERIOD_PKT) begin
   source_on <= 0;
    if (timecounter < `COOLDOWN_PERIOD) begin
      timecounter <= timecounter + 1;
    end
    if (timecounter == `COOLDOWN_PERIOD) begin
      measure <= 0;
      sendData <= 1;
      timecounter <= timecounter + 1;
      $display("Ending measurement period at simulation time %t.\n", $realtime);

    end
    if (timecounter == (`COOLDOWN_PERIOD + 1)) begin
      $stop;
    end
  end
  
end
  
`endif
  
endmodule
	    
	 
