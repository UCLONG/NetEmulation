//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit :
//  *  File Name   : sram.sv                                    *
//  *  Description : 4 x 4 SRAM modelled using transmission     *
//  *                gates and latch logic.                     *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       : Module from ELEC2010 Digital Design notes  *
//  *                by Phil Watts, with slight alteration.     *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module sram
  (inout wire [3:0] data,
   input logic [1:0] address,
   input logic re, we);
   
   // Memory Array
   logic [3:0] mem [0:3];
   
   // Output Logic
   assign data = re ? mem[address]:4'bzzzz;
   
   // Input logic (transmission gate)
   always_latch
    if (we && ~re)
      mem[address]<=data;

endmodule