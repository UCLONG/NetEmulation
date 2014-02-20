// --------------------------------------------------------------------------------------------------------------------
// IP Block    : ENoC
// Description : Declares Functions used in the Electrical Network on Chip.
// Functions   : log2(input int n); - calculates the number of bits required to represent an integer as binary
// --------------------------------------------------------------------------------------------------------------------

function integer log2(input int n);
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