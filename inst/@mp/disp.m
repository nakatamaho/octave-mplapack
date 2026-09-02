## SPDX-License-Identifier: BSD-2-Clause

function disp (value)
  ## Display canonical multiprecision text.  Octave's binary64 format setting
  ## does not reduce or otherwise change this representation.
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "disp expects one mp value");
  endif
  if (__mplapack_core__ ("value_is_matrix", value))
    fprintf ("%s\n", __mplapack_core__ ("matrix_display_text", value));
    return;
  endif
  fprintf ("%s\n", char (value));
endfunction
