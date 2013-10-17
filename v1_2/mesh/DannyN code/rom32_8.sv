//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit :
//  *  File Name   : rom32_8.sv                                 *
//  *  Description : A 32 x 8 bit ROM (Look Up Table)           *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       : Module from ELEC2010 Digital Design notes  *
//  *                by Phil Watts, with slight alteration.     *
//  *                Simply a 2D array.                         *
//  *                mem[1] refers to the 2nd word in the ROM   *
//  *                mem[1][7] refers to most significant bit   *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module rom32_8
  (output logic [7:0] dout,
   input logic  [4:0] adrs);
   
   // Define an array of 32 8-bit words
   logic [7:0]mem[0:31] =
    {8'b01010101, // Value for adrs0
     8'b11111111, // Value for adrs1
     // ...
     // ...
     8'b10101010}; // Value for adrs 31
  
   // Output Combinational Logic
   always_comb
     dout=mem[adrs];

endmodule