% Build the fixed NEIGT VA1 source models without using a trusted factor.
function result = net_v_a1_model (regime, n, bits)
  regime = char (regime);
  if (n != 4 || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:VA1", "invalid fixed VA1 model dimensions");
  endif
  pair = net_exact_similarity (n, bits);
  J = mp (zeros (n, n));
  if (strcmp (regime, "real_simple") || strcmp (regime, "complex_simple"))
    diagonal = [1, 2, 4, 8];
    for index = 1:n
      J(index,index) = mp (diagonal(index));
    endfor
  elseif (strcmp (regime, "defective_block"))
    J(1,1) = mp (1);
    J(1,2) = mp (1);
    J(2,2) = mp (1);
    J(3,3) = mp (4);
    J(4,4) = mp (8);
  else
    error ("mplapack:neigt:VA1", "unsupported fixed VA1 regime %s", regime);
  endif
  A_real = pair.Y * J * pair.X;
  if (strcmp (regime, "real_simple") || strcmp (regime, "defective_block"))
    A = A_real;
  elseif (strcmp (regime, "complex_simple"))
    Z = mp (eye (n));
    Z(1,1) = net_mp_complex (mp (1), mp (0));
    Z(2,2) = net_mp_complex (mp (0), mp (1));
    Z(3,3) = net_mp_complex (mp (-1), mp (0));
    Z(4,4) = net_mp_complex (mp (0), mp (-1));
    A = Z * A_real * ctranspose (Z);
  endif
  if (strcmp (regime, "real_simple"))
    result = struct ("family", "exact_similarity", "n", n, ...
      "A_model", A, "A_frozen", A, "source", ...
      "VA1_REAL_SIMPLE_EXACT_SIMILARITY", "input_status", "exact_model");
  elseif (strcmp (regime, "complex_simple"))
    result = struct ("family", "exact_similarity", "n", n, ...
      "A_model", A, "A_frozen", A, "source", ...
      "VA1_COMPLEX_PHASED_REAL_SIMPLE_EXACT_SIMILARITY", ...
      "input_status", "exact_model");
  elseif (strcmp (regime, "defective_block"))
    result = struct ("family", "exact_similarity", "n", n, ...
      "A_model", A, "A_frozen", A, "source", ...
      "VA1_DEFECTIVE_BLOCK_EXACT_SIMILARITY", "input_status", "exact_model");
  endif
endfunction
