// Define the log to base 2 function 
 	function automatic integer log2;
	 input [31:0] value;
	 for (log2=0; value>0; log2=log2+1)
	   value = value>>1;
	 log2=log2-1;
	endfunction