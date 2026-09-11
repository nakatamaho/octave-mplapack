% Construct the declared ordinary reference without replacing measured outputs.
function result = net_case_reference (entry, bits1, bits2)
  if (nargin != 3 || ! isstruct (entry) || bits1 != fix (bits1) ...
      || bits2 != fix (bits2) || bits1 < 64 || bits2 < bits1)
    error ("mplapack:neigt:Reference", "invalid ordinary reference arguments");
  endif
  id = entry.id;
  p = entry.parameters;
  if (any (strcmp (id, {"OO53_REAL", "OO53_PAIR", "OO128_CLOSE"})))
    generator = net_oo_generator (id, p.n);
    values = generator.realized_spectrum;
    result = struct ("status", "exact_realized_generation", ...
      "values", values, "source", generator.source, ...
      "reference_bits", generator.generation_bits);
  elseif (strncmp (id, "SIM_", 4))
    gap = 0;
    if (isfield (p, "gap_exponent"))
      gap = p.gap_exponent;
    endif
    fixture = net_similarity_model (lower (p.regime), p.n, gap, bits2);
    result = struct ("status", "exact_J_diagonal", "values", diag (fixture.J), ...
      "source", fixture.source, "reference_bits", bits2);
  elseif (strcmp (id, "TOEPLITZ") || strcmp (id, "TOEPLITZ_SYM"))
    ref = net_toeplitz_reference (p.n, p.b, bits2);
    result = struct ("status", ref.reference_status, "values", ref.eigenvalues, ...
      "source", ref.source, "reference_bits", bits2, ...
      "condition_numbers", ref.condition_numbers);
  elseif (strncmp (id, "FORSYTHE", 8))
    if (strcmp (p.representation, "zero_limit"))
      values = mp (ones (p.n, 1));
      result = struct ("status", "exact_defective_zero_limit", ...
        "values", values, "source", "S4_ZERO_LIMIT_REFERENCE", ...
        "reference_bits", bits2);
    else
      ref = net_forsythe_reference (p.n, p.a, bits2);
      result = struct ("status", ref.reference_status, "values", ref.eigenvalues, ...
        "source", ref.source, "reference_bits", bits2, ...
        "unit_roots", ref.unit_roots, "radius", ref.radius);
    endif
  elseif (strcmp (id, "HAD_BIDIAG") || strcmp (id, "HAD_COMPLEX"))
    ref = net_hadamard_reference (p.n, p.s, bits2);
    result = struct ("status", ref.reference_status, "values", ref.eigenvalues, ...
      "source", ref.source, "reference_bits", bits2, ...
      "condition_numbers", ref.condition_numbers);
  elseif (strcmp (id, "FRANK0") || strcmp (id, "FRANK1"))
    ref = net_frank_reference (p.n, bits2);
    result = struct ("status", ref.reference_status, "values", ref.eigenvalues, ...
      "source", ref.source, "reference_bits", bits2, ...
      "reference_auxiliary_bits", bits1);
  elseif (strcmp (id, "WILKINSON"))
    ref = net_wilkinson_reference (p.n, bits2);
    result = struct ("status", ref.reference_status, "values", ref.roots, ...
      "source", ref.source, "reference_bits", ref.reference_bits, ...
      "horner_exact_zero", ref.horner_exact_zero);
  elseif (strcmp (id, "GRCAR"))
    model = net_grcar_model (p.n, p.upper_bandwidth, bits2);
    ref = net_grcar_reference (model, bits1, bits2);
    result = struct ("status", ref.reference_status, "values", ref.values2, ...
      "source", ref.source, "reference_bits", bits2, ...
      "reference_agreement", ref.agreement);
  elseif (strcmp (id, "MKS"))
    model = net_mks_model (p.n, p.m, net_dyadic_parameter (p.delta, bits2), bits2);
    ref = net_mks_reference (model, bits1, bits2);
    result = struct ("status", ref.reference_status, "values", ref.values2, ...
      "source", ref.source, "reference_bits", bits2, "gcd", ref.gcd, ...
      "reference_agreement", ref.nonzero_agreement);
  elseif (strcmp (id, "MARKOV"))
    model = net_markov_model (p.n, p.epsilon_exponent, bits2);
    ref = net_markov_reference (model, bits1, bits2, false);
    result = struct ("status", ref.reference_status, "values", ref.values2, ...
      "source", ref.source, "reference_bits", bits2, ...
      "stationary_formula", ref.stationary_formula, ...
      "stationary_independent", ref.stationary_independent);
  elseif (strcmp (id, "PERRON_POS"))
    model = net_perron_model (p.n, p.epsilon_exponent, bits2);
    ref = net_markov_reference (model.markov, bits1, bits2, true);
    result = struct ("status", ref.reference_status, "values", ref.values2, ...
      "source", ref.source, "reference_bits", bits2);
  else
    error ("mplapack:neigt:Reference", "unsupported ordinary case %s", id);
  endif
endfunction
