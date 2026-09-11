% Build the fixed NEIGT VA1 source models without using a trusted factor.
function result = net_v_a1_model (regime, n, bits)
  regime = char (regime);
  if (n != 4 || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:VA1", "invalid fixed VA1 model dimensions");
  endif
  if (strcmp (regime, "real_simple"))
    pair = net_exact_similarity (n, bits);
    J = mp (zeros (n, n));
    diagonal = [1, 2, 4, 5];
    for index = 1:n
      J(index,index) = mp (diagonal(index));
    endfor
    A = pair.Y * J * pair.X;
    result = struct ("family", "exact_similarity", "n", n, ...
      "A_model", A, "A_frozen", A, "source", ...
      "VA1_REAL_SIMPLE_EXACT_SIMILARITY", "input_status", "exact_model");
  elseif (strcmp (regime, "complex_simple"))
    entry = struct ("id", "HAD_COMPLEX", "tier", "V", ...
      "parameters", struct ("n", n, "s", 2, ...
                             "phases", "quarter_turn_repeated"));
    result = net_case_model (entry, bits);
  elseif (strcmp (regime, "defective_block"))
    entry = struct ("id", "SIM_JORDAN", "tier", "V", ...
      "parameters", struct ("n", n, "gap_exponent", 0, ...
                             "regime", "jordan"));
    result = net_case_model (entry, bits);
  else
    error ("mplapack:neigt:VA1", "unsupported fixed VA1 regime %s", regime);
  endif
endfunction
