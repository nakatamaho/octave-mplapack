## SPDX-License-Identifier: BSD-2-Clause

function [argument, value, exitflag, output] = fminsearch (fun, initial, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{x} =} fminsearch (@var{fun}, @var{x0})
  ## @deftypefnx {} {[@var{x}, @var{fval}, @var{exitflag}, @var{output}] =} fminsearch (@dots{}, @var{options})
  ## Minimize a real scalar MP objective with an arbitrary-precision
  ## Nelder-Mead simplex.
  ## @end deftypefn
  if (nargin < 2 || nargin > 3 || ! isa (fun, "function_handle"))
    error ("mplapack:optimization:InvalidArguments", ...
           "fminsearch expects a function handle, initial mp data, and options");
  endif
  [initial, template, shape] = mp_opt_initial (initial);
  dimension = numel (initial);
  options = mp_opt_options (varargin, template, dimension, "fminsearch");
  zero = mp_opt_element (initial, 1) * 0;
  simplex = repmat (zero, dimension, dimension + 1);
  for row = 1:dimension
    simplex = mp_solver_put (simplex, row, 1, mp_opt_element (initial, row));
  endfor
  for vertex = 2:(dimension + 1)
    for row = 1:dimension
      simplex = mp_solver_put (simplex, row, vertex, ...
                              mp_opt_element (initial, row));
    endfor
    coordinate = mp_opt_element (initial, vertex - 1);
    if (abs (coordinate) > mp ("1"))
      step = mp ("0.05") * abs (coordinate);
    else
      step = mp ("0.00025");
    endif
    simplex = mp_solver_put (simplex, vertex - 1, vertex, coordinate + step);
  endfor

  values = repmat (zero, dimension + 1, 1);
  evaluations = 0;
  for vertex = 1:(dimension + 1)
    values = mp_solver_put (values, vertex, 1, ...
                            mp_opt_call (fun, mp_opt_vertex (simplex, vertex), shape));
    evaluations += 1;
  endfor

  ## Standard Nelder-Mead coefficients.  They are exact decimal MP values,
  ## not constants obtained by converting binary64 literals.
  alpha = mp ("1");
  gamma = mp ("2");
  rho = mp ("0.5");
  sigma = mp ("0.5");
  exitflag = 0;
  iterations = 0;
  for iteration = 1:options.max_iter
    iterations = iteration;
    order = mp_opt_order (values);
    best_index = order(1);
    worst_index = order(end);
    second_worst_index = order(end - 1);
    best = mp_opt_vertex (simplex, best_index);
    worst = mp_opt_vertex (simplex, worst_index);
    diameter = mp ("0");
    for row = 1:dimension
      distance = abs (mp_opt_element (best, row) ...
                     - mp_opt_element (worst, row));
      if (distance > diameter), diameter = distance; endif
    endfor
    best_value = mp_opt_element (values, best_index);
    spread = abs (mp_opt_element (values, worst_index) - best_value);
    if (diameter <= options.tol_x * (mp ("1") + mp_opt_vector_scale (best)) ...
        && spread <= options.tol_fun * (mp ("1") + abs (best_value)))
      exitflag = 1;
      break;
    endif
    centroid = repmat (zero, dimension, 1);
    for ordered = 1:dimension
      vertex = mp_opt_vertex (simplex, order(ordered));
      centroid += vertex;
    endfor
    centroid = centroid / mp (dimension);
    reflected = centroid + alpha * (centroid - worst);
    reflected_value = mp_opt_call (fun, reflected, shape);
    evaluations += 1;
    if (reflected_value < best_value)
      expanded = centroid + gamma * (reflected - centroid);
      expanded_value = mp_opt_call (fun, expanded, shape);
      evaluations += 1;
      if (expanded_value < reflected_value)
        simplex = mp_opt_replace_vertex (simplex, expanded, worst_index);
        values = mp_solver_put (values, worst_index, 1, expanded_value);
      else
        simplex = mp_opt_replace_vertex (simplex, reflected, worst_index);
        values = mp_solver_put (values, worst_index, 1, reflected_value);
      endif
    elseif (reflected_value < mp_opt_element (values, second_worst_index))
      simplex = mp_opt_replace_vertex (simplex, reflected, worst_index);
      values = mp_solver_put (values, worst_index, 1, reflected_value);
    else
      if (reflected_value < mp_opt_element (values, worst_index))
        contracted = centroid + rho * (reflected - centroid);
      else
        contracted = centroid + rho * (worst - centroid);
      endif
      contracted_value = mp_opt_call (fun, contracted, shape);
      evaluations += 1;
      if (contracted_value < mp_opt_element (values, worst_index))
        simplex = mp_opt_replace_vertex (simplex, contracted, worst_index);
        values = mp_solver_put (values, worst_index, 1, contracted_value);
      else
        for ordered = 2:(dimension + 1)
          vertex_index = order(ordered);
          current = mp_opt_vertex (simplex, vertex_index);
          shrunk = best + sigma * (current - best);
          simplex = mp_opt_replace_vertex (simplex, shrunk, vertex_index);
          values = mp_solver_put (values, vertex_index, 1, ...
                                  mp_opt_call (fun, shrunk, shape));
          evaluations += 1;
        endfor
      endif
    endif
    if (evaluations >= options.max_fun_evals)
      break;
    endif
  endfor
  order = mp_opt_order (values);
  argument = reshape (mp_opt_vertex (simplex, order(1)), shape(1), shape(2));
  value = mp_opt_element (values, order(1));
  if (exitflag == 1)
    message = "converged";
  elseif (evaluations >= options.max_fun_evals)
    message = "maximum function evaluations reached";
  else
    message = "maximum iterations reached";
  endif
  output = struct ("iterations", iterations, "funcCount", evaluations, ...
                   "algorithm", "MP Nelder-Mead simplex", "message", message);
endfunction

function [value, template, shape] = mp_opt_initial (value)
  if (isa (value, "mp"))
    if (! isreal (value) || isempty (value))
      error ("mplapack:optimization:InvalidInput", ...
             "fminsearch initial point must be nonempty real mp data");
    endif
    template = mp_opt_element (value, 1);
  elseif (isnumeric (value) && isreal (value) && ! isempty (value))
    template = mp (value(1));
    value = template * 0 + value;
  else
    error ("mplapack:optimization:InvalidInput", ...
           "fminsearch initial point must be nonempty real data");
  endif
  shape = size (value);
  value = reshape (value, numel (value), 1);
endfunction

function order = mp_opt_order (values)
  count = numel (values);
  order = 1:count;
  for index = 2:count
    candidate = order(index);
    position = index - 1;
    while (position >= 1 ...
           && mp_opt_element (values, candidate) ...
              < mp_opt_element (values, order(position)))
      order(position + 1) = order(position);
      position -= 1;
    endwhile
    order(position + 1) = candidate;
  endfor
endfunction

function result = mp_opt_replace_vertex (simplex, vertex, column)
  [dimension, unused] = size (simplex);
  result = simplex;
  for row = 1:dimension
    result = mp_solver_put (result, row, column, mp_opt_element (vertex, row));
  endfor
endfunction

function result = mp_opt_vector_scale (value)
  result = mp ("1");
  for index = 1:numel (value)
    candidate = abs (mp_opt_element (value, index));
    if (candidate > result), result = candidate; endif
  endfor
endfunction
