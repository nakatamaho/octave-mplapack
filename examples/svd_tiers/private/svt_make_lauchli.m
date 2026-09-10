## SPDX-License-Identifier: BSD-2-Clause

function result = svt_make_lauchli (case_id, parameters, work_bits)
  ## Construct the Lauchli tall/wide pair and optional quarter-turn phase.
  if (nargin != 3 || ! ischar (case_id) || ! isstruct (parameters) ...
      || ! isfield (parameters, "n") || ! isfield (parameters, "b") ...
      || ! isfield (parameters, "representation"))
    error ("mplapack:svt:InvalidLauchliRequest", "invalid Lauchli request");
  endif
  n = parameters.n;
  b = parameters.b;
  representation = char (parameters.representation);
  if (! isnumeric (n) || ! isscalar (n) || n != fix (n) || n < 1 ...
      || ! isnumeric (b) || ! isscalar (b) || b != fix (b) || b < 1 ...
      || ! any (strcmp (representation, {"tall", "wide"})) ...
      || work_bits != fix (work_bits))
    error ("mplapack:svt:InvalidLauchliParameters", ...
           "Lauchli requires positive integer n/b and tall/wide representation");
  endif
  required_bits = b + svt_ceil_log2_integer (n) + 3;
  svt_require_guard (required_bits, work_bits, "Lauchli exact dyadic construction");
  phase_requested = isfield (parameters, "quarter_turn_phases") ...
                    && parameters.quarter_turn_phases;
  if (phase_requested && strcmp (representation, "wide"))
    error ("mplapack:svt:InvalidLauchliParameters", ...
           "quarter-turn Lauchli control is defined for the tall form");
  endif

  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (work_bits);
  mu = svt_pow2 (-b);
  ones_row = mp (ones (1, n));
  eye_n = mp (eye (n));
  tall = [ones_row; mu * eye_n];
  phase_left = mp (eye (n + 1));
  phase_right = mp (eye (n));
  matrix = tall;
  if (phase_requested)
    phase_left = svt_phase_diagonal (n + 1);
    phase_right = svt_phase_diagonal (n);
    matrix = phase_left * tall * phase_right';
  elseif (strcmp (representation, "wide"))
    matrix = tall';
  endif
  spectrum = mp (zeros (n, 1));
  spectrum(1) = sqrt (mp (n) + mu * mu);
  for index = 2:n
    spectrum(index) = mu;
  endfor
  base_right = mp (eye (n)) - ...
               (mp (ones (n, 1)) * mp (ones (1, n))) / mp (n);
  base_left = mp (zeros (n + 1, n + 1));
  base_left(2:end, 2:end) = base_right;
  if (phase_requested)
    right_projector = phase_right * base_right * phase_right';
    left_projector = phase_left * base_left * phase_left';
  elseif (strcmp (representation, "tall"))
    right_projector = base_right;
    left_projector = base_left;
  else
    right_projector = base_left;
    left_projector = base_right;
  endif
  normal_model = mp (ones (n, n)) + (mu * mu) * mp (eye (n));
  identity = svt_case_identity (case_id, "lauchli", tall, matrix, work_bits, ...
                                "exact_dyadic", ...
                                "Lauchli repeated-small-group projector; normal equations are negative control");
  result = struct ("id", case_id, "tier", "A", "family", "lauchli", ...
                   "parameters", parameters, "n", n, "b", b, ...
                   "representation", representation, "mu", mu, "tall", tall, ...
                   "A", matrix, "model", tall, "analytic_values", spectrum, ...
                   "right_projector", right_projector, "left_projector", left_projector, ...
                   "normal_equations_model", normal_model, ...
                   "normal_equations_negative_control", true, "phase_left", phase_left, ...
                   "phase_right", phase_right, "rank", n, "full_rank", true, ...
                   "det_model", [], "construction_guard_bits", required_bits, ...
                   "identity", identity, "status", "CONSTRUCTED");
  clear cleanup;
endfunction
