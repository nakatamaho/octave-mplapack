## SPDX-License-Identifier: BSD-2-Clause

%!function assert_matrix_close (value, expected, tolerance)
%!  if (nargin < 3)
%!    tolerance = 1e-11;
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
%!   A = mp ([1, 2; 3, 4; 5, 7; 11, 13]);
%!   R_one = qr (A);
%!   [Q, R] = qr (A);
%!   assert (size (R_one), [4, 2]);
%!   assert_matrix_close (R_one, double (R));
%!   assert (size (Q), [4, 4]);
%!   assert (size (R), [4, 2]);
%!   assert_matrix_close (Q * R, [1, 2; 3, 4; 5, 7; 11, 13], 1e-10);
%!   assert_matrix_close (Q.' * Q, eye (4), 1e-10);
%!   for column = 1:columns (R)
%!     for row = column+1:rows (R)
%!       assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                                  R, row, column, 0));
%!     endfor
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! mpbits (256);
%! A = mp ([1, 2; 3, 4; 5, 7; 11, 13]);
%! [Qe, Re] = qr (A, "econ");
%! [Q0, R0] = qr (A, 0);
%! assert (size (Qe), [4, 2]);
%! assert (size (Re), [2, 2]);
%! assert (size (Q0), [4, 2]);
%! assert (size (R0), [2, 2]);
%! assert_matrix_close (Qe * Re, double (A), 1e-10);
%! assert_matrix_close (Q0 * R0, double (A), 1e-10);
%! assert_matrix_close (Qe.' * Qe, eye (2), 1e-10);
%! assert_matrix_close (Re, double (R0));
%! mpbits (512);

%!test
%! mpbits (256);
%! wide = mp ([1, 2, 3, 4; 5, 6, 7, 8]);
%! [Q, R] = qr (wide);
%! [Qe, Re] = qr (wide, "econ");
%! assert (size (Q), [2, 2]);
%! assert (size (R), [2, 4]);
%! assert (size (Qe), [2, 2]);
%! assert (size (Re), [2, 4]);
%! assert_matrix_close (Q * R, double (wide), 1e-10);
%! assert_matrix_close (Q.' * Q, eye (2), 1e-10);
%! assert_matrix_close (Qe * Re, double (wide), 1e-10);
%! mpbits (512);

%!test
%! mpbits (256);
%! row = mp ([1, 2, 3]);
%! col = mp ([1; 2; 3]);
%! [Qr, Rr] = qr (row);
%! [Qc, Rc] = qr (col, "econ");
%! assert (size (Qr), [1, 1]);
%! assert (size (Rr), [1, 3]);
%! assert (size (Qc), [3, 1]);
%! assert (size (Rc), [1, 1]);
%! assert_matrix_close (Qr * Rr, [1, 2, 3]);
%! assert_matrix_close (Qc * Rc, [1; 2; 3]);
%! mpbits (512);

%!test
%! mpbits (256);
%! for shape_cell = {[0, 0], [0, 3], [3, 0]}
%!   shape = shape_cell{1};
%!   A = mp (zeros (shape(1), shape(2)));
%!   [Q, R] = qr (A);
%!   [Qe, Re] = qr (A, "econ");
%!   [Q0, R0] = qr (A, 0);
%!   assert (size (Q), [shape(1), shape(1)]);
%!   assert (size (R), [shape(1), shape(2)]);
%!   if (shape(1) > shape(2))
%!     assert (size (Qe), [shape(1), shape(2)]);
%!     assert (size (Re), [shape(2), shape(2)]);
%!   else
%!     assert (size (Qe), [shape(1), shape(1)]);
%!     assert (size (Re), [shape(1), shape(2)]);
%!   endif
%!   assert (size (Q0), size (Qe));
%!   assert (size (R0), size (Re));
%! endfor
%! mpbits (512);

%!test
%! mpbits (256);
%! for x = [5, -5, 0]
%!   [Q, R] = qr (mp (x));
%!   assert (size (Q), [1, 1]);
%!   assert (size (R), [1, 1]);
%!   assert (__mplapack_core__ ("scalar_test_equal_double", Q, 1));
%!   assert (__mplapack_core__ ("scalar_test_equal_double", R, x));
%!   assert (__mplapack_core__ ("scalar_test_equal_double", qr (mp (x)), x));
%! endfor
%! mpbits (512);

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   tail = strcat ("1.", repmat ("0", 1, 210), "1");
%!   A = mp ({"1", "1"; "0", tail; "0", "0"});
%!   mpbits (128);
%!   [Q, R] = qr (A);
%!   [Qe, Re] = qr (A, "econ");
%!   assert (__mplapack_core__ ("matrix_test_info", Q).precision_bits, ...
%!           uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_info", R).precision_bits, ...
%!           uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_info", Qe).precision_bits, ...
%!           uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_info", Re).precision_bits, ...
%!           uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", R, 2, 2, ...
%!                              A, 2, 2));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", Re, 2, 2, ...
%!                              A, 2, 2));
%!   assert (mpbits (), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%!   mpbits (4096);
%!   [Qh, Rh] = qr (A);
%!   assert (__mplapack_core__ ("matrix_test_info", Qh).precision_bits, ...
%!           uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_info", Rh).precision_bits, ...
%!           uint64 (1024));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (2048);
%!   tail = strcat ("1.", repmat ("0", 1, 450), "1");
%!   A = mp ({"1", "1"; "0", tail; "0", "0"});
%!   mpbits (128);
%!   [Q, R] = qr (A);
%!   assert (__mplapack_core__ ("matrix_test_info", R).precision_bits, ...
%!           uint64 (2048));
%!   assert (__mplapack_core__ ("matrix_test_element_equal", R, 2, 2, ...
%!                              A, 2, 2));
%!   assert (mpbits (), uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! mpbits (256);
%! A = mp ([1, 2; 3, 4]);
%! before = double (A);
%! [Q, R] = qr (A);
%! assert (double (A), before);
%! B = A;
%! [QB, RB] = qr (B);
%! assert (double (A), before);
%! clear A B;
%! assert (__mplapack_core__ ("matrix_test_element_double", Q, 1, 1) != 0);
%! assert (__mplapack_core__ ("matrix_test_element_double", RB, 1, 1) != 0);
%! mpbits (512);

%!test
%! A = mp ([1, 2; 3, 4]);
%! [Qv, Rv] = qr (A, "vector");
%! [Qm, Rm] = qr (A, "matrix");
%! [Qp, Rp, P] = qr (A);
%! assert (double (Qv * Rv), double (A), 1e-10);
%! assert (double (Qm * Rm), double (A), 1e-10);
%! assert (double (Qp * Rp), double (A * P), 1e-10);
%! fail ("qr (A, \"foo\")", "option");
%! fail ("qr (A, A)", "qr option");
%! mpbits (512);
