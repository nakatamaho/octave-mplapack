% Analytic Markov/Perron spectrum and two independent stationary solves.
function result = net_markov_reference (model, bits1, bits2, is_perron)
  if (nargin != 4 || ! isstruct (model) || ! isfield (model, "P_model") ...
      || bits1 != fix (bits1) || bits2 != fix (bits2) || bits1 < 64 ...
      || bits2 < bits1 || ! islogical (is_perron))
    error ("mplapack:neigt:Markov", "invalid Markov reference arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits1);
    epsilon = net_pow2 (-model.epsilon_exponent, bits1);
    h = model.h;
    pi_value = acos (mp (-1));
    values1 = mp (zeros (model.n, 1));
    values1(1) = mp (1);
    values1(2) = mp (1) - epsilon;
    next = 3;
    for block = 1:2
      if (block == 1)
        alpha = mp (1) / mp (4);
      else
        alpha = mp (1) / mp (8);
      endif
      for k = 1:(h - 1)
        angle = mp (2) * pi_value * mp (k) / mp (h);
        root = net_mp_complex (cos (angle), sin (angle));
        values1(next) = (mp (1) - epsilon) ...
          * (mp (1) - alpha + alpha * root);
        next += 1;
      endfor
    endfor
    if (is_perron)
      values1 = (mp (3) / mp (2)) * values1;
    endif
    mpbits (bits2);
    epsilon = net_pow2 (-model.epsilon_exponent, bits2);
    pi_value = acos (mp (-1));
    values2 = mp (zeros (model.n, 1));
    values2(1) = mp (1);
    values2(2) = mp (1) - epsilon;
    next = 3;
    for block = 1:2
      if (block == 1)
        alpha = mp (1) / mp (4);
      else
        alpha = mp (1) / mp (8);
      endif
      for k = 1:(h - 1)
        angle = mp (2) * pi_value * mp (k) / mp (h);
        root = net_mp_complex (cos (angle), sin (angle));
        values2(next) = (mp (1) - epsilon) ...
          * (mp (1) - alpha + alpha * root);
        next += 1;
      endfor
    endfor
    if (is_perron)
      values2 = (mp (3) / mp (2)) * values2;
    endif

    mpbits (bits2);
    P = model.P_model;
    identity = mp (eye (model.n));
    rhs = epsilon * transpose (model.r);
    stationary_matrix = identity - (mp (1) - epsilon) * model.Q;
    stationary_column = transpose (stationary_matrix) \ transpose (rhs);
    normalized_matrix = transpose (P) - identity;
    normalized_rhs = mp (zeros (model.n, 1));
    normalized_matrix(end, :) = mp (ones (1, model.n));
    normalized_rhs(end) = mp (1);
    independent_column = normalized_matrix \ normalized_rhs;
    stationary_formula = transpose (stationary_column);
    independent_row = transpose (independent_column);
    stationary_equation = stationary_formula * P - stationary_formula;
    independent_equation = independent_row * P - independent_row;
    stationary_difference = stationary_formula - independent_row;
    result = struct ("reference_status", "analytic_spectrum_two_stationary_solves", ...
      "bits1", bits1, "bits2", bits2, "values1", values1, "values2", values2, ...
      "stationary_formula", stationary_formula, ...
      "stationary_independent", independent_row, ...
      "stationary_equation", stationary_equation, ...
      "independent_equation", independent_equation, ...
      "stationary_difference", stationary_difference, ...
      "source", "A6_ANALYTIC_FOURIER_AND_LINEAR_SOLVE_REFERENCE");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
