///////////////////////////////////////////////////////////////////////////////
// b2bTop.v 
// Board-to-board code for the BEE3 boards 
// Philip Watts, created 30/4/2010
// Based on the Xilinx Aurora protocol
// Instantiates two 4-lane x 3.125 Gb/s interfaces
// 
///////////////////////////////////////////////////////////////////////////////

`define TX_DRIVER_CHIPSCOPE

`ifdef C3D_BUILD 
  `include "../../interfaces/b2b/src/verilog/aur1.v"
  `include "../../interfaces/b2b/src/verilog/aur1_aurora_lane.v"
  `include "../../interfaces/b2b/src/verilog/aur1_channel_error_detect.v"
  `include "../../interfaces/b2b/src/verilog/aur1_channel_init_sm.v"
  `include "../../interfaces/b2b/src/verilog/aur1_chbond_count_dec.v"
  `include "../../interfaces/b2b/src/verilog/aur1_clock_module.v"
  `include "../../interfaces/b2b/src/verilog/aur1_error_detect.v"
  `include "../../interfaces/b2b/src/verilog/aur1_global_logic.v"
  `include "../../interfaces/b2b/src/verilog/aur1_idle_and_ver_gen.v"
  `include "../../interfaces/b2b/src/verilog/aur1_lane_init_sm.v"
  `include "../../interfaces/b2b/src/verilog/aur1_rx_stream.v"
  `include "../../interfaces/b2b/src/verilog/aur1_standard_cc_module.v"
  `include "../../interfaces/b2b/src/verilog/aur1_sym_dec.v"
  `include "../../interfaces/b2b/src/verilog/aur1_sym_gen.v"
  `include "../../interfaces/b2b/src/verilog/aur1_transceiver_tile.v"
  `include "../../interfaces/b2b/src/verilog/aur1_transceiver_wrapper.v"
  `include "../../interfaces/b2b/src/verilog/aur1_tx_stream.v"
`else
  `include "aur1.v"
  `include "aur1_aurora_lane.v"
  `include "aur1_channel_error_detect.v"
  `include "aur1_channel_init_sm.v"
  `include "aur1_chbond_count_dec.v"
  `include "aur1_clock_module.v"
  `include "aur1_error_detect.v"
  `include "aur1_global_logic.v"
  `include "aur1_idle_and_ver_gen.v"
  `include "aur1_lane_init_sm.v"
  `include "aur1_rx_stream.v"
  `include "aur1_standard_cc_module.v"
  `include "aur1_sym_dec.v"
  `include "aur1_sym_gen.v"
  `include "aur1_transceiver_tile.v"
  `include "aur1_transceiver_wrapper.v"
  `include "aur1_tx_stream.v"
  `include "aur1_frame_check.v"
  `include "aur1_frame_gen.v"
  `include "../../build/synth/coregen/cs_icon.v"
  `include "../../build/synth/coregen/cs_ila.v"
  `include "../../build/synth/coregen/cs_vio.v"
`endif
	
     
`timescale 1 ns / 1 ps
// Original core generation parameters
(* core_generation_info = "aur1,aurora_8b10b_v5_1,{backchannel_mode=Sidebands, c_aurora_lanes=4, c_column_used=left, c_gt_clock_1=GTPD7, c_gt_clock_2=None, c_gt_loc_1=X, c_gt_loc_10=X, c_gt_loc_11=X, c_gt_loc_12=X, c_gt_loc_13=3, c_gt_loc_14=4, c_gt_loc_15=1, c_gt_loc_16=2, c_gt_loc_17=X, c_gt_loc_18=X, c_gt_loc_19=X, c_gt_loc_2=X, c_gt_loc_20=X, c_gt_loc_21=X, c_gt_loc_22=X, c_gt_loc_23=X, c_gt_loc_24=X, c_gt_loc_25=X, c_gt_loc_26=X, c_gt_loc_27=X, c_gt_loc_28=X, c_gt_loc_29=X, c_gt_loc_3=X, c_gt_loc_30=X, c_gt_loc_31=X, c_gt_loc_32=X, c_gt_loc_33=X, c_gt_loc_34=X, c_gt_loc_35=X, c_gt_loc_36=X, c_gt_loc_37=X, c_gt_loc_38=X, c_gt_loc_39=X, c_gt_loc_4=X, c_gt_loc_40=X, c_gt_loc_41=X, c_gt_loc_42=X, c_gt_loc_43=X, c_gt_loc_44=X, c_gt_loc_45=X, c_gt_loc_46=X, c_gt_loc_47=X, c_gt_loc_48=X, c_gt_loc_5=X, c_gt_loc_6=X, c_gt_loc_7=X, c_gt_loc_8=X, c_gt_loc_9=X, c_lane_width=2, c_line_rate=3.125, c_nfc=false, c_nfc_mode=IMM, c_refclk_frequency=156.25, c_simplex=false, c_simplex_mode=TX, c_stream=true, c_ufc=false, flow_mode=None, interface_mode=Streaming, dataflow_config=Duplex,}" *)

module b2bTop #
(
     parameter   SIM_GTPRESET_SPEEDUP = 1      // Set to 1 to speed up sim reset
)
(
`ifdef C3D_BUILD // Signals only for C3D_BUILD
    input   [63:00]	B2B_TX_DATA1,
    input   [63:00]	B2B_TX_DATA2,
    output  [63:00]	B2B_RX_DATA1,
    output  [63:00]	B2B_RX_DATA2,
    output		B2B_TX_READY1,
    input		B2B_TX_DATA_VALID1,
    output		B2B_RX_DATA_VALID1,
    output		B2B_TX_READY2,
    input		B2B_TX_DATA_VALID2,
    output		B2B_RX_DATA_VALID2,
	// RDY, EN signals	
    output reg [01:00]	B2B_CHANNEL_UP,
    output reg [01:00]	B2B_ERROR,
    output 			B2B_TXOUTCLK,
    input			B2B_USR_CLK_IN,
    input			B2B_SYNC_CLK_IN,
    input			PLL_LOCKED,		
`else 		// Signals only for standalone build 
`endif
	//Common signals
    input   [07:00] RXP,
    input   [07:00] RXN,
    output  [07:00] TXP,
    output  [07:00] TXN,
    input	 		B2B_REFCLK_N,
    input			B2B_REFCLK_P
);

//********************************Wire Declarations**********************************

    // Stream TX Interface
    wire    [0:63]     tx_d_i;
    wire               tx_src_rdy_n_i;
    wire               tx_dst_rdy_n_i;
    wire    [0:63]     tx2_d_i;
    wire               tx2_src_rdy_n_i;
    wire               tx2_dst_rdy_n_i;
    // Stream RX Interface
    wire    [0:63]     rx_d_i;
    wire               rx_src_rdy_n_i;
    wire    [0:63]     rx2_d_i;
    wire               rx2_src_rdy_n_i;
    // V5 Reference Clock Interface
    wire               GTPD7_left_i;

    // Error Detection Interface
    wire               hard_error_i;
    wire               soft_error_i;
    wire               hard_error2_i;
    wire               soft_error2_i;
    // Status
    wire               channel_up_i;
    wire    [0:3]      lane_up_i;
    wire               channel_up2_i;
    wire    [0:3]      lane_up2_i;
    // Clock Compensation Control Interface
    wire               warn_cc_i;
    wire               do_cc_i;
    wire               warn_cc2_i;
    wire               do_cc2_i;
    // System Interface
    wire               pll_not_locked_i;
    wire               user_clk_i;
    wire               sync_clk_i;
    wire               reset_i;
    wire               power_down_i;
    wire    [2:0]      loopback_i;
    wire               tx_lock_i;
    wire               tx2_lock_i;

    wire               tx_out_clk_i;
    wire               buf_tx_out_clk_i;

    //wire               gt_reset_i; 
    //wire               system_reset_i;
    //Frame check signals
    wire    [0:7]      error_count_i;
    wire               test_reset_i;
    wire    [0:7]      error_count2_i;
    wire               test_reset2_i;

    wire [35:0] icon_to_vio_i;
    wire [63:0] sync_in_i;
    wire [15:0] sync_out_i;
    
    wire   lane_up_i_i;
    wire   tx_lock_i_i;
    wire   lane_up2_i_i;
    wire   tx2_lock_i_i;
	wire	[2:0]	txdiff_i;
	wire	[2:0]	txpreemp_i;

	// Chipscope Signals
	wire [35:0] CONTROL0;
	wire [35:0] CONTROL1;
	wire [35:0] CONTROL2;
	wire [35:0] CONTROL3;
	wire [35:0] CONTROL4;
	wire [35:0] CONTROL5;
	wire [255:0] TRIG0;
	wire [255:0] TRIG1;
	wire [255:0] TRIG2;
	wire [255:0] TRIG3;
	wire [31:0] VIO0;	 
	 
//*********************************Main Body of Code**********************************
//_______________________________Clock Buffers_________________________________
	IBUFDS IBUFDS
	 (
	 .I(B2B_REFCLK_P),
	 .IB(B2B_REFCLK_N),
	 .O(GTPD7_left_i)
	 );

	BUFG BUFG
 	(
  	.I(tx_out_clk_i),
  	.O(buf_tx_out_clk_i)
	);

`ifdef C3D_BUILD

	assign B2B_TXOUTCLK = buf_tx_out_clk_i;

`else

    	// Instantiate a clock module for clock division.
    	aur1_CLOCK_MODULE clock_module_i
    	(
        .GT_CLK(buf_tx_out_clk_i),
        .GT_CLK_LOCKED(tx_lock_i),
        .USER_CLK(user_clk_i),
        .SYNC_CLK(sync_clk_i),
        .PLL_NOT_LOCKED(pll_not_locked_i)
    	);

`endif

//_________________________Top Level Signals for C3D_BUILD____________________________

`ifdef C3D_BUILD

    always @(posedge user_clk_i)
    begin
        B2B_ERROR      <=  {hard_error2_i | soft_error2_i , hard_error_i | soft_error_i};
        //LANE_UP         <=  lane_up_i;
        B2B_CHANNEL_UP      <=  {channel_up2_i, channel_up_i};
    end
    
    assign usr_clk_i 		= B2B_USR_CLK_IN;
    assign sync_clk_i 		= B2B_SYNC_CLK_IN;
    assign tx_d_i 		= B2B_TX_DATA1;
    assign tx2_d_i		= B2B_TX_DATA2;
    assign B2B_RX_DATA1		= rx_d_i;
    assign B2B_RX_DATA2		= rx2_d_i;
    assign tx_src_rdy_n_i	= !B2B_TX_DATA_VALID1;
    assign B2B_TX_READY1	= !tx_dst_rdy_n_i;
    assign B2B_RX_DATA_VALID1	= !rx_src_rdy_n_i;
    assign tx2_src_rdy_n_i	= !B2B_TX_DATA_VALID2;
    assign B2B_TX_READY2	= !tx2_dst_rdy_n_i;
    assign B2B_RX_DATA_VALID2	= !rx2_src_rdy_n_i;
    assign pll_not_locked_i	= !PLL_LOCKED;
		 		
`endif

//____________________________Tie off unused signals_______________________________

    // System Interface
    assign  power_down_i        =   1'b0;
    //assign  loopback_i          =   3'b000;

//___________________________Module Instantiations_________________________________
    aur1 #
    (
        .SIM_GTPRESET_SPEEDUP(SIM_GTPRESET_SPEEDUP)
    )
    aurora_module_i
    (
        // Stream TX Interface
        .TX_D(tx_d_i),
        .TX_SRC_RDY_N(tx_src_rdy_n_i),
        .TX_DST_RDY_N(tx_dst_rdy_n_i),
        // Stream RX Interface
        .RX_D(rx_d_i),
        .RX_SRC_RDY_N(rx_src_rdy_n_i),
        // V5 Serial I/O
        .RXP(RXP[3:0]),
        .RXN(RXN[3:0]),
        .TXP(TXP[3:0]),
        .TXN(TXN[3:0]),
        // V5 Reference Clock Interface
        .GTPD7(GTPD7_left_i),
        // Error Detection Interface
        .HARD_ERROR(hard_error_i),
        .SOFT_ERROR(soft_error_i),
        // Status
        .CHANNEL_UP(channel_up_i),
        .LANE_UP(lane_up_i),
        // Clock Compensation Control Interface
        .WARN_CC(warn_cc_i),
        .DO_CC(do_cc_i),
        // System Interface
        .USER_CLK(user_clk_i),
        .SYNC_CLK(sync_clk_i),
        .RESET(reset_i),
        .POWER_DOWN(power_down_i),
        .LOOPBACK(loopback_i),
        .GT_RESET(1'b0),
        .TX_LOCK(tx_lock_i),
        .TX_OUT_CLK(tx_out_clk_i),
	.TXDIFF(txdiff_i),
	.TXPREEMP(txpreemp_i)
    );

 aur1 #
    (
        .SIM_GTPRESET_SPEEDUP(SIM_GTPRESET_SPEEDUP)
    )
    aurora_module2_i
    (
        // Stream TX Interface
        .TX_D(tx2_d_i),
        .TX_SRC_RDY_N(tx2_src_rdy_n_i),
        .TX_DST_RDY_N(tx2_dst_rdy_n_i),
        // Stream RX Interface
        .RX_D(rx2_d_i),
        .RX_SRC_RDY_N(rx2_src_rdy_n_i),
        // V5 Serial I/O
        .RXP(RXP[7:4]),
        .RXN(RXN[7:4]),
        .TXP(TXP[7:4]),
        .TXN(TXN[7:4]),
        // V5 Reference Clock Interface
        .GTPD7(GTPD7_left_i),
        // Error Detection Interface
        .HARD_ERROR(hard_error2_i),
        .SOFT_ERROR(soft_error2_i),
        // Status
        .CHANNEL_UP(channel_up2_i),
        .LANE_UP(lane_up2_i),
        // Clock Compensation Control Interface
        .WARN_CC(warn_cc2_i),
        .DO_CC(do_cc2_i),
        // System Interface
        .USER_CLK(user_clk_i),
        .SYNC_CLK(sync_clk_i),
        .RESET(reset_i),
        .POWER_DOWN(power_down_i),
        .LOOPBACK(loopback_i),
        .GT_RESET(1'b0),
        .TX_LOCK(tx2_lock_i),
        .TX_OUT_CLK(),
	.TXDIFF(txdiff_i),
	.TXPREEMP(txpreemp_i)
    );

    aur1_STANDARD_CC_MODULE standard_cc_module_i
    (
        .RESET(reset_i),
        // Clock Compensation Control Interface
        .WARN_CC(warn_cc_i),
        .DO_CC(do_cc_i),
        // System Interface
        .PLL_NOT_LOCKED(pll_not_locked_i),
        .USER_CLK(user_clk_i)
    );

    aur1_STANDARD_CC_MODULE standard_cc_module2_i
    (
        .RESET(reset_i),
        // Clock Compensation Control Interface
        .WARN_CC(warn_cc2_i),
        .DO_CC(do_cc2_i),
        // System Interface
        .PLL_NOT_LOCKED(pll_not_locked_i),
        .USER_CLK(user_clk_i)
    );

//////////////////////////////// Xilinx Test Modules////////////////////////////////
  
`ifndef C3D_BUILD

    //Connect a frame generator to the TX User interface
    aur1_FRAME_GEN frame_gen_i
    (
        // User Interface
        .TX_D(tx_d_i),  
        .TX_SRC_RDY_N(tx_src_rdy_n_i),
        .TX_DST_RDY_N(tx_dst_rdy_n_i),


        // System Interface
        .USER_CLK(user_clk_i),       
        .RESET(test_reset_i),
        .CHANNEL_UP(channel_up_i)
    );
    aur1_FRAME_GEN frame_gen2_i
    (
        // User Interface
        .TX_D(tx2_d_i),  
        .TX_SRC_RDY_N(tx2_src_rdy_n_i),
        .TX_DST_RDY_N(tx2_dst_rdy_n_i),


        // System Interface
        .USER_CLK(user_clk_i),       
        .RESET(test_reset2_i),
        .CHANNEL_UP(channel_up2_i)
    );
    aur1_FRAME_CHECK frame_check_i
    (
        // User Interface
        .RX_D(rx_d_i),  
        .RX_SRC_RDY_N(rx_src_rdy_n_i),
 
        // System Interface
        .USER_CLK(user_clk_i),       
        .RESET(test_reset_i),
        .CHANNEL_UP(channel_up_i),
        .ERR_COUNT(error_count_i)
    );    
    aur1_FRAME_CHECK frame_check2_i
    (
        // User Interface
        .RX_D(rx2_d_i),  
        .RX_SRC_RDY_N(rx2_src_rdy_n_i),
 
        // System Interface
        .USER_CLK(user_clk_i),       
        .RESET(test_reset2_i),
        .CHANNEL_UP(channel_up2_i),
        .ERR_COUNT(error_count2_i)
    );
 
`endif
/////////////////////////////End of Xilinx Test Modules////////////////////////////

`ifdef C3D_BUILD
     	assign  reset_i 		 =   pll_not_locked_i;
`else
	assign  reset_i =   pll_not_locked_i | sync_out_i[0];
   	assign test_reset_i = !lane_up_i | sync_out_i[15];
   	assign test_reset2_i = !lane_up2_i | sync_out_i[14];
`endif

`ifndef TX_DRIVER_CHIPSCOPE
     assign  loopback_i          =   3'b000;
     assign  txdiff_i            =   3'b100;
     assign  txpreemp_i          =   3'b111;
`endif
	


/*
`ifndef C3D_BUILD
////////////////////////Simple Traffic Gen//////////////////////////
// Bluespec Interface traffic generator (only required for c2c test)

	mkGetOutput trafficgen1 (
		.CLK(usr_clk_i),
		.RST_N(channel_up_i),
		.EN_tx_sink_get(!tx_dst_rdy_n_i),
		.tx_sink_get(tx_d_i),
		.RDY_tx_sink_get(!tx_src_rdy_n_i));

	assign tx2_d_i = tx_d_i;
`endif
*/
///////////////////////Chipscope Debug//////////////////////////////
`ifndef C3D_BUILD
	
	cs_icon inst_icon (
    	.CONTROL0(CONTROL0),
    	.CONTROL1(CONTROL1),
    	.CONTROL2(CONTROL2),
	   .CONTROL3(CONTROL3),
	   .CONTROL4(CONTROL4),
	   .CONTROL5(CONTROL5)) /* synthesis syn_noprune =1 */ ;
		
//    	cs_vio inst_vio (
//    	.CONTROL(CONTROL0),
//    	.ASYNC_OUT(sync_out),
//	   .ASYNC_IN(sync_in)) /* synthesis syn_noprune =1 */ ;
		
  cs_vio i_vio
    (
      .CONTROL(CONTROL0),
      .CLK(user_clk_i),
      .SYNC_IN(sync_in_i),
      .SYNC_OUT(sync_out_i)
    );		
	 
	cs_ila inst_ila_cx4_1 (
    	.CONTROL(CONTROL1),
    	.CLK(user_clk_i),
    	.TRIG0(TRIG0))		/* synthesis syn_noprune =1 */ ;
		
	cs_ila inst_ila_cx4_2 (
	    .CONTROL(CONTROL2),
	    .CLK(user_clk_i),
     	.TRIG0(TRIG1))		/* synthesis syn_noprune =1 */ ;
		
	cs_ila inst_ila_c2c1 (
	    .CONTROL(CONTROL3),
	    .CLK(user_clk_i),
    	.TRIG0(TRIG2))		/* synthesis syn_noprune =1 */ ;
		
	cs_ila inst_ila_c2c2 (
	    .CONTROL(CONTROL4),
	    .CLK(user_clk_i),
    	.TRIG0(TRIG3))		/* synthesis syn_noprune =1 */ ;
		
	cs_ila inst_ila_spare (
	    .CONTROL(CONTROL5),
	    .CLK(user_clk_i),
    	.TRIG0(TRIG4))		/* synthesis syn_noprune =1 */ ;
  
  assign lane_up_i_i = &lane_up_i;
  assign tx_lock_i_i = tx_lock_i;  
  assign lane_up2_i_i = &lane_up2_i;
  assign tx2_lock_i_i = tx2_lock_i;
 
        assign  sync_in_i[7:0]          =  tx_d_i;
        assign  sync_in_i[15:8]         =  rx_d_i;
        assign  sync_in_i[23:16]        =  tx2_d_i;
        assign  sync_in_i[31:24]        =  rx2_d_i;
        assign  sync_in_i[39:32]        =  error_count_i;
	assign  sync_in_i[47:40]	=  error_count2_i;
	assign  sync_in_i[53]		=  soft_error2_i;
	assign  sync_in_i[54]		=  hard_error2_i;	
	assign  sync_in_i[55]		=  tx2_lock_i_i;
	assign  sync_in_i[56]		=  channel_up2_i;
	assign  sync_in_i[57]		=  lane_up2_i_i;
        assign  sync_in_i[58]           =  soft_error_i;
        assign  sync_in_i[59]           =  hard_error_i;
        assign  sync_in_i[60]           =  tx_lock_i_i;
        assign  sync_in_i[61]           =  pll_not_locked_i;
        assign  sync_in_i[62]           =  channel_up_i;
        assign  sync_in_i[63]           =  lane_up_i_i;
		  
	`ifdef TX_DRIVER_CHIPSCOPE	
		assign loopback_i	=  sync_out_i[3:1];
		assign txdiff_i		=  sync_out_i[6:4];
		assign txpreemp_i	=  sync_out_i[9:7];
	`endif		
	
	assign TRIG0[63:0]     =   tx_d_i;
	assign TRIG0[127:64]   =   rx_d_i;
	assign TRIG0[135:128]  =   error_count_i;
	assign TRIG0[136]      =   tx_dst_rdy_n_i;
	assign TRIG0[137]      =   tx_src_rdy_n_i;
	assign TRIG0[138]      =   rx_src_rdy_n_i;
	assign TRIG0[139]		  =	soft_error_i;
	assign TRIG0[140]		  =	hard_error_i;

	assign TRIG1[63:0]     =   tx2_d_i;
	assign TRIG1[127:64]   =   rx2_d_i;
	assign TRIG1[135:128]  =   error_count2_i;
	assign TRIG1[136]      =   tx2_dst_rdy_n_i;
	assign TRIG1[137]      =   tx2_src_rdy_n_i;
	assign TRIG1[138]      =   rx2_src_rdy_n_i;
	assign TRIG1[139]	=  soft_error2_i;
	assign TRIG1[140]	=  hard_error2_i;

	assign TRIG2 = {256'h0000000000000000000000000000000000000000000000000000000000000000};
	assign TRIG3 = {256'h0000000000000000000000000000000000000000000000000000000000000000};
	assign TRIG4 = {256'h0000000000000000000000000000000000000000000000000000000000000000};
`endif
//////////////////////End of Chipscope Debug/////////////////////////



endmodule


                                                                                                                                                                       
