% Evaluate one real scalar operation and enclose its rounded result.
function result = net_iv_primitive (operation, x, y, q)
  if (nargin != 4 || ! (ischar (operation) || isstring (operation)))
    error ("mplapack:neigt:IntervalPrimitive", "invalid primitive operation");
  endif
  net_iv_q (q);
  if (mpbits () != q)
    error ("mplapack:neigt:IntervalPrecision", ...
           "primitive must execute at its declared current precision");
  endif
  operation = char (operation);
  if (! isa (x, "mp") || ! isscalar (x) || ! isfinite (x))
    error ("mplapack:neigt:IntervalPrimitive", "invalid first operand");
  endif
  if (! strcmp (operation, "sqrt") ...
      && (! isa (y, "mp") || ! isscalar (y) || ! isfinite (y)))
    error ("mplapack:neigt:IntervalPrimitive", "invalid second operand");
  endif
  switch (operation)
    case "add"
      rounded = x + y;
      witness = (x == -y);
    case "sub"
      rounded = x - y;
      witness = (x == y);
    case "mul"
      rounded = x * y;
      witness = (x == mp (0) || y == mp (0));
    case "div"
      if (y == mp (0))
        error ("mplapack:neigt:IntervalDomain", "division by zero");
      endif
      rounded = x / y;
      witness = (x == mp (0));
    case "sqrt"
      if (x < mp (0))
        error ("mplapack:neigt:IntervalDomain", ...
               "square root has a negative argument");
      endif
      rounded = sqrt (x);
      witness = (x == mp (0));
    otherwise
      error ("mplapack:neigt:IntervalPrimitive", ...
             "unknown real primitive %s", operation);
  endswitch
  result = net_iv_round (rounded, q, witness, operation);
endfunction
