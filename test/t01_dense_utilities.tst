## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({'1','2';'3','4'});
%!   X = pinv (A);
%!   I = eye (2, "like", A);
%!   assert (double (norm (A*X-I, "fro")) < 1e-50);
%!   assert (double (norm (X*A-I, "fro")) < 1e-50);
%!   assert (double (norm (A*X*A-A, "fro")) < 1e-50);
%!   assert (double (norm (X*A*X-X, "fro")) < 1e-50);
%!   Xe = pinv (A, mp ('1e-100'));
%!   assert (double (norm (Xe-X, "fro")) < 1e-50);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({'1','2','3';'2','4','6'});
%!   Z = null (A);
%!   assert (size (Z) == [3, 2]);
%!   assert (double (norm (A*Z, "fro")) < 1e-50);
%!   assert (double (norm (Z'*Z-eye (2, "like", Z), "fro")) < 1e-50);
%!   O = orth (A);
%!   assert (size (O) == [2, 1]);
%!   assert (double (norm (O'*O-eye (1, "like", O), "fro")) < 1e-50);
%!   assert (double (norm (O*O'*A-A, "fro")) < 1e-50);
%!   Ztol = null (A, mp ('1e-10'));
%!   assert (size (Ztol) == [3, 2]);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   A = mp ({'1','2','3';'2','4','6'});
%!   [R,k] = rref (A);
%!   assert (k == 1);
%!   assert (double (norm (R-mp ({'1','2','3';'0','0','0'}), "fro")) < 1e-50);
%!   [Rt,kt] = rref (A, mp ('1e-10'));
%!   assert (kt == 1);
%!   assert (double (norm (Rt-R, "fro")) < 1e-50);
%!   K = kron (mp ([1,2]), mp ([3;4]));
%!   assert (size (K) == [2, 2]);
%!   assert (double (K(1,1)) == 3 && double (K(2,2)) == 8);
%!   C = [mp('1','2'),mp('2','-1')];
%!   Kc = kron (C, mp ([1;2]));
%!   assert (! isreal (Kc));
%!   assert (double (real (Kc(1,1))) == 1);
%!   assert (double (imag (Kc(1,1))) == 2);
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
%!     for k = 1:limit, tiny = tiny * mp ('0.5'); endfor
%!     A = mp ({'1','1';'1','1'});
%!     A(2,2) = mp (1) + tiny;
%!     [R,k] = rref (A);
%!     assert (k == [1,2]);
%!     assert (double (norm (R-eye (2, "like", R), "fro")) < 1e-12);
%!     assert (__mplapack_core__ ("matrix_test_info", R).precision_bits == uint64 (bits));
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
