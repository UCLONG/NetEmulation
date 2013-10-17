module testtest;
  
int randomnumber;
int seed;
  
initial
  begin
    seed = 10;
    forever
    begin
      #100ps
      randomnumber = $dist_uniform(seed, 0, 10);
    end
  end
  
endmodule