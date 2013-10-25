// --------------------------------------------------------------------------------------------------------------------
// IP Block    : LIB
// Sub Block   : Allocator
// Function    : InputFirst_tb
// Module name : LIB_Allocator_InputFirst_tb
// Description : Creates a 4 input 3 output (NxM) Separable Allocator and inputs random requests.
// Uses        : LIB_Allocator_InputFirst.sv
// --------------------------------------------------------------------------------------------------------------------

module LIB_Allocator_InputFirst_tb;

  logic clk;
  logic reset_n;
  
  logic [0:2] i_request [0:3]; // N, M-bit request vectors
  
  logic [0:2] o_grant   [0:3]; // N, M-bit Grant vectors
  
  // DUT
  // ------------------------------------------------------------------------------------------------------------------       
  LIB_Allocator_InputFirst #(.N(4), .M(3))
    inst_LIB_Allocator_InputFirst (.*);
  
  // Clock Generation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    clk = 0;
    forever #100ps clk = ~clk;
  end
  
  // Reset Simulation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    reset_n = 0;
    #150ps
    reset_n = 1;
  end

  // Random input Generation
  // ------------------------------------------------------------------------------------------------------------------  
  always_ff@(posedge clk) begin
    if(~reset_n) begin
      for(int i=0; i<4; i++) begin
        i_request[i] <= 0;
      end
    end else begin
      for(int i=0; i<4; i++) begin
        i_request[i] <= $urandom_range(16);
      end
    end
  end
  
endmodule