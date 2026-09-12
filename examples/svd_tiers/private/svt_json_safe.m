## SPDX-License-Identifier: BSD-2-Clause

function output = svt_json_safe (value, q, method)
  ## Convert an in-memory result tree to JSON-safe data. MP values use V4
  ## exact snapshots; ordinary native values remain explicitly native data.
  if (nargin < 3), method = "svt_exact_dyadic_v1"; endif
  if (isa (value, "mp"))
    output = svt_serialize_mp_array (value, q, method);
  elseif (isstruct (value))
    if (numel (value) != 1)
      output = cell (numel (value), 1);
      for index = 1:numel (value)
        output{index} = svt_json_safe (value(index), q, method);
      endfor
    else
      names = fieldnames (value);
      output = struct ();
      for index = 1:numel (names)
        name = names{index};
        output.(name) = svt_json_safe (value.(name), q, method);
      endfor
    endif
  elseif (iscell (value))
    output = cell (numel (value), 1);
    for index = 1:numel (value)
      output{index} = svt_json_safe (value{index}, q, method);
    endfor
  elseif (ischar (value) || islogical (value) || isstring (value) ...
          || (isnumeric (value) && isreal (value)))
    output = value;
  elseif (isnumeric (value) && ! isreal (value))
    output = struct ("kind", "native-complex", "real", real (value), ...
                     "imag", imag (value));
  elseif (isempty (value))
    output = [];
  else
    error ("mplapack:svt:JsonValue", "unsupported result value for JSON");
  endif
endfunction
