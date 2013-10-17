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

module mux4_1
  (output logic Y,
   input logic I0, I1, I2, I3,
   input logic [1:0] S);
   
  always_comb
    case(S)
      2'b00:Y=I0;
      2'b01:Y=I1;
      2'b10:Y=I2;
      2'b11:Y=I3;
      default:Y=1'bx;
    endcase
    
endmodule