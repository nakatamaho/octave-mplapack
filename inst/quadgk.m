## SPDX-License-Identifier: BSD-2-Clause

function [result, error_estimate] = quadgk (fun, a, b, varargin)
  ## -*- texinfo -*-
  ## @deftypefn {} {@var{q} =} quadgk (@var{fun}, @var{a}, @var{b})
  ## @deftypefnx {} {[@var{q}, @var{err}] =} quadgk (@dots{}, @var{options})
  ## Adaptive arbitrary-precision one-dimensional quadrature.  This
  ## implementation uses MPFR/MPC tanh-sinh quadrature, a robust
  ## double-exponential method compatible with endpoint singularities.
  ## @end deftypefn
  if (nargin < 3 || ! isa (fun, "function_handle"))
    error ("mplapack:quad:InvalidArguments", ...
           "quadgk expects a function handle and two endpoints");
  endif
  [a, b, template] = mp_quad_endpoints (a, b);
  options = mp_quad_options (varargin, template);
  if (! isempty (options.waypoints) && (isinf (a) || isinf (b)))
    error ("mplapack:quad:Unsupported", ...
           "Waypoints with an infinite endpoint are not supported");
  endif
  if (a == b)
    result = template * 0;
    error_estimate = template * 0;
    return;
  endif

  points = {a};
  if (! isempty (options.waypoints))
    for index = 1:numel (options.waypoints)
      point = options.waypoints{index};
      if (point > a && point < b), points{end + 1} = point; endif
    endfor
  endif
  points{end + 1} = b;
  points = mp_quad_sort_points (points);
  result = [];
  error_estimate = [];
  for index = 1:(numel (points) - 1)
    [piece, piece_error] = mp_quad_tanh_sinh (fun, points{index}, ...
                                              points{index + 1}, options);
    if (isempty (result))
      result = piece;
      error_estimate = piece_error;
    else
      result += piece;
      error_estimate += piece_error;
    endif
  endfor
endfunction

function [left, right, template] = mp_quad_endpoints (a, b)
  if (isa (a, "mp"))
    if (! isreal (a) || ! isscalar (a)), error ("mplapack:quad:InvalidInterval", ...
                                                 "endpoints must be real scalars"); endif
    left = a;
  elseif (isnumeric (a) && isreal (a) && isscalar (a))
    left = mp (a);
  else
    error ("mplapack:quad:InvalidInterval", "endpoints must be real scalars");
  endif
  template = left;
  if (isa (b, "mp"))
    if (! isreal (b) || ! isscalar (b)), error ("mplapack:quad:InvalidInterval", ...
                                                 "endpoints must be real scalars"); endif
    right = b;
  elseif (isnumeric (b) && isreal (b) && isscalar (b))
    right = template * 0 + b;
  else
    error ("mplapack:quad:InvalidInterval", "endpoints must be real scalars");
  endif
  if (isnan (left) || isnan (right))
    error ("mplapack:quad:InvalidInterval", "endpoints must not be NaN");
  endif
endfunction

function points = mp_quad_sort_points (points)
  ## Insertion sort keeps waypoint ordering in MP comparisons rather than
  ## converting the grid to builtin doubles.
  for index = 2:numel (points)
    candidate = points{index};
    position = index - 1;
    while (position >= 1 && points{position} > candidate)
      points{position + 1} = points{position};
      position -= 1;
    endwhile
    points{position + 1} = candidate;
  endfor
endfunction
