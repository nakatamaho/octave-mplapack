% Build one ordinary NEIGT case at the requested mathematical work precision.
function result = net_case_model (entry, bits)
  if (nargin != 2 || ! isstruct (entry) || ! isfield (entry, "id") ...
      || ! isfield (entry, "parameters") || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:Case", "invalid ordinary case entry");
  endif
  id = entry.id;
  p = entry.parameters;
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    if (any (strcmp (id, {"OO53_REAL", "OO53_PAIR", "OO128_CLOSE"})))
      generator = net_oo_generator (id, p.n);
      A_model = generator.A;
      A_frozen = net_widen (A_model, bits, generator.generation_bits);
      source = generator.source;
      input_status = "fixed_generation_then_exact_widening";
    elseif (strncmp (id, "SIM_", 4))
      gap = 0;
      if (isfield (p, "gap_exponent"))
        gap = p.gap_exponent;
      endif
      fixture = net_similarity_model (lower (p.regime), p.n, gap, bits);
      A_model = fixture.A_model;
      A_frozen = fixture.A_frozen;
      source = fixture.source;
      input_status = fixture.input_status;
    elseif (strcmp (id, "TOEPLITZ") || strcmp (id, "TOEPLITZ_SYM"))
      fixture = net_toeplitz_model (p.n, p.b, p.representation, bits);
      A_model = fixture.A;
      A_frozen = fixture.A;
      source = fixture.source;
      input_status = "exact_model";
    elseif (strncmp (id, "FORSYTHE", 8))
      fixture = net_forsythe_model (p.n, p.a, p.representation, bits);
      A_model = fixture.A;
      A_frozen = fixture.A;
      source = fixture.source;
      input_status = "exact_model";
    elseif (strcmp (id, "HAD_BIDIAG"))
      fixture = net_hadamard_model (p.n, p.s, bits);
      A_model = fixture.A;
      A_frozen = fixture.A;
      source = fixture.source;
      input_status = "exact_model";
    elseif (strcmp (id, "FRANK0") || strcmp (id, "FRANK1"))
      orientation = p.orientation;
      fixture = net_frank_model (p.n, orientation, bits);
      A_model = fixture.A;
      A_frozen = fixture.A;
      source = fixture.source;
      input_status = "exact_model";
    elseif (strcmp (id, "WILKINSON"))
      fixture = net_wilkinson_model (p.n, bits);
      A_model = fixture.A_model;
      A_frozen = fixture.A_frozen;
      source = fixture.source;
      input_status = fixture.input_status;
    elseif (strcmp (id, "GRCAR"))
      fixture = net_grcar_model (p.n, p.upper_bandwidth, bits);
      A_model = fixture.A_model;
      A_frozen = fixture.A_frozen;
      source = fixture.source;
      input_status = fixture.input_status;
    elseif (strcmp (id, "MKS"))
      delta = net_dyadic_parameter (p.delta, bits);
      fixture = net_mks_model (p.n, p.m, delta, bits);
      A_model = fixture.A_model;
      A_frozen = fixture.A_frozen;
      source = fixture.source;
      input_status = fixture.input_status;
    elseif (strcmp (id, "MARKOV"))
      fixture = net_markov_model (p.n, p.epsilon_exponent, bits);
      A_model = fixture.P_model;
      A_frozen = fixture.P_frozen;
      source = fixture.source;
      input_status = fixture.input_status;
    elseif (strcmp (id, "PERRON_POS"))
      fixture = net_perron_model (p.n, p.epsilon_exponent, bits);
      A_model = fixture.A_model;
      A_frozen = fixture.A_frozen;
      source = fixture.source;
      input_status = fixture.input_status;
    elseif (strcmp (id, "HAD_COMPLEX"))
      base = net_hadamard_model (p.n, p.s, bits);
      Z = mp (zeros (p.n, p.n));
      for index = 1:p.n
        phase = mod (index - 1, 4);
        if (phase == 0)
          Z(index, index) = net_mp_complex (mp (1), mp (0));
        elseif (phase == 1)
          Z(index, index) = net_mp_complex (mp (0), mp (1));
        elseif (phase == 2)
          Z(index, index) = net_mp_complex (mp (-1), mp (0));
        else
          Z(index, index) = net_mp_complex (mp (0), mp (-1));
        endif
      endfor
      A_model = Z * base.A * ctranspose (Z);
      A_frozen = A_model;
      source = "A1_COMPLEX_QUARTER_TURN_SIMILARITY";
      input_status = "exact_model";
    else
      error ("mplapack:neigt:Case", "unsupported ordinary case %s", id);
    endif
    result = struct ("id", id, "bits", bits, "A_model", A_model, ...
      "A_frozen", A_frozen, "native_A", double (A_model), ...
      "input_status", input_status, "source", source);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
