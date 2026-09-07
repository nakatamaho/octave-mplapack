## SPDX-License-Identifier: BSD-2-Clause

%!function assert_rejected (thunk, label)
%!  rejected = false;
%!  try
%!    thunk ();
%!  catch
%!    rejected = true;
%!  end_try_catch
%!  assert (rejected, label);
%!endfunction

%!function assert_residual (A, V, D, tolerance, label)
%!  residual = double (norm (A * V - V * D, "fro"));
%!  assert (residual < tolerance, label);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   A = mp ([2, 1; 1, 2]);
%!   values = eig (A);
%!   [V, D] = eig (A);
%!   [Vv, d] = eig (A, "vector");
%!   [Vm, Dm] = eig (A, "matrix");
%!   assert (isa (values, "mp") && isa (V, "mp") && isa (D, "mp"));
%!   assert (size (values), [2, 1]);
%!   assert (size (V), [2, 2]);
%!   assert (size (D), [2, 2]);
%!   assert (size (Vv), [2, 2]);
%!   assert (size (d), [2, 1]);
%!   assert (size (Vm), [2, 2]);
%!   assert (size (Dm), [2, 2]);
%!   assert (__mplapack_core__ ("value_is_real", values));
%!   assert (__mplapack_core__ ("value_is_real", V));
%!   assert (__mplapack_core__ ("value_is_real", D));
%!   assert_residual (A, V, D, 1e-12, "real symmetric eig residual");
%!   assert_residual (A, Vv, D, 1e-12, "real vector eig residual");
%!   assert_residual (A, Vm, Dm, 1e-12, "real matrix eig residual");
%!   assert (double (transpose (V) * V), eye (2), 1e-12);
%!   assert (double (transpose (Vv) * Vv), eye (2), 1e-12);
%!   assert (double (d (1)), 1, 1e-12);
%!   assert (double (d (2)), 3, 1e-12);
%!   assert (__mplapack_core__ ("matrix_test_element_equal_double", A, 1, 2, 1));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   H = mp ([2, 1 + 1i; 1 - 1i, 3]);
%!   [V, D] = eig (H);
%!   [Vv, d] = eig (H, "vector");
%!   assert (__mplapack_core__ ("value_is_real", D));
%!   assert (__mplapack_core__ ("value_is_real", d));
%!   assert (! __mplapack_core__ ("value_is_real", V));
%!   assert (! __mplapack_core__ ("value_is_real", Vv));
%!   assert_residual (H, V, D, 1e-12, "complex Hermitian eig residual");
%!   assert_residual (H, Vv, D, 1e-12, "complex Hermitian vector residual");
%!   assert (double (ctranspose (V) * V), eye (2), 1e-12);
%!   assert (size (d), [2, 1]);
%!   assert (double (d (1)) > 0 && double (d (2)) > double (d (1)));
%!   assert (__mplapack_core__ ("matrix_test_element_equal_text", H, 2, 1, "(1,-1)"));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   [Vg, Dg] = eig (mp ([1, 2; 3, 4]));
%!   assert_residual (mp ([1, 2; 3, 4]), Vg, Dg, 1e-12, ...
%!                    "nonsymmetric real eig uses the N05 general path");
%!   Cg = mp ([1 + 1i, 2; 3, 4]);
%!   [Vc, Dc] = eig (Cg);
%!   assert_residual (Cg, Vc, Dc, 1e-12, ...
%!                    "non-Hermitian complex eig uses the N05 general path");
%!   Cdiag = mp ([1 + 1i, 0; 0, 2]);
%!   [Vdiag, Ddiag] = eig (Cdiag);
%!   assert_residual (Cdiag, Vdiag, Ddiag, 1e-12, ...
%!                    "complex diagonal non-Hermitian eig uses N05");
%!   assert_rejected (@() eig (mp ([1, 2, 3])), ...
%!                    "non-square eig must be rejected");
%!   assert_rejected (@() eig (mp ([1, 2; 2, 1]), "bad-option"), ...
%!                    "invalid eig option must be rejected");
%!   assert_rejected (@() eig (mp ([1, 2; 2, 1]), "vector"), ...
%!                    "one-output eig vector option must be rejected");
%!   assert_rejected (@() eig (mp ([1, 2; 2, 1]), mp (eye (2))), ...
%!                    "generalized eig must remain deferred");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   repeated = mp ([2, 0; 0, 2]);
%!   [V, D] = eig (repeated);
%!   assert_residual (repeated, V, D, 1e-12, "repeated eig residual");
%!   assert (double (transpose (V) * V), eye (2), 1e-12);
%!   delta = mp ("1");
%!   for k = 1:300
%!     delta = delta * mp ("0.5");
%!   endfor
%!   nearly = mp ([1, 0; 0, 1]);
%!   nearly (1, 2) = delta;
%!   nearly (2, 1) = delta;
%!   [Vn, Dn] = eig (nearly);
%!   assert_residual (nearly, Vn, Dn, 1e-12, "nearly repeated eig residual");
%!   assert (double (transpose (Vn) * Vn), eye (2), 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! for precision = [1024, 2048]
%!   mpbits (precision);
%!   tiny = mp ("1");
%!   half = mp ("0.5");
%!   exponent = 1500;
%!   if (precision == 1024)
%!     exponent = 700;
%!   endif
%!   for k = 1:exponent
%!     tiny = tiny * half;
%!   endfor
%!   A = mp ([1, 0; 0, 3]);
%!   A (1, 1) = tiny;
%!   [V, D] = eig (A);
%!   assert_residual (A, V, D, 1e-12, "high precision eig residual");
%!   assert (__mplapack_core__ ("matrix_test_element_equal", D, 1, 1, A, 1, 1));
%!   info = __mplapack_core__ ("matrix_test_info", V);
%!   assert (info.precision_bits == uint64 (precision));
%! endfor

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (192);
%!   A = mp ([2, 1; 1, 2]);
%!   mpbits (768);
%!   [V, D] = eig (A);
%!   info = __mplapack_core__ ("matrix_test_info", V);
%!   assert (info.precision_bits == uint64 (192));
%!   assert_residual (A, V, D, 1e-12, "ambient precision eig residual");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
