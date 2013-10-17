//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit : DOR Requestor                              *
//  *  File Name   : DORRequestor.sv                            *
//  *  Description : Generates port requests                    *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       : Using two magnitude comparators and three  *
//  *                'and' gates, the current location in the x *
//  *                plane is compared with the destination and *
//  *                the appropriate request line generated if  *
//  *                they differ.  When equal the process is    *
//  *                mirrored for the Y plane.  If both X       *
//  *                and Y destinations match with location,    *
//  *                a request is made for the local PE.        *
//  *                Requests are as follows.                   *
//  *                r0 - Local Processing Element              *
//  *                r1 - Increase in Y plane                   *
//  *                r2 - Increase in X plane                   *
//  *                r3 - Decrease in Y plane                   *
//  *                r4 - Decrease in X plane                   *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module DORRequestorN #(parameter N = 3)
  
  // Outputs and Inputs.
  (output logic r0, r1, r2, r3, r4, 
    input logic [N-1:0] Xcurr, Xdest, Ycurr, Ydest,
    input logic clk);
  
  // Internal Logic
  logic a, b, c, d;
  
  // Instantiate Magnitude Comparators and gates
  MagnitudeComparatorN MC1 (r4, r2, a, Xcurr, Xdest, clk);
  MagnitudeComparatorN MC2 (d, c, b, Ycurr, Ydest, clk); 
  and gate1 (r0, a, b), gate2 (r1, a, c), gate3 (r3, a, d);
  
endmodule