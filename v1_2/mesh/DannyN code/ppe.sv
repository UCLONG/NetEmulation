//`include "../src/verilog/types.sv"
`timescale 10ps/1ps

// Fast programmable priority encoder 
// See P. Gupta, N.McKeown IEEE Micro Jan-Feb 1999
module fast_ppe(r, g, p, anyGnt);
  parameter n = 16;
  parameter lah = 4;
  
  input   [n-1:0] r;
  input   [n-1:0] p;
  output  [n-1:0] g;
  output                      anyGnt;   //low if a grant is made
  
  logic   [n-1:0] gnt_not_round;
  logic                       anyGnt_not_round;
  logic   [n-1:0] gnt_smpl;
  logic                       anyGnt_smpl;
  logic	[n-1:0] gnd;

assign gnd = 0;

generate 
	if (lah>0) begin // If lookahead is required
		ppe #(n, lah) inst_smpl_ppe (
			.r(r),
			.p(gnd),
			.g(gnt_smpl),
			.cin(1'b1),
			.cout(anyGnt_smpl));
    
		ppe #(n, lah) inst_not_round_ppe (
			.r(r),
			.p(p),
			.g(gnt_not_round),
			.cin(1'b0),
			.cout(anyGnt_not_round));
	end else begin // without lookahead
		arb #(n) ppe_without_la1 (.p(gnd), .r(r), .g(gnt_smpl), .cin(1'b1), .cout(anyGnt_smpl));
		arb #(n) ppe_without_la2 (.p(p), .r(r), .g(gnt_not_round), .cin(1'b0), .cout(anyGnt_not_round));
	end
endgenerate
	
  assign g = anyGnt_not_round ? gnt_smpl : gnt_not_round;    
  assign anyGnt = anyGnt_smpl;
  
endmodule
  
  
// A progarmmable priority encoder using lookahead carry logic 
`timescale 1ns/1ps
module ppe(r, g, p, cin, cout);
parameter n = 16;
parameter lah = 4;

input   [n-1:0] r;
input   [n-1:0] p;
output  [n-1:0] g;
input   cin;
output  cout;

	logic   [n/lah-1:0] c;
	logic   [n/lah-1:0] a;
	logic   [n/lah-1:0] b;
	
	generate
		for (genvar k=0;k<(n/lah)-1;k++) begin
        
            // Carry Look-ahead Generator
            clg #(lah) inst_clg (
            .r(r[k*lah+lah-1:k*lah]),
            .p(p[k*lah+lah-1:k*lah]),
            .a(a[k]),
            .b(b[k]));
                
                
            // Arbiter Module
            arb #(lah) inst_ppe_small (
				.r(r[k*lah+lah-1:k*lah]),
                .p(p[k*lah+lah-1:k*lah]),
                .g(g[k*lah+lah-1:k*lah]),
                .cin(c[k]),
				.cout());
                  
                
            // Carry Logic
            always @(*) begin
              c[k+1] = a[k] | (b[k] & c[k]);
            end   
                
		end
	endgenerate

	arb #(lah) inst_ppe_last (
		.r(r[n-1:n-lah]),
        .p(p[n-1:n-lah]),
        .g(g[n-1:n-lah]),
        .cin(c[(n/lah)-1]),
		.cout(cout));
 
		always @(*) begin
			c[0] = cin;       
		end

			

 endmodule

 
`timescale 10ps/1ps
 module clg (r, p, a, b);
   parameter lah = 4;
   
   input [lah-1:0] r;
   input [lah-1:0] p;
   output a;
   output b;
   
   logic [lah-1:0] t;
   logic b_int;
   logic a_int;
   
   always @(*) begin
      b_int <= & (~r); 
      a_int <= |t;
   end
   
   generate
      for (genvar k=0;k<lah;k++) begin
          assign t[k] = & {!r[lah-1:k], p[k]};
      end
  endgenerate   
   
   assign a = a_int;
   assign b = b_int;
   
 endmodule
 
 
`timescale 10ps/1ps
 module arb (r, p, g, cin, cout);
   parameter n = 8;
   
    input  [n-1:0] r;       
    input  [n-1:0] p;  
    output  [n-1:0] g;
    input cin;
    output cout;
		
    logic [n-1:1] c;
		
		arb_slice arb_slice_start(.p(p[0]), .r(r[0]), .cin(cin), .cout(c[1]), .g(g[0]));
		generate
		  for (genvar k=1;k<n-1;k++) begin
			   arb_slice inst_arb_slice(.p(p[k]), .r(r[k]), .cin(c[k]), .cout(c[k+1]), .g(g[k]));
		  end
		endgenerate
		arb_slice arb_slice_end(.p(p[n-1]), .r(r[n-1]), .cin(c[n-1]), .cout(cout), .g(g[n-1]));
  
 endmodule     
 


`timescale 10ps/1ps
module arb_slice(p, r, cin, cout, g);

input p;
input r;
input cin;
output reg cout;
output reg g;

reg a;

always @ (p or cin or r) begin
	a = p || cin;
	g = r && a;
	cout = a && (~r);
end 

endmodule
