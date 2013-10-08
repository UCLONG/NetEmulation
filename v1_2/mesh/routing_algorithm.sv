//-----------------------------------------------------
// File Name   : routing_algorithm.sv
// Function    : Generates router output port requests 
//               for head-of-line FIFO buffer packets.
//               Allows deterministic DOR-XY or fully 
//               adaptive routing depending on the
//               setting in the file config.sv                
// Author      : Danny Ly
// Date        : Academic Term 2012/2013 
//-----------------------------------------------------

`include "config.sv"

module routing_algorithm
  #(parameter xLocation = 0,
    parameter yLocation = 0,
    parameter X_NODES = 2,
    parameter Y_NODES = 2,
    parameter FIFO_DEPTH = 4)
    
  (output logic [4:0] outputPortRequest,
   output logic unproductive,  
   input reg empty,
   input logic [4:0] writeEnable,
   input logic [4:0] readEnable,
   input logic [log2(`MESH_WIDTH)-1:0] xdest,
   input logic [log2(`MESH_WIDTH)-1:0] ydest,
   input logic [log2(`UNPRODUCTIVE):0] misroute,
   input logic clk,
   input logic rst);
  
   logic [log2(FIFO_DEPTH):0] northFIFO;
   logic [log2(FIFO_DEPTH):0] eastFIFO;
   logic [log2(FIFO_DEPTH):0] southFIFO;
   logic [log2(FIFO_DEPTH):0] westFIFO;
   logic [2:0] random;
  
	 // Generate random number to resolve equal port traffic decision
	 always_ff @(posedge clk or posedge rst)
		 begin
		 if (rst)
			 random <= 3'b1;
		 else	
			 random <= {random[1:0], (random[0] ^ random[2])};		
     end
   
   // Resource gathering to quantify buffer queue length of adjacent routers
   // 5 bits [4:0] represent [Local, West, South, East, North]
   always_ff @ (posedge clk)
     begin
       if (rst)
         begin
           northFIFO <= 'b0;
           eastFIFO <= 'b0;
           southFIFO <= 'b0;
           westFIFO <= 'b0;
         end
       else
         begin
           if (writeEnable[0] == 1 && readEnable[0] == 0)
             northFIFO++;
           else if (readEnable[0] == 1 && writeEnable[0] == 0)
             northFIFO--;
           if (writeEnable[1] == 1 && readEnable[1] == 0)
             eastFIFO++;
           else if (readEnable[1] == 1 && writeEnable[1] == 0)
             eastFIFO--;
           if (writeEnable[2] == 1 && readEnable[2] == 0)
             southFIFO++;
           else if (readEnable[2] == 1 && writeEnable[2] == 0)
             southFIFO--;
           if (writeEnable[3] == 1 && readEnable[3] == 0)
             westFIFO++; 
           else if (readEnable[3] == 1 && writeEnable[3] == 0)
             westFIFO--;
         end
     end
 
 `ifdef DETERMINISTIC    
   //Derministic XY Routing 
    always_comb
     begin
       if (~empty) // If FIFO has packets
         begin
           if (xdest != xLocation)
             outputPortRequest <= (xdest > xLocation) ? 5'b00010 : 5'b01000; // East else West
           else if (ydest != yLocation)
             outputPortRequest <= (ydest > yLocation) ? 5'b00001 : 5'b00100; // North else South
           else
             outputPortRequest <= 5'b10000; // Local
         end
       // When FIFO empty no port is requested
       else
         outputPortRequest <= 5'b00000;
     end
     
 `else

   // Fully Adaptive Routing, outputPortRequest bit representation: [Local, West, South, East, North]
   always_comb
     begin
       if (~empty) // If FIFO has packets
         begin 
           // Check if current x and y < destination xy --------------------------------------------------------------------------------------
           if ((xLocation < xdest) && (yLocation < ydest))
             begin
	             // Check corresponding queue length of NORTH and EAST (productive paths)
	             // Choose shortest queue if both < `THRESHOLD, if equal pick randomly
	             if ((northFIFO < `THRESHOLD) || (eastFIFO < `THRESHOLD) || ((xLocation == 0) && (yLocation == 0)))
	               begin
	                 if (northFIFO < eastFIFO)
	                   begin
		                   outputPortRequest = 5'b00001;
		                   unproductive = 1'b0; // Reset flag
		                 end
	                 else if (eastFIFO < northFIFO)
		                 begin
		                   outputPortRequest = 5'b00010;
		                   unproductive = 1'b0; // Reset flag
		                 end
		               else // (northFIFO == eastFIFO)
		                 begin
		                   if (random[0] == 1)
		                     begin
		                       outputPortRequest = 5'b00001; // NORTH
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b00010; // EAST
		                       unproductive = 1'b0; // Reset flag
		                     end                   		                     
		                 end
		             end 
	             // Else both >= `THRESHOLD, choose shortest queue regardless of productive or unproductive (keeping within network boundary)            
		           else if ((xLocation == 0) && (yLocation != 0))
		             begin
		               if (southFIFO < northFIFO && southFIFO < eastFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00100;
		                   unproductive = 1'b1;
		                 end	               
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (northFIFO < eastFIFO)
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (eastFIFO < northFIFO)
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b0; // Reset flag
		                         end
		                     end
		                 end
		             end  		             	             
               else if ((xLocation != 0) && (yLocation == 0))
                 begin
		               if ((westFIFO < northFIFO) && (westFIFO < eastFIFO) && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b01000;
		                   unproductive = 1'b1;
		                 end
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (northFIFO < eastFIFO)
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (eastFIFO < northFIFO)
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b0; // Reset flag
		                         end
		                     end
		                 end
		             end    	
               else
                 begin
                   if (southFIFO < northFIFO && southFIFO < eastFIFO && southFIFO < westFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00100;
		                   unproductive = 1'b1;
		                 end		             
                   else if (westFIFO < northFIFO && westFIFO < eastFIFO && westFIFO < southFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b01000;
		                   unproductive = 1'b1;
		                 end
                   else if (westFIFO < northFIFO && westFIFO < eastFIFO && westFIFO == southFIFO && (misroute > 0))
	                   begin
		                   if (random[0] == 1)
		                     begin
		                       outputPortRequest = 5'b00100; // SOUTH
		                       unproductive = 1'b1; // Reset flag
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b01000; // WEST
		                       unproductive = 1'b1; // Reset flag
		                     end
		                 end
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (northFIFO < eastFIFO)
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (eastFIFO < northFIFO)
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                          begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b0; // Reset flag
		                          end
		                     end
		                 end	             
                 end
             end
           // Check if current x and y > destination xy --------------------------------------------------------------------------------------
           else if ((xLocation > xdest) && (yLocation > ydest))
             begin
	             // Check corresponding queue length of SOUTH and WEST (productive paths)
	             // Choose shortest queue if both < `THRESHOLD, if equal pick randomly
	             if (southFIFO < `THRESHOLD || westFIFO < `THRESHOLD || (xLocation == X_NODES-1 && yLocation == Y_NODES-1))
	               begin
	                 if (southFIFO < westFIFO)
	                   begin
		                   outputPortRequest = 5'b00100;
		                   unproductive = 1'b0; // Reset flag
		                 end
	                 else if (westFIFO < southFIFO)
		                 begin
		                   outputPortRequest = 5'b01000;
		                   unproductive = 1'b0; // Reset flag
		                 end
		               else // (southFIFO == westFIFO)
		                 begin
		                   if (random[0] == 1)
		                     begin
		                       outputPortRequest = 5'b00100; // SOUTH
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b01000; // WEST
		                       unproductive = 1'b0; // Reset flag
		                     end
		                 end
		             end
	             // Else both >= `THRESHOLD, choose shortest queue regardless of productive or unproductive (keeping within network boundary)      
		           else if (xLocation == X_NODES-1 && yLocation != Y_NODES-1)
		             begin
		               if (northFIFO < southFIFO && northFIFO < westFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00001;
		                   unproductive = 1'b1;
		                 end	               
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (southFIFO < westFIFO)
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (westFIFO < southFIFO)
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b0; // Reset flag
		                         end
		                     end
		                 end
		             end  		             	             
               else if (xLocation != X_NODES-1 && yLocation == Y_NODES-1)
                 begin
		               if (eastFIFO < southFIFO && eastFIFO < westFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00010;
		                   unproductive = 1'b1;
		                 end
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (southFIFO < westFIFO)
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (westFIFO < southFIFO)
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b0; // Reset flag
		                         end
		                     end
		                 end
		             end    	
               else
                 begin
                   if (northFIFO < southFIFO && northFIFO < eastFIFO && northFIFO < westFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00001;
		                   unproductive = 1'b1;
		                 end		             
                   else if (eastFIFO < northFIFO && eastFIFO < westFIFO && eastFIFO < southFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00010;
		                   unproductive = 1'b1;
		                 end
                   else if (eastFIFO < southFIFO && eastFIFO < westFIFO && eastFIFO == northFIFO && (misroute > 0))
	                   begin
		                   if (random[0] == 1)
		                     begin
		                       outputPortRequest = 5'b00001; // NORTH
		                       unproductive = 1'b1; // Reset flag
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b00010; // EAST
		                       unproductive = 1'b1; // Reset flag
		                     end
		                 end
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (southFIFO < westFIFO)
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (westFIFO < southFIFO)
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b0; // Reset flag
		                         end
		                     end
		                 end	             
                 end
             end
	         // Current x < dest and current y > dest ---------------------------------------------------------------------------------
	         else if (xLocation < xdest && yLocation > ydest)
	           begin
	             // Check corresponding queue length of EAST and SOUTH (productive paths)
	             // Choose shortest queue if both < `THRESHOLD, if equal pick randomly 
	             if (southFIFO < `THRESHOLD || eastFIFO < `THRESHOLD || ((xLocation == 0) && (yLocation == Y_NODES-1)))
	               begin
	                 if (southFIFO < eastFIFO)
	                   begin		 
	             		      outputPortRequest = 5'b00100;
		                   unproductive = 1'b0; // Reset flag
		                 end
		               else if (eastFIFO < southFIFO)
		                 begin		 
	             		      outputPortRequest = 5'b00010;
		                   unproductive = 1'b0; // Reset flag
		                 end
		               else // (southFIFO == eastFIFO)
		                 begin
		                   if (random[0] == 1)
		                     begin
		                       outputPortRequest = 5'b00100; // SOUTH
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b00010; // EAST
		                       unproductive = 1'b0; // Reset flag
		                     end
		                 end
		             end   
		           // Else both >= `THRESHOLD, choose shortest queue (keeping within network boundary)         
		           else if ((xLocation == 0) && (yLocation != Y_NODES-1))
		             begin
		               if (northFIFO < southFIFO && northFIFO < eastFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00001;
		                   unproductive = 1'b1;
		                 end	               
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (southFIFO < eastFIFO)
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (eastFIFO < southFIFO)
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b0; // Reset flag
		                         end
		                     end
		                 end
		             end  		             	             
               else if ((xLocation != 0) && (yLocation == Y_NODES-1))
                 begin
		               if ((westFIFO < southFIFO) && (westFIFO < eastFIFO) && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b01000;
		                   unproductive = 1'b1;
		                 end
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (southFIFO < eastFIFO)
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (eastFIFO < southFIFO)
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b0; // Reset flag
		                         end
		                     end
		                 end
		             end    	
               else // if (xLocation != 0 && yLocation != Y_NODES-1)
                 begin
                   if (northFIFO < southFIFO && northFIFO < eastFIFO && northFIFO < westFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00001;
		                   unproductive = 1'b1;
		                 end		             
                   else if (westFIFO < northFIFO && westFIFO < eastFIFO && westFIFO < southFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b01000;
		                   unproductive = 1'b1;
		                 end
                   else if (westFIFO < southFIFO && westFIFO < eastFIFO && westFIFO == northFIFO && (misroute > 0))
	                   begin
		                   if (random[0] == 1)
		                     begin
		                       outputPortRequest = 5'b00001; // NORTH
		                       unproductive = 1'b1; // Reset flag
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b01000; // WEST
		                       unproductive = 1'b1; // Reset flag
		                     end
		                 end	
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (southFIFO < eastFIFO)
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (eastFIFO < southFIFO)
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b0; // Reset flag
		                         end
		                     end
		                 end	             
                 end
             end        
	         // Current x > dest and current y < dest -----------------------------------------------------------------------------------
	         else if (xLocation > xdest && yLocation < ydest)
	           begin
	             // Check corresponding queue length of NORTH and WEST (productive paths)
	             // Choose shortest queue if both < `THRESHOLD, if equal pick randomly
	             if (northFIFO < `THRESHOLD || westFIFO < `THRESHOLD || (xLocation == X_NODES-1 && yLocation == 0))
	               begin
	                 if (northFIFO < westFIFO)
	                   begin
		                   outputPortRequest = 5'b00001;
		                   unproductive = 1'b0; // Reset flag
		                 end
	                 else if (westFIFO < northFIFO)
		                 begin
		                   outputPortRequest = 5'b01000;
		                   unproductive = 1'b0; // Reset flag
		                 end
		               else // (northFIFO == westFIFO)
		                 begin
		                   if (random[0] == 1)
		                     begin
		                       outputPortRequest = 5'b00001; // NORTH
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b01000; // WEST
		                       unproductive = 1'b0; // Reset flag
		                     end
		                 end
		             end
	             // Else both >= `THRESHOLD, choose shortest queue regardless of productive or unproductive (keeping within network boundary)          
		           else if (xLocation == X_NODES-1 && yLocation != 0)
		             begin
		               if (southFIFO < northFIFO && southFIFO < westFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00100;
		                   unproductive = 1'b1;
		                 end	               
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (northFIFO < westFIFO)
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (westFIFO < northFIFO)
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b0; // Reset flag
		                         end
		                     end
		                 end
		             end  		             	             
               else if (xLocation != X_NODES-1 && yLocation == 0)
                 begin
		               if (eastFIFO < northFIFO && eastFIFO < westFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00010;
		                   unproductive = 1'b1;
		                 end
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (northFIFO < westFIFO)
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (westFIFO < northFIFO)
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b0; // Reset flag
		                         end
		                     end
		                 end
		             end    	
               else // if (xLocation != X_NODES-1 && yLocation != 0)
                 begin
                   if (southFIFO < northFIFO && southFIFO < eastFIFO && southFIFO < westFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00100;
		                   unproductive = 1'b1;
		                 end		             
                   else if (eastFIFO < northFIFO && eastFIFO < westFIFO && eastFIFO < southFIFO && (misroute > 0))
	                   begin
		                   outputPortRequest = 5'b00010;
		                   unproductive = 1'b1;
		                 end
                   else if (eastFIFO < northFIFO && eastFIFO < westFIFO && eastFIFO == southFIFO && (misroute > 0))
	                   begin
		                   if (random[0] == 1)
		                     begin
		                       outputPortRequest = 5'b00010; // EAST
		                       unproductive = 1'b1; // Reset flag
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b00100; // SOUTH
		                       unproductive = 1'b1; // Reset flag
		                     end
		                 end	
		               else // No single unproductive path shortest for this boundary, equal to productive
		                 begin
		                   if (northFIFO < westFIFO)
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                   else if (westFIFO < northFIFO)
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
		                     end
		                   else
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b0; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b0; // Reset flag
		                         end
		                     end
		                 end	             
                 end
             end   
           // Check if current x equals destination  ----------------------------------------------------------------------------------
           else if (xLocation == xdest)
	           begin
	             if (yLocation < ydest)// ------------------------------------------------
		             begin
		               // Check corresponding queue length of NORTH (productive path)
	                 // Request NORTH if < `THRESHOLD
		               if (northFIFO < `THRESHOLD)
		                 begin
			                 outputPortRequest = 5'b00001;
			                 unproductive = 1'b0; // Reset flag
			               end
		               else if ((xLocation == 0) && (yLocation == 0))
                     begin
                       if (eastFIFO < northFIFO && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b1;
		                     end
                       else
                         begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
                         end
                     end           
		               else if ((xLocation == X_NODES-1) && (yLocation == 0))
		                 begin
		                   if (westFIFO < northFIFO && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b1;
		                     end	               
		                   else
		                     begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                 end 		             	             
                   else if ((xLocation > 0) && (xLocation < X_NODES-1) && (yLocation == 0))
                     begin
		                   if ((eastFIFO < northFIFO) && (eastFIFO < westFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b1;
		                     end
		                   else if ((westFIFO < northFIFO) && (westFIFO < eastFIFO) && (misroute > 0))
		                     begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b1;
		                     end
		                   else if ((westFIFO < northFIFO) && (westFIFO == eastFIFO) && (misroute > 0))
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                 end 	
                   else if ((xLocation == 0) && (yLocation != 0))
                     begin
                       if ((eastFIFO < northFIFO) && (eastFIFO < southFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b1;
		                     end		             
                       else if ((southFIFO < northFIFO) && (southFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b1;
		                     end
                       else if ((eastFIFO < northFIFO) && (eastFIFO == southFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00010; // EAST (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end	
		                   else
		                     begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
                   else if ((xLocation == X_NODES-1) && (yLocation != 0))
                     begin
                       if ((westFIFO < northFIFO) && (westFIFO < southFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b1;
		                     end		             
                       else if ((southFIFO < northFIFO) && (southFIFO < westFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b1;
		                     end
                       else if ((westFIFO < northFIFO) && (westFIFO == southFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b01000; // WEST (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
                   else // (boundary condition of the centre - all paths possible)
                     begin
                       if ((westFIFO < northFIFO) && (westFIFO < southFIFO) && (westFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b1;
		                     end
		                   else if ((eastFIFO < northFIFO) && (eastFIFO < westFIFO) && (eastFIFO < southFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b1;
		                     end  		             
                       else if ((southFIFO < northFIFO) && (southFIFO < westFIFO) && (southFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b1;
		                     end
                       else if ((eastFIFO < northFIFO) && (eastFIFO < westFIFO) && (eastFIFO == southFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00010; // EAST (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else if ((westFIFO < northFIFO) && (westFIFO < eastFIFO) && (westFIFO == southFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b01000; // WEST (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else if ((eastFIFO < northFIFO) && (eastFIFO < southFIFO) && (eastFIFO == westFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end			
		                   else
		                     begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
		             end
		           else if (yLocation > ydest) // --------------------------------------------------
		             begin
		               // Check corresponding queue length of SOUTH (productive path)
	                 // Request SOUTH if < `THRESHOLD
		               if (southFIFO < `THRESHOLD)
		                 begin
			                 outputPortRequest = 5'b00100;
			                 unproductive = 1'b0; // Reset flag
			               end
		               else if ((xLocation == X_NODES-1) && (yLocation == Y_NODES-1))
                     begin
                       if (westFIFO < southFIFO && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b1;
		                     end
                       else
                         begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
                         end
                     end           
		               else if ((xLocation == 0) && (yLocation == Y_NODES-1))
		                 begin
		                   if (eastFIFO < southFIFO && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b1;
		                     end	               
		                   else
		                     begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                 end 		             	             
                   else if ((xLocation > 0) && (xLocation < X_NODES-1) && (yLocation == Y_NODES-1))
                     begin
		                   if ((eastFIFO < southFIFO) && (eastFIFO < westFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b1;
		                     end
		                   else if ((westFIFO < southFIFO) && (westFIFO < eastFIFO) && (misroute > 0))
		                     begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b1;
		                     end
		                   else if ((westFIFO < southFIFO) && (westFIFO == eastFIFO) && (misroute > 0))
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                 end 	
                   else if ((xLocation == X_NODES-1) && (yLocation != Y_NODES-1))
                     begin
                       if ((westFIFO < southFIFO) && (westFIFO < northFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b1;
		                     end		             
                       else if ((northFIFO < southFIFO) && (southFIFO < westFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b1;
		                     end
                       else if ((westFIFO < southFIFO) && (westFIFO == northFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b01000; // WEST (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end	
		                   else
		                     begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
                   else if ((xLocation == 0) && (yLocation != Y_NODES-1))
                     begin
                       if ((eastFIFO < southFIFO) && (eastFIFO < northFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b1;
		                     end		             
                       else if ((northFIFO < southFIFO) && (northFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b1;
		                     end
                       else if ((eastFIFO < southFIFO) && (eastFIFO == northFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00010; // EAST (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
                   else // (boundary condition of the centre - all paths possible)
                     begin
                       if ((westFIFO < southFIFO) && (westFIFO < northFIFO) && (westFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b1;
		                     end
		                   else if ((eastFIFO < northFIFO) && (eastFIFO < westFIFO) && (eastFIFO < southFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b1;
		                     end  		             
                       else if ((northFIFO < southFIFO) && (northFIFO < westFIFO) && (northFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b1;
		                     end
                       else if ((eastFIFO < southFIFO) && (eastFIFO < westFIFO) && (eastFIFO == northFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00010; // EAST (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else if ((westFIFO < southFIFO) && (westFIFO < eastFIFO) && (westFIFO == northFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b01000; // WEST (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else if ((eastFIFO < northFIFO) && (eastFIFO < southFIFO) && (eastFIFO == westFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end		
		                   else
		                     begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
		             end   
	             else // Packet coordinates both equal to the current router location
		             begin
		               outputPortRequest = 5'b10000; // Local
		               unproductive = 1'b0; // Reset flag
		             end
	           end              
           // Check if current y equals destination  ----------------------------------------------------------------------------------
           else if (yLocation == ydest)
	           begin
	             // Check corresponding queue length of EAST (productive path)
	             // Request EAST if < `THRESHOLD
	             if (xLocation < xdest) // -------------------------------------------------
		             begin
		               if (eastFIFO < `THRESHOLD)
		                 begin
			                 outputPortRequest = 5'b00010;
			                 unproductive = 1'b0; // Reset flag
			               end
		               else if ((xLocation == 0) && (yLocation == Y_NODES-1))
                     begin
                       if (eastFIFO < southFIFO && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b1;
		                     end
                       else
                         begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
                         end
                     end           
		               else if ((xLocation == 0) && (yLocation == 0))
		                 begin
		                   if (northFIFO < eastFIFO && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b1;
		                     end	               
		                   else
		                     begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                 end 		             	             
                   else if ((yLocation > 0) && (yLocation < Y_NODES-1) && (xLocation == 0))
                     begin
		                   if ((southFIFO < northFIFO) && (southFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b1;
		                     end
		                   else if ((northFIFO < southFIFO) && (northFIFO < eastFIFO) && (misroute > 0))
		                     begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b1;
		                     end
		                   else if ((northFIFO < eastFIFO) && (northFIFO == southFIFO) && (misroute > 0))
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                 end 	
                   else if ((yLocation == Y_NODES-1) && (xLocation != 0))
                     begin
                       if ((southFIFO < eastFIFO) && (southFIFO < westFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b1;
		                     end		             
                       else if ((westFIFO < eastFIFO) && (westFIFO < southFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b1;
		                     end
                       else if ((southFIFO < eastFIFO) && (southFIFO == westFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end	
		                   else
		                     begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
                   else if ((yLocation == 0) && (xLocation != 0))
                     begin
                       if ((northFIFO < eastFIFO) && (northFIFO < westFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b1;
		                     end		             
                       else if ((westFIFO < eastFIFO) && (westFIFO < northFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b1;
		                     end
                       else if ((northFIFO < eastFIFO) && (northFIFO == westFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end	
		                   else
		                     begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
                   else // (boundary condition of the centre - all paths possible)
                     begin
                       if ((northFIFO < eastFIFO) && (northFIFO < southFIFO) && (northFIFO < westFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b1;
		                     end
		                   else if ((southFIFO < northFIFO) && (southFIFO < westFIFO) && (southFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b1;
		                     end  		             
                       else if ((westFIFO < northFIFO) && (westFIFO < southFIFO) && (westFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b1;
		                     end
                       else if ((northFIFO < eastFIFO) && (northFIFO < westFIFO) && (northFIFO == southFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else if ((northFIFO < eastFIFO) && (northFIFO < southFIFO) && (northFIFO == westFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else if ((southFIFO < eastFIFO) && (southFIFO < northFIFO) && (southFIFO == westFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b01000; // WEST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end			
		                   else
		                     begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
		             end
	             else if (xLocation > xdest) // -------------------------------------------------------
	               begin
	                 // Check corresponding queue length of WEST (productive path)
	                 // Request WEST if < `THRESHOLD
		               if (westFIFO < `THRESHOLD)
		                 begin
			                 outputPortRequest = 5'b01000;
			                 unproductive = 1'b0; // Reset flag
			               end
		               else if ((xLocation == X_NODES-1) && (yLocation == 0))
                     begin
                       if (northFIFO < westFIFO && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b1;
		                     end
                       else
                         begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
                         end
                     end           
		               else if ((xLocation == X_NODES-1) && (yLocation == Y_NODES-1))
		                 begin
		                   if (southFIFO < westFIFO && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b1;
		                     end	               
		                   else
		                     begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                 end 		             	             
                   else if ((yLocation > 0) && (yLocation < Y_NODES-1) && (xLocation == X_NODES-1))
                     begin
		                   if ((northFIFO < westFIFO) && (northFIFO < southFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b1;
		                     end
		                   else if ((southFIFO < westFIFO) && (southFIFO < northFIFO) && (misroute > 0))
		                     begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b1;
		                     end
		                   else if ((southFIFO < westFIFO) && (southFIFO == northFIFO) && (misroute > 0))
		                     begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else
		                     begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
		                     end 
		                 end 	
                   else if ((yLocation == 0) && (xLocation != X_NODES-1))
                     begin
                       if ((northFIFO < westFIFO) && (northFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b1;
		                     end		             
                       else if ((eastFIFO < westFIFO) && (eastFIFO < northFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b1;
		                     end
                       else if ((northFIFO < westFIFO) && (northFIFO == eastFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end	
		                   else
		                     begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
                   else if ((yLocation == Y_NODES-1) && (xLocation != X_NODES-1))
                     begin
                       if ((southFIFO < westFIFO) && (southFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b1;
		                     end		             
                       else if ((eastFIFO < westFIFO) && (eastFIFO < southFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b1;
		                     end
                       else if ((southFIFO < westFIFO) && (southFIFO == eastFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end	
		                   else
		                     begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
                   else // (boundary condition of the centre - all paths possible)
                     begin
                       if ((northFIFO < westFIFO) && (northFIFO < eastFIFO) && (northFIFO < southFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00001;
		                       unproductive = 1'b1;
		                     end
		                   else if ((southFIFO < northFIFO) && (southFIFO < westFIFO) && (southFIFO < eastFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00100;
		                       unproductive = 1'b1;
		                     end  		             
                       else if ((eastFIFO < southFIFO) && (eastFIFO < westFIFO) && (eastFIFO < northFIFO) && (misroute > 0))
	                       begin
		                       outputPortRequest = 5'b00010;
		                       unproductive = 1'b1;
		                     end
                       else if ((northFIFO < eastFIFO) && (northFIFO < westFIFO) && (northFIFO == southFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else if ((northFIFO < southFIFO) && (northFIFO < westFIFO) && (northFIFO == eastFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00001; // NORTH (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end
		                   else if ((southFIFO < northFIFO) && (southFIFO < westFIFO) && (southFIFO == eastFIFO) && (misroute > 0))
	                       begin
		                       if (random[0] == 1)
		                         begin
		                           outputPortRequest = 5'b00100; // SOUTH (MORE PRODUCTIVE AS PERPENDICULAR)
		                           unproductive = 1'b1; // Reset flag
		                         end
		                       else
		                         begin
		                           outputPortRequest = 5'b00010; // EAST
		                           unproductive = 1'b1; // Reset flag
		                         end
		                     end			
		                   else
		                     begin
		                       outputPortRequest = 5'b01000;
		                       unproductive = 1'b0; // Reset flag
		                     end	             
                     end
		             end   
	             else // Packet coordinates both equal to the current router location
		             begin
		               outputPortRequest = 5'b10000; // Local
		               unproductive = 1'b0; // Reset flag
		             end
	           end
	       end
	     else // FIFO empty
	       begin
	         outputPortRequest = 5'b00000; //FIFO reading from is empty
	         unproductive = 1'b0; // Reset flag
	       end
	   end

 `endif
 
endmodule
