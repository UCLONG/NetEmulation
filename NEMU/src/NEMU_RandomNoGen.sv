// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : RandomNoGen
// Module name : NEMU_RandomNoGen
// Description : Creates a random number of arbitrary range. Uses shift registers to create pseudo-random numbers.
//             : If required range is of power of two, a pseudo-random number created may be out of range, in which case
//             : value of a counter is assigned as a pseudo-random number.
// Uses        : config.sv
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------


`include "config.sv"

module NEMU_RandomNoGen(
input logic i_clk,
input logic reset_n,
output logic [`PORT_BITS-1:0] l_dest);

logic [7:0] l_r8;
logic [7:0] l_temp; 
logic [7:0] l_randomCounter = 0;
logic ifTest;
logic [`PORT_BITS-1:0] l_testDest;

parameter PORT_DIGITS = 4;
parameter port_no = 3; //check how is this changed

always_ff @(posedge i_clk or posedge reset_n) begin
  if (reset_n) begin
    l_r8 <= (2^8)-(`SEED * (port_no+1));
    l_randomCounter <= 0;
  end
  
  else begin
    l_r8 <= {l_r8[6:0], (l_r8[0] ^ l_r8[4] ^ l_r8[5] ^ l_r8[7])};
    //l_temp <= l_r8[7:`PORT_BITS] - 1;
    l_temp <= l_r8 - 1;
    if (l_temp > `PORTS - 2) begin
      l_dest <= l_randomCounter;
    end
    else begin
      l_dest <= l_temp;
    end
  
  end

  if (l_randomCounter == `PORTS - 2) 
    l_randomCounter <= 0;
  else
    l_randomCounter <= l_randomCounter + 1;
end

assign ifTest = (l_temp > (`PORTS - 2));

always_ff @(posedge i_clk) begin
  if (ifTest == 1)
    l_testDest <= l_dest;
end

endmodule