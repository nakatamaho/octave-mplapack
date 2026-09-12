% Canonical JSON encoder for NEIGT proof records and tagged values.
function result = net_neigt_json_encode (value)
  if (ischar (value))
    result = json_quote (value);
  elseif (islogical (value) && isscalar (value))
    result = ternary (value, "true", "false");
  elseif (isa (value, "double") && isscalar (value))
    if (! isfinite (value))
      error ("mplapack:neigt:Serialize", "nonfinite JSON number");
    endif
    result = sprintf ("%.17g", value);
  elseif (iscell (value))
    % jsondecode collapses a one-element JSON array to a scalar.  Keep an
    % explicit array wrapper so canonical bytes survive a process restart.
    result = strcat ("{\"kind\":\"json_array\",\"items\":", ...
                     encode_array_items (value), "}");
  elseif (isstruct (value) && isscalar (value) ...
         && isfield (value, "kind") && strcmp (value.kind, "json_array"))
    % Preserve the explicit array-wrapper order across jsondecode/re-encode.
    result = strcat ("{\"kind\":\"json_array\",\"items\":", ...
                     encode_array_items (value.items), "}");
  elseif (isstruct (value) && isscalar (value))
    names = sort (fieldnames (value));
    result = "{";
    for index = 1:numel (names)
      if (index > 1), result = strcat (result, ","); endif
      name = names{index};
      result = strcat (result, json_quote (name), ":", ...
                       net_neigt_json_encode (value.(name)));
    endfor
    result = strcat (result, "}");
  elseif (isstruct (value))
    result = "[";
    for index = 1:numel (value)
      if (index > 1), result = strcat (result, ","); endif
      result = strcat (result, net_neigt_json_encode (value(index)));
    endfor
    result = strcat (result, "]");
  elseif (isnumeric (value) && isvector (value))
    result = "[";
    for index = 1:numel (value)
      if (index > 1), result = strcat (result, ","); endif
      result = strcat (result, net_neigt_json_encode (double (value(index))));
    endfor
    result = strcat (result, "]");
  elseif (isnumeric (value) && isempty (value))
    result = "[]";
  else
    error ("mplapack:neigt:Serialize", ...
           "unsupported canonical JSON class %s", class (value));
  endif
endfunction

function result = encode_array_items (items)
  result = "[";
  if (iscell (items))
    count = numel (items);
    for index = 1:count
      if (index > 1), result = strcat (result, ","); endif
      result = strcat (result, net_neigt_json_encode (items{index}));
    endfor
  elseif (isstruct (items) && numel (items) > 1)
    count = numel (items);
    for index = 1:count
      if (index > 1), result = strcat (result, ","); endif
      result = strcat (result, net_neigt_json_encode (items(index)));
    endfor
  elseif ((isnumeric (items) || islogical (items)) && numel (items) > 1)
    count = numel (items);
    for index = 1:count
      if (index > 1), result = strcat (result, ","); endif
      result = strcat (result, net_neigt_json_encode (items(index)));
    endfor
  elseif (! isempty (items))
    result = strcat (result, net_neigt_json_encode (items));
  endif
  result = strcat (result, "]");
endfunction

function result = json_quote (value)
  value = strrep (value, "\\", "\\\\");
  value = strrep (value, '"', '\\"');
  value = strrep (value, char (10), "\\n");
  value = strrep (value, char (13), "\\r");
  value = strrep (value, char (9), "\\t");
  result = ['"', value, '"'];
endfunction

function result = ternary (condition, if_true, if_false)
  if (condition), result = if_true; else, result = if_false; endif
endfunction
