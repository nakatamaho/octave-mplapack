## SPDX-License-Identifier: BSD-2-Clause

function [result, error_estimate] = mp_quad_tanh_sinh (fun, a, b, options)
  ## Tanh-sinh (double-exponential) quadrature.  The construction is from
  ## the published Mori/Takahasi formula: x=tanh(pi/2*sinh(t)), with its
  ## derivative used as the weight.  Every numerical quantity below is an
  ## mp value.  The level refinement is the adaptive error mechanism.
  if (a == b)
    result = a * 0;
    error_estimate = a * 0;
    return;
  endif

  orientation = mp ("1");
  if (! isinf (a) && ! isinf (b) && b < a)
    temporary = a; a = b; b = temporary;
    orientation = -orientation;
  elseif (isinf (a) && isinf (b) && a > b)
    temporary = a; a = b; b = temporary;
    orientation = -orientation;
  endif

  if (isinf (a) && a > 0)
    error ("mplapack:quad:InvalidInterval", ...
           "the left infinite endpoint must be -Inf");
  endif
  if (isinf (b) && b < 0)
    error ("mplapack:quad:InvalidInterval", ...
           "the right infinite endpoint must be Inf");
  endif
  if (! isinf (a) && ! isfinite (a)), error ("mplapack:quad:InvalidInterval", ...
                                             "invalid left endpoint"); endif
  if (! isinf (b) && ! isfinite (b)), error ("mplapack:quad:InvalidInterval", ...
                                             "invalid right endpoint"); endif

  pi_value = acos (mp ("-1"));
  half_pi = pi_value / mp ("2");
  previous = [];
  result = [];
  error_estimate = [];
  for level = 0:options.max_levels-1
    h = mp ("1") / (mp ("2") ^ (level + 1));
    sum_value = [];
    for integer = 0:4096
      k = integer;
      if (integer == 0)
        [coordinate, weight] = mp_quad_tanh_sinh_node (mp ("0"), ...
                                                        half_pi, a, b);
        value = mp_quad_call (fun, coordinate);
        sum_value = value * weight;
        continue;
      endif
      t = mp (k) * h;
      [coordinate_plus, weight_plus, valid_plus] ...
        = mp_quad_tanh_sinh_node (t, half_pi, a, b);
      [coordinate_minus, weight_minus, valid_minus] ...
        = mp_quad_tanh_sinh_node (-t, half_pi, a, b);
      if (valid_plus)
        value_plus = mp_quad_call (fun, coordinate_plus);
        sum_value += value_plus * weight_plus;
      endif
      if (valid_minus)
        value_minus = mp_quad_call (fun, coordinate_minus);
        sum_value += value_minus * weight_minus;
      endif
      if (! valid_plus && ! valid_minus)
        break;
      endif
    endfor
    if (isempty (result))
      result = sum_value * h * orientation;
      error_estimate = abs (result) * 0;
    else
      candidate = sum_value * h * orientation;
      error_estimate = abs (candidate - result);
      result = candidate;
      scale = abs (result);
      if (scale < mp ("1")), scale = mp ("1"); endif
      tolerance = options.abs_tol;
      relative = options.rel_tol * scale;
      if (relative > tolerance), tolerance = relative; endif
      if (error_estimate <= tolerance)
        return;
      endif
    endif
  endfor
  if (isempty (result))
    error ("mplapack:quad:Failure", "quadrature produced no samples");
  endif
endfunction

function [coordinate, weight, valid] = mp_quad_tanh_sinh_node (t, half_pi, a, b)
  u = tanh (half_pi * sinh (t));
  one = mp ("1");
  valid = (u > -one && u < one && isfinite (u));
  if (! valid)
    coordinate = a * 0;
    weight = a * 0;
    return;
  endif
  denominator = cosh (half_pi * sinh (t));
  weight_u = half_pi * cosh (t) / (denominator * denominator);
  if (! isinf (a) && ! isinf (b))
    center = (a + b) / mp ("2");
    half_width = (b - a) / mp ("2");
    coordinate = center + half_width * u;
    weight = half_width * weight_u;
  elseif (! isinf (a) && isinf (b))
    denominator_map = one - u;
    coordinate = a + (one + u) / denominator_map;
    weight = mp ("2") / (denominator_map * denominator_map) * weight_u;
  elseif (isinf (a) && ! isinf (b))
    denominator_map = one + u;
    coordinate = b - (one - u) / denominator_map;
    weight = mp ("2") / (denominator_map * denominator_map) * weight_u;
  else
    denominator_map = one - u * u;
    coordinate = u / denominator_map;
    weight = (one + u * u) / (denominator_map * denominator_map) * weight_u;
  endif
  valid = valid && isfinite (coordinate) && isfinite (weight);
endfunction

function value = mp_quad_call (fun, coordinate)
  value = fun (coordinate);
  if (! isa (value, "mp") || ! isscalar (value) || ! isfinite (value))
    error ("mplapack:quad:CallbackContract", ...
           "quadrature callback must return one finite mp scalar");
  endif
endfunction
