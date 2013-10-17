module testStart  
  #(parameter X_NODES = 32,
    parameter Y_NODES = 32,
    parameter FIFO_WIDTH = 64,
    parameter FIFO_DEPTH = 4,
    parameter MODE = 0,
    parameter N1 = 0,
    parameter N2 = 1,
    parameter N3 = 0,
    parameter r  = 1);
    
// ---------------------------------------------------------------------------------- 
// Function to calculate an approximation of log2(n)
// ----------------------------------------------------------------------------------
  
function int log2(input int n);
  begin
    log2 = 0;     // log2 is zero to start
    n--;          // decrement 'n'
    while (n > 0) // While n is greater than 0
      begin
        log2++;   // Increment 'log2'
        n >>= 1;  // Bitwise shift 'n' to the right by one position
      end
  end
endfunction
  
// ----------------------------------------------------------------------------------
// Declare the structure of the flits that the network takes.
// ----------------------------------------------------------------------------------

typedef struct{
  
       logic        Valid;        // First bit 1 for valid
  rand logic  [4:0] xDestination; // X destination in next five bits
  rand logic  [4:0] yDestination; // Y destination in next five bits
       logic  [9:0] nodeOrigin;   // stores which node the flit was sent from
       logic [42:0] data;         // Data in rest

} flit_test;
  

// ----------------------------------------------------------------------------------
// Declare the class NOC_Message to contain methods to be performed on
// the flits such as writing data and creating random destinations.
// ----------------------------------------------------------------------------------

class NOC_Message;

  // Class Members
  
  rand flit_test message;
  rand int    xseed;
  rand int    yseed;
   
   
  // Class construct
  
  function new (int i);
    begin
      xseed = $random(i);
      yseed = $random(i+10);
    end
  endfunction
  
  
  // class method to set data
  
  task set_data (logic newData);
    message.data = newData;
  endtask
  
    
  // class method to randomise x and y destination within constraints.
  // this is needed as the randomize() function in SystemVerilog is not
  // available in the student version.
  
  task randomise();
    begin 
    message.xDestination = $dist_uniform(xseed,0,log2(X_NODES));
    message.yDestination = $dist_uniform(yseed,0,log2(Y_NODES));
    end
  endtask

endclass: NOC_Message
  
  
// ----------------------------------------------------------------------------------
//                                Module logic
// ----------------------------------------------------------------------------------
//  TYPE  packed size    Name                               Unpacked Size
// ----------------------------------------------------------------------------------

  logic                  reset;
  logic                  clk;
  logic                  valid;
  logic            [4:0] xDestination                       [(X_NODES*Y_NODES)];
  logic            [4:0] yDestination                       [(X_NODES*Y_NODES)];
  logic            [9:0] nodeOrigin                         [(X_NODES*Y_NODES)];
  logic           [42:0] data;
  logic [FIFO_WIDTH-1:0] randomData                         [(X_NODES*Y_NODES)];
  logic [FIFO_WIDTH-1:0] nodeToNetworkDataQueue             [(X_NODES*Y_NODES)][$];
  logic [FIFO_WIDTH-1:0] nodeToNetworkData                  [(X_NODES*Y_NODES)];
  logic [FIFO_WIDTH-1:0] networkToNodeData                  [(X_NODES*Y_NODES)];
  logic                  nodeToNetworkWriteRequest          [(X_NODES*Y_NODES)];
  logic                  nodeToNetworkHoldRequest           [(X_NODES*Y_NODES)];
  logic                  networkToNodeWriteRequest          [(X_NODES*Y_NODES)];
  logic                  networkToNodeHoldRequest           [(X_NODES*Y_NODES)];
  logic [FIFO_WIDTH-1:0] networkData                        [(X_NODES*Y_NODES)][0:4];
  logic [FIFO_WIDTH-1:0] routerInputData                    [(X_NODES*Y_NODES)][0:4];
  logic           [42:0] cycle;
  int                    countTotal;
  int                    countRecievedFromNode              [(X_NODES*Y_NODES)];
  int                    xDestinationFlag                   [(X_NODES*Y_NODES)];
  int                    yDestinationFlag                   [(X_NODES*Y_NODES)];
  int                    dataFlag             	             [(X_NODES*Y_NODES)];
  int                    networkDataXDestinationFlag        [(X_NODES*Y_NODES)][0:4];
  int                    networkDataYDestinationFlag        [(X_NODES*Y_NODES)][0:4];
  int                    networkDataDataFlag                [(X_NODES*Y_NODES)][0:4];
  int                    networkDataOriginFlag              [(X_NODES*Y_NODES)][0:4];
  int                    routerInputDataXDestinationFlag    [(X_NODES*Y_NODES)][0:4];
  int                    routerInputDataYDestinationFlag    [(X_NODES*Y_NODES)][0:4];
  int                    routerInputDataDataFlag            [(X_NODES*Y_NODES)][0:4];
  int                    routerInputDataOriginFlag          [(X_NODES*Y_NODES)][0:4];
  int                    queueSize                          [(X_NODES*Y_NODES)]; 
  logic           [N2:1] recieved                           [X_NODES*Y_NODES];
  int                    injection;
  int                    injectionSeed;
  int                    packetInN1, packetInN2, packetInN3;
  int                    nodeTotalLatency                   [X_NODES*Y_NODES];
  int                    totalLatency, averageLatency;
  
  
// ----------------------------------------------------------------------------------   
// Reset and Clock pulse creation.  Clock pulse rising edge every 100ps.
// ----------------------------------------------------------------------------------
  
initial
  begin
    clk = 1;
    forever #50ps clk = ~clk;
  end

// ----------------------------------------------------------------------------------
// Creation of a network
// ----------------------------------------------------------------------------------

network #(X_NODES, Y_NODES, FIFO_WIDTH, FIFO_DEPTH, MODE) networktest (networkToNodeData, networkToNodeWriteRequest, networkToNodeHoldRequest, networkData, routerInputData, nodeToNetworkData, nodeToNetworkWriteRequest, nodeToNetworkHoldRequest, reset, clk);

initial
  begin
    reset = 1'b1;
    for (int i = 0; i<X_NODES*Y_NODES; i++)
      begin
        nodeToNetworkHoldRequest[i] = 0;
        nodeToNetworkWriteRequest[i] = 0;
      end
    #50ps
    reset= 1'b0;
  end
    

// ----------------------------------------------------------------------------------
// Creation of randomish input data.  Depending on the injection rate 'r', on each 
// clock pulse, new data might be created of the class type NOC_Message,
// using the flit_test structure.  The x and y destination is randomised and and the 
// node of origin and cycle stored then inserted into a variable length queue to hold 
// the data until the network is ready.  This block utilises the SystemVerilog queue 
// function push_back().  There are three distinct stages, warm up, steady state and
// drain.
// ----------------------------------------------------------------------------------
  
initial
  begin
    NOC_Message test_message[0:(X_NODES*Y_NODES)-1];
    injectionSeed = $random;
    cycle = 0;
    for (int i = 0; i < (X_NODES*Y_NODES); i++)
      begin
        test_message[i] = new(i);
      end
    
    
    // Warm up
    
    repeat (N1)
      begin
        #100ps
        for (int i = 0; i < X_NODES*Y_NODES; i++)
          begin
            injection = $dist_uniform(injectionSeed, 0, 100);
            if (injection < (r*100)+1)
              begin
              test_message[i].randomise();
              valid           = 1'b1;
              xDestination[i] = test_message[i].message.xDestination;
              yDestination[i] = test_message[i].message.yDestination;
              data            = '0;
              nodeOrigin[i]   = i;
              randomData[i]  = {valid, xDestination[i], yDestination[i], nodeOrigin[i], data};
              nodeToNetworkDataQueue[i].push_back(randomData[i]);
              packetInN1++;
              end
          end
      end


    // Steady State

    repeat (N2)
      begin
        #100ps
        cycle = cycle + 1;
        for (int i = 0; i < X_NODES*Y_NODES; i++)
          begin
            injection = $dist_uniform(injectionSeed, 0, 100);
            if (injection < (r*100)+1)
              begin
              test_message[i].randomise();
              valid           = 1'b1;
              xDestination[i] = test_message[i].message.xDestination;
              yDestination[i] = test_message[i].message.yDestination;
              data            = cycle;
              nodeOrigin[i]   = i;
              randomData[i]  = {valid, xDestination[i], yDestination[i], nodeOrigin[i], data};
              nodeToNetworkDataQueue[i].push_back(randomData[i]);
              packetInN2++;
              end
            end
      end
      
      
    // Drain
    
    repeat (N3)
      begin
        #100ps
        cycle = cycle + 1;
        for (int i = 0; i < X_NODES*Y_NODES; i++)
          begin
            injection = $dist_uniform(injectionSeed, 0, 100);
            if (injection < (r*100)+1)
              begin
              test_message[i].randomise();
              valid           = 1'b1;
              xDestination[i] = test_message[i].message.xDestination;
              yDestination[i] = test_message[i].message.yDestination;
              data            = 0;
              nodeOrigin[i]   = i;
              randomData[i]  = {valid, xDestination[i], yDestination[i], nodeOrigin[i], data};
              nodeToNetworkDataQueue[i].push_back(randomData[i]);
              packetInN3++;
              end
          end
      end
    end

// ----------------------------------------------------------------------------------
// On each clock pulse, write Data to network provided there is data in the queue and 
// that there is space in the input unit.  This block utilises the SystemVerilog
// queue functions .size() and .pop_front().
// ----------------------------------------------------------------------------------
 
always_ff@(posedge clk)
  begin
    for (int i = 0; i < X_NODES*Y_NODES; i++)
      begin
        if ((nodeToNetworkDataQueue[i].size() != 0) && (networkToNodeHoldRequest[i] != 1))
          begin
            nodeToNetworkWriteRequest[i] <= 1'b1;
            nodeToNetworkData[i] <= nodeToNetworkDataQueue[i].pop_front();
          end
        else nodeToNetworkWriteRequest[i] <= 1'b0;
      end
  end

// Count total flits out

always_ff@(posedge clk)
  begin
    for (int i=0; i < X_NODES*Y_NODES; i++)
      begin
        countTotal = networkToNodeWriteRequest[i] ? countTotal+1 : countTotal;
      end
  end
       

// Calculate average latency
     
always_ff@(posedge clk)
  begin
    for (int i=0; i < X_NODES*Y_NODES; i++)
      begin
        if (networkToNodeWriteRequest[i] == 1)
          nodeTotalLatency[i] <= (cycle - networkToNodeData[i][FIFO_WIDTH-22:0]) + nodeTotalLatency[i];
          totalLatency <= totalLatency + nodeTotalLatency[i];
          averageLatency <= totalLatency / countTotal;
      end

  end
  

          
// ---------------------------------------------------------------------------------- 
// Read incoming data and make the various calculations neccessary to gain results
// ----------------------------------------------------------------------------------
  
initial
  begin
    #50ps                  // stalls the calculations so they happen mid clock cycle.
    forever #100ps
      begin
        

        // Count total flits out from each node origin
        
        for (int j = 0; j < X_NODES*Y_NODES; j++)
          begin
            for (int k = 0; k < X_NODES*Y_NODES; k++)
              countRecievedFromNode[j] = ((networkToNodeData[k][FIFO_WIDTH-12:FIFO_WIDTH-21] == j) && (networkToNodeData[k][FIFO_WIDTH-1] == 1)) ? countRecievedFromNode[j] + 1 : countRecievedFromNode[j];
          end
        
        
        // Recieved?
        for (int i = 0; i < X_NODES*Y_NODES; i++)
          begin
            for (int k = 0; k < X_NODES*Y_NODES; k++)
              begin
              if (networkToNodeData[i][FIFO_WIDTH-12:FIFO_WIDTH-21] == k)
                recieved[k][networkToNodeData[i][FIFO_WIDTH-22:0]] <= 1 ;
              end
          end
    
        
        // Creat flags for debugging, these make it easier to decipher the simulation wave window.
        
        for (int j = 0; j < X_NODES*Y_NODES; j++)
          begin
            xDestinationFlag[j] = (nodeToNetworkData[j][FIFO_WIDTH-1] == 1) ? nodeToNetworkData[j][FIFO_WIDTH-2:FIFO_WIDTH-6] :9;
            yDestinationFlag[j] = (nodeToNetworkData[j][FIFO_WIDTH-1] == 1) ? nodeToNetworkData[j][FIFO_WIDTH-7:FIFO_WIDTH-11] :9;
            dataFlag[j] = (nodeToNetworkData[j][FIFO_WIDTH-1] == 1) ? nodeToNetworkData[j][FIFO_WIDTH-22:0] : 0;
            queueSize[j] = nodeToNetworkDataQueue[j].size();
          
            for (int k = 0; k < 5; k++)
              begin
                networkDataXDestinationFlag[j][k] = (networkData[j][k][FIFO_WIDTH-1] == 1) ? networkData[j][k][FIFO_WIDTH-2:FIFO_WIDTH-6] :9;
                networkDataYDestinationFlag[j][k] = (networkData[j][k][FIFO_WIDTH-1] == 1) ? networkData[j][k][FIFO_WIDTH-7:FIFO_WIDTH-11] :9;          
                networkDataOriginFlag[j][k] = (networkData[j][k][FIFO_WIDTH-1] == 1) ? networkData[j][k][FIFO_WIDTH-12:FIFO_WIDTH-21] : 9;
                networkDataDataFlag[j][k] = (networkData[j][k][FIFO_WIDTH-1] == 1) ? networkData[j][k][FIFO_WIDTH-22:0] : 0;
          
                routerInputDataXDestinationFlag[j][k] = (routerInputData[j][k][FIFO_WIDTH-1] == 1) ? routerInputData[j][k][FIFO_WIDTH-2:FIFO_WIDTH-6] :9;
                routerInputDataYDestinationFlag[j][k] = (routerInputData[j][k][FIFO_WIDTH-1] == 1) ? routerInputData[j][k][FIFO_WIDTH-7:FIFO_WIDTH-11] :9;
                routerInputDataOriginFlag[j][k] = (routerInputData[j][k][FIFO_WIDTH-1] == 1) ? routerInputData[j][k][FIFO_WIDTH-12:FIFO_WIDTH-21] : 9;
                routerInputDataDataFlag[j][k] = (routerInputData[j][k][FIFO_WIDTH-1] == 1) ? routerInputData[j][k][FIFO_WIDTH-22:0] : 0;
              end
          end
        
            

          
      end
    end
      
endmodule
  
