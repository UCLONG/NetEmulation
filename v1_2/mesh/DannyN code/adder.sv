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
module adder #(parameter N=4)
  (output logic [N-1:0] Sum, 
  output logic Cout,
  input logic [N-1:0] A, B,
  input logic Cin);
  
  always_comb
  {Cout,Sum}=A+B+Cin;

endmodule