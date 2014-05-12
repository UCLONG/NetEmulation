`include "config.sv"
  
  module arbiter(clk, ce, r, g, rst);
    parameter n = 16;
//	parameter lah = 4;
	
    input clk;
    input [n-1:0] r; 
    input rst;   
    input ce;
    output reg [n-1:0] g;

	logic [n-1:0] p;
	logic [n-1:0] next_p;
	logic [n-1:0] g_int;
	logic anyGnt;
	genvar k;
	
	fast_ppe #(n, `LOOKAHEAD) inst_ppe2 (
	   .r(r),
	   .p(p),
	   .g(g_int),
	   .anyGnt(anyGnt));
	
	// If ce is asserted, update priority	
	always @(posedge clk or posedge rst) begin
		if (rst) begin
			p <= 1;
		end else if (ce) begin	
			//p <={p[0], p[n-1:1]};  // rotating arbiter
			p <= next_p;
		end	
	end
	
	// g is not buffered here
	assign g = g_int;	

 	//Assign next priority on a round robin basis	
	assign next_p = !anyGnt ? {g_int[n-2:0], g_int[n-1]} : p;
  //assign next_p = !anyGnt ? {g_int[0], g_int[n-1:1]} : p;
  
  	
endmodule	
