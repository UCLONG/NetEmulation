// --------------------------------------------------------------------------------------------------------------------
// IP Block    : NEMU
// Function    : SerialPortWrapper
// Module name : NEMU_SerialWrapper
// Description : Wrapper used to divide latency and packet count data into 8 bit words, that are then transmitted via
//             : rs-232 port (NEMU_SerialPortOutput)
// Uses        : config.sv, NEMU_SerialPortOutput
// Notes       : 

// --------------------------------------------------------------------------------------------------------------------


`include "config.sv"


module NEMU_SerialPortWrapper(
  input logic i_clk,
  input logic reset_n,
  input logic [23:0] i_latency [0:`PORTS-1][0:`PORTS-1],
  input logic [15:0] i_pkt_count_rx [0:`PORTS-1][0:`PORTS-1],
  input logic [15:0] i_pkt_count_tx [0:`PORTS-1][0:`PORTS-1],
  input logic i_SendSerial,
  output logic o_done,
  output logic o_serialTX
); 

logic[4:0] m;
logic[4:0] n;
logic[2:0] k;
logic[7:0] data1;
logic[7:0] data2;
logic[7:0] data3;
logic[7:0] data4;
logic[7:0] data5;
logic[7:0] data6;
logic[7:0] data7;
logic[7:0] data;
logic enable;
logic [23:0] testSignalLatency;
logic [15:0]testSignalRx;
logic [15:0] testSignalTx;
logic beginning;
logic l_wait;
logic l_wrEn;
logic l_serialFifoEmpty;

always_comb begin
  if (enable && i_SendSerial && l_serialFifoEmpty) //enables write when data is ready and fifo of the serial port is empty
 
    l_wrEn = 1;
  else
    l_wrEn = 0;
end

//sending all information for m to n port
//k - state variable
//k==000 send first third of latency data
//k==001 send second third of latency data
//k==010 send third third of latency data
//k==011 send first half of count data for received pkt
//k==100 send second half of count data for received pkt
//k==101 send first half of count data for transmitted pkt
//k==110 send second half of count data for transmitted pkt


always_ff @(posedge i_clk or posedge reset_n) begin
  if (reset_n) begin
    o_done <= 0;
    m <= 0;
    n <= 0;
    k <= 0;
    enable <= 0;
    beginning <= 1;
  end
if (enable && i_SendSerial && l_serialFifoEmpty) begin
  if (k == 3'b000) begin
    data <= data1;
    k <= k+1;
  end
  if (k == 3'b001) begin
    data <= data2;
    k <= k+1;
  end
  if (k == 3'b010) begin
    data <= data3;
    k <= k+1;
  end
    if (k == 3'b011) begin
    data <= data4;
    k <= k+1;
  end
  if (k == 3'b100) begin
    data <= data5;
    k <= k+1;
  end
  if (k == 3'b101) begin
    data <= data6;
    k <= k+1;
  end
  if (k == 3'b110) begin
    data <= data7;
    enable <= 0;
    k <= 3'b000;
    if (m == (`PORTS-1) && n ==  (`PORTS-1)) begin
      o_done <= 1;
    end 
    
  end
  
  if (k == 3'b111) begin
    k <= 0;
  end

end

if (!enable && i_SendSerial) begin
//beginning variable used to make sure the data from port 0 to port 0 is sent, delays n to increment
  if (beginning) begin
    beginning <= 0;
  end

if (!beginning) begin
  if (m <= (`PORTS-1)) begin
    if (n < (`PORTS-1)) begin
      n <= n+1;
    end
    else begin
      m <= m + 1;
      n <= 0;
    end

  
end


end

enable <= 1;

end


end

always_comb begin

  testSignalLatency = i_latency[m][n];
  testSignalRx = i_pkt_count_rx[m][n];
  testSignalTx = i_pkt_count_tx[m][n];
  data1 = i_latency[m][n][23:16];
  data2 = i_latency[m][n][15:8];
  data3 = i_latency[m][n][7:0];
  data4 = i_pkt_count_rx[m][n][15:8];
  data5 = i_pkt_count_rx[m][n][7:0];
  data6 = i_pkt_count_tx[m][n][15:8];
  data7 = i_pkt_count_tx[m][n][7:0];
end
                               
NEMU_SerialPortOutput serial(i_clk, reset_n, l_wrEn, data, l_wait, l_serialFifoEmpty, o_serialTX);                              


endmodule