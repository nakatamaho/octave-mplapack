% Exact finite-pencil fixtures from CASES.md Section 11.
function result = net_v_a2_model (regime, n, bits)
  regime = char (regime);
  if (n != 6 || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:VA2", "invalid fixed VA2 model dimensions");
  endif
  pair = net_exact_similarity (n, bits);
  J = mp (zeros (n, n));
  if (strcmp (regime, "real_simple"))
    for i = 1:n
      J(i,i) = mp (i);
    endfor
  elseif (strcmp (regime, "complex_simple"))
    J(1,1) = mp (1);
    J(1,2) = mp ("0.5");
    J(2,1) = mp ("-0.5");
    J(2,2) = mp (1);
    for i = 3:n
      J(i,i) = mp (i);
    endfor
  elseif (strcmp (regime, "defective_cluster"))
    J(1,1) = mp (1);
    J(1,2) = mp (1);
    J(2,2) = mp (1);
    for i = 3:n
      J(i,i) = mp (i + 1);
    endfor
  else
    error ("mplapack:neigt:VA2", "unsupported fixed VA2 regime %s", regime);
  endif
  C_real = pair.Y * J * pair.X;
  B_real = mp (eye (n)) + pair.N;
  if (strcmp (regime, "complex_simple"))
    Z = phase_matrix (n);
    C = Z * C_real * ctranspose (Z);
    B = Z * B_real * ctranspose (Z);
  else
    C = C_real;
    B = B_real;
  endif
  A = B * C;
  if (strcmp (regime, "real_simple"))
    source = "VA2_REAL_SIMPLE_EXACT_SOLVE_REDUCTION";
  elseif (strcmp (regime, "complex_simple"))
    source = "VA2_COMPLEX_SIMPLE_EXACT_SOLVE_REDUCTION";
  else
    source = "VA2_DEFECTIVE_CLUSTER_EXACT_SOLVE_REDUCTION";
  endif
  result = struct ("family", "finite_pencil", "n", n, "A_model", A, ...
    "A_frozen", A, "B_model", B, "B_frozen", B, "C_model", C, ...
    "C_frozen", C, "input_status", "exact_model", "source", source);
endfunction

function result = phase_matrix (n)
  result = mp (eye (n));
  values = mp (zeros (n, 1));
  values(1) = net_mp_complex (mp (1), mp (0));
  values(2) = net_mp_complex (mp (0), mp (1));
  values(3) = net_mp_complex (mp (-1), mp (0));
  values(4) = net_mp_complex (mp (0), mp (-1));
  values(5) = net_mp_complex (mp (1), mp (0));
  values(6) = net_mp_complex (mp (0), mp (1));
  for i = 1:n
    result(i,i) = values(i);
  endfor
endfunction
