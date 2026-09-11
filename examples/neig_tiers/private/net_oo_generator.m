% Deterministic Ozaki--Ogita Theorem-1 triple-product generator.
% This is the specified S1 generator, not a generic similarity constructor.
function result = net_oo_generator (kind, n)
  if (nargin != 2 || ! ischar (kind) || ! isnumeric (n) ...
      || ! isscalar (n) || n != fix (n) || n < 2)
    error ("mplapack:neigt:OO", "invalid generator arguments");
  endif
  if (strcmp (kind, "OO53_REAL") || strcmp (kind, "OO53_PAIR"))
    generation_bits = 53;
  elseif (strcmp (kind, "OO128_CLOSE"))
    generation_bits = 128;
  else
    error ("mplapack:neigt:OO", "unknown generator kind");
  endif
  if (strcmp (kind, "OO53_PAIR") && mod (n, 2) != 0)
    error ("mplapack:neigt:OO", "OO53_PAIR requires even n");
  endif

  saved_bits = mpbits ();
  unwind_protect
    mpbits (generation_bits);
    [X, Y, pair_metadata] = oo_inverse_pair (n, generation_bits);
    S_requested = net_oo_standard (kind, n, generation_bits);
    quant = oo_quantization_metadata (S_requested, X, Y, generation_bits);
    if (quant.predicate_value > mp (1))
      error ("mplapack:neigt:OO", ...
             "Theorem-1 inequality fails at the requested generation precision");
    endif
    sigma = mp (12) * quant.alpha * quant.P;
    S_realized = mp (zeros (n, n));
    pair_rule = false;
    for i = 1:n
      for j = 1:n
        S_realized(i, j) = oo_round_shift (S_requested(i, j), sigma, ...
                                           generation_bits);
      endfor
    endfor
    if (strcmp (kind, "OO53_PAIR"))
      pair_rule = true;
      for block = 0:(n / 2 - 1)
        first = 2 * block + 1;
        a_prime = oo_round_shift (S_requested(first, first), sigma, ...
                                  generation_bits);
        b_prime = oo_round_shift (S_requested(first, first + 1), sigma, ...
                                  generation_bits);
        % One rounded value is copied to both diagonal entries.  The lower
        % entry is a sign copy, never an independent rounding operation.
        S_realized(first, first) = a_prime;
        S_realized(first + 1, first + 1) = a_prime;
        S_realized(first, first + 1) = b_prime;
        S_realized(first + 1, first) = -b_prime;
      endfor
    endif

    inner_rounded = net_rounded_product (S_realized, X, generation_bits);
    [inner_exact, inner_exact_metadata] = ...
      net_exact_product_dyadic (S_realized, X, generation_bits);
    outer_rounded = net_rounded_product (Y, inner_rounded, generation_bits);
    [outer_exact, outer_exact_metadata] = ...
      net_exact_product_dyadic (Y, inner_exact, ...
                                inner_exact_metadata.check_bits);
    [xy_exact, xy_metadata] = net_exact_product_dyadic (X, Y, generation_bits);
    [yx_exact, yx_metadata] = net_exact_product_dyadic (Y, X, generation_bits);
    mpbits (max ([generation_bits, inner_exact_metadata.check_bits, ...
                  outer_exact_metadata.check_bits, xy_metadata.check_bits, ...
                  yx_metadata.check_bits]));
    identity = mp (eye (n));
    exact_xy = (xy_exact == identity);
    exact_yx = (yx_exact == identity);
    products_exact = (inner_rounded == inner_exact ...
                      && outer_rounded == outer_exact);
    if (! exact_xy || ! exact_yx || ! products_exact)
      error ("mplapack:neigt:OO", ...
             "independent exact dyadic product check failed");
    endif
    if (all (S_realized == S_requested))
      error ("mplapack:neigt:OO", ...
             "required generator fixture did not realize a quantization change");
    endif
    A = outer_rounded;
    [requested_spectrum, realized_spectrum] = ...
      oo_spectra (kind, S_requested, S_realized);
    model_hash = oo_matrix_hash (kind, n, generation_bits, S_requested, ...
                                 S_realized, A);
    if (strcmp (kind, "OO128_CLOSE"))
      realized_gap = S_realized(2, 2) - S_realized(1, 1);
      expected_gap = net_pow2 (-80, generation_bits);
    else
      realized_gap = mp (0);
      expected_gap = mp (0);
    endif
    result = struct (...
      "family", "ozaki_ogita_theorem_1", "kind", kind, "n", n, ...
      "generation_bits", generation_bits, "source", "OO22_THEOREM_1_SECTION_4", ...
      "method", "fixed_precision_two_step_RN_triple_product_v1", ...
      "S_requested", S_requested, "S_realized", S_realized, ...
      "requested_spectrum", requested_spectrum, ...
      "realized_spectrum", realized_spectrum, "X", X, "Y", Y, "A", A, ...
      "A_exact", outer_exact, "sigma", sigma, "alpha", quant.alpha, ...
      "beta", quant.beta, "gamma", quant.gamma, "theta", quant.theta, ...
      "omega", quant.omega, "P", quant.P, "nY", quant.nY, ...
      "nS", quant.nS, "nX", quant.nX, "nprime", quant.nprime, ...
      "u", quant.u, "predicate_value", quant.predicate_value, ...
      "theorem_predicate", quant.predicate_value <= mp (1), ...
      "pair_rule", pair_rule, "pair_metadata", pair_metadata, ...
      "xy_exact", exact_xy, "yx_exact", exact_yx, ...
      "products_exact", products_exact, ...
      "inner_exact_metadata", inner_exact_metadata, ...
      "outer_exact_metadata", outer_exact_metadata, ...
      "xy_metadata", xy_metadata, "yx_metadata", yx_metadata, ...
      "quantization_changed", true, "realized_gap", realized_gap, ...
      "requested_gap_component", expected_gap, "model_hash", model_hash, ...
      "hash_encoding", "S1_TEXT_V1", "status", "MEASURED");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function [X, Y, metadata] = oo_inverse_pair (n, bits)
  N = mp (zeros (n, n));
  for i = 1:(n - 1)
    N(i, i + 1) = mp (1);
  endfor
  L = mp (eye (n)) + ctranspose (N);
  U = mp (eye (n)) + N;
  X = L * U;
  U_inverse = net_triangular_inverse (U, bits);
  L_inverse = net_triangular_inverse (L, bits);
  Y = U_inverse * L_inverse;
  metadata = struct ("construction", "L=I+Nprime,U=I+N; finite_nilpotent_series", ...
                     "inverse_method", "finite_nilpotent_series", ...
                     "dyadic", true);
endfunction

function quant = oo_quantization_metadata (S, X, Y, bits)
  n = rows (S);
  phi = mp (zeros (size (X)));
  psi = mp (zeros (size (Y)));
  gamma = mp (1);
  omega = mp (1);
  for i = 1:n
    for j = 1:n
      if (X(i, j) != mp (0))
        part = net_dyadic_decompose (X(i, j), bits);
        phi(i, j) = net_pow2 (part.exponent, bits);
        gamma = max (gamma, net_ufp (abs (X(i, j))) / phi(i, j));
      endif
      if (Y(i, j) != mp (0))
        part = net_dyadic_decompose (Y(i, j), bits);
        psi(i, j) = net_pow2 (part.exponent, bits);
        omega = max (omega, net_ufp (abs (Y(i, j))) / psi(i, j));
      endif
    endfor
  endfor
  beta = mp (1);
  theta = mp (1);
  for j = 1:n
    nonzero = find (phi(:, j) != mp (0));
    if (! isempty (nonzero))
      beta = max (beta, max (phi(nonzero, j)) / min (phi(nonzero, j)));
    endif
  endfor
  for i = 1:n
    nonzero = find (psi(i, :) != mp (0));
    if (! isempty (nonzero))
      theta = max (theta, max (psi(i, nonzero)) / min (psi(i, nonzero)));
    endif
  endfor
  nY = 0;
  nS = 0;
  nX = 0;
  max_s = mp (0);
  for i = 1:n
    nY = max (nY, sum (Y(i, :) != mp (0)));
    nS = max (nS, sum (S(i, :) != mp (0)));
    max_s = max (max_s, max (abs (S(i, :))));
  endfor
  for j = 1:n
    nX = max (nX, sum (X(:, j) != mp (0)));
  endfor
  nprime = min (nS, nX);
  target = mp (nY * nprime) * max_s;
  alpha = mp (1);
  while alpha < target
    alpha = alpha * mp (2);
  endwhile
  P = beta * gamma * theta * omega;
  u = net_pow2 (-bits, bits);
  predicate_value = mp (4 * nY * nprime) * u * P;
  quant = struct ("phi", phi, "psi", psi, "beta", beta, ...
                  "gamma", gamma, "theta", theta, "omega", omega, ...
                  "P", P, "nY", nY, "nS", nS, "nX", nX, ...
                  "nprime", nprime, "max_s", max_s, "alpha", alpha, ...
                  "u", u, "predicate_value", predicate_value);
endfunction

function value = oo_round_shift (entry, sigma, bits)
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits);
    first = sigma + entry;
    first = first + mp (0);
    second = first - sigma;
    value = second + mp (0);
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction

function [requested, realized] = oo_spectra (kind, S_requested, S_realized)
  n = rows (S_requested);
  requested = mp (zeros (n, 1));
  realized = mp (zeros (n, 1));
  imaginary_unit = mp ("(0,1)");
  if (strcmp (kind, "OO53_PAIR"))
    for block = 0:(n / 2 - 1)
      first = 2 * block + 1;
      requested(first) = S_requested(first, first) ...
                         + S_requested(first, first + 1) * imaginary_unit;
      requested(first + 1) = S_requested(first, first) ...
                             - S_requested(first, first + 1) * imaginary_unit;
      realized(first) = S_realized(first, first) ...
                        + S_realized(first, first + 1) * imaginary_unit;
      realized(first + 1) = S_realized(first, first) ...
                            - S_realized(first, first + 1) * imaginary_unit;
    endfor
  else
    requested = diag (S_requested);
    realized = diag (S_realized);
  endif
endfunction

function result = oo_matrix_hash (kind, n, bits, requested, realized, A)
  text = sprintf ("%s|n=%d|g=%d|", kind, n, bits);
  for matrix = {requested, realized, A}
    value = matrix{1};
    tokens = cell (1, numel (value));
    for i = 1:numel (value)
      tokens{i} = char (value(i));
    endfor
    joined = strjoin (tokens, ";");
    text = [text, joined];
    text = [text, "|"];
  endfor
  result = hash ("sha256", text);
endfunction
