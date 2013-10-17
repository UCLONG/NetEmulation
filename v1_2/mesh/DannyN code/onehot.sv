//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit :
//  *  File Name   : onehot.sv                                  *
//  *  Description : A parametised log2(N):N '1-hot' decoder    *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       : Module from ELEC2010 Digital Design notes  *
//  *                by Phil Watts, with slight alteration.     *
//  *                For a small decoder, a case statement may  *
//  *                be used however a parametised decoder is   *
//  *                more useful and scalable.                  *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module onehot #(parameter N=8)
  (output logic [N-1:0] Y,
   input logic  [log2(N)-1:0] A);
   
   function int log2 (input int value);
     for (log2=0;value>1;log2++)
          value=value>>1;
   endfunction
   
   always_comb
    Y=1'b1<<A;

endmodule