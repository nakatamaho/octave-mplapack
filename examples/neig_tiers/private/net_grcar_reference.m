% Two independently evaluated general MP eig references for Grcar.
function result = net_grcar_reference (model, bits1, bits2)
  if (nargin != 3 || ! isstruct (model) || ! isfield (model, "A_model") ...
      || bits1 != fix (bits1) || bits2 != fix (bits2) || bits1 < 64 || bits2 < bits1)
    error ("mplapack:neigt:Grcar", "invalid Grcar reference arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (bits1);
    A1 = mp (zeros (size (model.A_model))) + model.A_model;
    [unused1, D1] = eig (A1, "nobalance");
    values1 = diag (D1);
    mpbits (bits2);
    A2 = mp (zeros (size (model.A_model))) + model.A_model;
    [unused2, D2] = eig (A2, "nobalance");
    values2 = diag (D2);
    comparison = net_match (values2, values1, "absolute");
    result = struct ("reference_status", "general_mp_eig_two_precisions", ...
      "bits1", bits1, "bits2", bits2, "values1", values1, "values2", values2, ...
      "agreement", comparison, "source", "A4_GENERAL_MP_EIG_REFERENCE");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
