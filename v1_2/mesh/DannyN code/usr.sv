//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit :
//  *  File Name   : usr.sv                                     *
//  *  Description : Universal Shift Register                   *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       : Module from ELEC2010 Digital Design notes  *
//  *                by Phil Watts, with slight alteration.     *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module usr #(parameter N=8)(
  output logic [N-1:0] A,
  input logic  [N-1:0] I,
  input logic  [1:0]   S,
  input logic  right_in, left_in,
  input logic  clk, reset );
  
  always_ff@(posedge clk, reset)
    if (reset)
      A <= 0;
    else
      case(S)
        2'b11:A<=1; // S = 3 Parallel load
        2'b10:A<= {A[N-2:0], left_in}; // S = 2 left shift
        2'b01:A<= {right_in, A[N-1:1]}; // S = 1 right shift
        default:; // no change
      endcase

endmodule