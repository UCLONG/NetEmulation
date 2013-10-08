`include "config.sv"

module base_network
  #(parameter X_NODES = 2,
    parameter Y_NODES = 2,
    parameter FIFO_WIDTH = 64,
    parameter FIFO_DEPTH = 4)
    
    // Inputs and outputs for connected nodes
    (output packet_mesh networkToNodeData [X_NODES*Y_NODES],
     output logic [X_NODES*Y_NODES-1:0] networkToNodeHoldRequest, // Network full signal
     
     // These output are used only for debugging with net_emulation module
     output packet_mesh networkData       [0: (X_NODES*Y_NODES)-1][0:4], // [16][5] = [cores][ports]
     output packet_mesh routerInputData   [0: (X_NODES*Y_NODES)-1][0:4], // [16][5] = [cores][ports]
     
     input packet_mesh nodeToNetworkData [X_NODES*Y_NODES],
     input logic [X_NODES*Y_NODES-1:0] nodeToNetworkHoldRequest,
     input logic reset, clk);
     
     // Internal logic for calculating and switching network data
     logic [4:0] routerToNetworkHoldPorts    [0: (X_NODES*Y_NODES)-1];
     logic [4:0] networkToRouterHoldPorts    [0: (X_NODES*Y_NODES)-1];
     logic [4:0] routerToNetworkWriteRequest [0: (X_NODES*Y_NODES)-1];
     logic [4:0] networkToRouterWriteRequest [0: (X_NODES*Y_NODES)-1];
     logic [4:0] routerToNetworkRead         [0: (X_NODES*Y_NODES)-1];
     logic [4:0] networkToRouterRead         [0: (X_NODES*Y_NODES)-1];

     // Internal logic for generating x and y location
     logic [log2(X_NODES):0] xLocation;
     logic [log2(Y_NODES):0] yLocation;
     
     // Generate router inputs (local inputs of each router and internal connections)
     always_comb
      begin
        for (int nodeNumber = 0; nodeNumber < (X_NODES*Y_NODES); nodeNumber++)
          begin
                // Generate mesh router input Data using network data (router LNESW connections)
                routerInputData[nodeNumber][0] = (nodeNumber < (X_NODES*(Y_NODES-1))) ? networkData[nodeNumber + X_NODES][2] : 'b0; //North of current to south of previous
                routerInputData[nodeNumber][1] = (((nodeNumber + 1)% X_NODES) == 0) ? 'b0 : networkData[nodeNumber + 1][3]; //East to west
                routerInputData[nodeNumber][2] = (nodeNumber > (X_NODES-1)) ? networkData[nodeNumber - X_NODES][0] : 'b0; //South to north
                routerInputData[nodeNumber][3] = ((nodeNumber % X_NODES) == 0) ? 'b0 : networkData [nodeNumber - 1][1]; //West to east
                routerInputData[nodeNumber][4] = nodeToNetworkData[nodeNumber]; //local input
                
                // Generate mesh router hold request inputs
                networkToRouterHoldPorts[nodeNumber][0] = (nodeNumber < (X_NODES*(Y_NODES-1))) ? routerToNetworkHoldPorts[nodeNumber + X_NODES][2] : 1'b0;
                networkToRouterHoldPorts[nodeNumber][1] = (((nodeNumber + 1) % X_NODES) == 0) ? 1'b0 : routerToNetworkHoldPorts[nodeNumber + 1][3];
                networkToRouterHoldPorts[nodeNumber][2] = (nodeNumber > (X_NODES-1)) ? routerToNetworkHoldPorts[nodeNumber - X_NODES][0] : 1'b0;
                networkToRouterHoldPorts[nodeNumber][3] = ((nodeNumber % X_NODES) == 0) ? 1'b0 : routerToNetworkHoldPorts[nodeNumber - 1][1];
                networkToRouterHoldPorts[nodeNumber][4] = nodeToNetworkHoldRequest[nodeNumber];
                
                // Generate mesh router write request inputs
                networkToRouterWriteRequest[nodeNumber][0] = (nodeNumber < (X_NODES*(Y_NODES-1))) ? routerToNetworkWriteRequest[nodeNumber + X_NODES][2] : 1'b0;
                networkToRouterWriteRequest[nodeNumber][1] = (((nodeNumber + 1) % X_NODES) == 0) ? 1'b0 : routerToNetworkWriteRequest[nodeNumber + 1][3];
                networkToRouterWriteRequest[nodeNumber][2] = (nodeNumber > (X_NODES-1)) ? routerToNetworkWriteRequest[nodeNumber - X_NODES][0] : 1'b0;
                networkToRouterWriteRequest[nodeNumber][3] = ((nodeNumber % X_NODES) == 0) ? 1'b0 : routerToNetworkWriteRequest[nodeNumber - 1][1];
                networkToRouterWriteRequest[nodeNumber][4] = nodeToNetworkData[nodeNumber].valid;

                // Generate mesh router read inputs
                networkToRouterRead[nodeNumber][0] = (nodeNumber < (X_NODES*(Y_NODES-1))) ? routerToNetworkRead[nodeNumber + X_NODES][2] : 1'b0;
                networkToRouterRead[nodeNumber][1] = (((nodeNumber + 1) % X_NODES) == 0) ? 1'b0 : routerToNetworkRead[nodeNumber + 1][3];
                networkToRouterRead[nodeNumber][2] = (nodeNumber > (X_NODES-1)) ? routerToNetworkRead[nodeNumber - X_NODES][0] : 1'b0;
                networkToRouterRead[nodeNumber][3] = ((nodeNumber % X_NODES) == 0) ? 1'b0 : routerToNetworkRead[nodeNumber - 1][1];
                networkToRouterRead[nodeNumber][4] = 1'b0; // NOT REQUIRED - Not checked in routing algorithm - if not set then equals x
                                
                // Generate mesh network to Node data
                networkToNodeData[nodeNumber] = networkData[nodeNumber][4];
                networkToNodeHoldRequest[nodeNumber] = routerToNetworkHoldPorts[nodeNumber][4];
          end
      end
     
     // Generate 2D Network
     genvar x,y;
      generate 
        for (y = 0; y < Y_NODES; y++)
          begin
            for (x = 0; x < X_NODES; x++)
              begin
                router #(x, y, X_NODES, Y_NODES, FIFO_WIDTH, FIFO_DEPTH) router (
                  networkData[x + (X_NODES*y)][0:4],
                  routerToNetworkHoldPorts[x + (X_NODES*y)], 
                  routerToNetworkWriteRequest[x + (X_NODES*y)],
                  routerToNetworkRead[x + (X_NODES*y)], 
                  routerInputData[x + (X_NODES*y)][0:4],
                  networkToRouterHoldPorts[x + (X_NODES*y)], 
                  networkToRouterWriteRequest[x + (X_NODES*y)],
                  networkToRouterRead[x + (X_NODES*y)],
                  reset, 
                  clk);
              end
          end
      endgenerate
endmodule
   
     