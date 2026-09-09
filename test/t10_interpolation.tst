## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   x = mp ({"0", "1", "3", "7"});
%!   y = mp ({"0", "1", "9", "49"});
%!   q = mp ({"0.5", "2", "5"});
%!   linear = interp1 (x, y, q, "linear");
%!   assert (linear(1) == mp ("0.5"));
%!   assert (linear(2) == mp ("5"));
%!   assert (linear(3) == mp ("29"));
%!   nearest = interp1 (x, y, q, "nearest");
%!   assert (nearest(1) == mp ("1"));
%!   assert (nearest(2) == mp ("9"));
%!   previous = interp1 (x, y, q, "previous");
%!   next_value = interp1 (x, y, q, "next");
%!   assert (previous(2) == mp ("1"));
%!   assert (next_value(2) == mp ("9"));
%!   descending = interp1 (flipud (x), flipud (y), q, "linear");
%!   assert (descending(3) == linear(3));
%!   assert (isnan (interp1 (x, y, mp ("-1"))));
%!   assert (interp1 (x, y, mp ("-1"), "linear", "extrap") == mp ("-1"));
%!   linear_pp = interp1 (x, y, "linear", "pp");
%!   assert (ppval (linear_pp, q)(2) == mp ("5"));
%!   assert (__mplapack_core__ ("serialize", linear).precision_bits == uint64 (1024));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   x = mp ([0, 1, 2, 3]);
%!   y = mp ([0, 1, 4, 9]);
%!   q = mp ([0.5, 1.5, 2.5]);
%!   p = pchip (x, y);
%!   s = spline (x, y);
%!   pv = ppval (p, q);
%!   sv = ppval (s, q);
%!   assert (pv(1) > mp ("0") && pv(1) < mp ("1"));
%!   assert (pv(2) > mp ("1") && pv(2) < mp ("4"));
%!   assert (sv(1) == mp ("0.25"));
%!   assert (sv(2) == mp ("2.25"));
%!   assert (sv(3) == mp ("6.25"));
%!   assert (ppval (p, mp ("2.5")) > mp ("4") ...
%!           && ppval (p, mp ("2.5")) < mp ("9"));
%!   d = ppder (s);
%!   assert (ppval (d, mp ("2")) == mp ("4"));
%!   integrated = ppint (d);
%!   assert (ppval (integrated, mp ("2")) == mp ("4"));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   step = mp ("1");
%!   for k = 1:700, step = step * mp ("0.5"); endfor
%!   query = mp ("1") + step;
%!   grid = mp ({"0", "2"});
%!   data = mp ({"0", "2"});
%!   value = interp1 (grid, data, query, "linear");
%!   assert (double (query) == 1);
%!   assert (value > mp ("1"));
%!   z = mp ({"(0,1)", "(1,3)", "(2,5)", "(3,7)"});
%!   complex_value = ppval (pchip (grid, mp ({"(0,1)", "(2,5)"})), query);
%!   assert (real (complex_value) > mp ("1"));
%!   assert (imag (complex_value) > mp ("2"));
%!   complex_grid = mp ({"0", "1", "2", "3"});
%!   assert (real (interp1 (complex_grid, z, query, "spline")) > mp ("1"));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! x = mp ([0, 1, 2]);
%! coefficients = mp ([2, 3; 4, 5]);
%! pp = mkpp (x, coefficients);
%! [breaks, coefs, pieces, order, dimension] = unmkpp (pp);
%! assert (pieces == 2 && order == 2 && dimension == 1);
%! assert (ppval (pp, mp ([0.5, 1.5]))(1) == mp ("4"));
%! assert (ppval (ppder (pp), mp ("0.5")) == mp ("2"));
%! integral = ppint (pp);
%! assert (ppval (integral, mp ("1")) == mp ("4"));
%! assert (breaks(2) == mp ("1") && coefs(2,2) == mp ("5"));
