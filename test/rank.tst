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
%!   mpbits (512);
%!   A = mp ({"1", "2"; "2", "4"; "3", "6"});
%!   X = A \ mp ({"1"; "2"; "3"});
%!   assert_matrix_close (X, [1/5; 2/5]);
%!   X = A \ mp ({"1"; "2"; "4"});
%!   assert_matrix_close (X, [17/70; 17/35]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   delta_text = strcat ("0.", repmat ("0", 1, 451), "1");
%!   mpbits (2048);
%!   A = mp ({"1", "0"; "0", delta_text; "0", "0"});
%!   B = mp ({"0"; delta_text; "0"});
%!   mpbits (128);
%!   X = A \ B;
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits, ...
%!           uint64 (2048));
%!   assert (__mplapack_core__ ("matrix_test_element_double", X, 2, 1), ...
%!           1, 1e-12);
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2"; "2", "4"; "3", "6"});
%!   B = mp ({"1"; "2"; "3"});
%!   mpbits (4096);
%!   X = A \ B;
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits, ...
%!           uint64 (256));
%!   assert_matrix_close (X, [1/5; 2/5]);
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (4096));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ({"1", "2", "3"; "2", "4", "6"});
%!   B = mp ({"1", "2"; "2", "4"});
%!   X = A \ B;
%!   assert_matrix_close (X, [1/14, 2/14; 2/14, 4/14; 3/14, 6/14]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp (zeros (3, 2));
%!   B = mp ({"1"; "2"; "3"});
%!   X = A \ B;
%!   info = __mplapack_core__ ("matrix_test_info", X);
%!   assert (info.rows, uint64 (2));
%!   assert (info.columns, uint64 (1));
%!   assert_matrix_close (X, [0; 0]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   delta_text = strcat ("0.", repmat ("0", 1, 210), "1");
%!   mpbits (512);
%!   A512 = mp ({"1", "0"; "0", delta_text; "0", "0"});
%!   B512 = mp ({"0"; delta_text; "0"});
%!   X512 = A512 \ B512;
%!   assert (__mplapack_core__ ("matrix_test_info", X512).precision_bits, ...
%!           uint64 (512));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", ...
%!     X512, 2, 1, 0));
%!   mpbits (1024);
%!   A1024 = mp ({"1", "0"; "0", delta_text; "0", "0"});
%!   B1024 = mp ({"0"; delta_text; "0"});
%!   mpbits (128);
%!   X1024 = A1024 \ B1024;
%!   assert (__mplapack_core__ ("matrix_test_info", X1024).precision_bits, ...
%!           uint64 (1024));
%!   assert (__mplapack_core__ ("matrix_test_element_double", ...
%!     X1024, 2, 1), 1, 1e-12);
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (128));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits"), ...
%!           uint64 (128));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "2"; "2", "4"; "3", "6"});
%!   B = [1; 2; 3];
%!   X = A \ B;
%!   assert_matrix_close (X, [1/5; 2/5]);
%!   X2 = [1, 2; 2, 4; 3, 6] \ mp ({"1"; "2"; "3"});
%!   assert_matrix_close (X2, [1/5; 2/5]);
%!   B_mp = mp ({"1"; "2"; "3"});
%!   mpbits (4096);
%!   X3 = A \ B_mp;
%!   assert (__mplapack_core__ ("matrix_test_info", X3).precision_bits, ...
%!           uint64 (256));
%!   assert (__mplapack_core__ ("precision_get_bits"), uint64 (4096));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({"1", "0"; "0", "1"; "1", "1"});
%!   B = mp ({"0"; "1"; "4"});
%!   X = A \ B;
%!   assert_matrix_close (X, [1; 2]);
%!   assert (__mplapack_core__ ("matrix_test_info", X).precision_bits, ...
%!           uint64 (256));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
