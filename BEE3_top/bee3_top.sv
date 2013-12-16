// File: bee3_top.sv
// A top level bee3 wrapper for synthesis in Mentor PS providing 
// clocking, chip2chip interfaces and chipscope debug for network
// designs using the BEE3 boards
// Author: Philip Watts, UCL, December 2013

// Notes:
// 1. // 	Ring UP goes to the FPGA with the higher Letter, e.g., 
// FPGA A->B, B->C, C->D, D->A.  Ring DN goes to the FPGA with 
// the lower Letter, e.g., FPGA A->D, B->A, C->B, D->C.  This is 
// from the original Microsoft documentation - a simpler way of 
// puting it is Up goes clockwise or anticlockwise and down goes 
// the other way.  We will need to experiment to be sure of the 
// details.
// There are also diagonal connections (if implemented on our 
// board) which will need an extra ring32b_bidir module to be
// instantiated.  If these are present, they will be very useful
// for optical networks with a central switch.    

module bee3_top (
	// Clocks
	input  logic         clk100m_p, 
	input  logic         clk100m_n,
	// Chip2Chip interface and handshaking
	input  logic [31:00] C2C_U_IN,
  input  logic [31:00] C2C_D_IN,
  output logic [31:00]	C2C_U_OUT,
  output logic [31:00] C2C_D_OUT,
  input		logic        	C2C_U_LOCK_IN,
  output	logic        	C2C_U_LOCK_OUT,
  input		logic        	C2C_U_RDY_IN,
  output	logic       		C2C_U_RDY_OUT, 
  input		logic        	C2C_D_LOCK_IN,
  output	logic        	C2C_D_LOCK_OUT,
  input		logic        	C2C_D_RDY_IN,
  output	logic       		C2C_D_RDY_OUT);
	
	// === Internal Signals ===
	// Chipscope
	logic        [35:0]  CONTROL0, CONTROL1;
	logic        [255:0] TRIG0;
	logic        [15:0]  ASYNC_IN, ASYNC_OUT;
	logic        [31:0]  c2cu_status,c2cd_status;
	// Clocks and resets
	logic                clk;
	logic                MCLK, MCLK180;
	logic                PLL_LOCK;
	logic                reset_ring;
	logic                reset_counter;
	logic                pll_lock1,pll_lock2,pll_lock3;
	logic                c2cu_reset,c2cd_reset; 
	// Network interface signals
	logic        [63:0]  count;
	logic        [63:0]  count_received_u;
  logic        [63:0]  count_received_d;
  	
	// === NETWORK CODE ===
	// This is where the network code goes.  All other modules below
	// support this by providing clocks, external interfaces and 
	// debugging (chipscope).  In this test example, the "network"
	// consists of a simple counter 
	counter_top inst_count (
		.count(count),
		.rst(reset_counter),
		.clk(clk));


  //=== CHIPSCOPE CONNECTIONS ===
  // Specify signals to appear on chipscope.  TRIG0 is input to 
  // scope (integrated logic analyser), maximum 256 signals.
  // ASYNC_IN and ASYNC_OUT are connections to virtual IO, max
  // 16 bits in, 16 bits out
  always_comb begin
    TRIG0 = {	PLL_LOCK,c2cu_status[5:0],c2cd_status[5:0],count_received_u,count_received_d,count};
    ASYNC_IN[0]   =   PLL_LOCK;
    reset_ring    =   ASYNC_OUT[0];
    reset_counter =   ASYNC_OUT[1];
  end
	
		
	// === CLOCKS ===
	// All clock generation code is included in this module
	clock_manager inst_clocks (
	   .CLK        (clk),
	   .MCLK       (MCLK),
	   .MCLK180    (MCLK180),
	   .PLL_LOCK   (PLL_LOCK),
	   .CLK100M_P  (clk100m_p),
	   .CLK100M_N  (clk100m_n));

  // === GENERATE RESETS ===
	always_ff @ (posedge clk) begin
      pll_lock3 <= pll_lock2;
      pll_lock2 <= pll_lock1;
      pll_lock1 <= PLL_LOCK;
    end
  always_comb begin
    c2cu_reset = (!(pll_lock3 & C2C_U_RDY_IN)) | reset_ring;
    c2cd_reset = (!(pll_lock3 & C2C_D_RDY_IN)) | reset_ring;
  end  

  // === C2C Modules ===	 

  ring32b_bidir inst_c2c_up(
  .CLK		(clk),
  .swClk0		(MCLK),
  .swClk180	(MCLK180),	
  .Reset		(c2cu_reset),
  .din		(count),  // This is the data for transmission
  .dout		(count_received_u), // This is the received data
  .RING_OUT	(C2C_U_OUT),
  .RING_IN	(C2C_U_IN),
  .lock_in	(C2C_U_LOCK_IN),
  .lock_out	(C2C_U_LOCK_OUT),
  //.partner_ready	(C2C_U_RDY_IN),
  .test_sigs	(c2cu_status));

ring32b_bidir inst_c2c_dn(
  .CLK		(clk),
  .swClk0		(MCLK),
  .swClk180	(MCLK180),	
  .Reset		(c2cd_reset),
  .din		(count),  // This is the data for transmission
  .dout		(count_received_d), // This is the received data
  .RING_OUT	(C2C_D_OUT),
  .RING_IN	(C2C_D_IN),
  .lock_in	(C2C_D_LOCK_IN),
  .lock_out	(C2C_D_LOCK_OUT),
  //.partner_ready	(C2C_D_RDY_IN),
  .test_sigs	(c2cd_status));

  always_comb begin
    C2C_U_RDY_OUT = PLL_LOCK;
    C2C_D_RDY_OUT = PLL_LOCK;
  end

  // === IDELAYCTRL for alignment of ring interconnect ===
 IDELAYCTRL idelayctrl0 (
    .RDY	(),
    .REFCLK	(clk), 
    .RST	(~pll_lock3)
  )  /* synthesis syn_noprune =1 */ ;
	
	//=== CHIPSCOPE MODULES ===
	  cs_icon inst_icon (
      .CONTROL0(CONTROL0), // INOUT BUS [35:0]
      .CONTROL1(CONTROL1) // INOUT BUS [35:0]
    );
		cs_scope inst_scope (
        .CONTROL(CONTROL0), // INOUT BUS [35:0]
        .CLK(clk), // IN
        .TRIG0(TRIG0) // IN BUS [255:0]
    );
    cs_vio inst_vio (
        .CONTROL(CONTROL1), // INOUT BUS [35:0]
        .ASYNC_IN(ASYNC_IN), // IN BUS [15:0]
        .ASYNC_OUT(ASYNC_OUT) // OUT BUS [15:0]
    );
    
endmodule	