//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit :
//  *  File Name   : mux8_1.sv                                  *
//  *  Description : N bit 8 x 1 Multiplexer                    *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1                                          *
//  *  Notes       :                                            *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module mux8_1 #(parameter N = 64)
  (output logic [N-1:0] Y,
    input logic [N-1:0] i0, i1, i2, i3, i4, i5, i6, i7,
    input logic [2:0] S);
   
  always_comb
    case(S)
      3'b000:Y=i0;
      3'b001:Y=i1;
      3'b010:Y=i2;
      3'b011:Y=i3;
      3'b100:Y=i4;
      3'b001:Y=i5;
      3'b010:Y=i6;
      3'b011:Y=i7;     
      default:Y=1'bx;
    endcase
    
endmodule