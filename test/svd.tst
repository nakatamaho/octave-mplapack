## SPDX-License-Identifier: BSD-2-Clause

%!function assert_close_mp (value, tolerance, label)
%!  got = double (norm (value, "fro"));
%!  assert (got < tolerance, label);
%!endfunction

%!function assert_svd_shapes (m, n, economy, U, S, V)
%!  k = min (m, n);
%!  if (economy)
%!    assert (size (U), [m, k]);
%!    assert (size (S), [k, k]);
%!    assert (size (V), [n, k]);
%!  else
%!    assert (size (U), [m, m]);
%!    assert (size (S), [m, n]);
%!    assert (size (V), [n, n]);
%!  endif
%!endfunction

%!function check_real_svd (m, n)
%!  A = mp (reshape (1:(m * n), m, n));
%!  [U, S, V] = svd (A);
%!  assert_svd_shapes (m, n, false, U, S, V);
%!  assert (isa (U, "mp") && isa (S, "mp") && isa (V, "mp"));
%!  assert (__mplapack_core__ ("value_is_real", U));
%!  assert (__mplapack_core__ ("value_is_real", S));
%!  assert (__mplapack_core__ ("value_is_real", V));
%!  if (m > 0 && n > 0)
%!    assert_close_mp (A - U * S * transpose (V), 1e-10, ...
%!                     "real full SVD reconstruction");
%!  endif
%!  k = min (m, n);
%!  if (k > 0)
%!    assert_close_mp (transpose (U) * U - mp (eye (m)), 1e-10, ...
%!                     "real full U orthogonality");
%!    assert_close_mp (transpose (V) * V - mp (eye (n)), 1e-10, ...
%!                     "real full V orthogonality");
%!  endif
%!  singular_values = svd (A);
%!  assert (size (singular_values), [k, 1]);
%!  assert (__mplapack_core__ ("value_is_real", singular_values));
%!  if (k == 1)
%!    assert_close_mp (singular_values - S, 1e-10, ...
%!                     "real scalar singular values output");
%!  else
%!    for index = 1:k
%!      assert_close_mp (singular_values (index) - S (index, index), 1e-10, ...
%!                       "real singular values output");
%!    endfor
%!  endif
%!  [Ue, Se, Ve] = svd (A, "econ");
%!  assert_svd_shapes (m, n, true, Ue, Se, Ve);
%!  if (m > 0 && n > 0)
%!    assert_close_mp (A - Ue * Se * transpose (Ve), 1e-10, ...
%!                     "real economy SVD reconstruction");
%!  endif
%!  if (k > 0)
%!    assert_close_mp (transpose (Ue) * Ue - mp (eye (k)), 1e-10, ...
%!                     "real economy U orthogonality");
%!    assert_close_mp (transpose (Ve) * Ve - mp (eye (k)), 1e-10, ...
%!                     "real economy V orthogonality");
%!  endif
%!  [U0, S0, V0] = svd (A, 0);
%!  assert_svd_shapes (m, n, true, U0, S0, V0);
%!endfunction

%!function check_complex_svd (m, n)
%!  A = mp (complex (reshape (1:(m * n), m, n), ...
%!                   reshape (m:(m * n + m - 1), m, n)));
%!  [U, S, V] = svd (A);
%!  assert_svd_shapes (m, n, false, U, S, V);
%!  assert (isa (U, "mp") && isa (S, "mp") && isa (V, "mp"));
%!  assert (! __mplapack_core__ ("value_is_real", U));
%!  assert (__mplapack_core__ ("value_is_real", S));
%!  assert (! __mplapack_core__ ("value_is_real", V));
%!  if (m > 0 && n > 0)
%!    assert_close_mp (A - U * S * ctranspose (V), 1e-10, ...
%!                     "complex full SVD reconstruction");
%!  endif
%!  k = min (m, n);
%!  if (k > 0)
%!    identity = mp (complex (eye (k), zeros (k)));
%!    assert_close_mp (ctranspose (U) * U - mp (complex (eye (m), zeros (m))), ...
%!                     1e-10, "complex full U unitarity");
%!    assert_close_mp (ctranspose (V) * V - mp (complex (eye (n), zeros (n))), ...
%!                     1e-10, "complex full V unitarity");
%!    assert (isa (identity, "mp"));
%!  endif
%!  singular_values = svd (A);
%!  assert (size (singular_values), [k, 1]);
%!  assert (__mplapack_core__ ("value_is_real", singular_values));
%!  [Ue, Se, Ve] = svd (A, "econ");
%!  assert_svd_shapes (m, n, true, Ue, Se, Ve);
%!  assert (__mplapack_core__ ("value_is_real", Se));
%!  if (m > 0 && n > 0)
%!    assert_close_mp (A - Ue * Se * ctranspose (Ve), 1e-10, ...
%!                     "complex economy SVD reconstruction");
%!  endif
%!  [U0, S0, V0] = svd (A, 0);
%!  assert_svd_shapes (m, n, true, U0, S0, V0);
%!endfunction

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   for shape = [1, 1; 3, 2; 2, 3; 0, 3; 3, 0; 0, 0].'
%!     check_real_svd (shape (1), shape (2));
%!   endfor
%!   for shape = [1, 1; 3, 2; 2, 3; 0, 3; 3, 0; 0, 0].'
%!     check_complex_svd (shape (1), shape (2));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (1024);
%!   A1024 = mp ({"1e-700", "0"; "0", "1"});
%!   s1024 = svd (A1024);
%!   assert (__mplapack_core__ ("value_shape_info", s1024).precision_bits == 1024);
%!   assert (! __mplapack_core__ ("scalar_test_info", s1024 (2)).is_zero);
%!   mpbits (2048);
%!   A2048 = mp ({"1e-1500", "0"; "0", "1"});
%!   [U, S, V] = svd (A2048);
%!   assert (__mplapack_core__ ("matrix_test_info", S).precision_bits == 2048);
%!   assert_close_mp (S (1, 1) - mp ("1"), 1e-10, ...
%!                    "2048-bit dominant singular value");
%!   assert (! __mplapack_core__ ("scalar_test_info", S (2, 2)).is_zero);
%!   before = A2048;
%!   svd (A2048);
%!   assert_close_mp (A2048 - before, 1e-10, "SVD input immutability");
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   A = mp ({"1", "2"; "3", "4"});
%!   mpbits (128);
%!   assert (mpbits () == 128);
%!   svd (A);
%!   assert (mpbits () == 128);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ([1, 2; 3, 4]);
%! rejected = false;
%! try
%!   svd (A, "bad-option");
%! catch
%!   rejected = true;
%! end_try_catch
%! assert (rejected, "invalid SVD option was accepted");
%! rejected = false;
%! try
%!   [U, S] = svd (A);
%! catch
%!   rejected = true;
%! end_try_catch
%! assert (rejected, "two-output SVD was accepted");
