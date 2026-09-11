function result = net_hex_bit_length (hex)
  if (! ischar (hex) || isempty (hex) || hex(1) == "0")
    error ("mplapack:neigt:DyadicHex", "invalid normalized hexadecimal integer");
  endif
  digit = find ("0123456789abcdef" == lower (hex(1))) - 1;
  if (isempty (digit))
    error ("mplapack:neigt:DyadicHex", "invalid hexadecimal digit");
  endif
  bits = 0;
  while (digit > 0)
    bits += 1;
    digit = floor (digit / 2);
  endwhile
  result = 4 * (numel (hex) - 1) + bits;
endfunction
