% Run the NEIG03 Hadamard experiment at one work precision and mode.
function row = nes_hadamard_run (parameters, work_bits, mode, model_q, reference, native)
  if (nargin != 6 || ! isstruct (parameters) || ! isstruct (reference)
      || ! ischar (mode) || ! islogical (native) || ! isscalar (native))
    error ("NEIG:RunArguments", "invalid Hadamard run arguments");
  endif
  if (! any (strcmp (mode, {"balance", "nobalance"})))
    error ("NEIG:RunMode", "eig mode must be balance or nobalance");
  endif
  n = parameters.n;
  q = reference.reference_bits;
  model = model_q;
  if (native)
    built = nes_build ("hadamard", parameters, q);
    actual = built.native_A;
    source_bits = 53;
    input_precision = "native-binary64";
  else
    built = nes_build ("hadamard", parameters, work_bits);
    actual = built.A;
    source_bits = work_bits;
    input_precision = "mp";
  endif
  actual_q = nes_promote (actual, q, source_bits);
  input_error = norm (actual_q - model, "fro");
  model_norm = norm (model, "fro");
  if (model_norm == mp ("0"))
    error ("NEIG:RunModel", "Hadamard model norm is zero");
  endif
  input_error_relative = input_error / model_norm;

  solver_status = "success";
  solver_error = '';
  solver_time = NaN;
  saved_bits = mpbits ();
  try
    if (! native)
      mpbits (work_bits);
    endif
    started = tic ();
    if (native)
      [vectors, diagonal, left_vectors] = eig (actual, mode);
    else
      [vectors, diagonal, left_vectors] = eig (actual, mode);
    endif
    solver_time = toc (started);
  catch exception
    solver_status = "error";
    solver_error = exception.message;
  end_try_catch
  mpbits (saved_bits);

  row = struct ("schema", "neig-v1", "family", "hadamard", ...
                "representation", "hadamard_similar", "n", n, ...
                "s", parameters.s, "backend", ternary (native, "native", "mpfr"), ...
                "work_bits", work_bits, "evaluation_bits", q, ...
                "reference_bits", reference.reference_bits, "mode", mode, ...
                "input_precision", input_precision, "native", native, ...
                "solver_status", solver_status, "solver_error", solver_error, ...
                "solver_time", solver_time, "input_error", input_error, ...
                "input_error_relative", input_error_relative, ...
                "accuracy_status", "not_targeted", "reference_status", ...
                reference.reference_status, "condition_status", "unresolved", ...
                "max_imaginary", mp ("NaN"), "absolute_error", mp ("NaN"), ...
                "relative_error", mp ("NaN"), "right_residual", mp ("NaN"), ...
                "left_residual", mp ("NaN"), "right_column_residual", mp ("NaN"), ...
                "left_column_residual", mp ("NaN"), "condition_estimates", ...
                mp ("NaN"), "vector_condition", mp ("NaN"), ...
                "condition_disagreement", mp ("NaN"), "absolute_mapping", [], ...
                "relative_mapping", [], "computed_values", [], ...
                "reference_values", reference.eigenvalues);
  if (! strcmp (solver_status, "success"))
    return;
  endif

  if (native)
    vectors_q = nes_promote (vectors, q, 53);
    diagonal_q = nes_promote (diagonal, q, 53);
    left_vectors_q = nes_promote (left_vectors, q, 53);
  else
    vectors_q = nes_promote (vectors, q, work_bits);
    diagonal_q = nes_promote (diagonal, q, work_bits);
    left_vectors_q = nes_promote (left_vectors, q, work_bits);
  endif
  metrics = nes_metrics (actual_q, vectors_q, diagonal_q, left_vectors_q, ...
                         reference.eigenvalues);
  values = metrics.values;
  absolute_mapping = metrics.absolute_match.mapping;
  relative_mapping = metrics.relative_match.mapping;
  disagreement = mp (zeros (n, 1));
  for j = 1:n
    target = reference.condition_numbers(absolute_mapping(j));
    disagreement(j) = abs (metrics.condition_estimates(j) - target) / target;
  endfor
  row.accuracy_status = "meets_target";
  row.condition_status = metrics.condition_status;
  row.max_imaginary = max (abs (imag (values)));
  row.absolute_error = metrics.absolute_match.threshold;
  row.relative_error = metrics.relative_match.threshold;
  row.right_residual = metrics.right_residual;
  row.left_residual = metrics.left_residual;
  row.right_column_residual = metrics.right_column_residual;
  row.left_column_residual = metrics.left_column_residual;
  row.condition_estimates = metrics.condition_estimates;
  row.vector_condition = metrics.vector_condition;
  row.condition_disagreement = max (disagreement);
  row.absolute_mapping = absolute_mapping;
  row.relative_mapping = relative_mapping;
  row.computed_values = values;
endfunction

function answer = ternary (condition, if_true, if_false)
  if (condition)
    answer = if_true;
  else
    answer = if_false;
  endif
endfunction
