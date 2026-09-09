## SPDX-License-Identifier: BSD-2-Clause

%!function result = reference_square (value)
%!  d = double (value);
%!  result = [d(1, 1) * d(1, 1) + d(1, 2) * d(2, 1), ...
%!            d(1, 1) * d(1, 2) + d(1, 2) * d(2, 2); ...
%!            d(2, 1) * d(1, 1) + d(2, 2) * d(2, 1), ...
%!            d(2, 1) * d(1, 2) + d(2, 2) * d(2, 2)];
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   a = mp ("2");
%!   assert (isequal (a .^ mp ([2, 3]), mp ([4, 8])));
%!   assert (isequal (mp ([2; 3]) .^ 2, mp ([4; 9])));
%!   assert (isequal (2 .^ mp ([2, 3]), mp ([4, 8])));
%!   assert (abs (double (mp ("-1") .^ mp ("0.5")) - 1i) < 1e-12);
%!   z = mp ("1", "2");
%!   assert (abs (double (z .^ mp ("2")) - (-3 + 4i)) < 1e-12);
%!   assert (abs (double (mp ("2") .^ z) - 2^complex (1, 2)) < 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   assert (double (A ^ 0), eye (2));
%!   assert (double (A ^ 2), [7, 10; 15, 22]);
%!   assert (double (A ^ -1) * double (A), eye (2), 1e-12);
%!   Z = mp ([1 + 1i, 2; 3, 4 - 1i]);
%!   assert (double (Z ^ 0), eye (2));
%!   assert (double (Z ^ 2), reference_square (Z), 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   real_values = cell (1, 3);
%!   real_values{1} = mp ("0.25");
%!   real_values{2} = mp ("2");
%!   real_values{3} = mp ("-1");
%!   functions = {"sqrt", "exp", "expm1", "log", "log1p", "log10", ...
%!                "log2", "sin", "cos", "tan", "asin", "acos", "atan", ...
%!                "sinh", "cosh", "tanh", "asinh", "acosh", "atanh", "cbrt"};
%!   for i = 1:numel (functions)
%!     for j = 1:numel (real_values)
%!       value = feval (functions{i}, real_values{j});
%!       assert (isa (value, "mp"));
%!     endfor
%!   endfor
%!   z = mp ("(0.25,-0.5)");
%!   for i = 1:numel (functions)
%!     assert (isa (feval (functions{i}, z), "mp"));
%!   endfor
%!   assert (abs (double (sqrt (mp ("-1"))) - 1i) < 1e-12);
%!   assert (abs (double (log (mp ("-1"))) - pi * 1i) < 1e-12);
%!   assert (abs (double (asin (mp ("2"))) ...
%!               - (pi / 2 - 1i * log (2 + sqrt (3)))) < 1e-12);
%!   assert (abs (double (acos (mp ("2"))) ...
%!               - 1i * log (2 + sqrt (3))) < 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for precision = [1024, 2048]
%!     mpbits (precision);
%!     if (precision == 1024)
%!       x = mp ("1e-211");
%!     else
%!       x = mp ("1e-451");
%!     endif
%!     e = expm1 (x);
%!     l = log1p (x);
%!     assert (__mplapack_core__ ("scalar_test_info", e).precision_bits ...
%!             == precision);
%!     assert (__mplapack_core__ ("scalar_test_info", l).precision_bits ...
%!             == precision);
%!     assert (isfinite (e) && isfinite (l));
%!     mpbits (128);
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits") == 128);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
