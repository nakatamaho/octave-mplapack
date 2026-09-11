% Example-local facade over the previously tested MP bottleneck matcher.
function result = net_match (computed, reference, kind, varargin)
  here = fileparts (mfilename ("fullpath"));
  repo_root = fileparts (fileparts (fileparts (here)));
  old_private = fullfile (repo_root, "examples", "nonsymmetric_eig", ...
                          "private");
  if (exist (fullfile (old_private, "nes_match.m"), "file") != 2)
    error ("mplapack:neigt:Matching", "existing NEIG matcher is unavailable");
  endif
  added = false;
  if (! any (strcmp (strsplit (path (), pathsep), old_private)))
    addpath (old_private);
    added = true;
  endif
  unwind_protect
    if (nargin == 3)
      result = nes_match (computed, reference, kind);
    elseif (nargin == 5)
      result = nes_match (computed, reference, kind, varargin{1}, varargin{2});
    else
      error ("mplapack:neigt:Matching", "invalid matching arguments");
    endif
    result.method = "minimum_bottleneck_bijective_v1";
    result.paper_algorithm_reproduction = false;
    if (added)
      rmpath (old_private);
    endif
  unwind_protect_cleanup
    if (added && any (strcmp (strsplit (path (), pathsep), old_private)))
      rmpath (old_private);
    endif
  end_unwind_protect
endfunction
