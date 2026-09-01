function disp (value)
  ## Minimal M03 placeholder.  Numeric formatting belongs to M05.
  if (nargin != 1 || ! isa (value, "mp") || ! isscalar (value))
    error ("mplapack:mp:InvalidInput", ...
           "disp expects one scalar mp value");
  endif
  fprintf ("mp scalar\n");
endfunction
