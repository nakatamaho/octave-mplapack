% Encode an arbitrary finite result value without a decimal MP round trip.
% The returned tagged structure is consumed by net_neigt_decode_value.
function result = net_neigt_encode_value (value, stored_bits)
  if (nargin != 2 || ! isnumeric (stored_bits) || ! isscalar (stored_bits) ...
      || stored_bits != fix (stored_bits) || stored_bits < 1)
    error ("mplapack:neigt:Serialize", "invalid encoded-value precision");
  endif

  if (isa (value, "mp"))
    result = struct ("kind", "mp_matrix", "shape", size (value), ...
                     "stored_precision", stored_bits, "values", []);
    encoded = cell (numel (value), 1);
    for index = 1:numel (value)
      if (numel (value) == 1)
        item = value;
      else
        item = value(index);
      endif
      encoded{index} = net_dyadic_encode_scalar (item, stored_bits);
    endfor
    result.values = encoded;
    return;
  endif

  if (islogical (value))
    result = struct ("kind", "logical_array", "shape", size (value), ...
                     "values", []);
    result.values = num2cell (value(:));
    return;
  endif

  if (isa (value, "double"))
    if (any (! isfinite (value(:))))
      error ("mplapack:neigt:Serialize", ...
             "nonfinite binary value cannot enter a proof artifact");
    endif
    result = struct ("kind", "double_array", "shape", size (value), ...
                     "values", []);
    result.values = num2cell (value(:));
    return;
  endif

  if (ischar (value))
    if (rows (value) != 1)
      error ("mplapack:neigt:Serialize", "character matrices are unsupported");
    endif
    result = struct ("kind", "char", "value", value);
    return;
  endif

  if (iscell (value))
    result = struct ("kind", "cell_array", "shape", size (value), ...
                     "items", []);
    items = cell (numel (value), 1);
    for index = 1:numel (value)
      items{index} = net_neigt_encode_value (value{index}, stored_bits);
    endfor
    result.items = items;
    return;
  endif

  if (isstruct (value))
    if (numel (value) == 1)
      result = struct ("kind", "struct", "fields", struct ());
      names = fieldnames (value);
      for index = 1:numel (names)
        name = names{index};
        result.fields.(name) = net_neigt_encode_value ...
          (value.(name), stored_bits);
      endfor
    else
      result = struct ("kind", "struct_array", "shape", size (value), ...
                       "items", []);
      items = cell (numel (value), 1);
      for index = 1:numel (value)
        items{index} = net_neigt_encode_value (value(index), stored_bits);
      endfor
      result.items = items;
    endif
    return;
  endif

  error ("mplapack:neigt:Serialize", ...
         "unsupported proof-artifact value class %s", class (value));
endfunction
