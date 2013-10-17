//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit : Allocator                                  *
//  *  File Name   : SepAlloc5_5.sv                             *
//  *  Description : 5 x 5 Seperable Allocator                  *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       :                                            *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module SepAlloc5_5
  
  (output logic Grant00, Grant10, Grant20, Grant30, Grant40, 
                Grant01, Grant11, Grant21, Grant31, Grant41, 
                Grant02, Grant12, Grant22, Grant32, Grant42,
                Grant03, Grant13, Grant23, Grant33, Grant43,
                Grant04, Grant14, Grant24, Grant34, Grant44,
                
   output logic re0, re1, re2, re3, re4, we0, we1, we2, we3, we4,
   
    input logic Req00, Req01, Req02, Req03, Req04,
                Req10, Req11, Req12, Req13, Req14,
                Req20, Req21, Req22, Req23, Req24,
                Req30, Req31, Req32, Req33, Req34,
                Req40, Req41, Req42, Req43, Req44,
                clk);
                
  // Internal Logic For Flip Flop output
  
  logic X00, X10, X20, X30, X40;
  logic X01, X11, X21, X31, X41;
  logic X02, X12, X22, X32, X42;
  logic X03, X13, X23, X33, X43;
  logic X04, X14, X24, X34, X44;
  
  // Internal logic for output of the first stage of Arbitration
  
  logic Y00, Y10, Y20, Y30, Y40;
  logic Y01, Y11, Y21, Y31, Y41;
  logic Y02, Y12, Y22, Y32, Y42;
  logic Y03, Y13, Y23, Y33, Y43;
  logic Y04, Y14, Y24, Y34, Y44;
  
  // Flip Flop connections to first stage of arbitration
  
  dff input00 (X00, Req00, clk);
  dff input01 (X01, Req01, clk);
  dff input02 (X02, Req02, clk);
  dff input03 (X03, Req03, clk);
  dff input04 (X04, Req04, clk);
  FPArbiter ARB0A (Y00, Y01, Y02, Y03, Y04, X00, X01, X02, X03, X04);
  
  dff input10 (X10, Req10, clk);
  dff input11 (X11, Req11, clk);
  dff input12 (X12, Req12, clk);
  dff input13 (X13, Req13, clk);
  dff input14 (X14, Req14, clk);
  FPArbiter ARB1A (Y10, Y11, Y12, Y13, Y14, X10, X11, X12, X13, X14);
  
  dff input20 (X20, Req20, clk);
  dff input21 (X21, Req21, clk);
  dff input22 (X22, Req22, clk);
  dff input23 (X23, Req23, clk);
  dff input24 (X24, Req24, clk);
  FPArbiter ARB2A (Y20, Y21, Y22, Y23, Y24, X20, X21, X22, X23, X24);
  
  dff input30 (X30, Req30, clk);
  dff input31 (X31, Req31, clk);
  dff input32 (X32, Req32, clk);
  dff input33 (X33, Req33, clk);
  dff input34 (X34, Req34, clk);
  FPArbiter ARB3A (Y30, Y31, Y32, Y33, Y34, X30, X31, X32, X33, X34);
  
  dff input40 (X40, Req40, clk);
  dff input41 (X41, Req41, clk);
  dff input42 (X42, Req42, clk);
  dff input43 (X43, Req43, clk);
  dff input44 (X44, Req44, clk);
  FPArbiter ARB4A (Y40, Y41, Y42, Y43, Y44, X40, X41, X42, X43, X44);
  
  // Second stage of arbitration
    
  FPArbiter ARB0B (Grant00, Grant10, Grant20, Grant30, Grant40, X00, X10, X20, X30, X40); 
  FPArbiter ARB1B (Grant01, Grant11, Grant21, Grant31, Grant41, X01, X11, X21, X31, X41); 
  FPArbiter ARB2B (Grant02, Grant12, Grant22, Grant32, Grant42, X02, X12, X22, X32, X42);
  FPArbiter ARB3B (Grant03, Grant13, Grant23, Grant33, Grant43, X03, X13, X23, X33, X43); 
  FPArbiter ARB4B (Grant04, Grant14, Grant24, Grant34, Grant44, X04, X14, X24, X34, X44);
    
  // Read Control Flag
      
  or read0 (re0, Grant00, Grant01, Grant02, Grant03, Grant04);
  or read1 (re1, Grant10, Grant11, Grant12, Grant13, Grant14);
  or read2 (re2, Grant20, Grant21, Grant22, Grant23, Grant24);
  or read3 (re3, Grant30, Grant31, Grant32, Grant33, Grant34);
  or read4 (re4, Grant40, Grant41, Grant42, Grant43, Grant44);
      
  // Write Control Flag
      
  or write0 (we0, Grant00, Grant10, Grant20, Grant30, Grant40);
  or write1 (we1, Grant01, Grant11, Grant21, Grant31, Grant41);
  or write2 (we2, Grant02, Grant12, Grant22, Grant32, Grant42);
  or write3 (we3, Grant03, Grant13, Grant23, Grant33, Grant43);
  or write4 (we4, Grant04, Grant14, Grant24, Grant34, Grant44);

endmodule  
                
                
                