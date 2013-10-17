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
// For large N and M this becomes very resource intense.  High end FPGA's have
// dedicated hardware for large multipliers to avoid using the configurable logic
// blocks.

module multiplier #(parameter N=4, M=4)
  (output logic [(N*M)-1:0] C,
   input logic  [N-1:0] A,
   input logic  [M-1:0] B);
   
   assign C=A*B;
   
endmodule