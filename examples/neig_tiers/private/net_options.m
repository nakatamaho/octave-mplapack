% Parse strict NEIGT facade options.
function options = net_options (profile, supplied)
  if (nargin < 1 || nargin > 2 || ! (ischar (profile) || isstring (profile)))
    error ("mplapack:neigt:Options", "profile must be smoke, demo, or stress");
  endif
  profile = char (profile);
  if (! any (strcmp (profile, {"smoke", "demo", "stress"})))
    error ("mplapack:neigt:Options", ...
           "profile must be smoke, demo, or stress");
  endif
  defaults = struct ("tier", "all", "output_dir", "", "plot", false);
  if (nargin == 1 || isempty (supplied))
    supplied = struct ();
  endif
  if (! isstruct (supplied) || ! isscalar (supplied))
    error ("mplapack:neigt:Options", "options must be a scalar struct");
  endif
  fields = fieldnames (supplied);
  for index = 1:numel (fields)
    if (! any (strcmp (fields{index}, fieldnames (defaults))))
      error ("mplapack:neigt:Options", ...
             "unknown NEIGT option: %s", fields{index});
    endif
  endfor
  options = defaults;
  for index = 1:numel (fields)
    options.(fields{index}) = supplied.(fields{index});
  endfor
  if (! (ischar (options.tier) || isstring (options.tier)))
    error ("mplapack:neigt:Options", "tier must be a character value");
  endif
  options.tier = char (options.tier);
  if (! any (strcmp (options.tier, {"all", "S", "A", "V-S", "V-A", "V"})))
    error ("mplapack:neigt:Options", ...
           "tier must be all, S, A, V-S, V-A, or V");
  endif
  if (! (ischar (options.output_dir) || isstring (options.output_dir)))
    error ("mplapack:neigt:Options", ...
           "output_dir must be a character value");
  endif
  options.output_dir = char (options.output_dir);
  if (! islogical (options.plot) || ! isscalar (options.plot))
    error ("mplapack:neigt:Options", "plot must be a logical scalar");
  endif
  options.profile = profile;
endfunction
