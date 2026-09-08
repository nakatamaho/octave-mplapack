## SPDX-License-Identifier: BSD-2-Clause

function [solution, fval, info, output] = fsolve (fun, x0, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{x} =} fsolve (@var{fun}, @var{x0})
  ## @deftypefnx {} {@var{x} =} fsolve (@dots{}, @var{options})
  ## Solve a real MP nonlinear system with MP Newton steps and MP finite
  ## differences.  With @code{Jacobian="on"}, the callback returns
  ## @code{[residual,jacobian]} using MP values.
  ## @end deftypefn
  if (nargin < 2 || nargin > 3 || ! isa (fun, "function_handle"))
    error ("mplapack:solver:InvalidArguments", "fsolve expects a function handle, x0, and options");
  endif
  if (isa (x0, "mp"))
    template = mp_solver_element (x0, 1);
    original_rows = rows (x0);
    original_columns = columns (x0);
    x = reshape (x0, numel (x0), 1);
  elseif (isnumeric (x0) && isreal (x0))
    template = mp (x0(1));
    original_rows = rows (x0);
    original_columns = columns (x0);
    x = reshape (template * 0 + x0, numel (x0), 1);
  else
    error ("mplapack:solver:InvalidInput", "fsolve x0 must be real mp data");
  endif
  options = [];
  if (nargin == 3), options = varargin{1}; endif
  [tolx, tolfun, max_iter] = mp_solver_options (options, x);
  jacobian_on = false;
  if (! isempty (options) && isfield (options, "Jacobian")
      && ischar (options.Jacobian) && strcmp (lower (options.Jacobian), "on"))
    jacobian_on = true;
  endif

  [residual, jacobian, evaluations] = mp_solver_system_call (fun, x, jacobian_on);
  if (numel (residual) != numel (x))
    error ("mplapack:solver:DimensionMismatch", "fsolve residual size must match x0");
  endif
  residual = reshape (residual, numel (residual), 1);
  info = 0;
  iterations = 0;
  for iteration = 1:max_iter
    iterations = iteration;
    residual_norm = norm (residual);
    x_norm = norm (x);
    if (residual_norm <= tolfun * (1 + x_norm))
      info = 1;
      break;
    endif
    if (! jacobian_on)
      jacobian = mp_solver_fd_jacobian (fun, x, residual);
      evaluations += numel (x);
    endif
    if (! isa (jacobian, "mp") || ! isreal (jacobian)
        || rows (jacobian) != numel (x) || columns (jacobian) != numel (x))
      error ("mplapack:solver:CallbackContract", "fsolve Jacobian must be a real square mp matrix");
    endif
    step = -(jacobian \ residual);
    if (! isa (step, "mp")), error ("mplapack:solver:CallbackContract", "fsolve step lost mp type"); endif
    step_norm = norm (step);
    if (step_norm <= tolx * (1 + x_norm))
      x = x + step;
      [residual, jacobian, calls] = mp_solver_system_call (fun, x, jacobian_on);
      evaluations += calls;
      residual = reshape (residual, numel (residual), 1);
      info = 1;
      break;
    endif
    trial = x + step;
    [trial_residual, unused_jacobian, calls] = mp_solver_system_call (fun, trial, false);
    evaluations += calls;
    trial_residual = reshape (trial_residual, numel (trial_residual), 1);
    damping = mp ("1");
    for backtrack = 1:16
      if (norm (trial_residual) <= residual_norm), break; endif
      damping = damping * mp ("0.5");
      trial = x + damping * step;
      [trial_residual, unused_jacobian, calls] = mp_solver_system_call (fun, trial, false);
      evaluations += calls;
      trial_residual = reshape (trial_residual, numel (trial_residual), 1);
    endfor
    x = trial;
    residual = trial_residual;
    if (jacobian_on)
      [unused_residual, jacobian, calls] = mp_solver_system_call (fun, x, true);
      evaluations += calls;
    endif
  endfor
  if (info == 0)
    [residual, unused_jacobian, calls] = mp_solver_system_call (fun, x, false);
    evaluations += calls;
    residual = reshape (residual, numel (residual), 1);
  endif
  solution = reshape (x, original_rows, original_columns);
  fval = reshape (residual, original_rows, original_columns);
  if (info == 1), message = "converged"; else, message = "maximum iterations reached"; endif
  output = struct ("iterations", iterations, "funcCount", evaluations, ...
                   "algorithm", "MPFR Newton with MPFR finite differences", ...
                   "message", message);
endfunction

function [residual, jacobian, evaluations] = mp_solver_system_call (fun, x, request_jacobian)
  if (request_jacobian)
    [residual, jacobian] = fun (x);
    evaluations = 1;
  else
    residual = fun (x);
    jacobian = [];
    evaluations = 1;
  endif
  if (! isa (residual, "mp") || ! isreal (residual) || isempty (residual)
      || ! isfinite (residual))
    error ("mplapack:solver:CallbackContract", "fsolve callback must return finite real mp residuals");
  endif
  if (request_jacobian && (! isa (jacobian, "mp") || ! isreal (jacobian)))
    error ("mplapack:solver:CallbackContract", "fsolve Jacobian callback result must be real mp data");
  endif
endfunction

function jacobian = mp_solver_fd_jacobian (fun, x, residual)
  n = numel (x);
  zero = mp_solver_element (x, 1) * 0;
  jacobian = repmat (zero, n, n);
  for column = 1:n
    coordinate = mp_solver_element (x, column);
    scale = abs (coordinate);
    if (scale < 1), scale = coordinate * 0 + 1; endif
    step = sqrt (eps (scale)) * scale;
    if (step == 0), step = sqrt (eps (scale)); endif
    perturbed = mp_solver_put (x, column, 1, coordinate + step);
    perturbed_residual = fun (perturbed);
    if (! isa (perturbed_residual, "mp") || ! isreal (perturbed_residual)
        || numel (perturbed_residual) != n || ! isfinite (perturbed_residual))
      error ("mplapack:solver:CallbackContract", "finite-difference callback must return a real mp vector");
    endif
    difference = (reshape (perturbed_residual, n, 1) - residual) / step;
    for row = 1:n
      jacobian = mp_solver_put (jacobian, row, column, mp_solver_element (difference, row));
    endfor
  endfor
endfunction
