//-----------------------------------------------------
// Design Name : syn_fifo
// File Name   : syn_fifo.v
// Function    : Synchronous (single clock) FIFO
// Coder       : Deepak Kumar Tala
//-----------------------------------------------------

`include "config.sv"

module fifo(din, wr_en, rd_en, dout, full, empty, nearly_empty, clk, reset);
parameter DEPTH = 8;
parameter WIDTH = 8;
parameter output_type = 0;

 input logic [WIDTH-1:0]  din;
 input logic wr_en;
 input logic rd_en;
 output logic [WIDTH-1:0] dout;
 output logic full;
 output logic empty;
 output logic nearly_empty;
 input logic clk;
 input logic reset;
 
//parameter ADDR_WIDTH = log2(DEPTH);
logic   [log2(DEPTH) : 0]     rd_ptr; // note MSB is not really address
logic   [log2(DEPTH) : 0]     wr_ptr; // note MSB is not really address
logic  [log2(DEPTH)-1 : 0]  wr_loc;
logic  [log2(DEPTH)-1 : 0]  rd_loc;
logic [WIDTH-1:0]  mem [DEPTH-1 : 0];
 
assign wr_loc = wr_ptr[log2(DEPTH)-1 : 0];
assign rd_loc = rd_ptr[log2(DEPTH)-1 : 0];
 
always @(posedge clk or posedge reset) begin
 if(reset) begin
 wr_ptr <= 'h0;
 rd_ptr <= 'h0;
end // end if
else begin
 if(wr_en & (~full))begin
 wr_ptr <= wr_ptr+1;
 end
 if(rd_en & (~empty))
 rd_ptr <= rd_ptr+1;
 end //end else
end//end always
 
//empty if all the bits of rd_ptr and wr_ptr are the same.
//full if all bits except the MSB are equal and MSB differes
always @(rd_ptr or wr_ptr)begin
 //default catch-alls
 empty <= 1'b0;
 full  <= 1'b0;
 nearly_empty <= 1'b0;
 if(rd_ptr[log2(DEPTH)-1:0]==wr_ptr[log2(DEPTH)-1:0])begin
 if(rd_ptr[log2(DEPTH)]==wr_ptr[log2(DEPTH)])
	empty <= 1'b1;
 else
	full  <= 1'b1;
 end//end if
 if(((rd_loc+1)==wr_loc) | ((rd_loc==DEPTH-1)&(wr_loc==0)))
	nearly_empty <= 1'b1;
end//end always
 
always @(posedge clk) begin
 if (wr_en)
 mem[wr_loc] <= din;
end //end always

generate
case(output_type)
default:	 
//unregistered dout with data at current value of rd_loc always available 	 
assign dout = mem[rd_loc];
1:	 
//unregistered dout with data only present on rd_en
assign dout = rd_en ? mem[rd_loc]:'h0;
2:
//registered dout
 always @(posedge clk) begin
	if (reset)
		dout <= 'h0;
	else if (rd_en)
		dout <= mem[rd_ptr];
 end
endcase	
endgenerate

endmodule
