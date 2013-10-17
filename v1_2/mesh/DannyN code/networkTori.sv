//  *************************************************************
//  *************************************************************
//  **                                                         **
//  *  Design Unit : Network Tori                               *
//  *  File Name   : networkTori.sv                             *
//  *  Description : Network-on-Chip - Tori Topology            *
//  *  Author      : Danny Nicholls                             *
//  *                UCL                                        *
//  *                danny.nicholls.09@UCL.ac.uk                *
//  *  Version     : 1 - 12/02/2012                             *
//  *  Notes       : The network connects n*m routers in a 2D   *
//  *                Tori.  Each router produces a 5*FIFO_WIDTH *
//  *                output of its data, the network takes this *
//  *                and produces a 5*FIFO_WIDTH input for each *
//  *                router.  A similar thing is done with      *
//  *                write and hold requests.                   *
//  **                                                         **
//  *************************************************************
//  *************************************************************

module networkTori
  #(parameter X_NODES = 3,
    parameter Y_NODES = 3,
    parameter FIFO_WIDTH = 64,
    parameter FIFO_DEPTH = 4,
    parameter MODE = 1)
    
    // Inputs and outputs for connected nodes
    
    (output logic [FIFO_WIDTH-1:0] networkToNodeData [X_NODES*Y_NODES],
     output logic networkToNodeWriteRequest          [X_NODES*Y_NODES],
     output logic networkToNodeHoldRequest           [X_NODES*Y_NODES],
      input logic [FIFO_WIDTH-1:0] nodeToNetworkData [X_NODES*Y_NODES], 
      input logic nodeToNetworkWriteRequest          [X_NODES*Y_NODES],
      input logic nodeToNetworkHoldRequest           [X_NODES*Y_NODES],
      input logic reset, clk);
    
  
  // Internal logic for generating node numbers and x and y location
  
  logic [2:0]  xLocation;
  logic [2:0]  yLocation;
  logic nodeNumber;
  
  
  // Internal logic for calculating and switching network data
  
  logic [FIFO_WIDTH-1:0] networkData       [0: (X_NODES * Y_NODES)-1][0:4];
  logic [FIFO_WIDTH-1:0] routerInputData   [0: (X_NODES * Y_NODES)-1][0:4];
  logic [4:0]  routerToNetworkHoldPorts    [0: (X_NODES * Y_NODES)-1];
  logic [4:0]  networkToRouterHoldPorts    [0: (X_NODES * Y_NODES)-1];
  logic [4:0]  routerToNetworkWriteRequest [0: (X_NODES * Y_NODES)-1];
  logic [4:0]  networkToRouterWriteRequest [0: (X_NODES * Y_NODES)-1]; 
  
  
  // Generate router inputs
  
  always_comb
    begin        
      for (int nodeNumber = 0; nodeNumber < (X_NODES*Y_NODES); nodeNumber++)          
        begin
          
          
          // Generate router input Data using network data
          
          routerInputData[nodeNumber][0] = (nodeNumber < (X_NODES*(Y_NODES-1))) ? networkData [nodeNumber + X_NODES][2]      : networkData [nodeNumber - (X_NODES*(Y_NODES-1))][2];
          routerInputData[nodeNumber][1] = (((nodeNumber + 1) % X_NODES) == 0)  ? networkData [nodeNumber - (X_NODES-1)][3]  : networkData [nodeNumber + 1][3];
          routerInputData[nodeNumber][2] = (nodeNumber > (X_NODES-1))           ? networkData [nodeNumber - X_NODES][0]      : networkData [nodeNumber + (X_NODES*(Y_NODES-1))][0];
          routerInputData[nodeNumber][3] = ((nodeNumber % X_NODES) == 0)        ? networkData [nodeNumber + (X_NODES-1)][1]  : networkData [nodeNumber -1][1];
          routerInputData[nodeNumber][4] = nodeToNetworkData[nodeNumber];
          
          
          // Generate router hold request inputs 
  
          networkToRouterHoldPorts[nodeNumber][0] = (nodeNumber < (X_NODES*(Y_NODES-1))) ? routerToNetworkHoldPorts [nodeNumber + X_NODES][2]     : routerToNetworkHoldPorts [nodeNumber - (X_NODES*(Y_NODES-1))][2];
          networkToRouterHoldPorts[nodeNumber][1] = (((nodeNumber + 1) % X_NODES) == 0)  ? routerToNetworkHoldPorts [nodeNumber - (X_NODES-1)][3] : routerToNetworkHoldPorts [nodeNumber + 1][3]; 
          networkToRouterHoldPorts[nodeNumber][2] = (nodeNumber > (X_NODES-1))           ? routerToNetworkHoldPorts [nodeNumber - X_NODES][0]     : routerToNetworkHoldPorts [nodeNumber - X_NODES][0];
          networkToRouterHoldPorts[nodeNumber][3] = ((nodeNumber % X_NODES) == 0)        ? routerToNetworkHoldPorts [nodeNumber + (X_NODES-1)][1] : routerToNetworkHoldPorts [nodeNumber -1][1];
          networkToRouterHoldPorts[nodeNumber][4] = nodeToNetworkHoldRequest[nodeNumber];
  
  
          // Generate router write request inputs
          
          networkToRouterWriteRequest[nodeNumber][0] = (nodeNumber < (X_NODES*(Y_NODES-1))) ? routerToNetworkWriteRequest [nodeNumber + X_NODES][2]     : routerToNetworkWriteRequest [nodeNumber - (X_NODES*(Y_NODES-1))][2];
          networkToRouterWriteRequest[nodeNumber][1] = (((nodeNumber + 1) % X_NODES) == 0)  ? routerToNetworkWriteRequest [nodeNumber - (X_NODES-1)][3] : routerToNetworkWriteRequest [nodeNumber + 1][3];
          networkToRouterWriteRequest[nodeNumber][2] = (nodeNumber > (X_NODES-1))           ? routerToNetworkWriteRequest [nodeNumber - X_NODES][0]     : routerToNetworkWriteRequest [nodeNumber + (X_NODES*(Y_NODES-1))][0];
          networkToRouterWriteRequest[nodeNumber][3] = ((nodeNumber % X_NODES) == 0)        ? routerToNetworkWriteRequest [nodeNumber + (X_NODES-1)][1] : routerToNetworkWriteRequest [nodeNumber -1][1];
          networkToRouterWriteRequest[nodeNumber][4] = nodeToNetworkWriteRequest[nodeNumber];
          
          
          // Generate network to Node data
          networkToNodeData [nodeNumber]         = networkData[nodeNumber][4];
          networkToNodeWriteRequest [nodeNumber] = routerToNetworkWriteRequest [nodeNumber][4];
          networkToNodeHoldRequest [nodeNumber]  = routerToNetworkHoldPorts [nodeNumber][4];
          
        end
    end
  
  
  // Generate 2D Tori
  
  genvar x,y;
    generate 
      for ( y = 0; y < Y_NODES; y++)
        begin
          for ( x = 0; x < X_NODES; x++)
            begin
              router #(x, y, X_NODES, Y_NODES, FIFO_WIDTH, FIFO_DEPTH, MODE) router (networkData[x+(X_NODES*y)][0:4], routerToNetworkHoldPorts[x+(X_NODES*y)], routerToNetworkWriteRequest[x+(X_NODES*y)], routerInputData[x+(X_NODES*y)][0:4], networkToRouterHoldPorts[x+(X_NODES*y)], networkToRouterWriteRequest[x+(X_NODES*y)], reset, clk);
            end
        end
      endgenerate
        
endmodule