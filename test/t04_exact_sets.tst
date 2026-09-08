## SPDX-License-Identifier: BSD-2-Clause

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   a = mp ({'3','1','3','2'});
%!   [u,ia,inv] = unique (a);
%!   assert (double (norm (u-mp ([1,2,3]), "fro")) < 1e-50);
%!   assert (ia == [2;4;1]);
%!   assert (inv == [3;1;3;2]);
%!   [us,is,js] = unique (a, "stable");
%!   assert (double (norm (us-mp ([3,1,2]), "fro")) < 1e-50);
%!   assert (is == [1;2;4]);
%!   assert (js == [1;2;1;3]);
%!   b = mp ({'2','4','1'});
%!   [u,ua,ub] = union (a,b);
%!   assert (double (norm (u-mp ([1,2,3,4]), "fro")) < 1e-50);
%!   assert (ua == [2;4;1] && ub == 2);
%!   [u,ua,ub] = union (a,b, "stable");
%!   assert (double (norm (u-mp ([3,1,2,4]), "fro")) < 1e-50);
%!   assert (ua == [1;2;4] && ub == 2);
%!   [i,ia,ib] = intersect (a,b);
%!   assert (double (norm (i-mp ([1,2]), "fro")) < 1e-50);
%!   assert (ia == [2;4] && ib == [3;1]);
%!   [d,di] = setdiff (a,b, "stable");
%!   assert (double (norm (d-mp ('3'), "fro")) < 1e-50);
%!   assert (di == 1);
%!   [x,xi,xj] = setxor (a,b);
%!   assert (double (norm (x-mp ([3,4]), "fro")) < 1e-50);
%!   assert (xi == 1 && xj == 2);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (256);
%!   C = [mp('1','2'),mp('2','-1');mp('1','2'),mp('3','0')];
%!   [u,ia,inv] = unique (C, "rows");
%!   assert (size (u) == [2,2]);
%!   assert (ia == [1;2]);
%!   assert (inv == [1;2]);
%!   B = [mp('3','0'),mp('0','1');mp('1','2'),mp('2','-1')];
%!   [u,ua,ub] = union (C,B,"rows","stable");
%!   assert (size (u) == [3,2]);
%!   assert (ua == [1;2] && ub == 1);
%!   [i,ia,ib] = intersect (C,B,"rows");
%!   assert (size (i) == [1,2]);
%!   assert (ia == 1 && ib == 2);
%!   [tf,loc] = ismember (C,B,"rows");
%!   assert (tf == [true;false]);
%!   assert (loc == [2;0]);
%!   [d,di] = setdiff (C,B,"rows","stable");
%!   assert (size (d) == [1,2] && di == 2);
%!   [x,xi,xj] = setxor (C,B,"rows","stable");
%!   assert (size (x) == [2,2] && xi == 2 && xj == 1);
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   z = [mp('0'),mp('-0'),mp('Inf'),mp('-Inf'),mp('NaN'),mp('NaN')];
%!   uz = unique (z, "stable");
%!   assert (numel (uz) == 5);
%!   assert (isequaln (uz(1),mp('0')));
%!   assert (isinf (uz(2)) && isinf (uz(3)));
%!   assert (isnan (uz(4)) && isnan (uz(5)));
%!   [tf,loc] = ismember (mp('NaN'),uz);
%!   assert (! tf && loc == 0);
%!   C = [mp('1','2'),mp('1','2')];
%!   [tf,loc] = ismember (C, C);
%!   assert (tf == [true,true] && loc == [1,1]);
%!   empty = zeros (0,1,"like",C);
%!   assert (isempty (unique (empty)));
%!   assert (isempty (union (empty,empty)));
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
