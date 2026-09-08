## SPDX-License-Identifier: BSD-2-Clause

function options = mp_opt_options (arguments, template, dimension, method)
  scale = abs (template);
  if (scale < mp ("1")), scale = mp ("1"); endif
  options.tol_x = sqrt (eps (scale));
  options.tol_fun = sqrt (eps (scale));
  options.max_iter = max (100, 4 * double (mpbits ()));
  options.max_fun_evals = max (200, 200 * dimension);
  options.display = "off";
  if (isempty (arguments)), return; endif
  if (numel (arguments) == 1 && isstruct (arguments{1}))
    supplied = arguments{1};
    names = fieldnames (supplied);
    for index = 1:numel (names)
      options = mp_opt_set_option (options, names{index}, supplied.(names{index}), ...
                                   template, method);
    endfor
  else
    if (mod (numel (arguments), 2) != 0)
      error ("mplapack:optimization:InvalidOptions", ...
             "options must be a struct or name/value pairs");
    endif
    for index = 1:2:numel (arguments)
      if (! ischar (arguments{index}))
        error ("mplapack:optimization:InvalidOptions", ...
               "option names must be text");
      endif
      options = mp_opt_set_option (options, arguments{index}, ...
                                   arguments{index + 1}, template, method);
    endfor
  endif
endfunction

function options = mp_opt_set_option (options, supplied_name, value, template, method)
  name = lower (supplied_name);
  if (strcmp (name, "tolx"))
    options.tol_x = mp_opt_option_mp (value, template, "TolX");
  elseif (strcmp (name, "tolfun"))
    options.tol_fun = mp_opt_option_mp (value, template, "TolFun");
  elseif (strcmp (name, "maxiter"))
    options.max_iter = mp_opt_positive_count (value, "MaxIter");
  elseif (strcmp (name, "maxfunevals"))
    options.max_fun_evals = mp_opt_positive_count (value, "MaxFunEvals");
  elseif (strcmp (name, "display"))
    if (! ischar (value) || ! any (strcmp (lower (value), ...
                                    {"off", "iter", "final", "notify"})))
      error ("mplapack:optimization:InvalidOptions", ...
             "Display must be off, iter, final, or notify");
    endif
    options.display = lower (value);
  elseif (strcmp (name, "funvalcheck"))
    if (! islogical (value) || ! isscalar (value))
      error ("mplapack:optimization:InvalidOptions", ...
             "FunValCheck must be a scalar logical");
    endif
  elseif (strcmp (name, "outputfcn") || strcmp (name, "plotfcns"))
    error ("mplapack:optimization:Unsupported", ...
           "%s is not supported for MP optimization", supplied_name);
  else
    error ("mplapack:optimization:InvalidOptions", ...
           "unsupported %s option '%s'", method, supplied_name);
  endif
  if (options.tol_x <= 0 || options.tol_fun <= 0)
    error ("mplapack:optimization:InvalidOptions", ...
           "TolX and TolFun must be positive");
  endif
endfunction

function result = mp_opt_option_mp (value, template, name)
  if (isa (value, "mp"))
    result = value;
  elseif (isnumeric (value) && isreal (value) && isscalar (value) ...
          && isfinite (value))
    result = template * 0 + value;
  else
    error ("mplapack:optimization:InvalidOptions", ...
           "%s must be a positive finite scalar", name);
  endif
  if (! isreal (result) || ! isscalar (result) || ! isfinite (result) ...
      || result <= 0)
    error ("mplapack:optimization:InvalidOptions", ...
           "%s must be a positive finite scalar", name);
  endif
endfunction

function result = mp_opt_positive_count (value, name)
  if (! isnumeric (value) || ! isscalar (value) || ! isfinite (value) ...
      || value < 1 || value != fix (value))
    error ("mplapack:optimization:InvalidOptions", ...
           "%s must be a positive integer", name);
  endif
  result = double (value);
endfunction
