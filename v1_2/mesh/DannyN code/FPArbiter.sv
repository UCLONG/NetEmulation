//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit : Magnitude Comparator                       *
//  *  File Name   : MagnitudeComparatorN.sv                    *
//  *  Description : 8 x 1 Multiplexer                          *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       : An N-bit Magnitude Comparator              *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module FPArbiter
  (output logic [4:0] portGrant,
    input logic [4:0] portRequest,
    input logic reset, clk);
    
    logic Req0 , Req1, Req2, Req3, Req4, Grant0, Grant1, Grant2, Grant3, Grant4;
    
  assign portGrant = {Grant4, Grant3, Grant2, Grant1, Grant0};
  assign Req0 = portRequest[0];
  assign Req1 = portRequest[1];
  assign Req2 = portRequest[2];
  assign Req3 = portRequest[3];
  assign Req4 = portRequest[4];

  
  logic a, b, c;
  
  assign Grant0 = Req0;
  FPArbiterCell FPAC1 (a, Grant1, Req1, ~Req0);
  FPArbiterCell FPAC2 (b, Grant2, Req2, a);
  FPArbiterCell FPAC3 (c, Grant3, Req3, b);
  and gate1 (Grant4, c, Req4);

endmodule
