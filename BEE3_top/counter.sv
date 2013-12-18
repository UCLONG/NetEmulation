// A counter to test BEE3 programmed using Mentor PC + Xilinx ISE

module counter_top (
  output  logic [63:0]  count,
  input   logic         rst,
  input   logic         clk);
  
  always_ff @(posedge clk)
    if (rst)
      count <= 0;
    else
      count <= count + 1;
    
endmodule