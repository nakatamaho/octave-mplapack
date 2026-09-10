## SPDX-License-Identifier: BSD-2-Clause

function row = svt_run_svd (input, mode, evaluation_bits)
  ## Execute exactly one measured values-only or economy-factor SVD call.
  if (! isa (input, "mp") || ! any (strcmp (mode, {"values", "econ"})))
    error ("mplapack:svt:InvalidSvdRequest", ...
           "svt_run_svd requires an mp input and values/econ mode");
  endif
  if (nargin < 3)
    evaluation_bits = [];
  endif
  input_info = __mplapack_core__ ("value_shape_info", input);
  before = input;
  row = struct ();
  row.schema = "svt-row-v1";
  row.mode = mode;
  row.input_shape = [input_info.rows, input_info.columns];
  row.input_precision_bits = input_info.precision_bits;
  row.evaluation_bits = evaluation_bits;
  row.api = "mp.svd -> MPLAPACK Rgesvd/Cgesvd";
  row.status = "PASS";
  timer = tic ();
  if (strcmp (mode, "values"))
    row.values = svd (input);
    row.has_factors = false;
  else
    [row.U, row.S, row.V] = svd (input, "econ");
    row.values = diag (row.S);
    row.has_factors = true;
  endif
  row.svd_seconds = toc (timer);
  row.input_unchanged = all (all (input == before));
  if (! row.input_unchanged)
    error ("mplapack:svt:InputMutation", "SVD changed its public input");
  endif
  row.value_info = svt_validate_values (row.values, input_info);
  if (row.has_factors)
    row.metrics = svt_metrics (input, row.U, row.S, row.V, evaluation_bits);
  else
    row.metrics = struct ("status", "VALUES_ONLY", ...
                          "reconstruction", [], "rho_rec", [], ...
                          "rho_R", [], "rho_L", [], ...
                          "orthogonality_U", [], "orthogonality_V", []);
  endif
endfunction

function info = svt_validate_values (values, input_info)
  if (! isa (values, "mp"))
    error ("mplapack:svt:SvdContract", "SVD did not return an mp value vector");
  endif
  shape = size (values);
  k = min (input_info.rows, input_info.columns);
  if (shape(1) != k || shape(2) != 1)
    error ("mplapack:svt:SvdContract", "SVD value output has an invalid shape");
  endif
  if (! isreal (values) || ! all (all (isfinite (values))))
    error ("mplapack:svt:SvdContract", "SVD values are not finite real mp data");
  endif
  previous = mp (0);
  for index = 1:k
    current = values(index);
    if (current < mp (0))
      error ("mplapack:svt:SvdContract", "SVD returned a negative singular value");
    endif
    if (index > 1 && current > previous)
      error ("mplapack:svt:SvdContract", "SVD values are not descending");
    endif
    previous = current;
  endfor
  info = struct ("count", k, "real", true, "finite", true, ...
                "descending", true, "nonnegative", true);
endfunction
