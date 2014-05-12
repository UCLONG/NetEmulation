// Recirculation allocator for speculative network scheme 2
// Contend for outputs between transceiver and recirculation buffers 
// Shiyun Liu 10/2013

`include "config.sv"

module alloc_recirc (
  output  grant_t                               grant [0:`PORTS-1],
  output  logic      [0:`PORTS-1][`PORTS-1:0]   grant_switch,
  output  grant_t                               grant_buf [0:`PORTS-1],
  output  logic      [0:`PORTS-1][`PORTS-1:0]   grant_switch_buf, //to photonic switch
  input   req_t                                 req [0:`PORTS-1],
  input   logic                                 clk,
  input   logic                                 rst,
  input   req_t                                 req_buf [0:`PORTS-1]);
  
  // Internal signals
  logic [0:`PORTS-1][`PORTS-1:0]                       req_int ;
  logic [0:`PORTS-1][`PORTS-1:0][log2(`FIFO_DEPTH):0]  req_int_y; 
  //logic [0:`PORTS-1][`PORTS-1:0][log2(`FIFO_DEPTH):0]  req_int_test;  // used to put signal not get grant
  logic [0:`PORTS-1][log2(`SLOT_SIZE):0]               no_grant_counters;   // used to put signal showing it doesn't get grant
  logic [0:`PORTS-1][log2(`SLOT_SIZE):0]               grant_counters; // later make size of counters optimum
  logic [0:`PORTS-1][`PORTS-1:0]       ry          ; 
  logic [0:`PORTS-1][`PORTS-1:0]       gy          ;
  logic [0:`PORTS-1][`PORTS-1:0]       grant_int   ; 
  logic [0:`PORTS-1][`PORTS-1:0]       grant_switch_int_y;
  logic [0:`PORTS-1][`PORTS-1:0]       grant_switch_int_x;
  logic [0:`PORTS-1][`PORTS-1:0]       grant_config_x;
  logic [0:`PORTS-1][log2(`PORTS)-1:0] grant_ports;
  logic [0:`PORTS-1][log2(`PORTS)-1:0] no_grant_ports;
  logic [0:`PORTS-1][`PORTS-1:0]       grant_int_y ;
  logic [0:`PORTS-1][`PORTS-1:0]       gx          ;
  logic [0:`PORTS-1][`PORTS-1:0]       rx          ; 
             
  
  logic [0:`PORTS-1][log2(`SLOT_SIZE):0]              grant_counters_buf;
  logic [0:`PORTS-1][log2(`PORTS)-1:0]                grant_ports_buf;
  logic [0:`PORTS-1][`PORTS-1:0]                      req_int_buf; 

  `ifdef VC
    
    // Specific signals for VC network
    logic [0:`PORTS-1][`PORTS-1:0]       inty; 
    logic [0:`PORTS-1][`PORTS-1:0]       intx;   
    logic [0:`PORTS-1][log2(`PORTS)-1:0] grant_port;
    
    // Instantiate arbiters			
    generate
      for (genvar h=0;h<`PORTS;h++) begin
        arbiter #(`PORTS) output_arbiter(.clk(clk), .ce(|gy[h]), .r(ry[h]), .g(inty[h]), .rst(rst));
        arbiter #(`PORTS) input_arbiter(.clk(clk), .ce(1'b1), .r(intx[h]), .g(grant_int[h]), .rst(rst));
      end
    endgenerate	
  
  `else
  
    // Instantiate arbiters			
    generate for (genvar h=0;h<`PORTS;h++)
      arbiter #(`PORTS) output_arbiter(
        .clk(clk), 
        .ce(1'b1), 
        .r(ry[h]), 
        .g(gy[h]), 
        .rst(rst));
    endgenerate	
  
  `endif
  
  // Create internal request matrix
  // Counts requests so only a single request is sent per message
  always_ff @(posedge clk)
    if (rst) 
      for (int k=0;k<`PORTS;k++)
        for (int j=0;j<`PORTS;j++) begin
          req_int[k][j] <= 0;
          req_int_buf[k][j] <= 0;
        end
    else begin
        for (int k=0;k<`PORTS;k++)
          for (int j=0;j<`PORTS;j++) begin
             if ((req[k].valid) && (req[k].port==j)) begin
                          req_int[k][j] <=  1;
             end				
           else   req_int[k][j] <= 0;
           end 
    for (int k=0;k<`PORTS;k++)
      for (int j=0;j<`PORTS;j++)
         if ((req_buf[k].valid) && (req_buf[k].port==j)) begin
           if (!grant_int[k][j])	begin  
             req_int_buf[k][j] <= req_int_buf[k][j] + 1;
           end
         end else if ((grant_int[k][j])&&(req_int_buf[k]==grant_int[k])) begin
           req_int_buf[k][j] <= req_int_buf[k][j] - 1;
      end			
end    
       
  // Register grants and store grants for switch
  // Replace grants to switch buffer with by shift register in later version
  always_ff @(posedge clk)
    if (rst)
      for (int k=0;k<`PORTS;k++) begin
        grant[k].valid    <= 0;
        grant_switch[k]   <= 0;
        grant_buf[k].valid      <= 0;
       // grant_switch_buf[k]   <= 0;
      end
    else begin
     for (int k=0;k<`PORTS;k++)
     for (int j=0;j<`PORTS;j++)
     grant_switch [k][j]<= grant_config_x [j][k];
      for (int j=0;j<`PORTS;j++) begin
        `ifdef VC
            grant[j].valid    <=  |grant_int[j];
            grant[j].port     <=  grant_port[j]; 
        `else
          if((grant_int[j]==req_int_buf[j])&&(grant_int[j]!=0))begin
            grant_buf[j].valid   <= 1'b1;
            grant[j].valid   <= 1'b0;
          end else if((grant_int[j]==req_int[j])&&(grant_int[j]!=0)) begin
            grant_buf[j].valid   <= 1'b0;
            grant[j].valid   <= 1'b1;
          end else begin
            grant_buf[j].valid   <= 1'b0;
            grant[j].valid   <= 1'b0;
          end
        `endif
      end
    end
    
    //set the buffer matrix
    always_ff @(posedge clk)
    for(int k =0; k<`PORTS; k++) begin
      grant_switch_buf[0][k]<=0;
      grant_switch_buf[1][k]<=0;
      if(|grant_config_x[k]) begin
        if(grant_counters_buf[k]<`SLOT_SIZE-1)
            grant_switch_buf[1][k] <= 1'b1;
        if(grant_counters[k]<`SLOT_SIZE-1)
          grant_switch_buf[0][k] <= 1'b1;
        end
      end
      
    
    `ifdef VC
    // This block converts the grant matrix from
    // 1hot to binary with the correct width
    always_comb                   
      for (int j=0;j<`PORTS;j++)  
        grant_port[j] = log2(grant_int[j]);
    `endif
        
   always_comb
     for (int k=0;k<`PORTS;k++) begin
       for (int j=0;j<`PORTS;j++) begin
          `ifdef VC
              intx[k][j] = inty[j][k];
              gy[k][j]   = grant_int[j][k];
          `else begin
            grant_int[k][j] =   gy[j][k];
           end
          `endif
       end
     end

// Rotate matices (comb)
always_comb
     for (int k=0;k<`PORTS;k++) begin
       for (int j=0;j<`PORTS;j++) begin
         grant_switch_int_y[k][j] = grant_switch_int_x[j][k];
       //  grant_switch_int_buf_x[k][j] = grant_switch_int_buf_y[j][k];
         req_int_y[k][j] = req_int[j][k];
         gx[k][j] = gy[j][k];
         grant_int_y [k][j]=  grant_int[j][k];
       end
     end  
         
 
  // Create requests for arbs, including rotate (comb)
  always_comb
    for (int k=0;k<`PORTS;k++) begin
    for (int j=0;j<`PORTS;j++) begin
      if((req_int[k][j]&(~|req_int_buf[k]))|req_int_buf[k][j])  begin
        if ((~|grant_switch_int_y[j]) && (~|grant_switch_int_x[k]) ) 
          ry[j][k]  =   1'b1;
        else
          ry[j][k] = 1'b0;
        end
      else
        ry[j][k]  =   1'b0;
    end
  end
  
  // Grant counters
  always_ff @(posedge clk)
      if (rst)
        for (int k=0;k<`PORTS;k++) begin
          grant_counters[k] <= `SLOT_SIZE-1;
          grant_ports[k]    <= 0;
      end else
        for (int k=0;k<`PORTS;k++)
          if((grant_int[k]==req_int[k])&&(grant_int[k]!=0)) begin
            grant_counters[k] <= 0;
            grant_ports[k] <= log2(grant_int[k]);
          end else if (grant_counters[k]<`SLOT_SIZE-1)
            grant_counters[k] <= grant_counters[k] + 1;
  
  //No grant counters
  always_ff @(posedge clk)
        if (rst)
          for (int k=0;k<`PORTS;k++) begin
            no_grant_counters[k] <= `SLOT_SIZE-1;
            no_grant_ports[k]    <= 0;
        end else
          for (int k=0;k<`PORTS;k++)
            if ((req_int[k]!=grant_int[k])&&(|req_int[k])) begin
              no_grant_counters[k] <= 0;
              no_grant_ports[k] <= k;
            end else if (no_grant_counters[k]<`SLOT_SIZE-1)
              no_grant_counters[k] <= no_grant_counters[k] + 1;
              
  // Buffer grant counters
  always_ff @(posedge clk)
      if (rst)
        for (int k=0;k<`PORTS;k++) begin
          grant_counters_buf[k] <= `SLOT_SIZE-1;
          grant_ports_buf[k]    <= 0;
      end else
        for (int k=0;k<`PORTS;k++)
          if ((grant_int[k]==req_int_buf[k])&&(grant_int[k]!=0)) begin
             grant_counters_buf[k] <= 0;
             grant_ports_buf[k] <= log2(grant_int[k]);
          end else if (grant_counters_buf[k]<`SLOT_SIZE-1)
             grant_counters_buf[k] <= grant_counters_buf[k] + 1;
          
  // Define switch matrix (grouped by output ports)
  always_comb
    for (int k=0;k<`PORTS;k++) begin
      grant_switch_int_x[k] = 0;
      if (grant_counters[k]<`SLOT_SIZE-1)
        grant_switch_int_x[k][grant_ports[k]] = 1'b1;
      if (grant_counters_buf[k]<`SLOT_SIZE-1)
        grant_switch_int_x[k][grant_ports_buf[k]] = 1'b1;
    end
  
 // Define buffer control signals and adding it into switch matrix
  always_comb
  for (int k=0; k<`PORTS; k++) begin
  grant_config_x [k] = grant_switch_int_x[k];
  if (no_grant_counters[k]<`SLOT_SIZE-1)
    grant_config_x [k][k]=1'b1;
  end
          
    
endmodule
