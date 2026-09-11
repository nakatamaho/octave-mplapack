% S3 tridiagonal Toeplitz and directly constructed symmetric control.
function result = net_toeplitz_model (n, b, representation, bits)
  if (nargin != 4 || ! isnumeric (n) || ! isscalar (n) || n != fix (n) ...
      || n < 2 || ! isnumeric (b) || ! isscalar (b) || b != fix (b) ...
      || b < 1 || ! ischar (representation) ...
      || ! any (strcmp (representation, {"original", "explicitly_symmetric"})))
    error ("mplapack:neigt:Toeplitz", "invalid Toeplitz arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    A_original = mp (zeros (n, n));
    B_symmetric = mp (zeros (n, n));
    upper_A = net_pow2 (-2 * b, bits);
    offdiag_B = net_pow2 (-b, bits);
    for i = 1:n
      A_original(i, i) = mp (3);
      B_symmetric(i, i) = mp (3);
      if (i < n)
        A_original(i, i + 1) = upper_A;
        A_original(i + 1, i) = mp (1);
        B_symmetric(i, i + 1) = offdiag_B;
        B_symmetric(i + 1, i) = offdiag_B;
      endif
    endfor
    D = mp (zeros (n, n));
    for i = 1:n
      D(i, i) = net_pow2 (b * (i - 1), bits);
    endfor
    [left_relation, left_metadata] = ...
      net_exact_product_dyadic (A_original, D, bits);
    [right_relation, right_metadata] = ...
      net_exact_product_dyadic (D, B_symmetric, bits);
    relation_exact = (left_relation == right_relation);
    if (! relation_exact)
      error ("mplapack:neigt:Toeplitz", "A*D=D*B exact relation failed");
    endif
    if (strcmp (representation, "original"))
      A = A_original;
    else
      A = B_symmetric;
    endif
    result = struct (...
      "family", "toeplitz", "representation", representation, "n", n, ...
      "b", b, "bits", bits, "A", A, "A_original", A_original, ...
      "B_symmetric", B_symmetric, "D", D, ...
      "relation_exact", relation_exact, ...
      "relation_metadata", {{left_metadata, right_metadata}}, ...
      "source", "S3_DIRECT_TRIDIAGONAL_AND_SYMMETRIC", ...
      "status", "MEASURED");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
