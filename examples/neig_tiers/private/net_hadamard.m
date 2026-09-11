% Construct the Sylvester Hadamard matrix exactly.
function H = net_hadamard (n, bits)
  if (nargin != 2 || ! isnumeric (n) || ! isscalar (n) ...
      || n != fix (n) || n < 1 || ! isnumeric (bits) ...
      || bits != fix (bits) || bits < 1)
    error ("mplapack:neigt:Hadamard", "invalid Hadamard arguments");
  endif
  power = 1;
  while (power < n)
    power *= 2;
  endwhile
  if (power != n)
    error ("mplapack:neigt:Hadamard", "n must be a power of two");
  endif
  H_native = 1;
  while (rows (H_native) < n)
    H_native = [H_native, H_native; H_native, -H_native];
  endwhile
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    H = mp (H_native);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
