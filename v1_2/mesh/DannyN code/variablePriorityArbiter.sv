module variablePriorityArbiter
  (output logic G, Cout,
    input logic P, R, Cin);
    
    logic a;
    
    or  gate1 (a, Cin, P);
    and gate2 (G, R, a), gate3 (Cout, a, ~R);
    
endmodule