% Build and independently verify the common exact integer similarity pair.
function result = net_exact_similarity (n, bits)
  if (nargin != 2 || ! isnumeric (n) || n != fix (n) ...
      || n < 2 || ! isnumeric (bits) || bits != fix (bits) || bits < 1)
    error ("mplapack:neigt:Similarity", "invalid similarity arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    N = mp (zeros (n, n));
    for index = 1:(n - 1)
      N(index, index + 1) = mp (1);
    endfor
    identity = mp (eye (n));
    L = identity + ctranspose (N);
    U = identity + N;
    X = L * U;
    Uinv = net_triangular_inverse (U, bits);
    Linv = net_triangular_inverse (L, bits);
    Y = Uinv * Linv;
    product_guard = max (net_product_guard (L, U, bits), ...
                         net_product_guard (Uinv, Linv, bits));
    check_bits = max ([bits, product_guard]);
    old_check_bits = mpbits ();
    mpbits (check_bits);
    identity_check = mp (eye (n));
    xy = X * Y;
    yx = Y * X;
    xy_error = norm (xy - identity_check, "fro");
    yx_error = norm (yx - identity_check, "fro");
    exact = (xy_error == mp (0) && yx_error == mp (0));
    mpbits (old_check_bits);
    if (! exact)
      error ("mplapack:neigt:Exactness", ...
             "integer similarity inverse products were not exact");
    endif
    result = struct ("n", n, "bits", bits, "N", N, "L", L, "U", U, ...
                     "X", X, "Y", Y, "Uinv", Uinv, "Linv", Linv, ...
                     "product_guard_bits", product_guard, ...
                     "xy_error", xy_error, "yx_error", yx_error, ...
                     "exact", true, "source", "SIM_EXACT_INTEGER");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
