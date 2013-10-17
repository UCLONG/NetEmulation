//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit : Cross Bar                                  *
//  *  File Name   : CrossBarN.sv                               *
//  *  Description : N bit 5x5 CrossBar                         *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       :                                            *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module CrossBarN #(parameter N = 64)

  (output logic [N-1:0] o0, o1, o2, o3, o4,
    input logic [N-1:0] i0, i1, i2, i3, i4,
    input logic [2:0] sel0, sel1, sel2, sel3, sel4);
    
    mux8_1 mux0 (o0, i0, i1, i2, i3, i4, sel0);
    mux8_1 mux1 (o1, i0, i1, i2, i3, i4, sel1);
    mux8_1 mux2 (o2, i0, i1, i2, i3, i4, sel2);
    mux8_1 mux3 (o3, i0, i1, i2, i3, i4, sel3);
    mux8_1 mux4 (o4, i0, i1, i2, i3, i4, sel4);
    
endmodule