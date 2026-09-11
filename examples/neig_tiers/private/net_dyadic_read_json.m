% Read and verify a canonical dyadic witness; status fields are never trusted.
function result = net_dyadic_read_json (filename)
  if (nargin != 1 || ! ischar (filename) || isempty (filename))
    error ("mplapack:neigt:Deserialize", "invalid witness path");
  endif
  text = fileread (filename);
  while (! isempty (text) && any (text(end) == char ([9, 10, 13, 32])))
    text(end) = [];
  endwhile
  [result, position] = net_json_value (text, 1);
  position = net_json_skip (text, position);
  if (position <= numel (text))
    error ("mplapack:neigt:Deserialize", "trailing JSON content");
  endif
  if (! isstruct (result) || ! isfield (result, "sha256"))
    error ("mplapack:neigt:Deserialize", "witness hash is missing");
  endif
  supplied_hash = result.sha256;
  result = normalize_record (result);
  expected_hash = hash ("sha256", net_dyadic_canonical (result, false));
  if (! strcmp (supplied_hash, expected_hash))
    error ("mplapack:neigt:Deserialize", "witness content hash mismatch");
  endif
  result.sha256 = supplied_hash;
endfunction

function result = normalize_record (result)
  if (iscell (result.shape))
    shape = zeros (1, numel (result.shape));
    for index = 1:numel (shape)
      shape(index) = result.shape{index};
    endfor
    result.shape = shape;
  endif
  if (! iscell (result.values))
    error ("mplapack:neigt:Deserialize", "values must be a JSON array");
  endif
endfunction

function [value, position] = net_json_value (text, position)
  position = net_json_skip (text, position);
  if (position > numel (text))
    error ("mplapack:neigt:Deserialize", "unexpected JSON end");
  endif
  token = text(position);
  if (token == '{')
    [value, position] = net_json_object (text, position + 1);
  elseif (token == '[')
    [value, position] = net_json_array (text, position + 1);
  elseif (token == '"')
    [value, position] = net_json_string (text, position + 1);
  elseif (token == '-' || (token >= '0' && token <= '9'))
    [value, position] = net_json_number (text, position);
  else
    error ("mplapack:neigt:Deserialize", "unsupported JSON token");
  endif
endfunction

function position = net_json_skip (text, position)
  while (position <= numel (text) && any (text(position) == char ([9,10,13,32])))
    position += 1;
  endwhile
endfunction

function [value, position] = net_json_object (text, position)
  value = struct ();
  position = net_json_skip (text, position);
  if (position <= numel (text) && text(position) == '}')
    position += 1;
    return;
  endif
  while (true)
    if (position > numel (text) || text(position) != '"')
      error ("mplapack:neigt:Deserialize", "object key expected");
    endif
    [key, position] = net_json_string (text, position + 1);
    position = net_json_skip (text, position);
    if (position > numel (text) || text(position) != ':')
      error ("mplapack:neigt:Deserialize", "object colon expected");
    endif
    [item, position] = net_json_value (text, position + 1);
    value.(key) = item;
    position = net_json_skip (text, position);
    if (text(position) == '}')
      position += 1;
      return;
    elseif (text(position) != ',')
      error ("mplapack:neigt:Deserialize", "object separator expected");
    endif
    position = net_json_skip (text, position + 1);
  endwhile
endfunction

function [value, position] = net_json_array (text, position)
  value = {};
  position = net_json_skip (text, position);
  if (position <= numel (text) && text(position) == ']')
    position += 1;
    return;
  endif
  while (true)
    [item, position] = net_json_value (text, position);
    value{end + 1} = item;
    position = net_json_skip (text, position);
    if (text(position) == ']')
      position += 1;
      return;
    elseif (text(position) != ',')
      error ("mplapack:neigt:Deserialize", "array separator expected");
    endif
    position = net_json_skip (text, position + 1);
  endwhile
endfunction

function [value, position] = net_json_string (text, position)
  value = "";
  while (position <= numel (text))
    token = text(position);
    if (token == '"')
      position += 1;
      return;
    elseif (token == '\\')
      if (position + 1 > numel (text))
        error ("mplapack:neigt:Deserialize", "unterminated JSON escape");
      endif
      escaped = text(position + 1);
      if (escaped == '"' || escaped == '\\' || escaped == '/')
        value = [value, escaped];
      elseif (escaped == 'n')
        value = [value, char (10)];
      else
        error ("mplapack:neigt:Deserialize", "unsupported JSON escape");
      endif
      position += 2;
    else
      value = [value, token];
      position += 1;
    endif
  endwhile
  error ("mplapack:neigt:Deserialize", "unterminated JSON string");
endfunction

function [value, position] = net_json_number (text, position)
  first = position;
  while (position <= numel (text) && any (text(position) == "-+0123456789.eE"))
    position += 1;
  endwhile
  value = str2double (text(first:position - 1));
  if (! isfinite (value))
    error ("mplapack:neigt:Deserialize", "invalid JSON number");
  endif
endfunction
