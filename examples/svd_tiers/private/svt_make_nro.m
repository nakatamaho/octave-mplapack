## SPDX-License-Identifier: BSD-2-Clause

function result = svt_make_nro (case_id, parameters, work_bits)
  ## Construct the Section-5 NRO block fixture used by the SVT S1 tier.
  ## The returned inverse is an invariant/check object; measured solves still
  ## go through the public SVD/solve paths.
  if (nargin != 3 || ! ischar (case_id) || ! isstruct (parameters))
    error ("mplapack:svt:InvalidNroRequest", ...
           "svt_make_nro expects an ID, parameter struct, and work precision");
  endif
  required = {"m", "mode"};
  for index = 1:numel (required)
    if (! isfield (parameters, required{index}))
      error ("mplapack:svt:InvalidNroParameters", ...
             "NRO parameters lack field %s", required{index});
    endif
  endfor
  m = parameters.m;
  mode = char (parameters.mode);
  if (! isnumeric (m) || ! isscalar (m) || ! isreal (m) ...
      || ! isfinite (m) || m != fix (m) || m < 4 ...
      || 2 ^ svt_ceil_log2_integer (m) != m ...
      || svt_ceil_log2_integer (m) != 2 * fix (svt_ceil_log2_integer (m) / 2))
    error ("mplapack:svt:InvalidNroParameters", ...
           "NRO m must be a power of four of at least four");
  endif
  if (! any (strcmp (mode, {"two", "three", "graded"})))
    error ("mplapack:svt:InvalidNroParameters", "unknown NRO mode");
  endif
  if (! isnumeric (work_bits) || ! isscalar (work_bits) ...
      || ! isfinite (work_bits) || work_bits != fix (work_bits))
    error ("mplapack:svt:InvalidNroPrecision", "work precision must be integral");
  endif
  if (strcmp (mode, "graded"))
    if (! isfield (parameters, "g") || parameters.g != fix (parameters.g) ...
        || parameters.g < 1)
      error ("mplapack:svt:InvalidNroParameters", ...
             "graded NRO mode requires a positive integer g");
    endif
    max_exponent = parameters.g * (m - 1);
  else
    if (! isfield (parameters, "b") || parameters.b != fix (parameters.b) ...
        || parameters.b < 0)
      error ("mplapack:svt:InvalidNroParameters", ...
             "two/three-level NRO mode requires a nonnegative integer b");
    endif
    max_exponent = parameters.b;
  endif
  scale_bits = 0;
  if (isfield (parameters, "scale_bits"))
    scale_bits = parameters.scale_bits;
    if (! isnumeric (scale_bits) || ! isscalar (scale_bits) ...
        || ! isfinite (scale_bits) || scale_bits != fix (scale_bits))
      error ("mplapack:svt:InvalidNroParameters", ...
             "scale_bits must be an integer");
    endif
  endif
  required_bits = 8 + svt_ceil_log2_integer (m);
  svt_require_guard (required_bits, work_bits, "NRO exact block construction");

  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (work_bits);
  [h, unused_g] = svt_hadamard (m);
  weights = mp (zeros (m, 1));
  if (strcmp (mode, "two"))
    for index = 1:m
      weights(index) = svt_pow2 (parameters.b);
    endfor
  elseif (strcmp (mode, "three"))
    for index = 1:floor (m / 2)
      weights(index) = svt_pow2 (parameters.b);
    endfor
  else
    for index = 1:m
      weights(index) = svt_pow2 (parameters.g * (index - 1));
    endfor
  endif
  B = h * diag (weights);
  identity = mp (eye (m));
  zero = mp (zeros (m, m));
  model = [identity, B; zero, identity];
  inverse_model = [identity, -B; zero, identity];
  scale = svt_pow2 (scale_bits);
  represented = model * scale;
  inverse_formula = inverse_model / scale;

  sqrt_m_exponent = svt_ceil_log2_integer (m) / 2;
  beta = mp (zeros (m, 1));
  unscaled_values = mp (zeros (2 * m, 1));
  cursor = 1;
  for index = 1:m
    if (weights(index) == mp (0))
      beta(index) = mp (0);
      large = mp (1);
      small = mp (1);
    else
      weight_exponent = max_exponent;
      if (strcmp (mode, "two") || strcmp (mode, "three"))
        weight_exponent = parameters.b;
      elseif (strcmp (mode, "graded"))
        weight_exponent = parameters.g * (index - 1);
      endif
      beta(index) = svt_pow2 (weight_exponent + sqrt_m_exponent);
      root = sqrt (beta(index) * beta(index) + mp (4));
      denominator = root + beta(index);
      large = denominator / mp (2);
      ## Stable reciprocal formula; do not subtract nearly equal roots.
      small = mp (2) / denominator;
    endif
    unscaled_values(cursor) = large;
    unscaled_values(cursor + 1) = small;
    cursor = cursor + 2;
  endfor
  analytic_values = sort (unscaled_values, "descend") * scale;
  notes = "NRO Section-5 block; stable reciprocal singular-value formula";
  if (scale_bits != 0)
    notes = [notes, "; global exact dyadic scale applied"];
  endif
  result = struct ();
  result.id = case_id;
  result.tier = "S";
  result.family = "nro_block";
  result.mode = mode;
  result.parameters = parameters;
  result.m = m;
  result.H = h;
  result.G = unused_g;
  result.weights = weights;
  result.B = B;
  result.model = model;
  result.A = represented;
  result.inverse_formula = inverse_formula;
  result.beta = beta * scale;
  result.analytic_values = analytic_values;
  result.unscaled_analytic_values = unscaled_values;
  result.scale = scale;
  result.rank = 2 * m;
  result.full_rank = true;
  result.det_model = mp (1);
  result.construction_guard_bits = required_bits;
  result.identity = svt_case_identity (case_id, "nro_block", model, represented, ...
                                       work_bits, "exact_dyadic", notes);
  result.status = "CONSTRUCTED";
  clear cleanup;
endfunction
