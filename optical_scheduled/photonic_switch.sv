// Simple combinational switch
// Philip Watts 2/4/2013

`include "config.sv"
  
  module photonic_switch(
    output  packet_t    dout  [0:`PORTS-1],
    output  grant_t   grant_out [0:`PORTS-1],
    output  req_t   req_out [0:`PORTS-1],
    input   packet_t    din   [0:`PORTS-1],
    input   grant_t   grant_in  [0:`PORTS-1],
    input   req_t   req_in  [0:`PORTS-1],    
    input   logic   [0:`PORTS-1][`PORTS-1:0]      switch_config,
    input   logic                                 clk );
    
  // Internal signals
	logic  [0:`PORTS-1][`PORTS-1:0]  gy ;	
	packet_t    switch_dout  [0:`PORTS-1];
	packet_t    switch_din   [0:`PORTS-1];
	
/*	//rotate grant arrays
	always @(*) begin
		for (int k=0;k<`PORTS;k++) begin
			for (int j=0;j<`PORTS;j++) begin
				gy[k][j]=switch_config[j][k];
			end
		end
	end 	*/
  
  // Switch logic      
  always_comb
    for (int j=0;j<`PORTS;j++)
      if (|switch_config[j])
        switch_dout[j] = switch_din[log2(switch_config[j])];
      else
        switch_dout[j].valid = 0;
        
        
  // If transport delay is 1 clock cycle, it is not necessary 
  // to introduce extra delay here
  generate if (`TOF == 1) 
    begin
      assign grant_out  =   grant_in;
      assign req_out    =   req_in;
      assign switch_din =   din;
    end
  endgenerate
	
	// If TOF==2, add a register
	generate if (`TOF == 2) 
    begin
      always_ff @(posedge clk) begin
        grant_out  =   grant_in;
        req_out    =   req_in;
        switch_din  =   din;
      end
    end
  endgenerate
  
  // Add shift registers for TOF>2
  generate if (`TOF >2) 
        begin
          
         for (genvar h=0;h<`PORTS;h++) 
            begin
              sr_req #(`TOF) req_delay (req_out[h], req_in[h], clk);
              sr_grant #(`TOF) grant_delay (grant_out[h], grant_in[h], clk);
              sr_packet #(`TOF) data_delay1 (switch_din[h], din[h], clk);
              sr_packet #(`TOF+`SERIAL) data_delay2 (dout[h], switch_dout[h], clk);
            end
          
        end
  endgenerate 
  
  
  // Shift registers for serialisation and switch to dest port delays
  //generate for (genvar h=0;h<`PORTS;h++) 
  //  begin
     // `ifdef VC
     // sr_packet #((3*`TOF)/2+`SERIAL-2) data_delay (dout[h], switch_dout[h], clk);
  //    sr_packet #(`TOF) data_delay1 (switch_din[h], din[h], clk);
     //`else
     // sr_packet #((3*`TOF)/2+`SERIAL-1) data_delay (dout[h], switch_dout[h], clk);
  //    sr_packet #(`TOF+`SERIAL) data_delay2 (dout[h], switch_dout[h], clk);
     // `endif
  //  end
  //endgenerate
  
endmodule	

