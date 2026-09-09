## SPDX-License-Identifier: BSD-2-Clause

%!function assert_complex_pivot_shapes (Q, R, P, q_rows, q_columns, r_rows, r_columns)
%!  q_info = __mplapack_core__ ("matrix_test_info", Q);
%!  r_info = __mplapack_core__ ("matrix_test_info", R);
%!  assert (q_info.rows == uint64 (q_rows));
%!  assert (q_info.columns == uint64 (q_columns));
%!  assert (r_info.rows == uint64 (r_rows));
%!  assert (r_info.columns == uint64 (r_columns));
%!  assert (q_info.is_complex && r_info.is_complex);
%!  assert (q_info.all_elements_same_precision && ...
%!          r_info.all_elements_same_precision);
%!  assert (class (P), "double");
%!endfunction

%!function assert_complex_pivot_reconstruction (A, Q, R, P, p, tolerance)
%!  if (! isempty (P))
%!    expected = double (A) * P;
%!  else
%!    expected = double (A(:, p));
%!  endif
%!  assert (double (Q * R), expected, tolerance);
%!endfunction

%!function assert_permutation_pair (P, p)
%!  expected = zeros (size (P));
%!  for column = 1:numel (p)
%!    expected(p(column), column) = 1;
%!  endfor
%!  assert (P, expected);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([1 + 1i, 2 - 1i, 0 + 1i; ...
%!            2 + 0i, 1 + 2i, 1 - 2i; ...
%!            0 + 1i, 1 + 0i, 3 + 1i]);
%!   [Q, R, P] = qr (A);
%!   [Qv, Rv, p] = qr (A, "vector");
%!   assert_complex_pivot_shapes (Q, R, P, 3, 3, 3, 3);
%!   assert_complex_pivot_shapes (Qv, Rv, p, 3, 3, 3, 3);
%!   assert (size (p), [1, 3]);
%!   assert (sort (p), 1:3);
%!   assert_permutation_pair (P, p);
%!   assert_complex_pivot_reconstruction (A, Q, R, P, [], 1e-10);
%!   assert_complex_pivot_reconstruction (A, Qv, Rv, [], p, 1e-10);
%!   assert (double (Q' * Q), eye (3), 1e-10);
%!   assert (double (Qv' * Qv), eye (3), 1e-10);
%!   A_before = double (A);
%!   clear Q R P Qv Rv p;
%!   assert (double (A), A_before);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([1 + 1i, 2 - 1i, 0 + 1i; ...
%!            2 + 0i, 1 + 2i, 1 - 2i; ...
%!            0 + 1i, 1 + 0i, 3 + 1i; ...
%!            1 - 1i, 0 + 2i, 2 + 0i]);
%!   [Qe, Re, Pe] = qr (A, "econ");
%!   [Q0, R0, p0] = qr (A, 0);
%!   assert_complex_pivot_shapes (Qe, Re, Pe, 4, 3, 3, 3);
%!   assert_complex_pivot_shapes (Q0, R0, p0, 4, 3, 3, 3);
%!   assert (size (p0), [1, 3]);
%!   assert (sort (p0), 1:3);
%!   assert_permutation_pair (Pe, p0);
%!   assert_complex_pivot_reconstruction (A, Qe, Re, Pe, [], 1e-10);
%!   assert_complex_pivot_reconstruction (A, Q0, R0, [], p0, 1e-10);
%!   assert (double (Qe' * Qe), eye (3), 1e-10);
%!   assert (double (Q0' * Q0), eye (3), 1e-10);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   wide = mp ([1 + 1i, 2 - 1i, 0 + 1i, 1 - 1i; ...
%!               2 + 0i, 1 + 2i, 1 + 0i, 0 + 2i]);
%!   [Q, R, P] = qr (wide);
%!   [Qe, Re, Pe] = qr (wide, "econ");
%!   [Qv, Rv, p] = qr (wide, "vector");
%!   assert_complex_pivot_shapes (Q, R, P, 2, 2, 2, 4);
%!   assert_complex_pivot_shapes (Qe, Re, Pe, 2, 2, 2, 4);
%!   assert_complex_pivot_shapes (Qv, Rv, p, 2, 2, 2, 4);
%!   assert (size (P), [4, 4]);
%!   assert (size (p), [1, 4]);
%!   assert (sort (p), 1:4);
%!   assert_complex_pivot_reconstruction (wide, Q, R, P, [], 1e-10);
%!   assert_complex_pivot_reconstruction (wide, Qe, Re, Pe, [], 1e-10);
%!   assert_complex_pivot_reconstruction (wide, Qv, Rv, [], p, 1e-10);
%!   assert (double (Q' * Q), eye (2), 1e-10);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for setting = {[1024, 1500], [2048, 1500]}
%!     precision = setting{1}(1);
%!     exponent = setting{1}(2);
%!     mpbits (precision);
%!     delta = mp ("1", "0");
%!     for k = 1:exponent
%!       delta = delta ./ mp ("2", "0");
%!     endfor
%!     A = mp (complex (ones (1, 2), zeros (1, 2)));
%!     A(1, 2) = mp ("1", "0") + delta;
%!     mpbits (128);
%!     [Q, R, p] = qr (A, "vector");
%!     expected_first = 1;
%!     if (precision == 2048)
%!       expected_first = 2;
%!     endif
%!     assert (p(1), expected_first);
%!     assert (__mplapack_core__ ("matrix_test_info", R).precision_bits, ...
%!             uint64 (precision));
%!     assert (__mplapack_core__ ("scalar_test_info", Q).is_complex);
%!     assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%!     assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!             uint64 (128));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! mpbits (256);
%! A = mp (complex (zeros (0, 3), zeros (0, 3)));
%! [Q, R, P] = qr (A);
%! [Qv, Rv, p] = qr (A, "vector");
%! assert (size (Q), [0, 0]);
%! assert (size (R), [0, 3]);
%! assert (size (P), [3, 3]);
%! assert (size (Qv), [0, 0]);
%! assert (size (Rv), [0, 3]);
%! assert (size (p), [1, 3]);
%! assert (P, diag (ones (1, 3)));
%! assert (p, 1:3);

%!test
%! mpbits (256);
%! real_input = mp ([1, 0, 0; 0, 4, 0; 0, 0, 2]);
%! [Q, R, P] = qr (real_input);
%! assert (P, [0, 0, 1; 1, 0, 0; 0, 1, 0]);
%! assert (! __mplapack_core__ ("matrix_test_info", Q).is_complex);
%! assert (! __mplapack_core__ ("matrix_test_info", R).is_complex);
%! assert (double (Q * R), double (real_input) * P, 1e-12);

%!error <qr option must be> qr (mp (complex ([1, 2], [0, 0])), "foo")
