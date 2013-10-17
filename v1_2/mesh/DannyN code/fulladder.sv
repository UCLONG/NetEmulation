//  ************************************************
//  ************************************************
//  **                                            **
//  *  Design Unit :
//  *  File Name   : fulladder.sv                  *
//  *  Description :
//  *  Author      : Danny Nicholls                *
//  *                UCL                           *
//  *                danny.nicholls.09@UCL.ac.uk   *
//  *  Version     : 1                             *
//  **                                            **
//  ************************************************
//  ************************************************

// Module from ELEC2010 Digital Design notes by Phil Watts.
module fulladder(output logic sum, cout, input logic x, y, cin);

// Internal signal definitions
logic c1, c2, s1;

// Circuit Description
always_comb
  begin
    s1 = x^y;
    c1 = x&y;
    c2 = s1&cin;
    sum = s1^cin;
    cout = c1|c2;
  end

endmodule