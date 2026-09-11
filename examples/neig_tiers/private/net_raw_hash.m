% Deterministic raw-value binding hash for measured profile records.
function digest = net_raw_hash (value, label)
  if (nargin != 2 || ! ischar (label))
    error ("mplapack:neigt:Hash", "invalid raw hash arguments");
  endif
  if (isa (value, "mp"))
    tokens = cell (1, numel (value));
    for index = 1:numel (value)
      tokens{index} = char (value(index));
    endfor
    joined = tokens{1};
    for index = 2:numel (tokens)
      joined = [joined, ";", tokens{index}];
    endfor
    text = sprintf ("%s|mp|%dx%d|%s", label, rows (value), columns (value), joined);
  elseif (isa (value, "double"))
    text = sprintf ("%s|double|%dx%d|", label, rows (value), columns (value));
    tokens = cell (1, numel (value));
    for index = 1:numel (value)
      tokens{index} = sprintf ("%.17g", value(index));
    endfor
    joined = tokens{1};
    for index = 2:numel (tokens)
      joined = [joined, ";", tokens{index}];
    endfor
    text = [text, joined];
  else
    error ("mplapack:neigt:Hash", "raw hash accepts MP or double values");
  endif
  digest = hash ("sha256", text);
endfunction
