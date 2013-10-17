//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit :
//  *  File Name   : counter.sv                                 *
//  *  Description : Parametised counter with count enable      *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       : Module from ELEC2010 Digital Design notes  *
//  *                by Phil Watts, with slight alteration.     *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module counter #(parameter N=8)(
  output logic [N-1:0] Q,
  input logic clk, reset, enable);
  
  always_ff@(posedge clk, posedge reset)
    if(reset)
      Q<=0;
    else
      if(enable)
        Q<=Q+1;

endmodule