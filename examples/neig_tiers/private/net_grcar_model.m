% Exact Grcar integer matrix from the declared Hessenberg definition.
function result = net_grcar_model (n, upper_bandwidth, bits)
  if (nargin != 3 || n != fix (n) || n < 1 ...
      || upper_bandwidth != fix (upper_bandwidth) || upper_bandwidth < 0 ...
      || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:Grcar", "invalid Grcar arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    A = mp (zeros (n, n));
    for i = 1:n
      for j = 1:n
        if (j >= i && j - i <= upper_bandwidth)
          A(i, j) = mp (1);
        elseif (i - j == 1)
          A(i, j) = mp (-1);
        endif
      endfor
    endfor
    result = struct ("family", "grcar", "n", n, ...
      "upper_bandwidth", upper_bandwidth, "bits", bits, "A_model", A, ...
      "A_frozen", A, "native_A", double (A), "input_status", "exact_model", ...
      "source", "A4_GRCAR_EXACT_INTEGER_HESSENBERG");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
