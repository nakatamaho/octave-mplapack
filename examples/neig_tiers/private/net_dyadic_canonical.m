% Produce canonical JSON bytes, optionally including the content hash.
function result = net_dyadic_canonical (record, include_hash)
  if (nargin < 1 || nargin > 2 || ! isstruct (record))
    error ("mplapack:neigt:Serialize", "invalid dyadic record");
  endif
  if (nargin < 2)
    include_hash = false;
  endif
  required = {"schema", "method_version", "shape", "stored_precision", "values"};
  for index = 1:numel (required)
    if (! isfield (record, required{index}))
      error ("mplapack:neigt:Serialize", "record lacks %s", required{index});
    endif
  endfor
  result = "{\"schema\":";
  result = strcat (result, json_quote (record.schema), ",\"method_version\":");
  result = strcat (result, json_quote (record.method_version), ",\"shape\":[");
  result = strcat (result, json_shape (record.shape), "],\"stored_precision\":");
  result = strcat (result, sprintf ("%d", record.stored_precision), ",\"values\":[");
  for index = 1:numel (record.values)
    if (index > 1)
      result = strcat (result, ",");
    endif
    result = strcat (result, json_scalar (record.values{index}));
  endfor
  result = strcat (result, "]");
  if (include_hash)
    if (! isfield (record, "sha256") || ! ischar (record.sha256))
      error ("mplapack:neigt:Serialize", "record lacks sha256");
    endif
    result = strcat (result, ",\"sha256\":", json_quote (record.sha256));
  endif
  result = strcat (result, "}");
endfunction

function result = json_shape (shape)
  if (! isnumeric (shape) || numel (shape) != 2 || any (shape != fix (shape)) ...
      || any (shape < 0))
    error ("mplapack:neigt:Serialize", "invalid record shape");
  endif
  result = sprintf ("%d,%d", shape(1), shape(2));
endfunction

function result = json_scalar (value)
  if (! isstruct (value) || ! isfield (value, "kind"))
    error ("mplapack:neigt:Serialize", "invalid serialized scalar");
  endif
  if (strcmp (value.kind, "real"))
    result = strcat ("{\"kind\":\"real\",", json_real (value), "}");
  elseif (strcmp (value.kind, "complex"))
    result = strcat ("{\"kind\":\"complex\",\"real\":{", ...
                     json_real (value.real), "},\"imag\":{", ...
                     json_real (value.imag), "}}");
  else
    error ("mplapack:neigt:Serialize", "unknown serialized kind");
  endif
endfunction

function result = json_real (value)
  if (! isfield (value, "sign") || ! isfield (value, "mantissa_hex") ...
      || ! isfield (value, "exponent2"))
    error ("mplapack:neigt:Serialize", "invalid real encoding");
  endif
  result = strcat ("\"sign\":", sprintf ("%d", value.sign), ...
                   ",\"mantissa_hex\":", json_quote (value.mantissa_hex), ...
                   ",\"exponent2\":", sprintf ("%d", value.exponent2));
endfunction

function result = json_quote (value)
  if (! ischar (value))
    error ("mplapack:neigt:Serialize", "JSON string expected");
  endif
  value = strrep (value, "\\", "\\\\");
  value = strrep (value, '"', '\\"');
  result = ['"', value, '"'];
endfunction
