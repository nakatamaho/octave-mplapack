% Encode an MP matrix in column-major order.
function result = net_dyadic_encode_matrix (value, stored_bits)
  if (nargin != 2 || ! isa (value, "mp") || ndims (value) > 2)
    error ("mplapack:neigt:Serialize", "matrix serialization requires an MP matrix");
  endif
  if (! isnumeric (stored_bits) || ! isscalar (stored_bits) ...
      || stored_bits != fix (stored_bits) || stored_bits < 1 ...
      || ! all (isfinite (real (value))) || ! all (isfinite (imag (value))))
    error ("mplapack:neigt:Serialize", "invalid matrix serialization input");
  endif
  encoded = cell (numel (value), 1);
  for index = 1:numel (value)
    encoded{index} = net_dyadic_encode_scalar (value(index), stored_bits);
  endfor
  result = struct ("schema", "neigt-dyadic-v1", ...
    "method_version", "public-mp-binary-extraction-v1", ...
    "shape", size (value), "stored_precision", stored_bits, ...
    "values", {encoded});
endfunction
