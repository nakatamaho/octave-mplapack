## SPDX-License-Identifier: BSD-2-Clause

function result = svt_make_vandermonde (case_id, parameters, work_bits)
  ## Construct the dyadic-node Vandermonde matrix by successive MP powers.
  if (nargin != 3 || ! ischar (case_id) || ! isstruct (parameters) ...
      || ! isfield (parameters, "n") || ! isfield (parameters, "node_den_bits"))
    error ("mplapack:svt:InvalidVandermondeRequest", ...
           "invalid Vandermonde request");
  endif
  n = parameters.n;
  d = parameters.node_den_bits;
  if (! isnumeric (n) || ! isscalar (n) || n != fix (n) || n < 1 ...
      || ! isnumeric (d) || ! isscalar (d) || d != fix (d) || d < 1 ...
      || n >= 2 ^ d || work_bits != fix (work_bits))
    error ("mplapack:svt:InvalidVandermondeParameters", ...
           "Vandermonde requires n<2^d and integral parameters");
  endif
  required_bits = 2 + (n - 1) * svt_ceil_log2_integer (n);
  svt_require_guard (required_bits, work_bits, "Vandermonde exact dyadic construction");

  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (work_bits);
  denominator = svt_pow2 (d);
  nodes = mp (zeros (n, 1));
  matrix = mp (zeros (n, n));
  for i = 1:n
    nodes(i) = mp (i) / denominator;
    matrix(i, 1) = mp (1);
    for j = 2:n
      matrix(i, j) = matrix(i, j - 1) * nodes(i);
    endfor
  endfor
  distinct = true;
  for i = 1:(n - 1)
    for j = (i + 1):n
      if (nodes(i) == nodes(j))
        distinct = false;
      endif
    endfor
  endfor
  identity = svt_case_identity (case_id, "vandermonde", matrix, matrix, ...
                                work_bits, "exact_dyadic", ...
                                "nodes i/2^d; successive powers; distinct positive nodes");
  result = struct ("id", case_id, "tier", "A", "family", "vandermonde", ...
                   "parameters", parameters, "n", n, "node_den_bits", d, ...
                   "nodes", nodes, "model", matrix, "A", matrix, ...
                   "analytic_values", [], "rank", n, "full_rank", distinct, ...
                   "determinant_sign_proof", distinct, "determinant_positive", distinct, ...
                   "construction_guard_bits", required_bits, "identity", identity, ...
                   "status", "CONSTRUCTED");
  clear cleanup;
endfunction
