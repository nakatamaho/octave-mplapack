% Grcar exact-input and two-reference audit.
function result = net_grcar_audit (n, upper_bandwidth, bits, reference_bits)
  model = net_grcar_model (n, upper_bandwidth, bits);
  reference = net_grcar_reference (model, reference_bits, reference_bits + 64);
  saved_bits = mpbits ();
  unwind_protect
    mpbits (reference_bits + 64);
    [V, D, W] = eig (model.A_frozen, "nobalance");
    metrics = net_metrics (model.A_frozen, V, D, W, reference.values2);
    result = struct ("status", "MEASURED", "model", model, ...
      "reference", reference, "metrics", metrics, ...
      "source", "A4_GRCAR_AUDIT");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
