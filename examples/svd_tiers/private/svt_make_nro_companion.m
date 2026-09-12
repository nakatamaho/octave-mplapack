## SPDX-License-Identifier: BSD-2-Clause

function result = svt_make_nro_companion (case_id, parameters, work_bits)
  ## Construct the deterministic bounded-integer NRO companion-like matrix.
  if (nargin != 3 || ! ischar (case_id) || ! isstruct (parameters) ...
      || ! isfield (parameters, "n") || ! isfield (parameters, "nu"))
    error ("mplapack:svt:InvalidNroCompanionRequest", ...
           "invalid NRO companion request");
  endif
  n = parameters.n;
  nu = parameters.nu;
  if (! isnumeric (n) || ! isscalar (n) || n != fix (n) || n < 1 ...
      || ! isnumeric (nu) || ! isscalar (nu) || nu != fix (nu) || nu < 2 ...
      || work_bits != fix (work_bits))
    error ("mplapack:svt:InvalidNroCompanionParameters", ...
           "NRO companion requires integer n>=1, nu>=2, and integral precision");
  endif
  required_bits = svt_ceil_log2_integer (nu + 1) + 3;
  svt_require_guard (required_bits, work_bits, "NRO companion exact construction");

  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (work_bits);
  k = mp (zeros (n, 1));
  for index = 1:(n - 1)
    if (mod (index, 2) == 1)
      k(index) = mp (1);
    else
      k(index) = mp (-1);
    endif
  endfor
  k(n) = mp (1);
  coefficients = mp (zeros (n, 1));
  coefficients(1) = k(1);
  for index = 2:n
    coefficients(index) = k(index) - mp (nu) * k(index - 1);
  endfor
  matrix = mp (zeros (n, n));
  matrix(1, :) = coefficients';
  for index = 2:n
    matrix(index, index - 1) = mp (1);
    matrix(index, index) = -mp (nu);
  endfor
  horner = mp (zeros (n, 1));
  horner(1) = coefficients(1);
  for index = 2:n
    horner(index) = horner(index - 1) * mp (nu) + coefficients(index);
  endfor
  det_sign = (-1) ^ (n - 1);

  published_c = mp ([1, -6, 7, -9; 1, -5, 0, 0; 0, 1, -5, 0; 0, 0, 1, -5]);
  published_x = mp ([125, -124, 130, -225; 25, -25, 26, -45; ...
                     5, -5, 5, -9; 1, -1, 1, -2]);
  published_left_error = published_c * published_x - mp (eye (4));
  published_right_error = published_x * published_c - mp (eye (4));
  identity = svt_case_identity (case_id, "nro_companion", matrix, matrix, ...
                                work_bits, "exact_integer_recurrence", ...
                                "bounded-integer NRO companion; Horner unimodularity proof");
  result = struct ("id", case_id, "tier", "A", "family", "nro_companion", ...
                   "parameters", parameters, "n", n, "nu", nu, "k", k, ...
                   "coefficients", coefficients, "model", matrix, "A", matrix, ...
                   "analytic_values", [], "rank", n, "full_rank", true, ...
                   "det_model", mp (det_sign), "det_sign", det_sign, ...
                   "horner_states", horner, "horner_matches_k", all (all (horner == k)), ...
                   "entry_bound", nu + 1, "construction_guard_bits", required_bits, ...
                   "published_C", published_c, "published_X", published_x, ...
                   "published_left_error", published_left_error, ...
                   "published_right_error", published_right_error, "identity", identity, ...
                   "status", "CONSTRUCTED");
  clear cleanup;
endfunction
