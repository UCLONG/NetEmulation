// This switch tells the other modules to compile for the main build
`define C3D_BUILD

// Comment this to remove chipscope instantiations
`define CHIPSCOPE

`include "c3dClkGen2.v"
`include "../../interfaces/c2c/src/verilog/c2cTop.v"
`include "../../processors/mips64/src/verilog/mipsTop.v"
`include "../../interfaces/b2b/src/verilog/b2bTop.v"
`ifdef CHIPSCOPE
  `include "./coregen/icon.v"
  `include "./coregen/ila.v"
  `include "./coregen/vio.v"
`endif

module c3dTop (
  // clock inputs
  //input            CLK100M_N,
  //input            CLK100M_P,
  input            B2B_REFCLK_P,
  input            B2B_REFCLK_N,
  
  // uart
  input            UART_RX,
  output           UART_TX,
  
  // c2c module
  input  [31:00]   C2C_U_IN,      
  input  [31:00]   C2C_D_IN,      
  output [31:00]   C2C_U_OUT,     
  output [31:00]   C2C_D_OUT,     
  input			   C2C_U_LOCK_IN, 
  output		   C2C_U_LOCK_OUT,
  input			   C2C_U_RDY_IN,  
  output		   C2C_U_RDY_OUT, 
  input			   C2C_D_LOCK_IN, 
  output		   C2C_D_LOCK_OUT,
  input			   C2C_D_RDY_IN,  
  output		   C2C_D_RDY_OUT, 

  // b2b module
  input		[7:0]		B2B_RXN,
  input		[7:0]		B2B_RXP,
  output	[7:0]		B2B_TXN,
  output	[7:0]		B2B_TXP

);

  reg    [63:00]  c2c_u_tx_data, c2c_d_tx_data;   
  wire   [63:00]  c2c_u_rx_data, c2c_d_rx_data;
  reg    [63:00]  b2b_tx_data1, b2b_tx_data2;   
  wire   [63:00]  b2b_rx_data1, b2b_rx_data2;
  wire		  b2b_tx_ready1;
  wire		  b2b_tx_data_valid1;
  wire		  b2b_rx_data_valid1;
  wire		  b2b_tx_ready2;
  wire		  b2b_tx_data_valid2;
  wire		  b2b_rx_data_valid2;
  
  // Clock generation module
/*  c3dClkGen clk_gen (//.CLK100M_P (CLK100M_P  ),
					 //.CLK100M_N (CLK100M_N  ),
					 .CLK_IN    (b2bTxOutClk),
					 //.CLK_MAIN  (clkMain     ),  // O, main clock for design 
					 // pll 0 outputs (C2C and B2B)
					 .PLL0_OUT0 (clkMain    ),
					 .PLL0_OUT1 (clkMainX2  ),
					 .PLL0_OUT3 (clk156_180 ),  // *** NO BUFG ***
					 .PLL0_LOCK (pll0Lock   ),  // O: PLL 0 is locked
					 // pll 1 outputs (DDR2)
					 .PLL1_OUT0 (ddrClk     ),  // 266 MHz /?
					 .PLL1_OUT1 (ddrClk_90  ),
					 .PLL1_OUT2 (ddrClk_div4),
					 .PLL1_OUT4 (ddrClk_div2),
					 .PLL1_LOCK (pll1Lock   )   // O: PLL 1 is locked
  );	*/
c3dClkGen2	inst_clks (
	.CLKIN		(b2bTxOutClk),
	.SYSTEM_CLK	(clkMain),
	.SYNC_CLK	(b2b_sync_clk),
	.C2C_CLK	(c2c_clk),
	.C2C_CLK180	(c2c_clk180),
	.PLL0_LOCK	(pll0_lock));


  // mips64
  mipsTop mips64_0 (.CLK     (clkMain),
	                .RS232_RX(UART_RX),
	                .RS232_TX(UART_TX)
  );
  
  // Chip-to-Chip module
  c2cTop c2c_0 (.CLK           (clkMain       ),
				.MCLK          (c2c_clk        ),
				.MCLK180       (c2c_clk180    ),
				.PLL_LOCK      (pll0Lock      ), // I: PLL 0 is locked
				// UP
				.C2C_U_TX_DATA (c2c_u_tx_data ), // 64, data to send
				.C2C_U_RX_DATA (c2c_u_rx_data ), // 64, data received
				.C2C_U_IN      (C2C_U_IN      ), // 32, input from IO
				.C2C_U_OUT     (C2C_U_OUT     ), // 32, output to IO				
				.C2C_U_LOCK_IN (C2C_U_LOCK_IN ),
				.C2C_U_LOCK_OUT(C2C_U_LOCK_OUT),				
				.C2C_U_RDY_IN  (C2C_U_RDY_IN  ),
				.C2C_U_RDY_OUT (C2C_U_RDY_OUT ), 				
				// DOWN
				.C2C_D_TX_DATA (c2c_d_tx_data ), // 64, data to send
				.C2C_D_RX_DATA (c2c_d_rx_data ), // 64, data received
				.C2C_D_IN      (C2C_D_IN      ), // 32, input from IO
				.C2C_D_OUT     (C2C_D_OUT     ), // 32, output to IO
				.C2C_D_LOCK_IN (C2C_D_LOCK_IN ),
				.C2C_D_LOCK_OUT(C2C_D_LOCK_OUT),
				.C2C_D_RDY_IN  (C2C_D_RDY_IN  ),
				.C2C_D_RDY_OUT (C2C_D_RDY_OUT )
  );

  b2bTop b2b_0 (.B2B_REFCLK_N   (B2B_REFCLK_N),  // input clocks (156.25 MHz)
				.B2B_REFCLK_P   (B2B_REFCLK_P),
				.B2B_USR_CLK_IN (clkMain     ),  // I
				.B2B_SYNC_CLK_IN(b2b_sync_clk   ),	 // I					
				.B2B_TXOUTCLK   (b2bTxOutClk ),  // O, tx clock out				
				.B2B_TX_DATA1   (b2b_tx_data1),  // I 64
				.B2B_TX_DATA2   (b2b_tx_data2),  // I 64
				.B2B_RX_DATA1   (b2b_rx_data1),  // O 64
				.B2B_RX_DATA2   (b2b_rx_data2),  // O 64
				.B2B_CHANNEL_UP (),  // O 2
				.B2B_ERROR      (),  // O 2
				.PLL_LOCKED	(pll0Lock),
    			.B2B_TX_READY1		(b2b_tx_ready1),
    			.B2B_TX_DATA_VALID1	(b2b_tx_data_valid1),	
    			.B2B_RX_DATA_VALID1	(b2b_rx_data_valid1),
    			.B2B_TX_READY2		(b2b_tx_ready2),
    			.B2B_TX_DATA_VALID2	(b2b_tx_data_valid2),
 				.B2B_RX_DATA_VALID2	(b2b_rx_data_valid2),
				.RXP            (B2B_RXP),  // I 8
				.RXN            (B2B_RXN),  // I 8
				.TXP            (B2B_TXP),  // O 8
				.TXN            (B2B_TXN)   // O 8
  );  

/*  
  // DDR2 (x2) controller
  ddrTop ddr_0 (.CLK   (), // I
				.MCLK  (), // I
				.MCLK90(), // I
				.Ph0   (),  // I
				
				.a_Address  (), // I28
				.a_WriteAF  (), // I
				.a_AFfull   (), // I  
				.a_Read     (), // I H:Read, L:Write
				.a_ReadData (), // O128
				.a_RBempty  (), // O
				.a_WriteData(), // I128
				.a_WriteWB  (), // I
				.a_WBfull   (), // O
				
				.b_Address  (), // I28
				.b_WriteAF  (), // I
				.b_AFfull   (), // O  
				.b_Read     (), // I   // H:Read, L:Write
				.b_ReadData (), // O128
				.b_RBempty  (), // O
				.b_WriteData(), // I128
				.b_WriteWB  (), // I
				.b_WBfull   (), // O

  // Signals to the DIMMs A
				.a_DQ       (), // IO72 the 72 DQ pins
				.a_DQS      (), // IO18 the 18  DQS pins
				.a_DQS_L    (), // IO18
				.a_DIMMCK   (), // O2 differential clock to the DIMM
				.a_DIMMCKL  (), // O2
				.a_A        (), // O14 addresses to DIMMs
				.a_BA       (), // O3 bank address to DIMMs
				.a_RS       (), // O4 rank select
				.a_RAS      (), // O
				.a_CAS      (), // O
				.a_WE       (), // O
				.a_ODT      (), // O2
				.a_ClkEn    (), // O common clock enable for both DIMMs. SSTL1_8
				.a_DIMMreset(), // O low true
  
  // Signals to the DIMMs B
				.b_DQ       (), // IO72 the 72 DQ pins
				.b_DQS      (), // IO18 the 18  DQS pins
				.b_DQS_L    (), // IO18
				.b_DIMMCK   (), // O2 differential clock to the DIMM
				.b_DIMMCKL  (), // O2
				.b_A        (), // O14 addresses to DIMMs
				.b_BA       (), // O3 bank address to DIMMs
				.b_RS       (), // O4 rank select
				.b_RAS      (), // O
				.b_CAS      (), // O
				.b_WE       (), // O
				.b_ODT      (), // O2
				.b_ClkEn    (), // O common clock enable for both DIMMs. SSTL1_8
				.b_DIMMreset(), // O low true
				
				.FPGA_Reset  (), // I low true
				.Global_Reset(), // I low true
				.SCL         (), // I I2C clock
				.SDA         (), // I I2C data
				.TxD         (), // O RS232 transmit data
				.RxD         (), // I RS232 received data
				.Leds        (), // O2 low true to light the Led
				.LED_FP      (), // O
				.OTPIN       ()  // O Ensure this pin is low
  );
*/
  
  // just so there's something on the inputs
  always @(posedge clkMain) begin
    c2c_u_tx_data <= c2c_u_tx_data ^ c2c_u_rx_data + 3;
	c2c_d_tx_data <= c2c_d_tx_data ^ c2c_d_rx_data + 11; 
  end

//---------------------------------
// chipscope
//---------------------------------
`ifdef CHIPSCOPE

  wire [35:00] control0, control1;
  wire [63:00] trig0, trig1, trig2, trig3;
  wire [63:00] synch_in, synch_out;
  
  assign cs_clk = clkMain;
  
  assign trig0 = {62'd0,UART_RX,UART_TX};
  assign trig1 = {64'd0};
  assign trig2 = {64'd0};
  assign trig3 = {64'd0};
  
  assign synch_out = {c2c_d_tx_data[63:00]};
  
  // chipscope controller
  icon icon_0 (.CONTROL0(control0),  // 36 
			   .CONTROL1(control1)   // 36
  );  

  // chipscope integrated logic analyzer
  ila ila_0 (.CLK    (cs_clk  ), 
			 .CONTROL(control0), // 36
			 .TRIG0  (trig0   ), // 64
			 .TRIG1  (trig1   ), // 64
			 .TRIG2  (trig2   ), // 64
			 .TRIG3  (trig3   )  // 64
  );

  // chipscope virtual IO
  vio vio_0 (.CLK     (cs_clk   ), 
			 .CONTROL (control1 ), // 36 
			 .SYNC_OUT(synch_out), // 64 (to FPGA)
			 .SYNC_IN (synch_in )  // 64 (to host)
  );
  
`endif
  
endmodule
  
  
  
  
