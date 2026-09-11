% Decode a serialized MP matrix at sufficient destination precision.
function result = net_dyadic_decode_matrix (record, destination_bits)
  if (nargin != 2 || ! isstruct (record) || ! isfield (record, "schema") ...
      || ! strcmp (record.schema, "neigt-dyadic-v1") ...
      || ! isnumeric (destination_bits) || ! isscalar (destination_bits) ...
      || destination_bits != fix (destination_bits) || destination_bits < 1)
    error ("mplapack:neigt:Deserialize", "invalid matrix record");
  endif
  if (! isfield (record, "shape") || ! isfield (record, "stored_precision") ...
      || ! isfield (record, "values") || destination_bits < record.stored_precision)
    error ("mplapack:neigt:Deserialize", "incomplete or insufficient matrix record");
  endif
  shape = record.shape;
  if (numel (shape) != 2 || any (shape != fix (shape)) || any (shape < 0) ...
      || numel (record.values) != prod (shape))
    error ("mplapack:neigt:Deserialize", "invalid matrix shape/value count");
  endif
  saved_bits = mpbits ();
  unwind_protect
    mpbits (destination_bits);
    decoded = cell (numel (record.values), 1);
    complex_value = false;
    for index = 1:numel (record.values)
      decoded{index} = net_dyadic_decode_scalar (record.values{index}, destination_bits);
      complex_value = complex_value || ! isreal (decoded{index});
    endfor
    if (complex_value)
      result = mp (zeros (shape)) + net_mp_complex (mp (0), mp (0));
    else
      result = mp (zeros (shape));
    endif
    for index = 1:numel (decoded)
      result(index) = decoded{index};
    endfor
  unwind_protect_cleanup
    mpbits (saved_bits);
  end_unwind_protect
endfunction
