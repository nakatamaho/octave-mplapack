% A2 explicit Frank orientations from their defining formulas.
function result = net_frank_model (n, orientation, bits)
  if (nargin != 3 || n != fix (n) || n < 2 ...
      || ! any (orientation == [0, 1]))
    error ("mplapack:neigt:Frank", "invalid Frank model arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    F0 = mp (zeros (n, n));
    for i = 1:n
      for j = 1:n
        if (j >= i - 1)
          F0(i, j) = mp (n + 1 - max (i, j));
        endif
      endfor
    endfor
    reversal = mp (zeros (n, n));
    for i = 1:n
      reversal(i, n - i + 1) = mp (1);
    endfor
    F1 = reversal * ctranspose (F0) * reversal;
    if (orientation == 0)
      A = F0;
    else
      A = F1;
    endif
    result = struct ("family", "frank", "orientation", orientation, ...
      "n", n, "bits", bits, "A", A, "F0", F0, "F1", F1, ...
      "reversal", reversal, "source", "A2_EXPLICIT_FRANK_ORIENTATIONS", ...
      "status", "MEASURED");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
