## SPDX-License-Identifier: BSD-2-Clause

%!function assert_state_equal (lhs, rhs, label)
%!  assert (strcmp (lhs.schema, rhs.schema), label);
%!  assert (lhs.version == rhs.version, label);
%!  assert (strcmp (lhs.kind, rhs.kind), label);
%!  assert (lhs.rows == rhs.rows && lhs.columns == rhs.columns, label);
%!  assert (lhs.precision_bits == rhs.precision_bits, label);
%!  assert (isequal (lhs.elements, rhs.elements), label);
%!endfunction

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
%!   for bits = [128, 512, 1024, 2048]
%!     mpbits (bits);
%!     tiny = mp ('1');
%!     limit = 8;
%!     if (bits == 1024), limit = 700; endif
%!     if (bits == 2048), limit = 1500; endif
%!     for k = 1:limit, tiny = tiny * mp ('0.5'); endfor
%!
%!     V = mp ({'1.2345678901234567890123456789', '-0'; '0', 'NaN'});
%!     V(2, 1) = tiny;
%!     expected = __mplapack_core__ ('serialize', V);
%!     path = sprintf ('/tmp/mplapack-t07-binary-%d.mat', bits);
%!     save ('-binary', path, 'V');
%!     clear V;
%!     mpbits (256);
%!     load (path, 'V');
%!     actual = __mplapack_core__ ('serialize', V);
%!     assert_state_equal (expected, actual, ...
%!                         'binary save/load changed the MP state');
%!     assert (__mplapack_core__ ('value_shape_info', V).precision_bits ...
%!             == uint64 (bits));
%!     assert (mpbits () == uint64 (256), ...
%!             'binary load changed the ambient precision');
%!   endfor
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   C = mp ({'(1.234567890123456789,3.4)', '(0,-0)'; ...
%!            '(-Inf,NaN)', '(2.3,-4.5)'});
%!   E = mp (zeros (0, 3));
%!   CE = mp (complex (zeros (2, 0), zeros (2, 0)));
%!   expected_c = __mplapack_core__ ('serialize', C);
%!   expected_e = __mplapack_core__ ('serialize', E);
%!   expected_ce = __mplapack_core__ ('serialize', CE);
%!   saved_object = saveobj (C);
%!   mpbits (256);
%!   hook_value = loadobj (saved_object);
%!   assert_state_equal (expected_c, __mplapack_core__ ('serialize', hook_value), ...
%!                       'direct saveobj/loadobj changed the MP state');
%!   assert (mpbits () == uint64 (256), ...
%!           'direct loadobj changed the ambient precision');
%!   save ('-text', '/tmp/mplapack-t07-text-512.mat', 'C', 'E', 'CE');
%!   clear C E CE;
%!   load ('/tmp/mplapack-t07-text-512.mat');
%!   assert_state_equal (expected_c, __mplapack_core__ ('serialize', C), ...
%!                       'text complex round trip changed the MP state');
%!   assert_state_equal (expected_e, __mplapack_core__ ('serialize', E), ...
%!                       'text empty real round trip changed the shape');
%!   assert_state_equal (expected_ce, __mplapack_core__ ('serialize', CE), ...
%!                       'text empty complex round trip changed the shape');
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect

%!test
%! saved = mpbits ();
%! unwind_protect
%!   mpbits (512);
%!   state = __mplapack_core__ ('serialize', mp ('1'));
%!   bad = state;
%!   bad.version = uint64 (2);
%!   assert_rejected (@() __mplapack_core__ ('deserialize', bad), ...
%!                    'future serialization versions must be rejected');
%!   bad = state;
%!   bad.precision_bits = uint64 (0);
%!   assert_rejected (@() __mplapack_core__ ('deserialize', bad), ...
%!                    'invalid serialization precision must be rejected');
%!   bad = state;
%!   bad.elements = {'1', '2'};
%!   assert_rejected (@() __mplapack_core__ ('deserialize', bad), ...
%!                    'serialization element-count corruption must be rejected');
%! unwind_protect_cleanup
%!   mpbits (saved);
%! end_unwind_protect
