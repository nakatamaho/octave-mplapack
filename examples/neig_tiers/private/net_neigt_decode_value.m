% Decode the tagged exact result values written by net_neigt_encode_value.
function result = net_neigt_decode_value (encoded, destination_bits)
  if (nargin != 2 || ! isstruct (encoded) || ! isfield (encoded, "kind") ...
      || destination_bits != fix (destination_bits) || destination_bits < 1)
    error ("mplapack:neigt:Deserialize", "invalid tagged value");
  endif
  kind = char (encoded.kind);
  if (strcmp (kind, "mp_matrix"))
    shape = checked_shape (encoded.shape);
    values = items_as_cell (encoded.values);
    if (numel (values) != prod (shape) ...
        || ! isfield (encoded, "stored_precision") ...
        || destination_bits < encoded.stored_precision)
      error ("mplapack:neigt:Deserialize", "invalid MP matrix payload");
    endif
    saved_bits = mpbits ();
    unwind_protect
      mpbits (destination_bits);
      decoded = cell (numel (values), 1);
      complex_value = false;
      for index = 1:numel (values)
        item = values{index};
        decoded{index} = net_dyadic_decode_scalar (item, destination_bits);
        complex_value = complex_value || ! isreal (decoded{index});
      endfor
      if (complex_value)
        result = mp (zeros (shape)) + net_mp_complex (mp (0), mp (0));
      else
        result = mp (zeros (shape));
      endif
      if (numel (decoded) == 1)
        result = decoded{1};
      else
        for index = 1:numel (decoded)
          result(index) = decoded{index};
        endfor
      endif
    unwind_protect_cleanup
      mpbits (saved_bits);
    end_unwind_protect
    return;
  endif

  if (strcmp (kind, "logical_array"))
    shape = checked_shape (encoded.shape);
    values = items_as_cell (encoded.values);
    if (numel (values) != prod (shape))
      error ("mplapack:neigt:Deserialize", "logical value count mismatch");
    endif
    result = false (shape);
    for index = 1:numel (values)
      result(index) = logical (values{index});
    endfor
    return;
  endif

  if (strcmp (kind, "double_array"))
    shape = checked_shape (encoded.shape);
    values = items_as_cell (encoded.values);
    if (numel (values) != prod (shape))
      error ("mplapack:neigt:Deserialize", "double value count mismatch");
    endif
    result = zeros (shape);
    for index = 1:numel (values)
      if (! isnumeric (values{index}) || ! isscalar (values{index}) ...
          || ! isfinite (values{index}))
        error ("mplapack:neigt:Deserialize", "invalid double value");
      endif
      result(index) = values{index};
    endfor
    return;
  endif

  if (strcmp (kind, "char"))
    if (! isfield (encoded, "value") || ! ischar (encoded.value))
      error ("mplapack:neigt:Deserialize", "invalid character value");
    endif
    result = encoded.value;
    return;
  endif

  if (strcmp (kind, "cell_array"))
    shape = checked_shape (encoded.shape);
    items = items_as_cell (encoded.items);
    if (numel (items) != prod (shape))
      error ("mplapack:neigt:Deserialize", "cell value count mismatch");
    endif
    result = cell (shape);
    for index = 1:numel (items)
      result{index} = net_neigt_decode_value (items{index}, destination_bits);
    endfor
    return;
  endif

  if (strcmp (kind, "struct"))
    if (! isfield (encoded, "fields") || ! isstruct (encoded.fields))
      error ("mplapack:neigt:Deserialize", "invalid struct value");
    endif
    result = struct ();
    names = fieldnames (encoded.fields);
    for index = 1:numel (names)
      name = names{index};
      result.(name) = net_neigt_decode_value ...
        (encoded.fields.(name), destination_bits);
    endfor
    return;
  endif

  if (strcmp (kind, "struct_array"))
    shape = checked_shape (encoded.shape);
    items = items_as_cell (encoded.items);
    if (numel (items) != prod (shape))
      error ("mplapack:neigt:Deserialize", "struct value count mismatch");
    endif
    if (isempty (items))
      result = struct ([]);
      return;
    endif
    first = net_neigt_decode_value (items{1}, destination_bits);
    result = repmat (first, shape);
    for index = 2:numel (items)
      result(index) = net_neigt_decode_value (items{index}, destination_bits);
    endfor
    return;
  endif

  error ("mplapack:neigt:Deserialize", "unknown tagged value kind %s", kind);
endfunction

function shape = checked_shape (shape)
  if (! isnumeric (shape) || numel (shape) != 2 || any (shape != fix (shape)) ...
      || any (shape < 0))
    error ("mplapack:neigt:Deserialize", "invalid tagged value shape");
  endif
  shape = double (shape(:).');
endfunction

function result = items_as_cell (items)
  if (isstruct (items) && isscalar (items) && isfield (items, "kind") ...
      && strcmp (items.kind, "json_array"))
    result = items_as_cell (items.items);
    return;
  endif
  if (iscell (items))
    result = items;
  elseif (isstruct (items))
    result = cell (numel (items), 1);
    for index = 1:numel (items)
      result{index} = items(index);
    endfor
  elseif (isempty (items))
    result = cell (0, 1);
  else
    result = num2cell (items(:));
  endif
endfunction
