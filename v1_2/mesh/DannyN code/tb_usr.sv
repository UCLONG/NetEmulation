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

module tb_usr;
  
  logic [7:0] A;
  logic [7:0] I;
  logic [1:0] S;
  logic clk, reset;
  
  // Instantiate USR
  usr #(8) inst_usr(A,I,S,1'b0,A[0],clk,reset);
  
  initial // the clock
    begin
      clk = 0;
      forever #5ps clk = ~clk; // ~ is bitwise negation
    end
  
  initial // reset and test signals
    begin
      reset = 1'b1; // Sets A to zeros
      S = 2'b00;    // Default (no change)
      # 100ns;
      reset = 1'b0; // Not reset
      I = 8'b00000001; // Input set
      S = 2'b11;       // Parallel load
      #200ns;
      S = 2'b01;       // Shift right
    end

endmodule