//  ************************************************
//  ************************************************
//  **                                            **
//  *  Design Unit :
//  *  File Name   : fulladder.sv                  *
//  *  Description :
//  *  Author      : Danny Nicholls                *
//  *                UCL                           *
//  *                danny.nicholls.09@UCL.ac.uk   *
//  *  Version     : 1                             *
//  **                                            **
//  ************************************************
//  ************************************************

// Module from ELEC2010 Digital Design notes by Phil Watts with slight alteration.
module rippleadder #(parameter N=4)
  (output logic [N-1:0] Sum, 
   output logic Cout,
   input logic [N-1:0] A, B,
   input logic Cin);
  
  //Internal Logic
  logic [N-1:1] Ca;
  genvar i;
  
  fulladder f0(Sum[0],Ca[1],A[0],B[0],Cin);
  
  generate for(i=1;i<N-1;i++)
    begin
      fulladder fi(Sum[i],Ca[i+1],A[i],B[i],Ca[i]);
    end
  endgenerate
  
  fulladder fN(Sum[N-1],Cout,A[N-1],B[N-1],Ca[N-1]);
  
endmodule