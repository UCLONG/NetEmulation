// Define the log to base 2 function 
 	function automatic integer log2;
	 input [31:0] value;
	 for (log2=0; value>0; log2=log2+1)
	   value = value>>1;
	 log2=log2-1;
	endfunction
  
  
  
// Define the log to base 2 function, which rounds up the result
  function automatic integer log2AndRoundUp;
	 input [31:0] value;
   logic [4:0] numberOfOnes;
   
   numberOfOnes = 0;
	 
   if (value == 1)
    log2AndRoundUp = 0;
    
   else begin
    for (log2AndRoundUp=0; value>0; log2AndRoundUp=log2AndRoundUp+1) begin
      if (value[31] == 1)
          numberOfOnes++;
      value = value>>1;
      end
    if (numberOfOnes == 1)  
   /*log2(x) is an integer only if x has only one digit 1 in its binary notation, with the exception of number 1*/
    log2AndRoundUp=log2AndRoundUp-1;
   end
 
	endfunction