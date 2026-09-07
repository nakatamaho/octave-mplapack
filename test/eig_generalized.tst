## SPDX-License-Identifier: BSD-2-Clause

%!function assert_generalized_right_residual (A, B, V, D, tolerance, label)
%!  residual = double (norm (A * V - B * V * D, "fro"));
%!  assert (residual < tolerance, label);
%!endfunction

%!function assert_generalized_left_residual (A, B, D, W, tolerance, label)
%!  residual = double (norm (ctranspose (W) * A ...
%!                            - D * ctranspose (W) * B, "fro"));
%!  assert (residual < tolerance, label);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([2, 1; 1, 3]);
%!   B = mp ([3, 0; 0, 2]);
%!   A_before = double (A);
%!   [V, D, W] = eig (A, B);
%!   assert_generalized_right_residual (A, B, V, D, 1e-12, ...
%!                                      "real definite generalized right residual");
%!   assert_generalized_left_residual (A, B, D, W, 1e-12, ...
%!                                     "real definite generalized left residual");
%!   assert (sort (diag (double (D))), [0.5; 5/3], 1e-12);
%!   [Vc, Dc] = eig (A, B, "chol", "vector");
%!   assert_generalized_right_residual (A, B, Vc, diag (double (Dc)), 1e-12, ...
%!                                      "real chol vector residual");
%!   [Vq, Dq] = eig (A, B, "qz");
%!   assert_generalized_right_residual (A, B, Vq, Dq, 1e-12, ...
%!                                      "real forced QZ residual");
%!   assert (__mplapack_core__ ("matrix_test_info", Vq).is_complex);
%!   assert (double (A), A_before);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([0, 1; -1, 0]);
%!   B = mp (eye (2));
%!   [V, d, W] = eig (A, B, "qz", "vector");
%!   assert_generalized_right_residual (A, B, V, diag (double (d)), 1e-12, ...
%!                                      "real QZ conjugate-pair residual");
%!   assert_generalized_left_residual (A, B, diag (double (d)), W, 1e-12, ...
%!                                     "real QZ conjugate-pair left residual");
%!   values = sort (double (d));
%!   assert (values, [-1i; 1i], 1e-12);
%!   one_output = eig (A, B, "vector");
%!   assert (sort (double (one_output)), values, 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([1, 1i; -1i, 3]);
%!   B = mp ([2, 0; 0, 1]);
%!   [V, D, W] = eig (A, B, "chol");
%!   assert_generalized_right_residual (A, B, V, D, 1e-12, ...
%!                                      "complex definite generalized residual");
%!   assert_generalized_left_residual (A, B, D, W, 1e-12, ...
%!                                     "complex definite generalized left residual");
%!   assert (__mplapack_core__ ("matrix_test_info", V).is_complex);
%!   assert (! __mplapack_core__ ("matrix_test_info", D).is_complex);
%!   [Vq, Dq] = eig (A, B, "qz", "matrix");
%!   assert_generalized_right_residual (A, B, Vq, Dq, 1e-12, ...
%!                                      "complex forced QZ residual");
%!   mixed_a = mp ([2, 0; 0, 3]);
%!   mixed_b = mp ([1 + 1i, 0; 0, 1]);
%!   [Vm, Dm] = eig (mixed_a, mixed_b, "qz");
%!   assert_generalized_right_residual (mixed_a, mixed_b, Vm, Dm, 1e-12, ...
%!                                      "mixed real/complex generalized residual");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp (eye (2));
%!   B = mp ([1, 0; 0, 0]);
%!   values = eig (A, B);
%!   assert (any (isinf (double (values))));
%!   rejected = false;
%!   try
%!     eig (mp ([1, 1; 0, 1]), B, "chol");
%!   catch
%!     rejected = true;
%!   end_try_catch
%!   assert (rejected, "chol must reject a nonsymmetric generalized pair");
%!   rejected = false;
%!   try
%!     eig (A, B, "balance");
%!   catch
%!     rejected = true;
%!   end_try_catch
%!   assert (rejected, "balance must be rejected for generalized eig");
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
%!     A = mp ([1, 1; 0, 3]);
%!     A (1, 1) = tiny;
%!     B = mp (eye (2));
%!     ambient = mpbits (128);
%!     [V, D] = eig (A, B, "qz");
%!     assert_generalized_right_residual (A, B, V, D, 1e-12, ...
%!                                        "generalized high precision residual");
%!     assert (__mplapack_core__ ("matrix_test_info", D).precision_bits ...
%!             == uint64 (precision));
%!     assert (mpbits () == ambient);
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
