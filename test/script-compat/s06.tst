## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2", "3"; "4", "5", "6"});
%!   assert (double (mean (A)), [2.5, 3.5, 4.5], 1e-15);
%!   assert (double (mean (A, 2)), [2; 5], 1e-15);
%!   assert (double (mean (A, "all")), 3.5, 1e-15);
%!   assert (double (mean (A, "double")), [2.5, 3.5, 4.5], 1e-15);
%!   assert (double (median (A)), [2.5, 3.5, 4.5], 1e-15);
%!   assert (double (median (A, 2)), [2; 5], 1e-15);
%!   assert (double (median (A, "all")), 3.5, 1e-15);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2", "3"; "4", "5", "6"});
%!   assert (double (var (A)), [4.5, 4.5, 4.5], 1e-15);
%!   assert (double (var (A, 1)), [2.25, 2.25, 2.25], 1e-15);
%!   assert (double (std (A)), [2.1213203435596424, ...
%!                              2.1213203435596424, ...
%!                              2.1213203435596424], 1e-15);
%!   assert (double (std (A, 1)), [1.5, 1.5, 1.5], 1e-15);
%!   assert (double (var (A, [], "all")), 3.5, 1e-15);
%!   [V, M] = var (A, 0, 2);
%!   assert (double (V), [1; 1], 1e-15);
%!   assert (double (M), [2; 5], 1e-15);
%!   [S, N] = std (A, 1, "all");
%!   assert (double (S), 1.707825127659933, 1e-15);
%!   assert (double (N), 3.5, 1e-15);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   X = mp ({"1", "NaN", "3"});
%!   assert (isnan (mean (X)));
%!   assert (isequal (mean (X, "omitnan"), mp ("2")));
%!   assert (isnan (median (X)));
%!   assert (isequal (median (X, "omitnan"), mp ("2")));
%!   assert (isnan (var (X)));
%!   assert (isequal (var (X, [], "omitnan"), mp ("2")));
%!   assert (isequal (range (X), mp ("2")));
%!   [lo, hi] = bounds (X);
%!   assert (isequal (lo, mp ("1")) && isequal (hi, mp ("3")));
%!   assert (isnan (range (X, "includenan")));
%!   [lo, hi] = bounds (X, "includenan");
%!   assert (isnan (lo) && isnan (hi));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   stable = mp ({"100000000000000000000000000000001", ...
%!                 "100000000000000000000000000000002", ...
%!                 "100000000000000000000000000000003", ...
%!                 "100000000000000000000000000000004"});
%!   assert (double (var (stable, 1)), 1.25, 1e-12);
%!   assert (double (std (stable, 1)), 1.118033988749895, 1e-12);
%!   Z = mp ([1 + 2i, 2 + 4i, 3 + 8i]);
%!   assert (double (mean (Z)), 2 + 14 / 3 * 1i, 1e-12);
%!   [V, M] = var (Z);
%!   assert (double (V), 31 / 3, 1e-12);
%!   assert (double (M), 2 + 14 / 3 * 1i, 1e-12);
%!   assert (double (median (Z)), 2 + 4i, 1e-12);
%!   assert (double (range (Z)), 2 + 6i, 1e-12);
%!   [lo, hi] = bounds (Z);
%!   assert (double (lo), 1 + 2i, 1e-12);
%!   assert (double (hi), 3 + 8i, 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for precision = [1024, 2048]
%!     mpbits (precision);
%!     exponent = (precision == 1024) * -700 ...
%!                + (precision == 2048) * -1500;
%!     x = mp ("2") ^ exponent;
%!     values = [x, x + x, x + 2 * x];
%!     m = mean (values);
%!     assert (__mplapack_core__ ("value_shape_info", m).precision_bits == precision);
%!     assert (isequal (m, 2 * x));
%!     v = var (values, 1);
%!     assert (__mplapack_core__ ("value_shape_info", v).precision_bits == precision);
%!     assert (isequal (v, 2 * (x ^ 2 / 3)));
%!     mpbits (128);
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits") == 128);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!error <normalization must be scalar 0 or 1>
%! var (mp ([1, 2]), 2);
