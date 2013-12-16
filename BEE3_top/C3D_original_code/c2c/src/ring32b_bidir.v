/* 	ring32b_bidir.v
	Philip Watts
	6th April 2010
	Chip-to-chip module for the BEE3 based on the microsoft DDR2 code
	This version hides the clock inversion control from the top level
*/ 

`timescale 1ns / 1ps

module ring32b_bidir(
	 // Clocks and resets	
   	 input 		CLK,		// Main interface clock
	 input		swClk0,		// Unbuffered calibration clock  
	 input		swClk180,	// Unbuffered cal clock, 180 deg out of phase
	 input 		Reset,
	 
	 // Data interface with fabric
	 input [63:0] 	din,
	 output[63:0] 	dout,

	 //Pin signals
   	 output [31:0]	RING_OUT,
   	 input  [31:0]	RING_IN,

	 //Control signals
	 input 		lock_in,
	 output		lock_out,
	 input 		partner_ready,
	 output [31:0] 	test_sigs
     );
	
	//Each CLK, we send four 32-bit words.
	//The testing requires Chipscope.

	reg  Equalx;
	reg  Equal;
	reg  Zerox;
	reg  Zero;	
	reg  [63:0] TxD;
	reg  [63:0] RxD;
	wire [31:0] outData;
  	wire [31:0] bankData; //data from the input pin
   	wire [31:0] bankDataDly; //data from the IDELAY
   	wire [63:0] isData; //data out of the ISERDES
   	reg  [63:0] nextPoly;  //the next received value we expect
   	(* KEEP = "TRUE" *) reg incDelay;
   	(* KEEP = "TRUE" *) reg resetDelay;
   	reg[6:0] currentTap;
   	reg[5:0] candWS; //candidate window start
	reg candSW;
  	reg[5:0] candWW; //candidate window width
  	reg[5:0] WW; //window width
   	reg[5:0] WS; //window start
	reg realSW;
	reg[2:0] ringState;
	//wire [35:0] control0;
	//wire [255:0] cscope_sigs;
	reg lock_out_int;
	reg [63:0] dout_int;
	wire switchClock; 
	wire swClock;
	
	localparam Unlocked = 0;
	localparam DecWS = 1;
	localparam DecWW = 3;
	localparam Locked = 2;
	localparam NormOp = 6;
	
	assign test_sigs = {26'b0, Equal, Zero, ringState, switchClock};

	// Generate clocks for C2C phase alignment
	// Switchable between 0 and 180 degrees phase
 	BUFGMUX_CTRL swClkbuf1 (
		.O(swClock),	 	// Clock MUX output
		.I0(swClk0), 		// Clock0 input
		.I1(swClk180), 		// Clock1 input
		.S(switchClock)); 	// Clock select input


	// Hold in reset until communicating partner is ready.  Then send a test pattern
	// until calibration has finished
	always @(posedge CLK) begin
		if(Reset) 
			TxD <= 63'h1;
		else if (ringState==NormOp)
			TxD <= din;
		else
			TxD <= {TxD[62:0], (TxD[63] ^ TxD[62] ^ TxD[60] ^ TxD[59])};
	end	
	
  // The transmit pins
  genvar pin;
  generate
    for(pin = 0; pin < 32; pin = pin + 1)
    begin: makePin
    ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE"
      .INIT(1'b0), // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
    )  dataPin (
      .Q  (outData[pin]  ),
      .C  (CLK           ),
      .CE (1'b1          ),
      .D1 (TxD[2*pin + 1]),
      .D2 (TxD[2*pin]    ),
      .R  (1'b0          ),
      .S  (1'b0          )
    );
	 
	 OBUF pinBuf(
	   .I(outData[pin]),
		.O(RING_OUT[pin])
	 );
   end
  endgenerate
  
//The receiver pins
genvar inPin;
generate
  for(inPin = 0; inPin < 32; inPin = inPin + 1)
  begin: makeInPin
    IBUF rPinBuf(.I(RING_IN[inPin]), .O(bankData[inPin]));
	 
	 IDELAY #(
      .IOBDELAY_TYPE("VARIABLE"), // "DEFAULT", "FIXED" or "VARIABLE"
      .IOBDELAY_VALUE(0) // Any value from 0 to 63
    )  rPinDly (
      .O(bankDataDly[inPin]), // 1-bit output
      .C(CLK), // 1-bit clock input
      .CE(incDelay), // 1-bit clock enable input
      .I(bankData[inPin]), // 1-bit data input
      .INC(incDelay), // 1-bit increment input
      .RST(resetDelay) // 1-bit reset input
    );	
  

    IDDR #(
     .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE"
     .INIT_Q1(1'b0), // Initial value of Q1: 1?b0 or 1?b1
     .INIT_Q2(1'b0), // Initial value of Q2: 1?b0 or 1?b1
     .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC"
    ) rcvIddr (
    .Q1(isData[2 * inPin + 1]), // 1-bit output for positive edge of clock
    .Q2(isData[2 * inPin]), // 1-bit output for negative edge of clock
    .C(swClock), // 1-bit clock input
    .CE(1'b1), // 1-bit clock enable input
    .D(bankDataDly[inPin]), // 1-bit DDR data input
    .R(1'b0), // 1-bit reset
    .S(1'b0) // 1-bit set
  );
  end
endgenerate

// Calibration process
// Finds the maximum-width window (sequence of taps for which Equal is true).
 always @(posedge CLK) begin
   if(Reset) begin
     ringState <= Unlocked;
	  WS <= 0;
	  WW <= 0;
	  realSW <= 0;
	  candWS <= 0;
	  candWW <= 0;
	  candSW <= 0;
	  currentTap <= 0;
	  resetDelay <= 1;
	  incDelay <= 0;
	  lock_out_int <= 0;
	end
	else begin case(ringState)
	
	Unlocked: begin
	  resetDelay <= 0;
	  incDelay <= 1;
	  currentTap <= currentTap + 1;
	  if( (currentTap == 127) & ({1'b0, WW} > 8)) begin		// IDELAY has 64 taps x 2 phase states = 128 'taps'
		  resetDelay <= 1;
		  ringState <= DecWS;
	  end

	  else if(Equal & ~Zero & currentTap[5:0] != 31) candWW <= candWW + 1;
	  else begin
       if({1'b0,candWW} >= {1'b0,WW}) begin
	      WW <= candWW;
			realSW <= candSW;
	      WS <= candWS;
	    end
	    candWS <= currentTap[5:0];
		 candSW <= currentTap[6];
	    candWW <= 0;
	  end
	end
	
	DecWS: begin
	  resetDelay <= 0;
	  if(WS == 0) begin
       ringState <= DecWW;
		 WW <= WW/2;
	  end
	  else WS <= WS - 1;
	end
	
	DecWW: begin
	  if(WW == 0) begin
	    ringState <= Locked;
		 incDelay <= 0;
	  end
	  else WW <= WW - 1;
	end
	
	Locked: begin
		lock_out_int <= 1;
		if (lock_in == 1) ringState <= NormOp;
//		if(~Equal | Zero) begin
//       ringState <= Unlocked;
//		 WS <= 0;
//	    WW <= 0;
//       realSW <= 0;		
//	    candWS <= 0;
//	    candWW <= 0;
//		 candSW <= 0;
//	    currentTap <= 0;
//	    resetDelay <= 1;
//	    incDelay <= 0;
//		end
	end	

	
	NormOp: begin 
		if (lock_in == 0) ringState <= Locked;
	end
	  
	endcase
	end
 end

 assign switchClock = ringState == Unlocked ?  currentTap[6]: realSW;

 always @(posedge swClock) RxD <= isData;
 always @(posedge swClock) nextPoly <= {RxD[62:0], (RxD[63] ^ RxD[62] ^RxD[60] ^ RxD[59])};
 always @(posedge swClock) Equalx <= nextPoly == RxD;
 always @(posedge swClock) Zerox <= RxD == 0;
 always @(posedge CLK) Equal <= Equalx;
 always @(posedge CLK) Zero <= Zerox;
 
 always @(posedge CLK) dout_int <= RxD;
 assign dout = dout_int;
 assign lock_out = lock_out_int;
 	
endmodule
