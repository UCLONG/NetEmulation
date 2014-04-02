// --------------------------------------------------------------------------------------------------------------------
// IP Block    : LIB
// Function    : FIFO
// Module name : LIB_FIFO_tb
// Description : Multiple test cases for the LIB_FIFO.
// Uses        : LIB_FIFO.sv, LIB_FIFO_wave.do
// Notes       : If adding a test case, include a step by step explanation.  There should be no need to remove
//             : test cases.
// --------------------------------------------------------------------------------------------------------------------
`include "ENoC_Functions.sv"
`include "ENoC_Config.sv"

module LIB_FIFO_tb;
  
  logic clk;
  logic ce;
  logic reset_n;

  packet_t    o_data;
  logic       o_data_val;
  logic       o_en;
  logic       o_empty;
  logic       o_near_empty;
  logic       o_full;
  logic       o_near_full;
  
  packet_t    i_data;
  logic       i_data_val;
  logic       i_en;
  
  integer     test_case = 3;
  
  // DUT
  // ------------------------------------------------------------------------------------------------------------------
  LIB_FIFO_packet_t #(.DEPTH(4)) INST_LIB_FIFO (.*);
  
  // Clock Generation
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
    clk = 0;
    forever #100ps clk = ~clk;
  end
  
  assign ce=1;
  
  // Test Cases.
  // ------------------------------------------------------------------------------------------------------------------
  initial begin
  
    case (test_case)
    
    1: begin
  
        // Test case 1.  Load a single packet into the FIFO and read it out on the next rising edge.
        //-------------------------------------------------------------------------------------------------------------
        reset_n = 0;
        i_data = 4'hD;
        i_data_val = 1;
        i_en = 0;
        #205ps 
        reset_n = 1;
        #100ps // D is written to memory, wr_ptr increments, empty flag drops
        i_data = 4'hE;
        i_data_val = 0;
        i_en = 1;
        // D is read from memory, rd_ptr increments, empty flag lifts.
        $stop(1);
 
      
      end
  
    2 : begin
  
          // Test case 2.  Load a selection of data in and out of the FIFO.
          //-------------------------------------------------------------------------------------------------------------
          reset_n = 0;
          i_data.data = 4'hD;
          i_data_val = 1;
          i_en = 0;
          #205ps 
          reset_n = 1;
          #100ps // D is written to memory, wr_ptr increments, empty flag drops
          i_data.data = 4'hE;
          i_data_val = 1;
          i_en = 0;
          #200ps // E is written to memory, wr_ptr increments
          i_data.data = 4'hA;
          i_data_val = 1;
          i_en = 0;
          #200ps // A is written to memory, wr_ptr increments
          i_data.data = 4'hD;
          i_data_val = 1;
          i_en = 0;
          #200ps // D is written to memory, wr_ptr wraps, full flag lifts
          i_data.data = 4'hB;
          i_data_val = 1;
          i_en = 0;
          #200ps // Buffer still full, no change
          i_data.data = 4'hB;
          i_data_val = 1;
          i_en = 1;
          // Enable is high indicating D was read, rd_ptr increments, ouput changes to E, full flag stays high
          // because B was written to memory, wr_ptr increments, 
          #200ps 
          i_data.data = 4'hE;
          i_data_val = 1;
          i_en = 1;
          // Enable is high indicating E was read, rd_ptr increments, ouput changes to A, full flag stays high
          // because E was written to memory, wr_ptr increments, 
          #200ps    
          i_data.data = 4'hE;
          i_data_val = 1;
          i_en = 1;
          // Enable is high indicating A was read, rd_ptr increments, ouput changes to D, full flag stays high
          // because E was written to memory, wr_ptr increments, 
          #200ps    
          i_data.data = 4'hF;
          i_data_val = 1;
          i_en = 1;
          // Enable is high indicating D was read, rd_ptr increments, ouput changes to B, full flag stays high
          // because F was written to memory, wr_ptr increments, 
          #200ps    
          i_data.data = 4'h0;
          i_data_val = 0;
          i_en = 1;
          // Enable is high indicating B was read, rd_ptr increments, ouput changes to E, full flag drops
          #200ps    
          i_data.data = 4'h0;
          i_data_val = 1;
          i_en = 0;
          // Enable is low, valid is high, 0 is written to buffer, write pointer increments, full flag lifts
          #200ps    
          i_data.data = 4'h0;
          i_data_val = 0;
          i_en = 1;
          // Read E
          i_data.data = 4'h0;
          i_data_val = 0;
          i_en = 1;
          // Read E
          i_data.data = 4'h0;
          i_data_val = 0;
          i_en = 1;
          // Read F
          i_data.data = 4'h0;
          i_data_val = 0;
          i_en = 1;
          // Read 0
          i_data.data = 4'h0;
          i_data_val = 0;
          i_en = 1;
          // EMPTY!
          $stop(1);
        end
    
    3 : begin
          reset_n = 0;
          i_data.data = 0;
          i_data_val = 1;
          i_en = 0;
          #205ps 
          reset_n = 1;
          forever@(posedge clk) begin
            i_data.data = i_data.data+1;
            i_en = ~i_en;
          end
        end
    
    endcase
  end
endmodule
  
  