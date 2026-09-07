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
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ([1, 2; 3, 4]);
%!   assert_rejected (@() schur (A), "standalone schur must remain unsupported");
%!   assert_rejected (@() qz (A, A), "standalone qz must remain unsupported");
%!   assert_rejected (@() hess (A), "hess must remain unsupported");
%!   assert_rejected (@() expm (A), "expm must remain unsupported");
%!   assert_rejected (@() logm (A), "logm must remain unsupported");
%!   assert_rejected (@() sparse (A), "sparse conversion must remain unsupported");
%!   assert_rejected (@() reshape (A, [1, 1, 4]), ...
%!                    "N-dimensional reshape must remain unsupported");
%!   C = mp ([1 + 1i, 2; 3, 4 - 1i]);
%!   assert_rejected (@() (C < C), "ordered complex comparison must remain unsupported");
%!   assert_rejected (@() (C == C), "complex equality must remain unsupported");
%!   assert_rejected (@() (C ^ 2), "complex power must remain unsupported");
%!   assert (double (C / C), eye (2), 1e-12);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! mpbits (512);
%! G = mp (gallery ("grcar", 32));
%! [V, D] = eig (G, "nobalance");
%! assert (double (norm (G * V - V * D, "fro")) < 1e-12, ...
%!         "permanent N07 Grcar residual");
%! assert (__mplapack_core__ ("matrix_test_info", D).precision_bits ...
%!         == uint64 (512));
