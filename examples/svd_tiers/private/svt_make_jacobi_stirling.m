## SPDX-License-Identifier: BSD-2-Clause

function result = svt_make_jacobi_stirling (case_id, parameters, work_bits)
  ## Construct the z=1 Jacobi--Stirling second-kind matrix by MP integer
  ## recurrence.  Indices in the recurrence are zero-based mathematically.
  if (nargin != 3 || ! ischar (case_id) || ! isstruct (parameters) ...
      || ! isfield (parameters, "n") || ! isfield (parameters, "z"))
    error ("mplapack:svt:InvalidJsRequest", "invalid Jacobi--Stirling request");
  endif
  n = parameters.n;
  z = parameters.z;
  if (! isnumeric (n) || ! isscalar (n) || ! isfinite (n) ...
      || n != fix (n) || n < 1 || ! isnumeric (z) || ! isscalar (z) ...
      || z != 1 || work_bits != fix (work_bits))
    error ("mplapack:svt:InvalidJsParameters", ...
           "Jacobi--Stirling requires n>=1, z=1, and integral precision");
  endif
  required_bits = 3;
  for r = 1:(n - 1)
    required_bits = required_bits + svt_ceil_log2_integer (1 + r * (r + 1));
  endfor
  svt_require_guard (required_bits, work_bits, "Jacobi--Stirling exact recurrence");

  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (work_bits);
  matrix = mp (zeros (n, n));
  matrix(1, 1) = mp (1);
  for i = 1:(n - 1)
    for j = 1:i
      term_shift = mp (0);
      if (j <= i)
        term_shift = matrix(i, j);
      endif
      term_recur = mp (0);
      if (j <= i - 1)
        term_recur = mp (j * (j + 1)) * matrix(i, j + 1);
      endif
      matrix(i + 1, j + 1) = term_shift + term_recur;
    endfor
  endfor
  identity = svt_case_identity (case_id, "jacobi_stirling", matrix, matrix, ...
                                work_bits, "exact_integer_recurrence", ...
                                "z=1; unit lower triangular Jacobi--Stirling matrix");
  result = struct ("id", case_id, "tier", "S", "family", "jacobi_stirling", ...
                   "parameters", parameters, "n", n, "z", z, "model", matrix, ...
                   "A", matrix, "analytic_values", [], "rank", n, ...
                   "full_rank", true, "det_model", mp (1), ...
                   "construction_guard_bits", required_bits, "identity", identity, ...
                   "status", "CONSTRUCTED");
  clear cleanup;
endfunction
