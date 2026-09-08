## SPDX-License-Identifier: BSD-2-Clause

function value = loadobj (state)
  ## Reconstruct a saved @mp value at its recorded precision.  The ambient
  ## default is restored even when native reconstruction raises an error.
  if (nargin != 1 || ! isa (state, "mp"))
    error ("mplapack:SerializationError", ...
           "loadobj expects one serialized mp value");
  endif
  payload_state = builtin ("subsref", state, substruct (".", "payload_"));
  if (! isstruct (payload_state) || ! isfield (payload_state, "precision_bits"))
    error ("mplapack:SerializationError", ...
           "serialized mp value has no precision_bits field");
  endif

  saved_precision = mpbits ();
  unwind_protect
    mpbits (payload_state.precision_bits);
    value = state;
    value.payload_ = __mplapack_core__ ("deserialize", payload_state);
  unwind_protect_cleanup
    mpbits (saved_precision);
  end_unwind_protect
endfunction
