## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({'1','2','3';'4','5','6';'7','8','10'});
%!   [P,H] = hess (A);
%!   assert (double (norm (P*H*P'-A, "fro")) < 1e-60);
%!   assert (double (norm (P'*P-eye (3,"like",P), "fro")) < 1e-60);
%!   [U,S] = schur (A);
%!   assert (double (norm (U'*A*U-S, "fro")) < 1e-60);
%!   [Uc,Sc] = schur (A, "complex");
%!   assert (double (norm (Uc'*A*Uc-Sc, "fro")) < 1e-60);
%!   B = mp ({'1','0','0';'0','0','0';'0','0','2'});
%!   [AA,BB,Q,Z] = qz (A,B);
%!   assert (double (norm (Q*A*Z-AA, "fro")) < 1e-60);
%!   assert (double (norm (Q*B*Z-BB, "fro")) < 1e-60);
%!   [AAr,BBr,Qr,Zr] = qz (A,B,"real");
%!   assert (double (norm (Qr*A*Zr-AAr, "fro")) < 1e-60);
%!   assert (double (norm (Qr*B*Zr-BBr, "fro")) < 1e-60);
%!   C = [mp('1','2'),mp('2','-1');mp('3','0'),mp('4','3')];
%!   [Uc,Sc] = schur (C);
%!   assert (double (norm (Uc'*C*Uc-Sc, "fro")) < 1e-60);
%!   [Pc,Hc] = hess (C);
%!   assert (double (norm (Pc*Hc*Pc'-C, "fro")) < 1e-60);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   for bits = [1024, 2048]
%!     mpbits (bits);
%!     limit = 1500;
%!     if (bits == 1024), limit = 700; endif
%!     tiny = mp ('1');
%!     for k = 1:limit
%!       tiny = tiny * mp ('0.5');
%!     endfor
%!     A = mp ({'1','0';'0','2'});
%!     A(1,1) = tiny;
%!     [P,H] = hess (A);
%!     assert (double (norm (P*H*P'-A, "fro")) < 1e-12);
%!     [U,S] = schur (A);
%!     assert (double (norm (U'*A*U-S, "fro")) < 1e-12);
%!     assert (__mplapack_core__ ("matrix_test_info", H).precision_bits == uint64 (bits));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! A = mp ({'1','2';'3','4'});
%! assert (double (norm (balance (A)-A, "fro")) < 1e-12);
%! [P,H] = hess (A);
%! assert (double (norm (P*H*P'-A, "fro")) < 1e-12);
