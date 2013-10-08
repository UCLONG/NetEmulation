`include "config.sv"

module switchAllocator
  // Output to the crossbar a matrix containing the MUX selection information and individual read requests to each input unit contained in the router
  (output logic [2:0] sel [0:4], // size 3 of which there are 5
   output logic [4:0] readRequest, 
   output logic [4:0] writeRequest_Out,
   
  // Output port request from all 5 input units contained within a single router are inputted to be arbitrated.
  // The one-hot request refers to the outgoing ports (Local, West, South, East, North)
   input logic [4:0] outputPortRequest [0:4],
   input logic [4:0] holdPorts,
   input logic reset, clk,
   input logic [log2(`DEADLOCK_LIMIT):0] wait_count [0:4]);
   
  // Internal logic for the computed request matrix and grant matrix.
  logic [4:0] requestMatrix [0:4];
  logic [4:0] grantMatrix [0:4];
  
  // Create an output port request matrix which is essentially just the transpose of the inputs after a logical 'and' with 
  //  the negation of the holdPorts data. This will hold any data from being sent to full buffers.
  always_comb
    begin
      for (int j = 0; j < 5; j++)
        requestMatrix[j] = {outputPortRequest[4][j] && ~holdPorts[j], outputPortRequest[3][j] && ~holdPorts[j],
        outputPortRequest[2][j] && ~holdPorts[j], outputPortRequest[1][j] && ~holdPorts[j], outputPortRequest[0][j] && ~holdPorts[j]};
    end
    
  // Input the request matrix into 5 arbiters in order to generate a grant matrix.
  genvar i;
  generate for (i = 0; i < 5; i++)
    begin
      //arbiter #(5) ai (grantMatrix[i], requestMatrix[i], reset, clk);
      arbiter ai (grantMatrix[i], requestMatrix[i], reset, clk);
    end
  endgenerate
  
  // Using the grantMatrix, determine which internal buffers need to read, and which output ports need to write
  // as the matrix is one-hot in both dimensions, an or of the rows and columns indicated whether to read/write
  always_comb
  //always_ff @(posedge clk)
    begin
    for (int j = 0; j < 5; j++)
      begin
        if (wait_count[j] > 100) // Should have '`DEADLOCK_LIMIT' instead of a integer here
          readRequest[j] = 1'b1;
        else
          readRequest[j] = |{grantMatrix[0][j], grantMatrix[1][j], grantMatrix[2][j], grantMatrix[3][j], grantMatrix[4][j]};
      end
    end
    
  //always_ff @ (posedge clk)
  always_comb
    begin
      writeRequest_Out[0] = | grantMatrix[0]; // | or reduction operator
      writeRequest_Out[1] = | grantMatrix[1];
      writeRequest_Out[2] = | grantMatrix[2];
      writeRequest_Out[3] = | grantMatrix[3];
      writeRequest_Out[4] = | grantMatrix[4];
    end
  
  // Encode the information from each word in the grant matrix to create a MUX selection matrix
  //always_ff @ (posedge clk)
  always_comb
    begin
      for (int i = 0; i < 5; i++)
        begin
          unique casez (grantMatrix[i]) // Notice the invert. It is the result of the transposition of the request matrix.
            5'b00001 : sel[i] = 000;    // Select input 0 on output port i
            5'b0001? : sel[i] = 001;    // Select input 1 on output port i
            5'b001?? : sel[i] = 010;    // Select input 2 on output port i
            5'b01??? : sel[i] = 011;    // Select input 3 on output port i
            5'b1???? : sel[i] = 100;    // Select input 4 on output port i
             default : sel[i] = 101;    // Select z on crossbar
          endcase
        end      
    end
endmodule