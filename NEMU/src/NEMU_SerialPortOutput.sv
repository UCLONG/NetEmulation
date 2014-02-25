// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : SerialPortOutput
// Module name : NEMU_SerialPortOutput
// Description : Enables data transmission via an RS-232 port
// Uses        : LIB_FIFO
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------


module NEMU_SerialPortOutput(
  input logic i_clk, 
  input logic reset_n,
  input logic i_wrEn,
  input logic [7:0]i_data,
  output logic o_wait,
  output logic o_serialFifoEmpty,
  output logic  o_serialTX);
        
  logic [11:0]l_counter = 0;
  logic [3:0]l_state = 0;
  logic l_running = 0;
  logic [7:0]l_serialData;
  logic l_full;
  logic l_rdEn;
  
  always_comb begin
    if (l_state == 1 && l_counter == 0)
      l_rdEn = 1;
    else
      l_rdEn = 0;
  end
 

                
 fifo serialFifo (i_data, 
                  i_wrEn, 
                  l_rdEn, 
                  l_serialData, 
                  o_wait, 
                  o_serialFifoEmpty, ,
                  i_clk, 
                  reset_n);
					 
        
        always @(posedge i_clk, posedge reset_n) begin
                if(reset_n) begin
                        l_state <= 0;
                        l_counter <= 0;
                        l_running <= 0;
                end else begin
                        if(!o_serialFifoEmpty && !l_running) begin
                                l_running <= 1;
                                l_state <= 1;
                                l_counter <= 0;
                        end else if(l_running) begin
                                if(l_counter == 12'd868) begin
                                        l_counter <= 0;
                                        if(l_state == 9) begin
                                                l_state <= 0;
                                        end else if(l_state == 0) begin
                                                l_running <= 0;
                                        end else begin
                                                l_state <= l_state + 1;
                                        end
                                end else begin
                                        l_counter <= l_counter + 1;
                                end
                        end
                end
        end
        
        always @(*) begin
                case(l_state)
                        4'd0: o_serialTX <= 1;
                        4'd1: o_serialTX <= 0;
                        4'd2: o_serialTX <= l_serialData[7];
                        4'd3: o_serialTX <= l_serialData[6];
                        4'd4: o_serialTX <= l_serialData[5];
                        4'd5: o_serialTX <= l_serialData[4];
                        4'd6: o_serialTX <= l_serialData[3];
                        4'd7: o_serialTX <= l_serialData[2];
                        4'd8: o_serialTX <= l_serialData[1];
                        4'd9: o_serialTX <= l_serialData[0];
                        default: o_serialTX <= 1;
                endcase
        end
        
endmodule