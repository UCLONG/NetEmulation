//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit :
//  *  File Name   : mux8_1.sv                                  *
//  *  Description : 8 x 1 Multiplexer                          *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       :                                            *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module TestMagnitude;
  
  logic AgB1, BgA1, AeB1;
  logic [2:0] A, B;
  
  MagnitudeComparator mc (AgB1, BgA1, AeB1, A, B);
  
  initial
    begin
    A = 0;
    B = 0;
    #100ps A = 0;
           B = 1;
    #100ps A = 2;
           B = 1;
    #100ps A = 4;
           B = 0;
    end
    
endmodule
    