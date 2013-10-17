module dff
  (output logic [63:0] Q,
    input logic [63:0] D, clk);
  
  always_ff @ (posedge clk)
    Q <= D;

endmodule