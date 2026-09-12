## SPDX-License-Identifier: BSD-2-Clause

function snapshot = svt_serialize_mp_array (value, q, method)
  ## Serialize represented MPFR/MPC values without reading a private payload.
  ## The hash covers the exact JSON bytes of the metadata and encoded values.
  if (nargin < 3), method = "svt_exact_dyadic_v1"; endif
  if (! isa (value, "mp") || ndims (value) > 2)
    error ("mplapack:svt:SnapshotType", "snapshot requires a scalar or 2-D mp value");
  endif
  if (! isnumeric (q) || ! isscalar (q) || q != fix (q) || q < 64 || q > 4096)
    error ("mplapack:svt:SnapshotPrecision", "invalid snapshot precision");
  endif
  info = __mplapack_core__ ("value_shape_info", value);
  if (q < info.precision_bits)
    error ("mplapack:svt:SnapshotPrecision", ...
           "snapshot precision is below source precision");
  endif
  saved_bits = mpbits ();
  cleanup = onCleanup (@() mpbits (saved_bits));
  mpbits (q);
  shape = size (value);
  complex_value = ! isreal (value);
  if (complex_value)
    kind = "complex";
  else
    kind = "real";
  endif
  encoded_values = cell (numel (value), 1);
  if (numel (value) == 1)
    flat = value;
  else
    flat = value(:);
  endif
  for index = 1:numel (flat)
    if (numel (flat) == 1)
      element = flat;
    else
      element = flat(index);
    endif
    if (complex_value)
      encoded_values{index} = svt_dyadic_complex_encode (element, q);
    else
      encoded_values{index} = svt_dyadic_encode (element, q);
    endif
  endfor
  snapshot = struct ("schema", "svt-exact-snapshot-v1", "kind", kind, ...
                     "storage_bits", info.precision_bits, "shape", shape, ...
                     "order", "column-major", "method", method, ...
                     "values", {encoded_values});
  canonical_bytes = jsonencode (snapshot);
  snapshot.canonical_byte_hash = hash ("sha256", canonical_bytes);
  clear cleanup;
endfunction
