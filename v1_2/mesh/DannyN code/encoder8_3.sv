//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit :
//  *  File Name   : encoder8_3.sv                              *
//  *  Description : 8 x 1 Multiplexer                          *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       :                                            *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module encoder8_3
  (output logic o2,o1,o0,
   input logic i7, i6, i5, i4, i3, i2, i1, i0);
   
  or gate0 (o0, i1, i3, i5, i7), gate1 (o1, i2, i3, i6, i7), gate2 (o2, i4, i5, i6, i7);

endmodule