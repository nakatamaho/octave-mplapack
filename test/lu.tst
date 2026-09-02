## SPDX-License-Identifier: BSD-2-Clause

%!function assert_matrix_close (value, expected, tolerance)
%!  if (nargin < 3)
%!    tolerance = 1e-11;
%!  endif
%!  if (isa (expected, "mp"))
%!    expected = double (expected);
%!  endif
%!  info = __mplapack_core__ ("matrix_test_info", value);
%!  assert (info.rows, uint64 (rows (expected)));
%!  assert (info.columns, uint64 (columns (expected)));
%!  for column = 1:columns (expected)
%!    for row = 1:rows (expected)
%!      got = __mplapack_core__ ("matrix_test_element_double", ...
%!        value, row, column);
%!      assert (got, expected(row, column), tolerance);
%!    endfor
%!  endfor
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   Y = lu (A);
%!   assert (size (Y), [2, 2]);
%!   assert_matrix_close (Y, [3, 4; 1/3, 2/3]);
%!   assert (__mplapack_core__ ("matrix_test_info", Y).precision_bits, ...
%!           uint64 (256));
%!   assert (double (A), [1, 2; 3, 4]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! mpbits (256);
%! A = mp ([1, 2; 3, 4]);
%! [L, U] = lu (A);
%! assert (size (L), [2, 2]);
%! assert (size (U), [2, 2]);
%! assert_matrix_close (L * U, [1, 2; 3, 4]);
%! assert_matrix_close (L, [1/3, 1; 1, 0]);
%! assert_matrix_close (U, [3, 4; 0, 2/3]);
%! [Lc, Uc, P] = lu (A);
%! assert (strcmp (class (P), "double"));
%! assert (size (P), [2, 2]);
%! assert (P, [0, 1; 1, 0]);
%! assert_matrix_close (P * A, [3, 4; 1, 2]);
%! assert_matrix_close (Lc * Uc, P * A);
%! [Lv, Uv, p] = lu (A, "vector");
%! assert (strcmp (class (p), "double"));
%! assert (size (p), [2, 1]);
%! assert (p, [2; 1]);
%! assert_matrix_close (A(p, :), Lv * Uv);
%! assert_matrix_close (Lc, Lv);
%! assert_matrix_close (Uc, Uv);
%! mpbits (512);

%!test
%! mpbits (256);
%! tall = mp ([1, 2; 5, 4; 3, 6]);
%! [L, U, P] = lu (tall);
%! assert (size (L), [3, 2]);
%! assert (size (U), [2, 2]);
%! assert (size (P), [3, 3]);
%! assert_matrix_close (P * tall, L * U);
%! [L2, U2] = lu (tall);
%! assert (size (L2), [3, 2]);
%! assert (size (U2), [2, 2]);
%! assert_matrix_close (tall, L2 * U2);
%! wide = mp ([1, 2, 3; 5, 4, 6]);
%! [Lw, Uw, Pw] = lu (wide);
%! assert (size (Lw), [2, 2]);
%! assert (size (Uw), [2, 3]);
%! assert (size (Pw), [2, 2]);
%! assert_matrix_close (Pw * wide, Lw * Uw);
%! [Lw2, Uw2] = lu (wide);
%! assert_matrix_close (wide, Lw2 * Uw2);
%! mpbits (512);

%!test
%! mpbits (256);
%! S = mp ([1, 2; 2, 4]);
%! [L, U, P] = lu (S);
%! assert (P, [0, 1; 1, 0]);
%! assert_matrix_close (P * S, L * U);
%! [Lv, Uv, p] = lu (S, "vector");
%! assert (p, [2; 1]);
%! assert_matrix_close (S(p, :), Lv * Uv);
%! mpbits (512);

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   delta = strcat (".", repmat ("0", 1, 210), "1");
%!   text = {"4", "2"; "1", "3"};
%!   text{2,1} = strcat ("1", delta);
%!   A = mp (text);
%!   expected_text = {"1"; "1"};
%!   expected_text{2} = strcat ("1", delta);
%!   expected_tail = mp (expected_text) ./ 4;
%!   mpbits (128);
%!   [L, U, P] = lu (A);
%!   assert (P, eye (2));
%!   assert (__mplapack_core__ ("matrix_test_info", L).precision_bits, ...
%!           uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", ...
%!     L, 2, 1, expected_tail, 2, 1));
%!   assert_matrix_close (P * A, L * U, 1e-12);
%!   assert (mpbits (), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (2048);
%!   delta = strcat (".", repmat ("0", 1, 451), "1");
%!   text = {"4", "2"; "1", "3"};
%!   text{2,1} = strcat ("1", delta);
%!   A = mp (text);
%!   expected_text = {"1"; "1"};
%!   expected_text{2} = strcat ("1", delta);
%!   expected_tail = mp (expected_text) ./ 4;
%!   mpbits (128);
%!   [L, U] = lu (A);
%!   assert (__mplapack_core__ ("matrix_test_info", U).precision_bits, ...
%!           uint64 (2048));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", ...
%!     L, 2, 1, expected_tail, 2, 1));
%!   assert (mpbits (), uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   low = mp ({"1", "0"; "1", "1"});
%!   [~, ~, plow] = lu (low, "vector");
%!   assert (plow(1), 1);
%!   mpbits (1024);
%!   high = mp ({"1", "0"; "1", "1"});
%!   high(2, 1) = mp (strcat ("1.", repmat ("0", 1, 210), "1"));
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
%! for value = [4, -4, 0]
%!   Y = lu (mp (value));
%!   [L, U, P] = lu (mp (value));
%!   [Lv, Uv, p] = lu (mp (value), "vector");
%!   assert (size (Y), [1, 1]);
%!   assert (size (L), [1, 1]);
%!   assert (size (U), [1, 1]);
%!   assert (P, 1);
%!   assert (p, 1);
%!   assert (double (L * U), value);
%!   assert (double (Lv * Uv), value);
%! endfor
%! mpbits (512);

%!test
%! mpbits (256);
%! for shape_cell = {[0, 0], [0, 3], [3, 0]}
%!   shape = shape_cell{1};
%!   A = mp (zeros (shape(1), shape(2)));
%!   Y = lu (A);
%!   [L, U, P] = lu (A);
%!   [Lv, Uv, p] = lu (A, "vector");
%!   assert (size (Y), [0, 0]);
%!   assert (size (L), [0, 0]);
%!   assert (size (U), [0, 0]);
%!   assert (size (P), [0, 0]);
%!   assert (size (p), [0, 0]);
%!   assert (size (Lv), [0, 0]);
%!   assert (size (Uv), [0, 0]);
%! endfor
%! mpbits (512);

%!test
%! A = mp ([1, 2; 3, 4]);
%! fail ("lu (A, \"matrix\")", "vector");
%! fail ("lu (A, \"econ\")", "vector");
%! fail ("lu (A, 0)", "vector");
%! fail ("[a,b,c,d] = lu (A)", "at most three outputs");
