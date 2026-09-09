## SPDX-License-Identifier: BSD-2-Clause

function [rows_out, columns_out] = mp_random_dimensions (arguments, name)
  if (isempty (arguments))
    rows_out = 1;
    columns_out = 1;
    return;
  endif

  if (numel (arguments) == 1)
    specification = arguments{1};
    if (isnumeric (specification) && ! islogical (specification)
        && isreal (specification) && numel (specification) == 2)
      rows_out = mp_random_dimension (specification(1), name);
      columns_out = mp_random_dimension (specification(2), name);
      return;
    endif
    dimension = mp_random_dimension (specification, name);
    rows_out = dimension;
    columns_out = dimension;
    return;
  endif

  if (numel (arguments) == 2)
    rows_out = mp_random_dimension (arguments{1}, name);
    columns_out = mp_random_dimension (arguments{2}, name);
    return;
  endif

  error ("mplapack:rng:InvalidDimensions", ...
         "%s expects no dimensions, one dimension/vector, or two dimensions", name);
endfunction

function dimension = mp_random_dimension (value, name)
  if (! isnumeric (value) || islogical (value) || ! isreal (value)
      || ! isscalar (value))
    error ("mplapack:rng:InvalidDimensions", ...
           "%s dimensions must be nonnegative integer scalars", name);
  endif

  if (isinteger (value))
    if (is_signed_integer_type (value) && value < 0)
      error ("mplapack:rng:InvalidDimensions", ...
             "%s dimensions must be nonnegative", name);
    endif
    dimension = value;
    return;
  endif

  supplied = double (value);
  if (! isfinite (supplied) || supplied != fix (supplied) || supplied < 0
      || supplied > 9007199254740992)
    error ("mplapack:rng:InvalidDimensions", ...
           "%s dimensions must be nonnegative exact integers", name);
  endif
  dimension = supplied;
endfunction

function result = is_signed_integer_type (value)
  result = isa (value, "int8") || isa (value, "int16") ...
           || isa (value, "int32") || isa (value, "int64");
endfunction
