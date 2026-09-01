## SPDX-License-Identifier: BSD-2-Clause

function disp (value)
  ## Display the canonical multiprecision scalar text.  Octave's binary64
  ## format setting does not reduce or otherwise change this representation.
  if (nargin != 1 || ! isa (value, "mp") || ! isscalar (value))
    error ("mplapack:mp:InvalidInput", ...
           "disp expects one scalar mp value");
  endif
  fprintf ("%s\n", char (value));
endfunction
