## SPDX-License-Identifier: BSD-2-Clause

function options = mp_quad_options (arguments, template)
  ## Parse the deliberately small, MP-only integral/quadgk option surface.
  ## Numeric control values are converted from their supplied representation
  ## once, at the operation precision; they are never used as binary64
  ## quadrature constants.
  scale = abs (template);
  if (scale < mp ("1")), scale = mp ("1"); endif
  options.abs_tol = scale * sqrt (eps (scale));
  options.rel_tol = sqrt (eps (scale));
  options.waypoints = {};
  options.array_valued = false;
  options.max_levels = 8;

  if (isempty (arguments))
    return;
  endif
  if (numel (arguments) == 1 && isstruct (arguments{1}))
    supplied = arguments{1};
    names = fieldnames (supplied);
    for index = 1:numel (names)
      name = lower (names{index});
      value = supplied.(names{index});
      if (strcmp (name, "abstol"))
        options.abs_tol = mp_quad_option_mp (value, template, "AbsTol");
      elseif (strcmp (name, "reltol"))
        options.rel_tol = mp_quad_option_mp (value, template, "RelTol");
      elseif (strcmp (name, "waypoints"))
        options.waypoints = mp_quad_waypoints (value, template);
      elseif (strcmp (name, "arrayvalued"))
        if (! islogical (value) || ! isscalar (value))
          error ("mplapack:quad:InvalidOptions", ...
                 "ArrayValued must be a scalar logical");
        endif
        options.array_valued = value;
      elseif (strcmp (name, "maxlevels"))
        if (! isnumeric (value) || ! isscalar (value) || value < 1 ...
            || value != fix (value))
          error ("mplapack:quad:InvalidOptions", ...
                 "MaxLevels must be a positive integer");
        endif
        options.max_levels = double (value);
      else
        error ("mplapack:quad:InvalidOptions", ...
               "unsupported quadrature option '%s'", names{index});
      endif
    endfor
  else
    if (mod (numel (arguments), 2) != 0)
      error ("mplapack:quad:InvalidOptions", ...
             "quadrature options must be a struct or name/value pairs");
    endif
    for index = 1:2:numel (arguments)
      name = arguments{index};
      if (! ischar (name))
        error ("mplapack:quad:InvalidOptions", "option names must be text");
      endif
      value = arguments{index + 1};
      key = lower (name);
      if (strcmp (key, "abstol"))
        options.abs_tol = mp_quad_option_mp (value, template, "AbsTol");
      elseif (strcmp (key, "reltol"))
        options.rel_tol = mp_quad_option_mp (value, template, "RelTol");
      elseif (strcmp (key, "waypoints"))
        options.waypoints = mp_quad_waypoints (value, template);
      elseif (strcmp (key, "arrayvalued"))
        if (! islogical (value) || ! isscalar (value))
          error ("mplapack:quad:InvalidOptions", ...
                 "ArrayValued must be a scalar logical");
        endif
        options.array_valued = value;
      else
        error ("mplapack:quad:InvalidOptions", ...
               "unsupported quadrature option '%s'", name);
      endif
    endfor
  endif
  if (options.array_valued)
    error ("mplapack:quad:Unsupported", ...
           "ArrayValued integrands are not implemented for mp quadrature");
  endif
  if (options.abs_tol <= 0 || options.rel_tol <= 0)
    error ("mplapack:quad:InvalidOptions", ...
           "AbsTol and RelTol must be positive");
  endif
endfunction

function result = mp_quad_option_mp (value, template, name)
  if (isa (value, "mp"))
    result = value;
  elseif (isnumeric (value) && isreal (value) && isscalar (value) ...
          && isfinite (value))
    result = template * 0 + value;
  else
    error ("mplapack:quad:InvalidOptions", ...
           "%s must be a finite scalar", name);
  endif
  if (! isreal (result) || ! isscalar (result) || ! isfinite (result) ...
      || result <= 0)
    error ("mplapack:quad:InvalidOptions", ...
           "%s must be a positive finite scalar", name);
  endif
endfunction

function result = mp_quad_waypoints (value, template)
  if (isempty (value))
    result = {};
    return;
  endif
  result = {};
  if (isa (value, "mp"))
    if (! isreal (value))
      error ("mplapack:quad:InvalidOptions", ...
             "Waypoints must be real finite values");
    endif
    for index = 1:numel (value)
      point = mp_quad_element (value, index);
      if (! isfinite (point)), error ("mplapack:quad:InvalidOptions", ...
                                      "Waypoints must be finite"); endif
      result{end + 1} = point;
    endfor
  elseif (isnumeric (value) && isreal (value))
    for index = 1:numel (value)
      if (! isfinite (value(index)))
        error ("mplapack:quad:InvalidOptions", ...
               "Waypoints must be finite");
      endif
      result{end + 1} = template * 0 + value(index);
    endfor
  else
    error ("mplapack:quad:InvalidOptions", ...
           "Waypoints must be real finite values");
  endif
endfunction
