## SPDX-License-Identifier: BSD-2-Clause

%!function assert_right_residual (A, V, D, tolerance, label)
%!  residual = double (norm (A * V - V * D, "fro"));
%!  assert (residual < tolerance, label);
%!endfunction

%!function assert_left_residual (A, D, W, tolerance, label)
%!  residual = double (norm (ctranspose (W) * A - D * ctranspose (W), "fro"));
%!  assert (residual < tolerance, label);
%!endfunction

%!function assert_general_shapes (V, D, W, precision, label)
%!  v_info = __mplapack_core__ ("matrix_test_info", V);
%!  d_info = __mplapack_core__ ("matrix_test_info", D);
%!  w_info = __mplapack_core__ ("matrix_test_info", W);
%!  assert (v_info.rows == uint64 (2) && v_info.columns == uint64 (2), label);
%!  assert (d_info.rows == uint64 (2) && d_info.columns == uint64 (2), label);
%!  assert (w_info.rows == uint64 (2) && w_info.columns == uint64 (2), label);
%!  assert (v_info.precision_bits == uint64 (precision), label);
%!  assert (d_info.precision_bits == uint64 (precision), label);
%!  assert (w_info.precision_bits == uint64 (precision), label);
%!  assert (v_info.is_complex && d_info.is_complex && w_info.is_complex, label);
%!  assert (v_info.all_elements_same_precision ...
%!          && d_info.all_elements_same_precision ...
%!          && w_info.all_elements_same_precision, label);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([0, 1; -1, 0]);
%!   A_before = double (A);
%!   [V, D, W] = eig (A);
%!   assert_general_shapes (V, D, W, 512, "real general eig shape/precision");
%!   assert_right_residual (A, V, D, 1e-12, "real general right residual");
%!   assert_left_residual (A, D, W, 1e-12, "real general left residual");
%!   values = sort (diag (double (D)));
%!   assert (values, [-1i; 1i], 1e-12);
%!   [Vv, d] = eig (A, "vector");
%!   assert (__mplapack_core__ ("matrix_test_info", Vv).is_complex);
%!   assert (__mplapack_core__ ("matrix_test_info", d).is_complex);
%!   assert (sort (double (d)), values, 1e-12);
%!   assert (double (A), A_before);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([1 + 0i, 2 + 1i; 0 + 0i, 3 + 0i]);
%!   A_before = double (A);
%!   [V, D, W] = eig (A, "nobalance");
%!   assert_general_shapes (V, D, W, 512, "complex general eig shape/precision");
%!   assert_right_residual (A, V, D, 1e-12, "complex general right residual");
%!   assert_left_residual (A, D, W, 1e-12, "complex general left residual");
%!   assert (sort (diag (double (D))), [1; 3], 1e-12);
%!   assert (double (A), A_before);
%!   [Vb, Db] = eig (A, "balance");
%!   assert_right_residual (A, Vb, Db, 1e-12, "complex balance residual");
%!   [Vv, d] = eig (A, "vector");
%!   assert (__mplapack_core__ ("matrix_test_info", Vv).is_complex);
%!   assert (__mplapack_core__ ("matrix_test_info", d).is_complex);
%!   assert (sort (double (d)), [1; 3], 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   G = mp (gallery ("grcar", 8));
%!   [Vd, Dd] = eig (G);
%!   [Vb, Db, Wb] = eig (G, "balance");
%!   [Vn, Dn] = eig (G, "nobalance");
%!   assert_right_residual (G, Vd, Dd, 1e-12, "Grcar default right residual");
%!   assert_right_residual (G, Vb, Db, 1e-12, "Grcar balanced right residual");
%!   assert_left_residual (G, Db, Wb, 1e-12, "Grcar balanced left residual");
%!   assert_right_residual (G, Vn, Dn, 1e-12, "Grcar unbalanced right residual");
%!   assert (double (Dd), double (Db), 1e-12);
%!   assert (__mplapack_core__ ("matrix_test_info", Vb).is_complex);
%!   assert (__mplapack_core__ ("matrix_test_info", Wb).is_complex);
%!   for precision = [128, 256, 512]
%!     mpbits (precision);
%!     Gp = mp (gallery ("grcar", 8));
%!     [Vp, Dp] = eig (Gp, "balance");
%!     assert_right_residual (Gp, Vp, Dp, 1e-12, ...
%!                            "Grcar precision progression residual");
%!     assert (__mplapack_core__ ("matrix_test_info", Dp).precision_bits ...
%!             == uint64 (precision));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   delta = mp ("1");
%!   for k = 1:80
%!     delta = delta * mp ("0.5");
%!   endfor
%!   nearly = mp ([1, 1; 0, 1]);
%!   nearly (2, 2) = mp ("1") + delta;
%!   [Vj, Dj] = eig (nearly);
%!   assert_right_residual (nearly, Vj, Dj, 1e-12, ...
%!                          "nearly repeated general eig residual");
%!   scaled = mp ([1, 1; 0, 1]);
%!   scaled (1, 1) = mp ("1e100");
%!   scaled (2, 2) = mp ("1e-100");
%!   [Vs, Ds] = eig (scaled);
%!   assert_right_residual (scaled, Vs, Ds, 1e-12, ...
%!                          "badly scaled general eig residual");
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
%!     tiny = mp ("1");
%!     for k = 1:exponent
%!       tiny = tiny * mp ("0.5");
%!     endfor
%!     A = mp ([1, 2; 0, 3]);
%!     A (1, 1) = tiny;
%!     mpbits (128);
%!     [V, D] = eig (A, "nobalance");
%!     assert_right_residual (A, V, D, 1e-12, "general eig high precision residual");
%!     d_info = __mplapack_core__ ("matrix_test_info", D);
%!     assert (d_info.precision_bits == uint64 (precision));
%!     assert (! __mplapack_core__ ("matrix_test_element_equal_text", ...
%!                                  D, 1, 1, "(0,0)"));
%!     assert (__mplapack_core__ ("precision_get_bits") == uint64 (128));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (192);
%!   A = mp ([1, 2; 0, 3]);
%!   mpbits (768);
%!   [V, D] = eig (A);
%!   assert_right_residual (A, V, D, 1e-12, "ambient precision general eig residual");
%!   assert (__mplapack_core__ ("matrix_test_info", V).precision_bits ...
%!           == uint64 (192));
%!   assert (__mplapack_core__ ("precision_get_bits") == uint64 (768));
%!   assert (__mplapack_core__ ("precision_test_mpfr_global_bits") ...
%!           == uint64 (768));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! rejected = false;
%! try
%!   eig (mp ([1, 2; 2, 1]), mp (eye (2)));
%! catch
%!   rejected = true;
%! end_try_catch
%! assert (rejected, "generalized eig must remain deferred to N06");
