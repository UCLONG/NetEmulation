module arbiter
  
  // The amount of lines to arbitrate is passed as a parameter, the default being 5.
  
  #(parameter n = 5)
  
  
  // The arbiter outputs a one-hot n bit word denoting the port request that has been granted from
  // the port requests inputted in a one-hot fashion.
  
  (output logic [n-1:0] portGrant,
    input logic [n-1:0] portRequest,
    input logic         reset, clk);
          logic [n-1:0] portPriority;
          logic [n:0]   carryBit;


// Netlist describing combinational logic of a 5 bit variable priority iterative arbiter with 
// the wrap around combinational logic.  Some simulations have problems with wrap around logic.
// This logic can be used with different schemes to generate the one-hot priority input.
    
logic a, b, c, d, e;
    
or  gate1 (a, carryBit[0], portPriority[0]);
and gate2 (portGrant[0], portRequest[0], a), gate3 (carryBit[1], a, ~portRequest[0]);
or  gate4 (b, carryBit[1], portPriority[1]);
and gate5 (portGrant[1], portRequest[1], b), gate6 (carryBit[2], b, ~portRequest[1]);  
or  gate7 (c, carryBit[2], portPriority[2]);
and gate8 (portGrant[2], portRequest[2], c), gate9 (carryBit[3], c, ~portRequest[2]);
or  gate10 (d, carryBit[3], portPriority[3]);
and gate11 (portGrant[3], portRequest[3], d), gate12 (carryBit[4], d, ~portRequest[3]);
or  gate13 (e, carryBit[4], portPriority[4]);
and gate14 (portGrant[4], portRequest[4], e), gate15 (carryBit[0], e, ~portRequest[4]);


// Priority input generation.  Fixed input, rotating and round robin methods are included.
    
always_ff @ (posedge clk)
  begin
    if (reset)
      portPriority <= 'b00001;
    else
      begin
        // Fixed (could simply be assigned)
        // portPriority <= 5'b10000;
        
        // Rotating
        // portPriority <= {portPriority[n-2:0], portPriority[n-1]};
        
        // Round Robin
        portPriority <= |portGrant ? {portGrant[n-2:0], portGrant[n-1]} : portPriority;
      end 
  end
    
    // Netlist describing an n-bit variable priority iterative arbiter without the wrap around
    // combinational logic.  Some simulations have problems with wrap around logic.
    /*
    logic a,b,c,d,e,f,g,h,i,j;
    logic [n-1:0] portGrantA;
    logic [n-1:0] portGrantB;
    
    or  gate1 (a, 0, portPriority[0]);
    and gate2 (portGrantA[0], portRequest[0], a), gate3 (carryBit[1], a, ~portRequest[0]);
    or  gate4 (b, carryBit[1], portPriority[1]);
    and gate5 (portGrantA[1], portRequest[1], b), gate6 (carryBit[2], b, ~portRequest[1]);  
    or  gate7 (c, carryBit[2], portPriority[2]);
    and gate8 (portGrantA[2], portRequest[2], c), gate9 (carryBit[3], c, ~portRequest[2]);
    or  gate10 (d, carryBit[3], portPriority[3]);
    and gate11 (portGrantA[3], portRequest[3], d), gate12 (carryBit[4], d, ~portRequest[3]);
    or  gate13 (e, carryBit[4], portPriority[4]);
    and gate14 (portGrantA[4], portRequest[4], e), gate15 (carryBit[5], e, ~portRequest[4]);
 
    or  gate16 (f, carryBit[5], portPriority[0]);
    and gate17 (portGrantB[0], portRequest[0], f), gate18 (carryBit[6], f, ~portRequest[0]);
    or  gate19 (g, carryBit[6], portPriority[1]);
    and gate20 (portGrantB[1], portRequest[1], g), gate21 (carryBit[7], g, ~portRequest[1]);  
    or  gate22 (h, carryBit[7], portPriority[2]);
    and gate23 (portGrantB[2], portRequest[2], h), gate24 (carryBit[8], h, ~portRequest[2]);
    or  gate25 (i, carryBit[8], portPriority[3]);
    and gate26 (portGrantB[3], portRequest[3], i), gate27 (carryBit[9], i, ~portRequest[3]);
    or  gate28 (j, carryBit[9], portPriority[4]);
    and gate29 (portGrantB[4], portRequest[4], j), gate30 (carryBit[10], j, ~portRequest[4]);   
  
    or gate31 (portGrant[0], portGrantA[0], portGrantB[0]);
    or gate32 (portGrant[1], portGrantA[1], portGrantB[1]);  
    or gate33 (portGrant[2], portGrantA[2], portGrantB[2]);
    or gate34 (portGrant[3], portGrantA[3], portGrantB[3]);
    or gate35 (portGrant[4], portGrantA[4], portGrantB[4]);
    */

      
endmodule