## SPDX-License-Identifier: BSD-2-Clause

function result = svt_make_lah (case_id, parameters, work_bits)
  ## Construct the unsigned Lah matrix with its integer recurrence.
  if (nargin != 3 || ! ischar (case_id) || ! isstruct (parameters) ...
      || ! isfield (parameters, "n"))
    error ("mplapack:svt:InvalidLahRequest", "invalid Lah request");
  endif
  n = parameters.n;
  if (! isnumeric (n) || ! isscalar (n) || ! isfinite (n) ...
      || n != fix (n) || n < 1 || work_bits != fix (work_bits))
    error ("mplapack:svt:InvalidLahParameters", ...
           "Lah n must be a positive integer and precision integral");
  endif
  required_bits = 3;
  for i = 2:n
    required_bits = required_bits + svt_ceil_log2_integer (2 * i);
  endfor
  svt_require_guard (required_bits, work_bits, "Lah exact recurrence");

  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (work_bits);
  matrix = mp (zeros (n, n));
  matrix(1, 1) = mp (1);
  for i = 2:n
    for j = 1:i
      term_shift = mp (0);
      if (j >= 2)
        term_shift = matrix(i - 1, j - 1);
      endif
      term_recur = mp (0);
      if (j <= i - 1)
        term_recur = mp (i + j - 1) * matrix(i - 1, j);
      endif
      matrix(i, j) = term_shift + term_recur;
    endfor
  endfor
  identity = svt_case_identity (case_id, "lah", matrix, matrix, work_bits, ...
                                "exact_integer_recurrence", ...
                                "unsigned Lah recurrence; unit lower triangular");
  result = struct ("id", case_id, "tier", "S", "family", "lah", ...
                   "parameters", parameters, "n", n, "model", matrix, ...
                   "A", matrix, "analytic_values", [], "rank", n, ...
                   "full_rank", true, "det_model", mp (1), ...
                   "construction_guard_bits", required_bits, "identity", identity, ...
                   "status", "CONSTRUCTED");
  clear cleanup;
endfunction
