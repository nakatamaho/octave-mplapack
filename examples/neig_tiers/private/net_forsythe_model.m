% S4 Forsythe original, explicitly scaled, and zero-limit models.
function result = net_forsythe_model (n, a, representation, bits)
  if (nargin != 4 || ! isnumeric (n) || ! isscalar (n) || n != fix (n) ...
      || n < 3 || ! isnumeric (a) || ! isscalar (a) || a != fix (a) ...
      || a < 1 || ! ischar (representation) ...
      || ! any (strcmp (representation, {"original", "explicitly_scaled", ...
                                         "zero_limit"})))
    error ("mplapack:neigt:Forsythe", "invalid Forsythe arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    radius = net_pow2 (-a, bits);
    epsilon = net_pow2 (-a * n, bits);
    N = mp (zeros (n, n));
    for i = 1:(n - 1)
      N(i, i + 1) = mp (1);
    endfor
    P = N;
    P(n, 1) = mp (1);
    original = mp (eye (n)) + N;
    original(n, 1) = epsilon;
    scaled = mp (eye (n)) + radius * P;
    scaling = mp (zeros (n, n));
    for i = 1:n
      scaling(i, i) = net_pow2 (-a * (i - 1), bits);
    endfor
    [left_relation, left_metadata] = ...
      net_exact_product_dyadic (original, scaling, bits);
    [right_relation, right_metadata] = ...
      net_exact_product_dyadic (scaling, scaled, bits);
    relation_exact = (left_relation == right_relation);
    if (! relation_exact)
      error ("mplapack:neigt:Forsythe", "F*D=D*F_scaled exact relation failed");
    endif
    if (strcmp (representation, "original"))
      A = original;
    elseif (strcmp (representation, "explicitly_scaled"))
      A = scaled;
    else
      A = mp (eye (n)) + N;
      epsilon = mp (0);
    endif
    result = struct (...
      "family", "forsythe", "representation", representation, "n", n, ...
      "a", a, "bits", bits, "radius", radius, "epsilon", epsilon, ...
      "N", N, "P", P, "original", original, "scaled", scaled, ...
      "scaling", scaling, "A", A, "relation_exact", relation_exact, ...
      "relation_metadata", {{left_metadata, right_metadata}}, ...
      "source", "S4_FORSYTHE_SPLIT_SCALED_ZERO", "status", "MEASURED");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
