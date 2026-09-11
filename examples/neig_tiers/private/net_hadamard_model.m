% A1 Hadamard-similar upper bidiagonal model.
function result = net_hadamard_model (n, s, bits)
  if (nargin != 3 || n != fix (n) || n < 2 || s != fix (s) || s < 1)
    error ("mplapack:neigt:Hadamard", "invalid Hadamard model arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    H = net_hadamard (n, bits);
    T = mp (zeros (n, n));
    for i = 1:n
      T(i, i) = mp (i);
      if (i < n)
        T(i, i + 1) = mp (s);
      endif
    endfor
    [HT, ht_metadata] = net_exact_product_dyadic (H, T, bits);
    [HTH, hth_metadata] = net_exact_product_dyadic (HT, ctranspose (H), bits);
    A = HTH / mp (n);
    result = struct ("family", "hadamard_bidiag", "n", n, "s", s, ...
      "bits", bits, "H", H, "T", T, "A", A, ...
      "product_metadata", {{ht_metadata, hth_metadata}}, ...
      "spectrum_reference", mp (transpose (1:n)), ...
      "source", "A1_HADAMARD_SIMILAR_UPPER_BIDIAG", "status", "MEASURED");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
