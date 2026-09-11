% Independent reference-role dispatcher for fixed exact S2 models.
function result = net_reference (fixture, reference_bits)
  if (nargin != 2 || ! isstruct (fixture) || ! isscalar (fixture) ...
      || ! isnumeric (reference_bits) || ! isscalar (reference_bits) ...
      || reference_bits != fix (reference_bits) || reference_bits < 1)
    error ("mplapack:neigt:Reference", "invalid reference arguments");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (reference_bits);
    if (! isfield (fixture, "J") || ! isfield (fixture, "generation_bits"))
      error ("mplapack:neigt:Reference", ...
             "exact algebraic reference requires a fixed S2 model");
    endif
    values = net_widen (diag (fixture.J), reference_bits, fixture.generation_bits);
    result = struct ("values", values, "reference_bits", reference_bits, ...
                     "reference_status", "exact_algebraic", ...
                     "role", "INDEPENDENT_MODEL_REFERENCE", ...
                     "source", "SIM_EXACT_INTEGER", ...
                     "model_hash", "pending_exact_serializer");
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
