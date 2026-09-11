% Parse the bounded dyadic/ratio grammar used by the NEIGT manifests.
function value = net_dyadic_parameter (text, bits)
  if (nargin != 2 || ! ischar (text) || bits != fix (bits) || bits < 64)
    error ("mplapack:neigt:Parameter", "invalid dyadic parameter");
  endif
  pieces = strsplit (text, "/");
  if (numel (pieces) != 2 || isempty (pieces{1}) || isempty (pieces{2}))
    error ("mplapack:neigt:Parameter", "only integer ratios are accepted");
  endif
  numerator = parse_integer (pieces{1});
  denominator = parse_integer (pieces{2});
  if (denominator <= 0 || numerator <= 0)
    error ("mplapack:neigt:Parameter", "dyadic ratio must be positive");
  endif
  value = mp (numerator) / mp (denominator);
  decomposition = net_dyadic_decompose (value, bits);
  if (! decomposition.exact)
    error ("mplapack:neigt:Parameter", "ratio is not an exact MP dyadic");
  endif
endfunction

function value = parse_integer (text)
  if (isempty (regexp (text, "^[0-9]+$", "once")))
    error ("mplapack:neigt:Parameter", "invalid bounded integer token");
  endif
  value = 0;
  for index = 1:numel (text)
    value = value * 10 + (text(index) - "0");
    if (value > 2147483647)
      error ("mplapack:neigt:Parameter", "integer token is out of bounds");
    endif
  endfor
endfunction
