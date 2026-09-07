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

%!test
%! mpbits (256);
%! A = mp ([1 + 1i, 2; 3, 4 - 1i]);
%! [Vg, Dg, Wg] = eig (A);
%! assert (double (norm (A * Vg - Vg * Dg, "fro")) < 1e-12, ...
%!         "N05 general eig complex right residual");
%! assert (double (norm (ctranspose (Wg) * A - Dg * ctranspose (Wg), ...
%!                        "fro")) < 1e-12, ...
%!         "N05 general eig complex left residual");
%! assert (double (norm (sin (A) - sin (double (A)), "fro")) < 1e-12);
%! assert (double (norm (exp (A) - exp (double (A)), "fro")) < 1e-12);
%! assert (double (norm (sqrt (A) - sqrt (double (A)), "fro")) < 1e-12);
%! assert (double (norm (A ^ 2 - double (A) ^ 2, "fro")) < 1e-12);
%! assert (double (norm (A .^ 2 - double (A) .^ 2, "fro")) < 1e-12);
%! assert_rejected (@() (A < A), "complex ordered-comparison fallback");
%! assert_rejected (@() (A > A), "complex ordered-comparison fallback");
%! assert_rejected (@() (A == A), "complex comparison fallback");
%! assert_rejected (@() logical (A), "complex logical fallback");
%! assert_rejected (@() (A & A), "complex logical-and fallback");
%! assert_rejected (@() sparse (A), "complex sparse fallback");
%! assert (double (A / A), eye (2), 1e-12);
%! d = det (A);
%! X = inv (A);
%! assert (isfinite (double (d)));
%! assert (double (norm (A * X - mp (complex (eye (2), zeros (2))))) < 1e-12);
%! [U, S, V] = svd (A);
%! assert (__mplapack_core__ ("value_is_real", S));
%! assert (double (norm (A - U * S * ctranspose (V), "fro")) < 1e-12);
%! assert (rank (A), 2);
%! assert (double (cond (A)) > 1);
%! assert (double (rcond (A)) > 0);
