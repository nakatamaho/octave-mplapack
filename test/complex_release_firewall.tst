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
%! assert_rejected (@() eig (A), "complex eig fallback");
%! assert_rejected (@() svd (A), "complex svd fallback");
%! assert_rejected (@() det (A), "complex det fallback");
%! assert_rejected (@() inv (A), "complex inv fallback");
%! assert_rejected (@() rank (A), "complex rank fallback");
%! assert_rejected (@() cond (A), "complex cond fallback");
%! assert_rejected (@() norm (A), "complex norm fallback");
%! assert_rejected (@() sin (A), "complex sin fallback");
%! assert_rejected (@() exp (A), "complex exp fallback");
%! assert_rejected (@() sqrt (A), "complex sqrt fallback");
%! assert_rejected (@() (A ^ 2), "complex power fallback");
%! assert_rejected (@() (A .^ 2), "complex element power fallback");
%! assert_rejected (@() (A < A), "complex ordered-comparison fallback");
%! assert_rejected (@() (A > A), "complex ordered-comparison fallback");
%! assert_rejected (@() (A == A), "complex comparison fallback");
%! assert_rejected (@() logical (A), "complex logical fallback");
%! assert_rejected (@() (A & A), "complex logical-and fallback");
%! assert_rejected (@() sparse (A), "complex sparse fallback");
%! assert_rejected (@() (A / A), "complex right-division fallback");
