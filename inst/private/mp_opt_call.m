## SPDX-License-Identifier: BSD-2-Clause

function value = mp_opt_call (fun, argument, shape)
  if (nargin == 3)
    argument = reshape (argument, shape(1), shape(2));
  endif
  value = fun (argument);
  if (! isa (value, "mp") || ! isreal (value) || ! isscalar (value) ...
      || ! isfinite (value))
    error ("mplapack:optimization:CallbackContract", ...
           "optimization callback must return one finite real mp scalar");
  endif
endfunction
