## SPDX-License-Identifier: BSD-2-Clause

function [tolx, tolfun, max_iter] = mp_solver_options (options, template)
  scale = mp ("1");
  for index = 1:numel (template)
    candidate = abs (mp_solver_element (template, index));
    if (candidate > scale), scale = candidate; endif
  endfor
  default_tol = scale * sqrt (eps (scale));
  tolx = default_tol;
  tolfun = default_tol;
  ## A bisection safeguard may need roughly one bit of progress per
  ## iteration; scale the default budget with the active MP precision.
  max_iter = max (100, 4 * double (mpbits ()));
  if (isempty (options))
    return;
  endif
  if (! isstruct (options) || ! isscalar (options))
    error ("mplapack:solver:InvalidOptions", "solver options must be a scalar struct");
  endif
  if (isfield (options, "TolX") && ! isempty (options.TolX))
    tolx = mp_solver_option_mp (options.TolX, template, "TolX");
  endif
  if (isfield (options, "TolFun") && ! isempty (options.TolFun))
    tolfun = mp_solver_option_mp (options.TolFun, template, "TolFun");
  endif
  if (isfield (options, "MaxIter") && ! isempty (options.MaxIter))
    if (! isnumeric (options.MaxIter) || ! isscalar (options.MaxIter)
        || options.MaxIter < 1 || options.MaxIter != fix (options.MaxIter))
      error ("mplapack:solver:InvalidOptions", "MaxIter must be a positive integer");
    endif
    max_iter = double (options.MaxIter);
  endif
  if (tolx <= 0 || tolfun <= 0)
    error ("mplapack:solver:InvalidOptions", "TolX and TolFun must be positive");
  endif
endfunction

function result = mp_solver_option_mp (value, template, name)
  if (isa (value, "mp"))
    if (! isreal (value) || ! isscalar (value) || ! isfinite (value) || value <= 0)
      error ("mplapack:solver:InvalidOptions", "%s must be a positive finite scalar", name);
    endif
    result = value;
  elseif (isnumeric (value) && isreal (value) && isscalar (value)
          && isfinite (value) && value > 0)
    result = mp_solver_element (template, 1) * 0 + value;
  else
    error ("mplapack:solver:InvalidOptions", "%s must be a positive scalar", name);
  endif
endfunction
