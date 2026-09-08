## SPDX-License-Identifier: BSD-2-Clause

function state = saveobj (value)
  ## Serialize @mp values as an explicit, portable schema.  The native bridge
  ## emits canonical MPFR/MPC text and never converts through binary64.
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", "saveobj expects one mp value");
  endif
  state = value;
  ## Keep the original class marker so Octave's legacy serializer restores an
  ## mp object.  The native payload is replaced by a plain struct; the bridge
  ## lazily decodes that struct after load.
  state.payload_ = __mplapack_core__ ("serialize", value);
endfunction
