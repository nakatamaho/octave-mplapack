## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   x = mp ({"0", "1", "3"});
%!   y = mp ({"0", "2", "5"});
%!   z = mp ({"0", "1", "3"; "2", "3", "5"; "5", "6", "8"});
%!   xi = mp ([0.5, 2]);
%!   yi = mp ([0.5, 2]);
%!   linear = interp2 (x, y, z, xi, yi, "linear");
%!   assert (linear(1) == mp ("1"));
%!   assert (linear(2) == mp ("4"));
%!   nearest = interp2 (x, y, z, xi, yi, "nearest");
%!   assert (nearest(1) == mp ("0"));
%!   matrix_x = mp ({"0", "1", "3"; "0", "1", "3"; "0", "1", "3"});
%!   matrix_y = mp ({"0", "0", "0"; "2", "2", "2"; "5", "5", "5"});
%!   matrix_grid = interp2 (matrix_x, matrix_y, z, xi, yi);
%!   assert (matrix_grid(1) == linear(1) && matrix_grid(2) == linear(2));
%!   descending = interp2 (fliplr (x), fliplr (y), flipud (fliplr (z)), ...
%!                         xi, yi);
%!   assert (descending(1) == linear(1) && descending(2) == linear(2));
%!   extrapolated = interp2 (x, y, z, mp ("-1"), mp ("-1"), ...
%!                           "linear", "extrap");
%!   assert (extrapolated == mp ("-2"));
%!   assert (isnan (interp2 (x, y, z, mp ("-1"), mp ("-1"))));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect

%!test
%! saved_bits = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   axis = mp ([0, 1, 2, 3]);
%!   values = mp ([0, 1, 4, 9]);
%!   z = mp ([0, 1, 4, 9; 1, 2, 5, 10; 4, 5, 8, 13; 9, 10, 13, 18]);
%!   xi = mp ("0.5");
%!   yi = mp ("1.5");
%!   spline_value = interp2 (axis, axis, z, xi, yi, "spline");
%!   pchip_value = interp2 (axis, axis, z, xi, yi, "pchip");
%!   assert (spline_value == mp ("2.5"));
%!   assert (pchip_value > mp ("1") && pchip_value < mp ("5"));
%!   complex_z = mp ({"(0,0)", "(1,0)"; "(0,1)", "(1,1)"});
%!   complex_value = interp2 (mp ([0, 1]), mp ([0, 1]), complex_z, ...
%!                            mp ("0.25"), mp ("0.5"));
%!   assert (real (complex_value) == mp ("0.25"));
%!   assert (imag (complex_value) == mp ("0.5"));
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
%!   z = mp ([0, 2; 1, 3]);
%!   value = interp2 (mp ([0, 2]), mp ([0, 1]), z, query, mp ("0"));
%!   assert (double (query) == 1);
%!   assert (value > mp ("1"));
%!   default_grid = interp2 (mp ([0, 1; 1, 2]), mp ("1.5"), mp ("1.5"));
%!   assert (default_grid == mp ("1"));
%! unwind_protect_cleanup
%!   mpbits (saved_bits);
%! end_unwind_protect
