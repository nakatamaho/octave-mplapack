## SPDX-License-Identifier: BSD-2-Clause

function [root, fval, info, output] = fzero (fun, x0, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{x} =} fzero (@var{fun}, @var{x0})
  ## @deftypefnx {} {@var{x} =} fzero (@dots{}, @var{options})
  ## Solve a real scalar equation with MP callback values.  A two-element mp
  ## x0 supplies a bracket; a scalar x0 is expanded to find one.  The callback
  ## must return a real scalar mp value.
  ## @end deftypefn
  if (nargin < 2 || nargin > 3 || ! isa (fun, "function_handle"))
    error ("mplapack:solver:InvalidArguments", ...
           "fzero expects a function handle, starting point, and options");
  endif
  if (isa (x0, "mp"))
    template = mp_solver_element (x0, 1);
  elseif (isnumeric (x0) && isreal (x0))
    template = mp (x0(1));
    x0 = template * 0 + x0;
  else
    error ("mplapack:solver:InvalidInput", "fzero starting point must be real mp data");
  endif
  options = [];
  if (nargin == 3), options = varargin{1}; endif
  [tolx, unused_tolfun, max_iter] = mp_solver_options (options, template);
  if (numel (x0) == 2)
    a = mp_solver_element (x0, 1);
    b = mp_solver_element (x0, 2);
    if (b < a), temporary = a; a = b; b = temporary; endif
  elseif (numel (x0) == 1)
    center = mp_solver_element (x0, 1);
    step = template * 0 + 1;
    a = center - step;
    b = center + step;
    fa = mp_solver_call (fun, a);
    fb = mp_solver_call (fun, b);
    evaluations = 2;
    for expansion = 1:64
      if (fa == 0), root = a; fval = fa; info = 1; output = mp_solver_output (0, evaluations, "exact root"); return; endif
      if (fb == 0), root = b; fval = fb; info = 1; output = mp_solver_output (0, evaluations, "exact root"); return; endif
      if ((fa < 0 && fb > 0) || (fa > 0 && fb < 0)), break; endif
      step = step * 2;
      a = center - step;
      b = center + step;
      fa = mp_solver_call (fun, a);
      fb = mp_solver_call (fun, b);
      evaluations += 2;
    endfor
    if (! ((fa < 0 && fb > 0) || (fa > 0 && fb < 0)))
      error ("mplapack:solver:NoBracket", "fzero could not find a sign-changing bracket");
    endif
  else
    error ("mplapack:solver:InvalidInput", "fzero x0 must be a scalar or two-element bracket");
  endif

  if (! exist ("evaluations", "var")), evaluations = 0; endif
  if (! exist ("fa", "var")), fa = mp_solver_call (fun, a); fb = mp_solver_call (fun, b); evaluations += 2; endif
  if (fa == 0), root = a; fval = fa; info = 1; output = mp_solver_output (0, evaluations, "exact root"); return; endif
  if (fb == 0), root = b; fval = fb; info = 1; output = mp_solver_output (0, evaluations, "exact root"); return; endif

  info = 0;
  root = (a + b) / 2;
  fval = mp_solver_call (fun, root);
  evaluations += 1;
  iterations = 0;
  for iteration = 1:max_iter
    iterations = iteration;
    if (abs (b - a) <= tolx * (1 + abs (root)) || fval == 0)
      info = 1;
      break;
    endif
    denominator = fb - fa;
    if (denominator != 0)
      candidate = (a * fb - b * fa) / denominator;
    else
      candidate = (a + b) / 2;
    endif
    if (!(candidate > a && candidate < b))
      candidate = (a + b) / 2;
    endif
    root = candidate;
    fval = mp_solver_call (fun, root);
    evaluations += 1;
    if (fval == 0)
      info = 1;
      break;
    endif
    if ((fa < 0 && fval > 0) || (fa > 0 && fval < 0))
      b = root;
      fb = fval;
    else
      a = root;
      fa = fval;
    endif
    if (abs (b - a) <= tolx * (1 + abs (root)))
      root = (a + b) / 2;
      fval = mp_solver_call (fun, root);
      evaluations += 1;
      info = 1;
      break;
    endif
  endfor
  if (info == 0)
    root = (a + b) / 2;
    fval = mp_solver_call (fun, root);
    evaluations += 1;
  endif
  if (info == 1), message = "converged"; else, message = "maximum iterations reached"; endif
  output = mp_solver_output (iterations, evaluations, message);
endfunction

function value = mp_solver_call (fun, argument)
  value = fun (argument);
  if (! isa (value, "mp") || ! isreal (value) || ! isscalar (value))
    error ("mplapack:solver:CallbackContract", ...
           "fzero callback must return one real scalar mp value");
  endif
  if (! isfinite (value))
    error ("mplapack:solver:CallbackContract", "fzero callback returned a non-finite value");
  endif
endfunction

function output = mp_solver_output (iterations, evaluations, message)
  output = struct ("iterations", iterations, "funcCount", evaluations, ...
                   "algorithm", "MPFR bracketed secant-bisection", ...
                   "message", message);
endfunction
