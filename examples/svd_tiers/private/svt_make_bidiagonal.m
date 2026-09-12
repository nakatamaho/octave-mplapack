## SPDX-License-Identifier: BSD-2-Clause

function result = svt_make_bidiagonal (case_id, parameters, work_bits)
  ## Construct the graded bidiagonal raw/mixed pair from A3.
  if (nargin != 3 || ! ischar (case_id) || ! isstruct (parameters) ...
      || ! isfield (parameters, "n") || ! isfield (parameters, "a") ...
      || ! isfield (parameters, "representation"))
    error ("mplapack:svt:InvalidBidiagonalRequest", ...
           "invalid bidiagonal request");
  endif
  n = parameters.n;
  a = parameters.a;
  representation = char (parameters.representation);
  if (! isnumeric (n) || ! isscalar (n) || n != fix (n) || n < 1 ...
      || ! isnumeric (a) || ! isscalar (a) || a != fix (a) || a < 1 ...
      || ! any (strcmp (representation, {"raw", "mixed"})) ...
      || work_bits != fix (work_bits))
    error ("mplapack:svt:InvalidBidiagonalParameters", ...
           "bidiagonal requires positive integer n/a and raw/mixed representation");
  endif
  required_bits = a * (n - 1) + 4;
  svt_require_guard (required_bits, work_bits, "bidiagonal exact mixing");

  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (work_bits);
  raw = mp (zeros (n, n));
  for i = 1:n
    raw(i, i) = svt_pow2 (-a * (i - 1));
    if (i < n)
      raw(i, i + 1) = svt_pow2 (-a * (i - 1) - 1);
    endif
  endfor
  mixed = svt_mix (raw);
  if (strcmp (representation, "raw"))
    matrix = raw;
  else
    matrix = mixed;
  endif
  identity = svt_case_identity (case_id, "bidiagonal", raw, matrix, ...
                                work_bits, "exact_dyadic", ...
                                "graded one-bit bidiagonal; raw/mixed singular spectra agree");
  result = struct ("id", case_id, "tier", "A", "family", "bidiagonal", ...
                   "parameters", parameters, "n", n, "a", a, ...
                   "representation", representation, "raw", raw, "mixed", mixed, ...
                   "model", raw, "A", matrix, "analytic_values", [], "rank", n, ...
                   "full_rank", true, "det_model", svt_pow2 (-a * n * (n - 1) / 2), ...
                   "construction_guard_bits", required_bits, "identity", identity, ...
                   "status", "CONSTRUCTED");
  clear cleanup;
endfunction
