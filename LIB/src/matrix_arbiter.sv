`timescale 10ps/1ps

module arbiter(clk,ce,r,g,rst);
parameter n = 4;
  
  input logic clk;
  input logic [n-1:0]r;
  input logic rst;
  input logic ce;
  output logic [n-1:0]g;
  
 logic [n-1:0]gany;
 logic [n-1:0]dis;
 logic [n-1:0][n-1:0] w ;
 logic [n-1:0][n-1:0] k;

//initial begin
 //  for(int i=0; i<n; i++)
 //  for(int j=0; j<n; j++)
 //  if(i<=j) w[i][j]<=1'b1;
 //  else w[i][j]<=1'b0;
     //dis <= 4'b0000;
 //    r <= 4'b0000;
 //  end 
   
   
always_comb begin
  
 for(int i=0; i<n; i++)begin
 for(int j=0; j<n; j++)
 if(i!=j)
  k[j][i] = w[i][j] && r[i];
else
  k[j][i] = 0;
end
 
 for(int i=0; i<n; i++)begin
 dis[i] = |k[i];
 end
//dis[0] = k[1][0] || k[2][0] || k[3][0];
//dis[1] = k[0][1] || k[2][1] || k[3][1];
//dis[2] = k[0][2] || k[1][2] || k[3][2];
//dis[3] = k[0][3] || k[1][3] || k[2][3];
   
   for(int i=0; i<n; i++)begin
   for(int j=0; j<n; j++)
     if(i!=j) ;
   else begin
   gany[i] = r[i] && (~dis[i]);
 end
  end
   
end
     
         
 always_ff @(posedge clk) begin
   if(rst) begin
     for(int i=0; i<n; i++)
      for(int j=0; j<n; j++)
      if(i<=j) w[i][j]<=1'b1;
      else w[i][j]<=1'b0;
      end
    else begin   
   for(int i=0; i<n; i++)
   for(int j=0; j<n; j++)
   if(i!=j) begin
      w[i][j] <= (w[i][j] || gany[j] ) && (~gany[i]);
     end
  end
  //g <= gany;
 end
  
   always_comb g = gany;  
  
endmodule
