//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit :
//  *  File Name   : xor_tg.sv                                  *
//  *  Description : An XOR gate using transmission gates       *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       : Module from ELEC2010 Digital Design notes  *
//  *                by Phil Watts, with slight alteration.     *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module xor_tg
  (output wire Y,
   input logic A, B);
   
   assign Y =!A ? B:1'bz;
   assign Y = A ? !B:1'bz;
   
endmodule