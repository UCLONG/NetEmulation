//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit : Magnitude Comparator                       *
//  *  File Name   : MagnitudeComparator.sv                     *
//  *  Description : 8 x 1 Multiplexer                          *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       :                                            *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module MagnitudeComparator (output logic AgB, BgA, AeB,
                            input logic [2:0] A, B);
  
  always_comb
    begin
    AeB = (A == B) ? 1:0;
    AgB = (A > B) ? 1:0;
    BgA = (B > A) ? 1:0;
    end

endmodule    