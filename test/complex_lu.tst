## SPDX-License-Identifier: BSD-2-Clause

%!function assert_complex_matrix (value, rows_expected, columns_expected, precision_expected)
%!  info = __mplapack_core__ ("matrix_test_info", value);
%!  assert (info.rows, uint64 (rows_expected));
%!  assert (info.columns, uint64 (columns_expected));
%!  assert (info.is_complex);
%!  assert (info.all_elements_same_precision);
%!  assert (info.precision_bits, uint64 (precision_expected));
%!endfunction

%!test
%! mpbits (512);
%! A = mp ([1 + 1i, 2 + 2i; 3 - 1i, 4 + 0i]);
%! packed = lu (A);
%! assert_complex_matrix (packed, 2, 2, 512);
%! assert (double (packed), [3 - 1i, 4; 0.2 + 0.4i, 1.2 + 0.4i], 1e-12);
%! [L, U] = lu (A);
%! assert_complex_matrix (L, 2, 2, 512);
%! assert_complex_matrix (U, 2, 2, 512);
%! assert (double (L * U), double (A), 1e-10);
%! assert (double (L), [0.2 + 0.4i, 1; 1, 0], 1e-12);
%! assert (double (U), [3 - 1i, 4; 0, 1.2 + 0.4i], 1e-12);
%! [Lp, Up, P] = lu (A);
%! assert (strcmp (class (P), "double"));
%! assert (P, [0, 1; 1, 0]);
%! assert (double (P * A), double (Lp * Up), 1e-10);
%! [Lv, Uv, p] = lu (A, "vector");
%! assert (strcmp (class (p), "double"));
%! assert (size (p), [2, 1]);
%! assert (p, [2; 1]);
%! assert (double (A(p, :)), double (Lv * Uv), 1e-10);

%!test
%! mpbits (512);
%! tall = mp ([1 + 0i, 2 + 2i; 5 + 1i, 4 + 0i; 3 - 1i, 6 + 1i]);
%! [L, U, P] = lu (tall);
%! assert_complex_matrix (L, 3, 2, 512);
%! assert_complex_matrix (U, 2, 2, 512);
%! assert (size (P), [3, 3]);
%! assert (double (P * tall), double (L * U), 1e-10);
%! [L2, U2] = lu (tall);
%! assert (double (tall), double (L2 * U2), 1e-10);
%! wide = mp ([1 + 0i, 2 - 1i, 5 + 2i; 3 + 1i, 4 + 0i, 6 - 1i]);
%! [Lw, Uw, Pw] = lu (wide);
%! assert_complex_matrix (Lw, 2, 2, 512);
%! assert_complex_matrix (Uw, 2, 3, 512);
%! assert (size (Pw), [2, 2]);
%! assert (double (Pw * wide), double (Lw * Uw), 1e-10);
%! [Lw2, Uw2] = lu (wide);
%! assert (double (wide), double (Lw2 * Uw2), 1e-10);

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for setting = {[1024, 700], [2048, 1500]}
%!     precision = setting{1}(1);
%!     exponent = setting{1}(2);
%!     mpbits (precision);
%!     delta = mp ("1", "0");
%!     for k = 1:exponent
%!       delta = delta ./ mp ("2", "0");
%!     endfor
%!     A = mp (complex ([4, 2; 1, 3], [0, 1; 0, 0]));
%!     A(2, 1) = mp ("1", "0") + delta;
%!     expected = (mp ("1", "0") + delta) ./ mp ("4", "0");
%!     mpbits (128);
%!     [L, U, P] = lu (A);
%!     assert (P, eye (2));
%!     assert_complex_matrix (L, 2, 2, precision);
%!     assert (strcmp (char (L(2, 1)), char (expected)));
%!     assert (double (P * A), double (L * U), 1e-12);
%!     assert (mpbits (), uint64 (128));
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!             uint64 (128));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   low = mp (complex ([1, 0; 1, 1], [0, 1; 0, 0]));
%!   delta = mp ("1", "0");
%!   for k = 1:700
%!     delta = delta ./ mp ("2", "0");
%!   endfor
%!   low(2, 1) = mp ("1", "0") + delta;
%!   [~, ~, plow] = lu (low, "vector");
%!   assert (plow(1), 1);
%!   mpbits (1024);
%!   high = mp (complex ([1, 0; 1, 1], [0, 1; 0, 0]));
%!   delta = mp ("1", "0");
%!   for k = 1:700
%!     delta = delta ./ mp ("2", "0");
%!   endfor
%!   high(2, 1) = mp ("1", "0") + delta;
%!   mpbits (128);
%!   [~, ~, phigh] = lu (high, "vector");
%!   assert (phigh(1), 2);
%!   mpbits (4096);
%!   [~, ~, phigh_ambient] = lu (high, "vector");
%!   assert (phigh_ambient, phigh);
%!   assert (mpbits (), uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! mpbits (256);
%! S = mp ([1 + 1i, 2 + 2i; 2 + 2i, 4 + 4i]);
%! [L, U, P] = lu (S);
%! assert_complex_matrix (L, 2, 2, 256);
%! assert_complex_matrix (U, 2, 2, 256);
%! assert (P, [0, 1; 1, 0]);
%! assert (double (P * S), double (L * U), 1e-10);
%! [Lv, Uv, p] = lu (S, "vector");
%! assert (p, [2; 1]);
%! assert (double (S(p, :)), double (Lv * Uv), 1e-10);

%!test
%! mpbits (256);
%! for shape_cell = {[0, 0], [0, 3], [3, 0]}
%!   shape = shape_cell{1};
%!   A = mp (complex (zeros (shape(1), shape(2)), ...
%!                    zeros (shape(1), shape(2))));
%!   packed = lu (A);
%!   [L, U, P] = lu (A);
%!   [Lv, Uv, p] = lu (A, "vector");
%!   assert (size (packed), [0, 0]);
%!   assert (size (L), [0, 0]);
%!   assert (size (U), [0, 0]);
%!   assert (size (P), [0, 0]);
%!   assert (size (p), [0, 0]);
%!   assert (size (Lv), [0, 0]);
%!   assert (size (Uv), [0, 0]);
%! endfor

%!test
%! A = mp ([1 + 1i, 2; 3, 4 - 1i]);
%! fail ("lu (A, \"matrix\")", "vector");
%! fail ("lu (A, \"econ\")", "vector");
%! fail ("lu (A, 0)", "vector");
%! fail ("[a,b,c,d] = lu (A)", "at most three outputs");
