
     module c3dClkGen2 (
          input    CLKIN,        
          output   SYSTEM_CLK,   
          output   SYNC_CLK,     
          output   C2C_CLK,         
          output   C2C_CLK180,      
          output   PLL0_LOCK     
          // Other clocks i.e. for DDR if required
     );

// PLL for C2C and B2B modules
  PLL_BASE #(.BANDWIDTH("OPTIMIZED"), // "HIGH", "LOW" or "OPTIMIZED"
			 .CLKFBOUT_MULT(2), // Multiplication factor for all output clocks
			 .CLKFBOUT_PHASE(0.0), // Phase shift (degrees) of all output clocks
			 .CLKIN_PERIOD(3.2), // Clock period (ns) of input clock on CLKIN
			 
			 .CLKOUT0_DIVIDE(4), // Division factor for CLKOUT0 (1 to 128)
			 .CLKOUT0_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT0 (0.01 to 0.99)
			 .CLKOUT0_PHASE(0.0), // Phase shift (degrees) for CLKOUT0 (0.0 to 360.0)
			 
			 .CLKOUT1_DIVIDE(2), // Division factor for CLKOUT1 (1 to 128)
			 .CLKOUT1_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT1 (0.01 to 0.99)
			 .CLKOUT1_PHASE(0.0), // Phase shift (degrees) for CLKOUT1 (0.0 to 360.0)
			 
			 .CLKOUT2_DIVIDE(16), // Division factor for CLKOUT2 (1 to 128)
			 .CLKOUT2_DUTY_CYCLE(0.375), // Duty cycle for CLKOUT2 (0.01 to 0.99)
			 .CLKOUT2_PHASE(0.0), // Phase shift (degrees) for CLKOUT2 (0.0 to 360.0)
			 
			 .CLKOUT3_DIVIDE(4), // Division factor for CLKOUT3 (1 to 128)
			 .CLKOUT3_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT3 (0.01 to 0.99)
			 .CLKOUT3_PHASE(180.0), // Phase shift (degrees) for CLKOUT3 (0.0 to 360.0)
			 
			 .CLKOUT4_DIVIDE(8), // Division factor for CLKOUT4 (1 to 128)
			 .CLKOUT4_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT4 (0.01 to 0.99)
			 .CLKOUT4_PHASE(0.0), // Phase shift (degrees) for CLKOUT4 (0.0 to 360.0)
			 
			 .CLKOUT5_DIVIDE(4), // Division factor for CLKOUT5 (1 to 128)
			 .CLKOUT5_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT5 (0.01 to 0.99)
			 .CLKOUT5_PHASE(180.0), // Phase shift (degrees) for CLKOUT5 (0.0 to 360.0)
			 
			 .COMPENSATION("SYSTEM_SYNCHRONOUS"), // "SYSTEM_SYNCHRONOUS",
			 .DIVCLK_DIVIDE(1), // Division factor for all clocks (1 to 52)
			 .REF_JITTER(0.100)) // Input reference jitter (0.000 to 0.999 UI%)

			 pll_0   (.CLKFBOUT(pll0_fb   ), 	// General output feedback signal
				  .CLKOUT0 (pll0_0    ), 	// 156.25 MHz system clock before buffering
			          .CLKOUT1 (pll0_1    ), 	// 312.5 MHz clock for GTP TXUSRCLK
			          .CLKOUT2 (          ), 	// 
			          .CLKOUT3 (C2C_CLK180   ), 	// 156.25 MHz system clock before buffering, 180deg 
			          .CLKOUT4 (          ),        // 
			          .CLKOUT5 (          ),	//
			          .LOCKED  (PLL0_LOCK ),	// Active high PLL lock signal
			          .CLKFBIN (pll0_fb   ), 	// Clock feedback input
			          .CLKIN   (CLKIN    ), 	// 312.5 MHz clock input from GTP
			          .RST     (1'b0      )
  );

  BUFG bufg_0_0 (.I(pll0_0), .O(SYSTEM_CLK));
  BUFG bufg_0_1 (.I(pll0_1), .O(SYNC_CLK));
  assign C2C_CLK = pll0_0;

  // 2nd PLL for DDR if required
 
  //This PLL generates MCLK and MCLK90 at whatever frequency we want.
  PLL_BASE #(.BANDWIDTH("OPTIMIZED"), // "HIGH", "LOW" or "OPTIMIZED"
			 .CLKFBOUT_MULT(20), // Multiplication factor for all output clocks
			 .CLKFBOUT_PHASE(0.0), // Phase shift (degrees) of all output clocks
			 .CLKIN_PERIOD(10.0), // Clock period (ns) of input clock on CLKIN
			 
			 .CLKOUT0_DIVIDE(4), // Division factor for MCLK (1 to 128)
			 .CLKOUT0_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT0 (0.01 to 0.99)
			 .CLKOUT0_PHASE(0.0), // Phase shift (degrees) for CLKOUT0 (0.0 to 360.0)
			 
			 .CLKOUT1_DIVIDE(4), // Division factor for MCLK90 (1 to 128)
			 .CLKOUT1_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT1 (0.01 to 0.99)
			 .CLKOUT1_PHASE(90.0), // Phase shift (degrees) for CLKOUT1 (0.0 to 360.0)
			 
			 .CLKOUT2_DIVIDE(16), // Division factor for Ph0 (1 to 128)
			 .CLKOUT2_DUTY_CYCLE(0.375), // Duty cycle for CLKOUT2 (0.01 to 0.99)
			 .CLKOUT2_PHASE(0.0), // Phase shift (degrees) for CLKOUT2 (0.0 to 360.0)
			 
			 .CLKOUT3_DIVIDE(4), // Division factor for MCLK180 (1 to 128)
			 .CLKOUT3_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT3 (0.01 to 0.99)
			 .CLKOUT3_PHASE(180.0), // Phase shift (degrees) for CLKOUT3 (0.0 to 360.0)
			 
			 .CLKOUT4_DIVIDE(8), // Division factor for CLK (1 to 128)
			 .CLKOUT4_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT4 (0.01 to 0.99)
			 .CLKOUT4_PHASE(0.0), // Phase shift (degrees) for CLKOUT4 (0.0 to 360.0)
			 
			 .CLKOUT5_DIVIDE(4), // Division factor for CLK200 (1 to 128)
			 .CLKOUT5_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT5 (0.01 to 0.99)
			 .CLKOUT5_PHASE(180.0), // Phase shift (degrees) for CLKOUT5 (0.0 to 360.0)
			 
			 .COMPENSATION("SYSTEM_SYNCHRONOUS"), // "SYSTEM_SYNCHRONOUS",
			 .DIVCLK_DIVIDE(2), // Division factor for all clocks (1 to 52)
			 .REF_JITTER(0.100)) // Input reference jitter (0.000 to 0.999 UI%)
   
			 pll1    (.CLKFBOUT(pll1_fb  ),  // General output feedback signal
					  .CLKOUT0 (pll1_0   ),  // 266 MHz
					  .CLKOUT1 (pll1_1   ),  // 266 MHz, 90 degree shift
					  .CLKOUT2 (pll1_2   ),  // MCLK/4
					  .CLKOUT3 (pll1_3   ),
					  .CLKOUT4 (pll1_4   ),  // MCLK/2
					  .CLKOUT5 (         ),
					  .LOCKED  (PLL1_LOCK),  // Active high PLL lock signal
					  .CLKFBIN (pll1_fb  ),  // Clock feedback input
					  .CLKIN   (CLK_IN   ),  // Clock input
					  .RST     (1'b0     )
  );

  BUFG bufg_1_0 (.I(pll1_0), .O(PLL1_OUT0)); // MCLK
  BUFG bufg_1_1 (.I(pll1_1), .O(PLL1_OUT1)); // MCLK90
  BUFG pufg_1_2 (.I(pll1_2), .O(PLL1_OUT2)); // PH0 
  BUFG bufg_1_3 (.I(pll1_4), .O(PLL1_OUT4)); // CLK

  //BUFG bufg_1_4 (.I(MCLKx), .O(RingCLK));
  //BUFGMUX_CTRL swClkbuf (
  //.O(swClock), // Clock MUX output
  //.I0(MCLKx), // Clock0 input
  //.I1(MCLK180x), // Clock1 input
  //.S(switchClock) // Clock select input
  //);


endmodule

