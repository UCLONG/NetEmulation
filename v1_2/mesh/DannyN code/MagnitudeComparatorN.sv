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

module MagnitudeComparatorN #(parameter N = 3)
  (output logic AgB, BgA, AeB, 
    input logic [N-1:0] A, B,
    input logic clk);
  
  always_ff @ (posedge clk)
    begin
    AeB <= (A == B) ? 1:0;
    AgB <= (A > B) ? 1:0;
    BgA <= (B > A) ? 1:0;
    end

endmodule