## SPDX-License-Identifier: BSD-2-Clause

function [argument, value, exitflag, output] = fminbnd (fun, lower, upper, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{x} =} fminbnd (@var{fun}, @var{a}, @var{b})
  ## @deftypefnx {} {[@var{x}, @var{fval}, @var{exitflag}, @var{output}] =} fminbnd (@dots{}, @var{options})
  ## Minimize a real scalar MP objective on an MP bounded interval.
  ## @end deftypefn
  if (nargin < 3 || nargin > 4 || ! isa (fun, "function_handle"))
    error ("mplapack:optimization:InvalidArguments", ...
           "fminbnd expects a function handle, lower bound, upper bound, and options");
  endif
  [lower, upper, template] = mp_opt_bounds (lower, upper);
  if (lower > upper)
    temporary = lower; lower = upper; upper = temporary;
  endif
  options = mp_opt_options (varargin, template, 1, "fminbnd");
  if (lower == upper)
    argument = lower;
    value = mp_opt_call (fun, argument);
    exitflag = 1;
    output = mp_opt_output (0, 1, "bounded interval is a point", ...
                            "MP golden-section bounded search");
    return;
  endif

  golden = (sqrt (mp ("5")) - mp ("1")) / mp ("2");
  first = upper - golden * (upper - lower);
  second = lower + golden * (upper - lower);
  first_value = mp_opt_call (fun, first);
  second_value = mp_opt_call (fun, second);
  evaluations = 2;
  iterations = 0;
  exitflag = 0;
  for iteration = 1:options.max_iter
    iterations = iteration;
    center = (first + second) / mp ("2");
    ## A small objective-value difference does not imply a small distance
    ## from the minimizer (the two samples can straddle a flat minimum).
    ## Require the MP coordinate bracket to satisfy TolX; TolFun remains part
    ## of the common option contract and is used by fminsearch.
    if (abs (upper - lower) <= options.tol_x * (mp ("1") + abs (center)))
      exitflag = 1;
      break;
    endif
    if (first_value <= second_value)
      upper = second;
      second = first;
      second_value = first_value;
      first = upper - golden * (upper - lower);
      first_value = mp_opt_call (fun, first);
    else
      lower = first;
      first = second;
      first_value = second_value;
      second = lower + golden * (upper - lower);
      second_value = mp_opt_call (fun, second);
    endif
    evaluations += 1;
  endfor
  if (first_value <= second_value)
    argument = first; value = first_value;
  else
    argument = second; value = second_value;
  endif
  if (exitflag == 1)
    message = "converged";
  else
    message = "maximum iterations reached";
  endif
  output = mp_opt_output (iterations, evaluations, message, ...
                          "MP golden-section bounded search");
endfunction

function [lower, upper, template] = mp_opt_bounds (lower, upper)
  if (isa (lower, "mp"))
    if (! isreal (lower) || ! isscalar (lower) || ! isfinite (lower))
      error ("mplapack:optimization:InvalidBounds", ...
             "fminbnd bounds must be finite real mp scalars");
    endif
  elseif (isnumeric (lower) && isreal (lower) && isscalar (lower) ...
          && isfinite (lower))
    lower = mp (lower);
  else
    error ("mplapack:optimization:InvalidBounds", ...
           "fminbnd bounds must be finite real scalars");
  endif
  template = lower;
  if (isa (upper, "mp"))
    if (! isreal (upper) || ! isscalar (upper) || ! isfinite (upper))
      error ("mplapack:optimization:InvalidBounds", ...
             "fminbnd bounds must be finite real mp scalars");
    endif
  elseif (isnumeric (upper) && isreal (upper) && isscalar (upper) ...
          && isfinite (upper))
    upper = template * 0 + upper;
  else
    error ("mplapack:optimization:InvalidBounds", ...
           "fminbnd bounds must be finite real scalars");
  endif
endfunction

function output = mp_opt_output (iterations, evaluations, message, algorithm)
  output = struct ("iterations", iterations, "funcCount", evaluations, ...
                   "algorithm", algorithm, "message", message);
endfunction
