`include "config.sv"

module router
  // The router location and the width and depth of the FIFO are paramaterised
  #(parameter xLocation = 0,
    parameter yLocation = 0,
    parameter X_NODES = 2,
    parameter Y_NODES = 2,
    parameter FIFO_WIDTH = 64,
    parameter FIFO_DEPTH = 4)
    
  // Outputs and inputs
  (output packet_mesh routerDataOutDec[0:4],
   output logic [4:0] holdPorts_OUT, writeRequest_OUT,
   output logic [4:0] readRequest,
   input packet_mesh routerDataIn[0:4], // Receives packet data from 5 ports of a node
   input logic  [4:0] holdPorts_IN, writeRequest_IN,
   input logic  [4:0] readEnable_Adjacent,
   input logic reset, clk);
   
  // Interal Logic, essentially this is just connections.
  packet_mesh bufferDataOut [0:4];
  logic [4:0] outputPortRequest [0:4];
  logic [2:0] sel [0:4];
  packet_mesh routerDataInInc [0:4];
  logic unproductive [0:4];
  logic [4:0] rerouteDec;
  packet_mesh routerDataOut [0:4];
  logic [24:0] rerouted;
  logic [2:0] a, b;
  logic [log2(`DEADLOCK_LIMIT):0] wait_count [0:4];
  
  // Increment packet hop count & generate 5 input units
  genvar j;
  generate for (j = 0; j < 5; j++)
    begin
      // Hop Count Functionality (increment upon router entry)
      always_comb
        begin
          routerDataInInc[j] = routerDataIn[j];
          routerDataInInc[j].hopCount = routerDataIn[j].hopCount + 1;
        end
      inputUnit #(xLocation, yLocation, X_NODES, Y_NODES, FIFO_WIDTH, FIFO_DEPTH) inputUnitTest (
       bufferDataOut[j],
       outputPortRequest[j],
       holdPorts_OUT[j],
       unproductive[j], 
       wait_count[j], 
       routerDataInInc[j], 
       readRequest[j], 
       writeRequest_IN[j], 
       reset, 
       clk, 
       writeRequest_OUT, 
       readEnable_Adjacent);
    end
  endgenerate
  
  // Instantiate switch allocator and switch
  switchAllocator Inst_Allocator (sel, readRequest, writeRequest_OUT, outputPortRequest, holdPorts_IN, reset, clk, wait_count);
  switch #(5, 5, FIFO_WIDTH) Inst_switch (routerDataOut, bufferDataOut, sel); // sel maps input packets to correct output

  // Livelock Limit Functionality
  // Creates a vector to show which packet should have its 'reroute' constant decremented by checking
  // whether an unproductive output port request has been granted access to the switch
  always_comb
    begin
      rerouteDec = 5'b0;
      for (a = 0; a < 5; a++)
        begin
          if (unproductive[a] == 1)
            begin
              for (b = 0; b < 5; b++)
                begin
                  if (sel[b] == a)
                    rerouteDec[b] = 1'b1;
                end 
            end
        end  
    end
       
  // Decrement unproductive reroute/misroute constant (limit to ensure forward progression)
  // Decremented occur before packets exit the router
  genvar i;
  generate for (i = 0; i < 5; i++)
    begin
      always_comb
        begin
          if (rerouteDec[i] == 1)
            begin  
              routerDataOutDec[i] = routerDataOut[i];
              routerDataOutDec[i].reroute = routerDataOut[i].reroute - 1;      
            end
          else
            routerDataOutDec[i] = routerDataOut[i];
        end
     end
   endgenerate
   
endmodule