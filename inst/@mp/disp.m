## SPDX-License-Identifier: BSD-2-Clause

function disp (value)
  ## Display the canonical multiprecision scalar text.  Octave's binary64
  ## format setting does not reduce or otherwise change this representation.
  if (nargin != 1 || ! isa (value, "mp"))
    error ("mplapack:mp:InvalidInput", ...
           "disp expects one mp value");
  endif
  if (__mplapack_core__ ("value_is_matrix", value))
    info = __mplapack_core__ ("value_shape_info", value);
    fprintf ("mp %dx%d matrix\n", double (info.rows), double (info.columns));
    return;
  endif
  fprintf ("%s\n", char (value));
endfunction
