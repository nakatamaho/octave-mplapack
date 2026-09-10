## SPDX-License-Identifier: BSD-2-Clause

function result = svt_make_hadamard_spectrum (case_id, parameters, work_bits)
  ## Construct the C0 mixed diagonal spectrum cases used by A5.
  if (nargin != 3 || ! ischar (case_id) || ! isstruct (parameters) ...
      || ! isfield (parameters, "n") || ! isfield (parameters, "mode"))
    error ("mplapack:svt:InvalidHadamardSpectrumRequest", ...
           "invalid Hadamard-spectrum request");
  endif
  n = parameters.n;
  mode = char (parameters.mode);
  if (! isnumeric (n) || ! isscalar (n) || n != fix (n) || n < 1 ...
      || ! any (strcmp (mode, {"geometric", "close", "repeat", "rank4", "rank5"})) ...
      || work_bits != fix (work_bits))
    error ("mplapack:svt:InvalidHadamardSpectrumParameters", ...
           "invalid Hadamard-spectrum parameters");
  endif
  if (any (strcmp (mode, {"close", "rank5"})))
    if (! isfield (parameters, "b") || parameters.b != fix (parameters.b) ...
        || parameters.b < 1)
      error ("mplapack:svt:InvalidHadamardSpectrumParameters", ...
             "close/rank5 mode requires positive integer b");
    endif
    perturbation_bits = parameters.b;
  else
    perturbation_bits = 0;
  endif
  if (strcmp (mode, "geometric"))
    if (! isfield (parameters, "a") || parameters.a != fix (parameters.a) ...
        || parameters.a < 1)
      error ("mplapack:svt:InvalidHadamardSpectrumParameters", ...
             "geometric mode requires positive integer a");
    endif
    required_bits = parameters.a * (n - 1) + svt_ceil_log2_integer (n) + 2;
  elseif (perturbation_bits > 0)
    required_bits = perturbation_bits + svt_ceil_log2_integer (n) + 5;
  else
    required_bits = svt_ceil_log2_integer (n) + 5;
  endif
  svt_require_guard (required_bits, work_bits, "Hadamard spectrum exact construction");

  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (work_bits);
  values = mp (zeros (n, 1));
  if (strcmp (mode, "geometric"))
    for index = 1:n
      values(index) = svt_pow2 (-parameters.a * (index - 1));
    endfor
  elseif (strcmp (mode, "close") || strcmp (mode, "repeat"))
    if (n != 8)
      error ("mplapack:svt:InvalidHadamardSpectrumParameters", ...
             "close/repeat fixtures are defined for n=8");
    endif
    delta = mp (0);
    if (strcmp (mode, "close"))
      delta = svt_pow2 (-parameters.b);
    endif
    base = {"4", "2", "1", "1", "0.5", "0.25", "0.125", "0.0625"};
    for index = 1:n
      values(index) = mp (base{index});
    endfor
    values(3) = values(3) + delta;
  elseif (strcmp (mode, "rank4"))
    base = {"1", "0.5", "0.25", "0.125", "0", "0", "0", "0"};
    if (n != numel (base))
      error ("mplapack:svt:InvalidHadamardSpectrumParameters", ...
             "rank4 fixture is defined for n=8");
    endif
    for index = 1:n
      values(index) = mp (base{index});
    endfor
  else
    if (n != 8)
      error ("mplapack:svt:InvalidHadamardSpectrumParameters", ...
             "rank5 fixture is defined for n=8");
    endif
    base = {"1", "0.5", "0.25", "0.125", "0", "0", "0", "0"};
    for index = 1:n
      values(index) = mp (base{index});
    endfor
    values(5) = svt_pow2 (-parameters.b);
  endif
  diagonal = diag (values);
  [h, g] = svt_hadamard (n);
  mixed = svt_mix (diagonal);
  model_rank = sum (values != mp (0));
  cluster_indices = [];
  null_indices = [];
  if (strcmp (mode, "close") || strcmp (mode, "repeat"))
    cluster_indices = [3, 4];
  elseif (strcmp (mode, "rank4"))
    null_indices = 5:8;
  elseif (strcmp (mode, "rank5"))
    null_indices = 6:8;
  endif
  left_projector = [];
  right_projector = [];
  if (! isempty (cluster_indices))
    left_projector = svt_known_projector (h, cluster_indices);
    right_projector = svt_known_projector (g, cluster_indices);
  elseif (! isempty (null_indices))
    left_projector = svt_known_projector (h, null_indices);
    right_projector = svt_known_projector (g, null_indices);
  endif
  identity = svt_case_identity (case_id, "hadamard_spectrum", diagonal, mixed, ...
                                work_bits, "exact_dyadic", ...
                                "C0 two-sided Hadamard equivalence; model rank is constructive metadata");
  result = struct ("id", case_id, "tier", "A", "family", "hadamard_spectrum", ...
                   "parameters", parameters, "n", n, "mode", mode, ...
                   "values", values, "model", diagonal, "A", mixed, ...
                   "H", h, "G", g, "analytic_values", sort (values, "descend"), ...
                   "rank", model_rank, "model_rank", model_rank, ...
                   "full_rank", model_rank == n, "det_model", [], ...
                   "cluster_indices", cluster_indices, "null_indices", null_indices, ...
                   "left_projector", left_projector, "right_projector", right_projector, ...
                   "construction_guard_bits", required_bits, "identity", identity, ...
                   "status", "CONSTRUCTED");
  clear cleanup;
endfunction
