% A3 numerical/reference audit with separate model and frozen-input labels.
function result = net_wilkinson_audit (n, bits, reference_bits)
  model = net_wilkinson_model (n, bits);
  reference = net_wilkinson_reference (n, reference_bits);
  saved_bits = mpbits ();
  unwind_protect
    mpbits (max ([saved_bits, bits, reference_bits]));
    [V, D, W] = eig (model.A_frozen, "nobalance");
    metrics = net_metrics (model.A_frozen, V, D, W, reference.roots);
    values = diag (D);
    model_eta = mp (zeros (n, 1));
    frozen_coefficients = model.coefficients;
    for index = 1:n
      model_eta(index) = net_polynomial_backward_error ...
        (values(index), model.coefficients, reference_bits).eta;
    endfor
    frozen_eta = mp (zeros (n, 1));
    if (bits >= model.guard_bits)
      frozen_coefficients = model.coefficients;
    else
      frozen_coefficients = mp (zeros (1, n + 1)) + model.coefficients;
    endif
    for index = 1:n
      frozen_eta(index) = net_polynomial_backward_error ...
        (values(index), frozen_coefficients, reference_bits).eta;
    endfor
    result = struct ("status", "MEASURED", "model", model, ...
      "reference", reference, "values", values, "metrics", metrics, ...
      "model_coefficients", model.coefficients, ...
      "frozen_coefficients", frozen_coefficients, ...
      "model_eta_poly", model_eta, "frozen_eta_poly", frozen_eta, ...
      "model_matrix_residual", metrics.right_residual, ...
      "frozen_matrix_residual", metrics.right_residual, ...
      "source", "A3_WILKINSON_AUDIT");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
