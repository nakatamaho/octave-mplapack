% Construct one fixed exact S2 similarity model and its frozen work input.
function result = net_similarity_model (regime, n, gap_exponent, bits)
  if (nargin < 4)
    error ("mplapack:neigt:Similarity", "regime, n, gap, and bits are required");
  endif
  if (! ischar (regime) || ! any (strcmp (regime, ...
                                         {"simple", "semisimple", ...
                                          "jordan", "two_jordan"})))
    error ("mplapack:neigt:Similarity", "unsupported S2 regime");
  endif
  if (n < 4 || n != fix (n) || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:Similarity", "invalid S2 dimensions or precision");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    pair = net_exact_similarity (n, bits);
    J = mp (zeros (n, n));
    gap = mp (0);
    if (strcmp (regime, "simple") || strcmp (regime, "two_jordan"))
      gap = net_pow2 (-gap_exponent, bits);
    endif
    if (strcmp (regime, "simple") || strcmp (regime, "jordan") ...
        || strcmp (regime, "two_jordan"))
      J(1, 2) = mp (1);
    endif
    J(1, 1) = mp (1);
    if (strcmp (regime, "simple"))
      J(2, 2) = mp (1);
    else
      J(2, 2) = mp (1) + gap;
    endif
    start = 3;
    if (strcmp (regime, "two_jordan"))
      J(2, 2) = mp (1);
      J(2, 1) = mp (0);
      J(2, 3) = mp (0);
      J(3, 3) = mp (1) + gap;
      J(3, 4) = mp (1);
      J(4, 4) = mp (1) + gap;
      start = 5;
    endif
    for index = start:n
      J(index, index) = mp (index - start + 4);
    endfor
    if (strcmp (regime, "semisimple"))
      J(1, 2) = mp (0);
    endif
    A_model = pair.Y * J * pair.X;
    guard_yj = net_product_guard (pair.Y, J, bits);
    guard_jx = net_product_guard (pair.Y * J, pair.X, bits);
    guard = max ([pair.product_guard_bits, guard_yj, guard_jx]);
    if (bits < guard)
      error ("mplapack:neigt:Guard", ...
             "S2 model precision is below its exact product guard");
    endif
    % This is one rounding of the already constructed exact model.
    native_A = double (A_model);
    frozen = A_model;
    result = struct ("family", "similarity", "regime", regime, "n", n, ...
                     "gap_exponent", gap_exponent, "gap", gap, ...
                     "similarity", pair, "J", J, "A_model", A_model, ...
                     "A_frozen", frozen, "native_A", native_A, ...
                     "generation_bits", bits, "model_guard_bits", guard, ...
                     "input_status", "exact_model", ...
                     "source", "SIM_EXACT_INTEGER", ...
                     "model_products_exact", true);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
