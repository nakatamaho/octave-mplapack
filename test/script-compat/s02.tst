## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   assert (double (sum (A)), [4, 6]);
%!   assert (double (sum (A, 2)), [3; 7]);
%!   assert (double (sum (A, "all")), 10);
%!   assert (double (prod (A)), [3, 8]);
%!   assert (double (prod (A, 2)), [2; 12]);
%!   assert (double (prod (A, "all")), 24);
%!   assert (double (sumsq (A)), [10, 20]);
%!   assert (double (sumsq (A, "all")), 30);
%!   assert (double (sum (A, "double")), [4, 6]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   assert (double (cumsum (A)), [1, 2; 4, 6]);
%!   assert (double (cumsum (A, 2)), [1, 3; 3, 7]);
%!   assert (double (cumsum (A, "reverse")), [4, 6; 3, 4]);
%!   assert (double (cumsum (A, 2, "reverse")), [3, 2; 7, 4]);
%!   assert (double (cumprod (A)), [1, 2; 3, 8]);
%!   assert (double (cumprod (A, "reverse")), [3, 8; 3, 4]);
%!   assert (double (cumprod (A, 2)), [1, 2; 3, 12]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   Z = mp ([1 + 2i, 3 - 1i; 2, 4 + 3i]);
%!   assert (double (sum (Z)), [3 + 2i, 7 + 2i], 1e-12);
%!   assert (double (sum (Z, "all")), 10 + 4i, 1e-12);
%!   assert (double (prod (Z)), [(1 + 2i) * 2, (3 - 1i) * (4 + 3i)], 1e-12);
%!   assert (double (sumsq (Z)), [9, 35], 1e-12);
%!   assert (double (sumsq (Z, "all")), 44, 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, NaN; 2, 3]);
%!   assert (double (sum (A)), [3, NaN]);
%!   assert (double (sum (A, "omitnan")), [3, 3]);
%!   assert (double (prod (A)), [2, NaN]);
%!   assert (double (prod (A, "omitnan")), [2, 3]);
%!   assert (double (sumsq (A, "omitnan")), [5, 9]);
%!   [mn, mi] = min (A);
%!   assert (double (mn), [1, 3]);
%!   assert (mi, [1, 2]);
%!   [mn, mi] = min (A, "includenan");
%!   assert (isnan (mn), [false, true]);
%!   assert (mi, [1, 1]);
%!   [mx, mi] = max (A, "omitnan");
%!   assert (double (mx), [2, 3]);
%!   assert (mi, [2, 2]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   [mn, mi] = min (A);
%!   assert (double (mn), [1, 2]);
%!   assert (mi, [1, 1]);
%!   [mx, mi] = max (A);
%!   assert (double (mx), [3, 4]);
%!   assert (mi, [2, 2]);
%!   assert (double (min (A, [], 2)), [1; 3]);
%!   assert (double (max (A, [], 2)), [2; 4]);
%!   assert (double (min (A, [], "all")), 1);
%!   assert (double (max (A, [], "all")), 4);
%!   assert (double (min (A, mp (2))), [1, 2; 2, 2]);
%!   assert (double (max (A, mp (2))), [2, 2; 3, 4]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!error <pairwise min/max does not return indices>
%! [~, ~] = min (mp ([1, 2]), mp (2));

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   Z = mp ([1 + 1i, -1 - 1i; 1 - 1i, -1 + 1i]);
%!   [mn, mi] = min (Z);
%!   [mx, ma] = max (Z);
%!   assert (double (mn), [1 - 1i, -1 - 1i], 1e-12);
%!   assert (mi, [2, 1]);
%!   assert (double (mx), [1 + 1i, -1 + 1i], 1e-12);
%!   assert (ma, [1, 2]);
%!   W = mp ([1 + 2i, -1 + 3i]);
%!   assert (abs (double (min (W, "ComparisonMethod", "real")) ...
%!               - (-1 + 3i)) < 1e-12);
%!   V = mp ([1 + 1i, -1 - 1i]);
%!   assert (abs (double (min (V, "ComparisonMethod", "abs")) ...
%!               - (-1 - 1i)) < 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for precision = [1024, 2048]
%!     mpbits (precision);
%!     exponent = (precision == 1024) * -700 + (precision == 2048) * -1500;
%!     x = mp ("2") ^ exponent;
%!     y = sumsq (x);
%!     info = __mplapack_core__ ("scalar_test_info", y);
%!     assert (info.precision_bits == precision);
%!     assert (isfinite (y));
%!     mpbits (128);
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits") == 128);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
