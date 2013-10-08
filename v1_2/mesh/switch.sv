`include "config.sv"

module switch
  // The number of inputs, outputs and data width for the crossbar is parameterised. Standard is a 5x5 64 bit crossbar.
  #(parameter INPUT_NUM = 5,
    parameter OUTPUT_NUM = 5,
    parameter DATA_WIDTH = 64)
    
  // Input data, output data and the port selects are described using an array
  (output packet_mesh switchDataOut [0:OUTPUT_NUM-1],
   input packet_mesh switchDataIn [0:OUTPUT_NUM-1],
   input logic  [2:0] sel [0:4]);
   
  // Multiplexers are used to create crossbar.
  always_comb
    begin
      case(sel[0])
        3'b000 : switchDataOut[0] = switchDataIn[0];
        3'b001 : switchDataOut[0] = switchDataIn[1];
        3'b010 : switchDataOut[0] = switchDataIn[2];
        3'b011 : switchDataOut[0] = switchDataIn[3];
        3'b100 : switchDataOut[0] = switchDataIn[4];
        3'b101 : switchDataOut[0] = 1'bz;
      endcase
    
      case(sel[1])
        3'b000 : switchDataOut[1] = switchDataIn[0];
        3'b001 : switchDataOut[1] = switchDataIn[1];
        3'b010 : switchDataOut[1] = switchDataIn[2];
        3'b011 : switchDataOut[1] = switchDataIn[3];
        3'b100 : switchDataOut[1] = switchDataIn[4];
        3'b101 : switchDataOut[1] = 1'bz;
      endcase 
    
      case(sel[2])
        3'b000 : switchDataOut[2] = switchDataIn[0];
        3'b001 : switchDataOut[2] = switchDataIn[1];
        3'b010 : switchDataOut[2] = switchDataIn[2];
        3'b011 : switchDataOut[2] = switchDataIn[3];
        3'b100 : switchDataOut[2] = switchDataIn[4];
        3'b101 : switchDataOut[2] = 1'bz;
      endcase
    
      case(sel[3])
        3'b000 : switchDataOut[3] = switchDataIn[0];
        3'b001 : switchDataOut[3] = switchDataIn[1];
        3'b010 : switchDataOut[3] = switchDataIn[2];
        3'b011 : switchDataOut[3] = switchDataIn[3];
        3'b100 : switchDataOut[3] = switchDataIn[4];
        3'b101 : switchDataOut[3] = 1'bz;
      endcase   
    
      case(sel[4])
        3'b000 : switchDataOut[4] = switchDataIn[0];
        3'b001 : switchDataOut[4] = switchDataIn[1];
        3'b010 : switchDataOut[4] = switchDataIn[2];
        3'b011 : switchDataOut[4] = switchDataIn[3];
        3'b100 : switchDataOut[4] = switchDataIn[4];
        3'b101 : switchDataOut[4] = 1'bz;
      endcase
    end
endmodule        