% Run one Wilkinson-polynomial companion eigensystem.
function row = nes_companion_run (parameters, work_bits, mode, model_q, reference, native)
  n = parameters.n;
  q = reference.reference_bits;
  minimum_bits = nes_companion_min_bits (n);
  if (native)
    built = nes_build ("companion", parameters, q);
    actual = built.native_A;
    source_bits = 53;
    input_precision = "native-binary64";
    backend = "native";
  else
    built = nes_build ("companion", parameters, work_bits);
    actual = built.A;
    source_bits = work_bits;
    input_precision = "mp";
    backend = "mpfr";
  endif
  actual_q = nes_promote (actual, q, source_bits);
  input_error = norm (actual_q - model_q, "fro");
  input_error_relative = input_error / norm (model_q, "fro");
  solver_status = "success";
  solver_error = '';
  solver_time = NaN;
  saved_bits = mpbits ();
  try
    if (! native)
      mpbits (work_bits);
    endif
    started = tic ();
    [vectors, diagonal, left_vectors] = eig (actual, mode);
    solver_time = toc (started);
  catch exception
    solver_status = "error";
    solver_error = exception.message;
  end_try_catch
  mpbits (saved_bits);
  row = struct ("schema", "neig-v1", "family", "companion", ...
                "representation", "companion", "n", n, "s", NaN, ...
                "backend", backend, "work_bits", work_bits, ...
                "evaluation_bits", q, "reference_bits", reference.reference_bits, ...
                "low_reference_bits", NaN, "reference_agreement", mp ("NaN"), ...
                "reference_agreement_limit", mp ("NaN"), "mode", mode, ...
                "input_precision", input_precision, "native", native, ...
                "minimum_coefficient_bits", minimum_bits, ...
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
  vectors_q = nes_promote (vectors, q, source_bits);
  diagonal_q = nes_promote (diagonal, q, source_bits);
  left_vectors_q = nes_promote (left_vectors, q, source_bits);
  metrics = nes_metrics (actual_q, vectors_q, diagonal_q, left_vectors_q, ...
                         reference.eigenvalues);
  row.condition_status = metrics.condition_status;
  row.max_imaginary = max (abs (imag (metrics.values)));
  row.absolute_error = metrics.absolute_match.threshold;
  row.relative_error = metrics.relative_match.threshold;
  row.right_residual = metrics.right_residual;
  row.left_residual = metrics.left_residual;
  row.right_column_residual = metrics.right_column_residual;
  row.left_column_residual = metrics.left_column_residual;
  row.condition_estimates = metrics.condition_estimates;
  row.vector_condition = metrics.vector_condition;
  row.absolute_mapping = metrics.absolute_match.mapping;
  row.relative_mapping = metrics.relative_match.mapping;
  row.computed_values = metrics.values;
endfunction
