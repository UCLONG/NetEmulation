module TB_fpgatop();
  
  	//input 			REFCLK_N_IN, 
	//input 			REFCLK_P_IN,
	reg 			CLK100M_N;
	wire 			CLK100M_P;
	//c2c connections	
	wire [31:0] 		ring_up_in;
	wire [31:0] 		ring_dn_in;
	wire [31:0]		ring_up_out;
	wire [31:0] 		ring_dn_out;
	wire			ring_lock_in;
	wire			ring_lock_out;
	wire			ring_ready_in;
	wire			ring_ready_out;
	wire			ring_dn_lock_in;
	wire			ring_dn_lock_out;
	wire			ring_dn_ready_in;
	wire			ring_dn_ready_out;
	
	fpga_top uut(
		 //input 			REFCLK_N_IN, 
	   //input 			REFCLK_P_IN,
	   .CLK100M_N       (CLK100M_N),
	   .CLK100M_P       (CLK100M_P),
	   .ring_up_in      (ring_up_in),
	   .ring_dn_in      (ring_dn_in),
	   .ring_up_out     (ring_up_out),
	   .ring_dn_out     (ring_dn_out),
	   .ring_up_lock_in (ring_lock_in),
	   .ring_up_lock_out(ring_lock_out),
	   .ring_up_ready_in(ring_ready_in),
	   .ring_up_ready_out(ring_ready_out), 
	   .ring_dn_lock_in   (ring_dn_lock_in),
	   .ring_dn_lock_out  (ring_dn_lock_out),
	   .ring_dn_ready_in  (ring_dn_ready_in),
	   .ring_dn_ready_out (ring_dn_ready_out));

	fpga_top uut2(
		 //input 			REFCLK_N_IN, 
	   //input 			REFCLK_P_IN,
	   .CLK100M_N       (CLK100M_N),
	   .CLK100M_P       (CLK100M_P),
	   .ring_up_in      (),
	   .ring_dn_in      (ring_up_out),
	   .ring_up_out     (),
	   .ring_dn_out     (ring_up_in),
	   .ring_up_lock_in (),
	   .ring_up_lock_out(),
	   .ring_up_ready_in(),
	   .ring_up_ready_out(), 
	   .ring_dn_lock_in   (ring_lock_out),
	   .ring_dn_lock_out  (ring_lock_in),
	   .ring_dn_ready_in  (ring_ready_out),
	   .ring_dn_ready_out (ring_ready_in));
	   
	 initial begin
		// Initialize Inputs
	 //	REFCLK_N_IN = 0;
//		REFCLK_P_IN = 1;
		CLK100M_N = 0;
		//ring_up_in = 0;
		//ring_dn_in = 0;
		//ring_lock_in = 0;
		//ring_ready_in = 0;
  end
  
  always #5000 CLK100M_N <= !CLK100M_N;
  assign CLK100M_P = !CLK100M_N;
  
endmodule