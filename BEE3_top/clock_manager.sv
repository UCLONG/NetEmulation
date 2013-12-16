module clock_manager(
  output logic CLK,
  output logic MCLK, MCLK180,
  output logic PLL_LOCK,
  input  logic CLK100M_P, CLK100M_N );
  
  // Internal signals
  logic PLLBfb;
  logic clk100;

// Generate 100 MHz clock
        IBUFGDS #(
                .DIFF_TERM("TRUE"), // Differential Termination (Virtex-4/5, Spartan-3E/3A)
                .IOSTANDARD("LVDS_25") // Specifies the I/O standard for this buffer
        ) CLK100buf(
                .O(clk100),  // Clock buffer output
                .I(CLK100M_P),  // Diff_p clock buffer input
                .IB(CLK100M_N) // Diff_n clock buffer input
        );
        
// This PLL generates the main system clock, cx4 and C2C clocks from the cx4 output clock
// This has been modified to use the 100M clock input so that it can be used independently of the 
// CX4 module.  Outputs are at 150M presently.
PLL_BASE #(
.BANDWIDTH("OPTIMIZED"), // "HIGH", "LOW" or "OPTIMIZED"
.CLKFBOUT_MULT(6), // Multiplication factor for all output clocks
.CLKFBOUT_PHASE(0.0), // Phase shift (degrees) of all output clocks
.CLKIN_PERIOD(10), // Clock period (ns) of input clock on CLKIN

.CLKOUT0_DIVIDE(4), // Division factor for CLKOUT0 (1 to 128)
.CLKOUT0_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT0 (0.01 to 0.99)
.CLKOUT0_PHASE(0.0), // Phase shift (degrees) for CLKOUT0 (0.0 to 360.0)

.CLKOUT1_DIVIDE(2), // Division factor for CLKOUT1 (1 to 128)
.CLKOUT1_DUTY_CYCLE(0.5), // Duty cycle for CLKOUT1 (0.01 to 0.99)
.CLKOUT1_PHASE(0), // Phase shift (degrees) for CLKOUT1 (0.0 to 360.0)

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
.REF_JITTER(0.100) // Input reference jitter (0.000 to 0.999 UI%)


) clkBPLL (
.CLKFBOUT(PLLBfb), 					// General output feedback signal
.CLKOUT0(MCLK), 						// 156.25 MHz system clock before buffering
.CLKOUT1(), 			// 312.5 MHz clock for GTP TXUSRCLK
.CLKOUT2(), 							// 
.CLKOUT3(MCLK180), 					// 156.25 MHz system clock before buffering, 180deg 
.CLKOUT4(), 							// 
.CLKOUT5(),								//
.LOCKED(PLL_LOCK),					   // Active high PLL lock signal
.CLKFBIN(PLLBfb), 					// Clock feedback input
.CLKIN(clk100), 				// input clock 100M
.RST(1'b0)
);

// Buffer main system clock (CLK)
BUFG bufM (.O(CLK), .I(MCLK));

endmodule