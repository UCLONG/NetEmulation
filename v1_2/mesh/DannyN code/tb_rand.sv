`timescale 10ps/1ps
//`include "types.sv"

module tb_rand;
	parameter rate = 25000;
	parameter width = 8;

	logic clk;
	logic reset;
	logic [width-1:0] din;
	logic [width-1:0] dout;
	logic wr_en;
	logic rd_en;
	logic full, empty, nearly_empty;	
	logic [31:0] TxD;

	integer seed1 = 7;
	integer r1;
	integer seed2 = 17;
	integer r2;

	// Unit under test
	sync_fifo #(4, 8, 2) uut (din, wr_en, rd_en, dout, full, empty, nearly_empty, clk, reset);

	// Clock
	initial begin
		clk = 0;
		forever #200ps clk = ~clk;
	end

	// Reset
	initial begin
		$dumpfile("fifo.vcd");
		$dumpvars(0, tb_rand);
		$dumpon;
		reset = 1;
		#100ns
		reset = 0;
		#10us
		$dumpoff;
		$finish;
	end

	// Random arrivals
	always_ff @(posedge clk) begin
		if (reset) begin
			din <= 0;
			wr_en <= 0;
		end else begin
			r1 <= $dist_uniform(seed1, 1, 100000);
			if  (r1 <= rate && !full) begin
				wr_en <= 1;
				din <= TxD[width-1:0];
			end else begin
				wr_en <= 0;
				din <= 0;
			end
		end
	end

	// Random departures
	always_ff @(posedge clk) begin
		if (reset) begin
			rd_en <= 0;
		end else begin
			r2 <= $dist_uniform(seed2, 1, 100000);
			if  (r2 <= rate && !empty) begin
				rd_en <= 1;
			end else begin
				rd_en <= 0;
			end
		end
	end
	
	// Generate random data
	always_ff @(posedge clk or posedge reset) begin
		if (reset)
			TxD <= 32'b1;
		else	
			TxD <= {TxD[30:0], (TxD[0] ^ TxD[1] ^ TxD[21] ^ TxD[31])};
	end	
	
endmodule	
