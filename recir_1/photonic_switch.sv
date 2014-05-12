// Simple combinational switch for speculative network scheme 1
// Assumes forwarding input to output ports and oeo buffer ports
// Shiyun Liu 7/2013

`include "config.sv"
  
  module photonic_switch(
    output  packet_t    dout  [0:`PORTS-1],
    output  grant_t     grant_out  [0:`PORTS-1],
    output  req_t       req_out  [0:`PORTS-1],
    output  packet_t    dto_buf [0:`PORTS-1],
    input   packet_t    din   [0:`PORTS-1],
    input   grant_t     grant_in [0:`PORTS-1],
    input   req_t       req_in  [0:`PORTS-1],    
    input   logic   [0:`PORTS-1][`PORTS-1:0]      switch_config,
    input   logic   [0:`PORTS-1][`PORTS-1:0]      switch_config_buf,
    input   logic                                 clk, 
    input   packet_t   dfrom_buf  [0:`PORTS-1]);
    
  // Internal signals
	logic  [0:`PORTS-1][`PORTS-1:0]  gy ;	
	packet_t    switch_dout  [0:`PORTS-1];
	packet_t    din_after_delay  [0:`PORTS-1];
	packet_t    switch_din   [0:2*`PORTS-1];
	logic      [0:2*`PORTS-1][`PORTS-1:0]   grant_switch_config;
  integer      switch_input_count [0:`PORTS-1];
  integer      buffers_input_count [0:`PORTS-1];
  
  //Combine switch configure matrix
always_comb
  grant_switch_config = {switch_config,switch_config_buf};
  
  // Switch logic      
 always_comb
    for (int j=0;j<2*`PORTS;j++)
      if (|grant_switch_config[j]) begin
        if (grant_switch_config[j][j]==1)begin
             dto_buf[j] = switch_din[j];
             dto_buf[j].data[32] = 1;
        end
        if((j<`PORTS)&&(grant_switch_config[j]!=2**j)) begin
          if(grant_switch_config[j][j]==1)
            switch_dout[j] = switch_din[log2(grant_switch_config[j]-(2**j))];
          else
            switch_dout[j] = switch_din[log2(grant_switch_config[j])];
          end
        else if(j>=`PORTS)
        switch_dout[j-`PORTS] = switch_din[log2(grant_switch_config[j])+`PORTS];
        end
      else begin
        switch_dout[j].valid = 0;
        dto_buf[j] = 0;
      end

           
  // If transport delay is 1 clock cycle, it is not necessary 
  // to introduce extra delay here
  generate if (`TOF == 1) 
    begin
      assign grant_out  =   grant_in;
      assign req_out    =   req_in;
      assign switch_din =   {din,dfrom_buf};
    end
  endgenerate
	
	// If TOF==2, add a register
	generate if (`TOF == 2) 
    begin
      always_ff @(posedge clk) begin
        grant_out  <=   grant_in;
        req_out    <=   req_in;
        switch_din  <=   {din,dfrom_buf};
      end
    end
  endgenerate
  
  // Add shift registers for TOF>2
  generate if (`TOF>2) //(`TOF == 10) ||(`TOF == 20)||(`TOF == 30))
      begin
        
        for (genvar k=0;k<`PORTS;k++) begin
          sr_packet #(`TOF) send_delay (din_after_delay[k], din[k], clk);
          sr_req #(`TOF) req_delay (req_out[k], req_in[k], clk);
        end
        //always_ff @(posedge clk) begin
         // grant_out  =   grant_in;
         // req_out    =   req_in;
        always_comb
          switch_din  =   {din_after_delay,dfrom_buf};
        //end
      end
    endgenerate 
   
  // Shift registers for serialisation and switch to dest port delays
  generate for (genvar h=0;h<`PORTS;h++) 
    begin
      sr_packet #(`TOF+`SERIAL) data_delay (dout[h], switch_dout[h], clk);
    end
  endgenerate
  
  
endmodule	

