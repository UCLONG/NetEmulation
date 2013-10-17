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

module FPArbiterCell
  (output logic Cout, Grant, input logic r, Cin);
  
  always_comb
    begin
    Grant = r && Cin;
    Cout = ~r && Cin;
    end
    
endmodule