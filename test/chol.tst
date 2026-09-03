## SPDX-License-Identifier: BSD-2-Clause

%!function assert_matrix_close (value, expected)
%!  info = __mplapack_core__ ("matrix_test_info", value);
%!  assert (info.rows, uint64 (rows (expected)));
%!  assert (info.columns, uint64 (columns (expected)));
%!  for column = 1:columns (expected)
%!    for row = 1:rows (expected)
%!      got = __mplapack_core__ ("matrix_test_element_double", ...
%!        value, row, column);
%!      assert (got, expected(row, column), 1e-12);
%!    endfor
%!  endfor
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   upper_input = mp ({"4", "2"; "999", "10"});
%!   [R, p] = chol (upper_input);
%!   assert (isa (R, "mp"));
%!   assert (class (p), "double");
%!   assert (p, 0);
%!   assert_matrix_close (R, [2, 1; 0, 3]);
%!   lower_input = mp ({"4", "999"; "2", "10"});
%!   [L, p_lower] = chol (lower_input, "lower");
%!   assert (p_lower, 0);
%!   assert_matrix_close (L, [2, 0; 1, 3]);
%!   assert_matrix_close (chol (upper_input, "upper"), [2, 1; 0, 3]);
%!   L2 = chol (mp ({"4", "2"; "2", "10"}), "lower");
%!   assert_matrix_close (L2, [2, 0; 1, 3]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ({"1", "2"; "2", "1"});
%!   [R, p] = chol (A);
%!   assert (p, 2);
%!   assert (size (R), [1, 1]);
%!   assert (__mplapack_core__ ("scalar_test_equal_double", R, 1));
%!   fail ("chol (A)", "not positive definite");
%!   [R2, p2] = chol (mp ({"4", "0", "0"; "0", "-1", "0"; ...
%!                         "0", "0", "9"}));
%!   assert (p2, 2);
%!   assert (size (R2), [1, 1]);
%!   assert (__mplapack_core__ ("scalar_test_equal_double", R2, 2));
%!   fail ("chol (mp ([1, 2; 2, 1]))", "not positive definite");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   [x, p] = chol (mp ("4"));
%!   assert (isa (x, "mp"));
%!   assert (__mplapack_core__ ("value_shape_info", x).is_matrix, false);
%!   assert (p, 0);
%!   assert (__mplapack_core__ ("scalar_test_equal_double", x, 2));
%!   [z, zp] = chol (mp ("0"));
%!   assert (zp, 1);
%!   assert (size (z), [0, 0]);
%!   fail ("chol (mp (\"0\"))", "not positive definite");
%!   [n, np] = chol (mp ("-1"));
%!   assert (np, 1);
%!   assert (size (n), [0, 0]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"4", "2"; "999", "10"});
%!   before = double (A);
%!   [R, p] = chol (A);
%!   assert (p, 0);
%!   assert (double (A), before);
%!   assert (__mplapack_core__ ("matrix_test_info", R).precision_bits, ...
%!           uint64 (256));
%!   clear A;
%!   assert (__mplapack_core__ ("matrix_test_element_double", R, 1, 1), 2);
%!   C = mp ({"4", "2"; "999", "10"});
%!   mpbits (4096);
%!   [R_high, p_high] = chol (C);
%!   assert (p_high, 0);
%!   assert (__mplapack_core__ ("matrix_test_info", R_high).precision_bits, ...
%!           uint64 (256));
%!   ## The source was constructed before the higher ambient default.
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   delta_text = strcat (".", repmat ("0", 1, 210), "1");
%!   mpbits (1024);
%!   one_plus_delta = strcat ("1", delta_text);
%!   A = mp ({"1", "1"; "1", one_plus_delta});
%!   mpbits (128);
%!   [R, p] = chol (A);
%!   assert (p, 0);
%!   assert (__mplapack_core__ ("matrix_test_info", R).precision_bits, ...
%!           uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_element_double", R, 1, 1), 1);
%!   assert (__mplapack_core__ ("matrix_test_element_double", R, 1, 2), 1);
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!     R, 2, 1, 0));
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%!   delta_2048 = strcat (".", repmat ("0", 1, 451), "1");
%!   mpbits (2048);
%!   one_plus_delta_2048 = strcat ("1", delta_2048);
%!   A2 = mp ({"1", "1"; "1", one_plus_delta_2048});
%!   mpbits (128);
%!   [R2, p2] = chol (A2, "lower");
%!   assert (p2, 0);
%!   assert (__mplapack_core__ ("matrix_test_info", R2).precision_bits, ...
%!           uint64 (2048));
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   delta_text = strcat (".", repmat ("0", 1, 210), "1");
%!   mpbits (512);
%!   one_plus_delta = strcat ("1", delta_text);
%!   A512 = mp ({"1", "1"; "1", one_plus_delta});
%!   [R512, p512] = chol (A512);
%!   assert (p512 > 0);
%!   mpbits (1024);
%!   A1024 = mp ({"1", "1"; "1", one_plus_delta});
%!   mpbits (128);
%!   [R1024, p1024] = chol (A1024);
%!   assert (p1024, 0);
%!   assert (__mplapack_core__ ("matrix_test_info", R1024).precision_bits, ...
%!           uint64 (1024));
%!   assert (size (R512), [1, 1]);
%!   assert (__mplapack_core__ ("scalar_test_equal_double", R512, 1));
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   A = mp ([4, 2; NaN, 10]);
%!   [R, p] = chol (A);
%!   assert (p, 0);
%!   assert_matrix_close (R, [2, 1; 0, 3]);
%!   B = mp ([4, NaN; 2, 10]);
%!   [L, p2] = chol (B, "lower");
%!   assert (p2, 0);
%!   assert_matrix_close (L, [2, 0; 1, 3]);
%!   upper_inf = mp ([4, 2; Inf, 10]);
%!   [R_inf, p_inf] = chol (upper_inf);
%!   assert (p_inf, 0);
%!   assert_matrix_close (R_inf, [2, 1; 0, 3]);
%!   lower_inf = mp ([4, -Inf; 2, 10]);
%!   [L_inf, p_inf_lower] = chol (lower_inf, "lower");
%!   assert (p_inf_lower, 0);
%!   assert_matrix_close (L_inf, [2, 0; 1, 3]);
%!   S = mp ({"4", "2"; "2", "10"});
%!   R = chol (S);
%!   C = R.' * R;
%!   assert_matrix_close (C, [4, 2; 2, 10]);
%!   L = chol (S, "lower");
%!   C2 = L * L.';
%!   assert_matrix_close (C2, [4, 2; 2, 10]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ({"1", "2", "3"; "4", "5", "6"});
%! fail ("chol (A)", "requires a square");
%! fail ("chol (A, \"foo\")", "upper.*lower");
%! fail ("[R,p,Q] = chol (mp (\"4\"))", "at most a factor");
