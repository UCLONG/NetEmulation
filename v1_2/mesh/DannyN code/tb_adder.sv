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

// Module from ELEC2010 Digital Design notes by Phil Watts with slight alteration.

module tb_adder;
  
  // Test Signals
  logic [3:0] C;
  logic Cout;
  logic [3:0] A, B;
  logic Cin;
  
  // Instantiate module under test
  adder #(4) test_adder(C, Cout, A, B, Cin);
  
  // Provide test input signals
  initial
    begin
      Cin = 0;
      A = 2;
      B = 0;
      #100ps B=2;
      #100ps A=4;
      #100ps Cin=1;
    end

endmodule  