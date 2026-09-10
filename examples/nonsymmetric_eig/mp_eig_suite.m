% Entry point for the repository-local difficult nonsymmetric eigensystem suite.
function results = mp_eig_suite (profile, options)
  if (nargin < 1)
    profile = "smoke";
  endif
  if (nargin > 2)
    error ("NEIG:Arguments", "mp_eig_suite accepts a profile and optional options");
  endif
  if (! ischar (profile) || rows (profile) != 1)
    error ("NEIG:Profile", "profile must be a character row");
  endif
  if (! any (strcmp (profile, {"smoke", "demo", "stress"})))
    error ("NEIG:Profile", "profile must be smoke, demo, or stress");
  endif

  defaults = struct ("output_dir", "", "plot", false, "family", "all");
  if (nargin == 1)
    options = defaults;
  elseif (! isstruct (options) || ! isscalar (options))
    error ("NEIG:Options", "options must be a scalar struct");
  else
    names = fieldnames (options);
    for k = 1:numel (names)
      if (! isfield (defaults, names{k}))
        error ("NEIG:Options", "unknown option name: %s", names{k});
      endif
    endfor
    options = merge_options (defaults, options);
  endif
  if (! (ischar (options.output_dir) && rows (options.output_dir) == 1))
    error ("NEIG:Options", "output_dir must be a character row");
  endif
  if (! (islogical (options.plot) && isscalar (options.plot)))
    error ("NEIG:Options", "plot must be a logical scalar");
  endif
  if (! ischar (options.family) || rows (options.family) != 1)
    error ("NEIG:Options", "family must be a character row");
  endif
  if (! any (strcmp (options.family, {"all", "hadamard", "frank", ...
                                     "companion", "forsythe"})))
    error ("NEIG:Options", "unknown family: %s", options.family);
  endif
  if (! strcmp (options.family, "hadamard"))
    error ("NEIG:DeferredFamily", ...
           "this family is not implemented yet; no family was silently skipped");
  endif

  % NEIG01 deliberately stops before the eigensolve.  Later milestones connect
  % this validated skeleton to the matching and diagnostic engine.
  selected = nes_cases (profile, options.family);
  results = struct ("schema", "neig-v1", "profile", profile, ...
                    "family", options.family, "options", options, ...
                    "cases", selected, "rows", [], "ok", false, ...
                    "status", "NEIG01_skeleton_only");
endfunction

function result = merge_options (defaults, supplied)
  result = defaults;
  names = fieldnames (supplied);
  for k = 1:numel (names)
    result.(names{k}) = supplied.(names{k});
  endfor
endfunction
