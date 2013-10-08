module arbiter
  // The arbiter outputs a one-hot 5 bit word denoting the port request that has been granted from 
  // the port requests inputted in a one-hot fashion.
  (output logic [4:0] portGrant,
   input logic [4:0] portRequest,
   input logic reset, clk);
   
   logic [4:0] portPriority;
   logic [5:0] carryBit;
   
  // Netlist describing combinational logic of a 5 bit variable priority iterative arbiter with the wrap
  // around combinational logic. Some simulations have problems with wrap around logic. This logic can be used
  // with different schemes to generate the one-hot priority input.
  logic a, b, c, d, e;
  
  or gate1 (a, carryBit[0], portPriority[0]);
  and gate2 (portGrant[0], portRequest[0], a), gate3 (carryBit[1], a, ~portRequest[0]);
  or gate4 (b, carryBit[1], portPriority[1]);
  and gate5 (portGrant[1], portRequest[1], b), gate6 (carryBit[2], b, ~portRequest[1]);
  or gate7 (c, carryBit[2], portPriority[2]);
  and gate8 (portGrant[2], portRequest[2], c), gate9 (carryBit[3], c, ~portRequest[2]);
  or gate10 (d, carryBit[3], portPriority[3]);
  and gate11 (portGrant[3], portRequest[3], d), gate12 (carryBit[4], d, ~portRequest[3]);
  or gate13 (e, carryBit[4], portPriority[4]);
  and gate14 (portGrant[4], portRequest[4], e), gate15 (carryBit[0], e, ~portRequest[4]);
  
  // Priority input generation. Fixed input, rotating and round robin methods are included.
  always_ff @(posedge clk)
    begin
      if (reset)
        portPriority <= 'b00001;
      else
        begin
          // Fixed (could simply be assigned)
          //portPriority <= 5'b10000;
          
          // Rotating
          //portPriority <= {portPriority[n-2:0], portPriority[n-1]};
          
          // Round Robin
          portPriority <= |portGrant ? {portGrant[3:0], portGrant[4]} : portPriority; // | or reduction operator
        end
    end

endmodule  
  