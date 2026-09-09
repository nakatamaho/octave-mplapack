## SPDX-License-Identifier: BSD-2-Clause

%!function assert_qr_shapes (q, r, q_rows, q_columns, r_rows, r_columns)
%!  q_info = __mplapack_core__ ("matrix_test_info", q);
%!  r_info = __mplapack_core__ ("matrix_test_info", r);
%!  assert (q_info.rows == uint64 (q_rows));
%!  assert (q_info.columns == uint64 (q_columns));
%!  assert (r_info.rows == uint64 (r_rows));
%!  assert (r_info.columns == uint64 (r_columns));
%!  assert (q_info.is_complex && r_info.is_complex);
%!  assert (q_info.all_elements_same_precision && ...
%!          r_info.all_elements_same_precision);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([1 + 1i, 2 - 1i; 2 + 0i, 1 + 2i; 0 + 1i, 1 + 0i]);
%!   A_before = double (A);
%!   [Q, R] = qr (A);
%!   assert_qr_shapes (Q, R, 3, 3, 3, 2);
%!   assert (double (Q' * Q), eye (3), 1e-10);
%!   assert (double (Q * R), A_before, 1e-10);
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                              R, 2, 1, 0 + 0i));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                              R, 3, 1, 0 + 0i));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!                              R, 3, 2, 0 + 0i));
%!   assert (double (A), A_before);
%!   R_only = qr (A);
%!   assert_qr_shapes (mp (complex (eye (3), zeros (3))), R_only, ...
%!                    3, 3, 3, 2);
%!   assert (double (R_only), double (R), 1e-10);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([1 + 1i, 2 - 1i; 2 + 0i, 1 + 2i; 0 + 1i, 1 + 0i]);
%!   [Q, R] = qr (A, "econ");
%!   assert_qr_shapes (Q, R, 3, 2, 2, 2);
%!   assert (double (Q' * Q), eye (2), 1e-10);
%!   assert (double (Q * R), double (A), 1e-10);
%!   [Q0, R0] = qr (A, 0);
%!   assert_qr_shapes (Q0, R0, 3, 2, 2, 2);
%!   assert (double (Q0 * R0), double (A), 1e-10);
%!   B = mp ([1 + 0i, 2 + 1i, 3 - 1i; 4 + 2i, 5 + 0i, 6 - 2i]);
%!   [Qw, Rw] = qr (B);
%!   assert_qr_shapes (Qw, Rw, 2, 2, 2, 3);
%!   assert (double (Qw' * Qw), eye (2), 1e-10);
%!   assert (double (Qw * Rw), double (B), 1e-10);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for setting = {[1024, 700], [2048, 1500]}
%!     precision = setting{1}(1);
%!     exponent = setting{1}(2);
%!     mpbits (precision);
%!     tail = mp ("1", "-1");
%!     for k = 1:exponent
%!       tail = tail ./ mp ("2", "0");
%!     endfor
%!     A = mp (complex (eye (2), zeros (2)));
%!     A(1, 2) = tail;
%!     mpbits (128);
%!     [Q, R] = qr (A, "econ");
%!     assert_qr_shapes (Q, R, 2, 2, 2, 2);
%!     assert (__mplapack_core__ ("matrix_test_info", R).precision_bits, ...
%!             uint64 (precision));
%!     assert (! __mplapack_core__ ("scalar_test_info", R(1, 2)).is_zero);
%!     assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!             uint64 (128));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp (complex (ones (2, 1), zeros (2, 1)));
%! [Q, R] = qr (A);
%! assert (size (Q), [2, 2]);
%! assert (size (R), [2, 1]);
