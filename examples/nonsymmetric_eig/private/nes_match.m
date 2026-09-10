% Deterministic minimum-bottleneck one-to-one eigenvalue matching.
function result = nes_match (computed, reference, kind, varargin)
  if (nargin < 3 || nargin > 5 || ! isa (computed, "mp")
      || ! isa (reference, "mp") || ! ischar (kind))
    error ("NEIG:MatchArguments", ...
           "nes_match expects two mp vectors, a cost kind, and optional circle data");
  endif
  computed = computed(:);
  reference = reference(:);
  n = numel (computed);
  if (n < 1 || numel (reference) != n)
    error ("NEIG:MatchSize", "computed and reference spectra must have equal nonzero size");
  endif
  if (! any (strcmp (kind, {"absolute", "relative", "circle"})))
    error ("NEIG:MatchKind", "matching kind must be absolute, relative, or circle");
  endif
  if (! all (isfinite (computed)) || ! all (isfinite (reference)))
    error ("NEIG:MatchFinite", "matching spectra must contain only finite values");
  endif

  if (strcmp (kind, "circle"))
    if (nargin != 5 || ! isa (varargin{1}, "mp") || ! isa (varargin{2}, "mp")
        || ! isscalar (varargin{1}) || ! isscalar (varargin{2})
        || varargin{2} == mp ("0"))
      error ("NEIG:MatchCircle", "circle matching requires nonzero mp center and radius");
    endif
    center = varargin{1};
    radius = varargin{2};
  elseif (nargin != 3)
    error ("NEIG:MatchArguments", "non-circle matching does not accept circle data");
  endif

  costs = mp (zeros (n, n));
  for row = 1:n
    for col = 1:n
      if (strcmp (kind, "absolute"))
        costs(row, col) = abs (computed(row) - reference(col));
      elseif (strcmp (kind, "relative"))
        denominator = abs (reference(col));
        if (denominator == mp ("0"))
          error ("NEIG:MatchReferenceZero", ...
                 "relative matching requires nonzero reference roots");
        endif
        costs(row, col) = abs (computed(row) - reference(col)) / denominator;
      else
        costs(row, col) = abs ((computed(row) - center) / radius - reference(col));
      endif
    endfor
  endfor
  if (! all (isfinite (costs)))
    error ("NEIG:MatchFinite", "matching cost matrix contains a nonfinite value");
  endif

  candidates = sort (costs(:));
  lower = 1;
  upper = numel (candidates);
  while (lower < upper)
    middle = floor ((lower + upper) / 2);
    if (has_perfect_matching (costs, candidates(middle)))
      upper = middle;
    else
      lower = middle + 1;
    endif
  endwhile
  threshold = candidates(lower);
  [possible, mapping] = find_perfect_matching (costs, threshold);
  if (! possible)
    error ("NEIG:MatchInternal", "final bottleneck threshold has no perfect matching");
  endif
  for row = 1:n
    if (mapping(row) < 1 || mapping(row) > n)
      error ("NEIG:MatchInternal", "matching did not return a bijection");
    endif
  endfor
  if (numel (unique (mapping)) != n)
    error ("NEIG:MatchInternal", "matching did not return distinct reference indices");
  endif
  result = struct ("kind", kind, "threshold", threshold, "mapping", mapping, ...
                   "costs", costs, "status", "resolved");
endfunction

function answer = has_perfect_matching (costs, threshold)
  [answer, unused] = find_perfect_matching (costs, threshold);
endfunction

function [possible, mapping] = find_perfect_matching (costs, threshold)
  n = rows (costs);
  matched_column = zeros (1, n);
  seen = false (1, n);
  for row = 1:n
    seen(:) = false;
    if (! visit_row (row))
      possible = false;
      mapping = zeros (1, n);
      return;
    endif
  endfor
  mapping = zeros (1, n);
  for col = 1:n
    if (matched_column(col) == 0)
      possible = false;
      return;
    endif
    mapping(matched_column(col)) = col;
  endfor
  possible = true;

  function found = visit_row (row)
    found = false;
    for col = 1:n
      if (costs(row, col) <= threshold && ! seen(col))
        seen(col) = true;
        if (matched_column(col) == 0 || visit_row (matched_column(col)))
          matched_column(col) = row;
          found = true;
          return;
        endif
      endif
    endfor
  endfunction
endfunction
