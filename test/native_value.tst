## SPDX-License-Identifier: BSD-2-Clause

%!function value = m02_pass_through (value)
%!endfunction

%!test
%! v = __mplapack_core__ ("scalar_test_create", "0.125", 128);
%! info = __mplapack_core__ ("scalar_test_info", v);
%! assert (strcmp (info.internal_type, "mplapack_mpfr_scalar_internal"));
%! assert (strcmp (info.backend, "mpfr"));
%! assert (info.precision_bits == 128);
%! assert (info.is_scalar);
%! assert (strcmp (typeinfo (v), info.internal_type));
%! assert (__mplapack_core__ ("scalar_test_equal_string", v, "0.125"));
%! clear v;

%!test
%! a = __mplapack_core__ ("scalar_test_create", "1.5", 256);
%! b = a;
%! clear a;
%! info = __mplapack_core__ ("scalar_test_info", b);
%! assert (info.precision_bits == 256);
%! assert (__mplapack_core__ ("scalar_test_equal_string", b, "1.5"));

%!test
%! a = __mplapack_core__ ("scalar_test_create", "-2.25", 512);
%! b = __mplapack_core__ ("scalar_test_clone", a);
%! clear a;
%! info = __mplapack_core__ ("scalar_test_info", b);
%! assert (info.precision_bits == 512);
%! assert (__mplapack_core__ ("scalar_test_equal_string", b, "-2.25"));

%!test
%! a = __mplapack_core__ ("scalar_test_create", "0.125", 128);
%! values = {a, a};
%! clear a;
%! info1 = __mplapack_core__ ("scalar_test_info", values{1});
%! info2 = __mplapack_core__ ("scalar_test_info", values{2});
%! assert (info1.precision_bits == 128);
%! assert (info2.precision_bits == 128);
%! assert (__mplapack_core__ ("scalar_test_equal", values{1}, values{2}));

%!test
%! a = __mplapack_core__ ("scalar_test_create", "0.125", 128);
%! b = __mplapack_core__ ("scalar_test_create", "1.5", 256);
%! c = __mplapack_core__ ("scalar_test_create", "-2.25", 512);
%! ai = __mplapack_core__ ("scalar_test_info", a);
%! bi = __mplapack_core__ ("scalar_test_info", b);
%! ci = __mplapack_core__ ("scalar_test_info", c);
%! assert ([ai.precision_bits, bi.precision_bits, ci.precision_bits], ...
%!         int64 ([128, 256, 512]));
%! copied = __mplapack_core__ ("scalar_test_clone", a);
%! clear a;
%! copied_info = __mplapack_core__ ("scalar_test_info", copied);
%! assert (copied_info.precision_bits == 128);
%! assert (__mplapack_core__ ("scalar_test_equal_string", copied, "0.125"));

%!test
%! value = m02_pass_through (__mplapack_core__ (
%!   "scalar_test_create", "0.1", 512));
%! info = __mplapack_core__ ("scalar_test_info", value);
%! assert (info.precision_bits == 512);
%! assert (__mplapack_core__ ("scalar_test_equal_string", value, "0.1"));

%!test
%! count = 500;
%! values = cell (1, count);
%! for i = 1:count
%!   precision = [128, 256, 512](mod (i - 1, 3) + 1);
%!   values{i} = __mplapack_core__ (
%!     "scalar_test_create", "0.125", precision);
%! endfor
%! copied = values;
%! clear values;
%! for i = 1:37:count
%!   info = __mplapack_core__ ("scalar_test_info", copied{i});
%!   assert (info.precision_bits == [128, 256, 512](mod (i - 1, 3) + 1));
%!   assert (__mplapack_core__ (
%!     "scalar_test_equal_string", copied{i}, "0.125"));
%! endfor
%! clear copied;

%!test
%! first = __mplapack_core__ ("scalar_test_create", "0.125", 128);
%! expected_type = typeinfo (first);
%! for i = 1:500
%!   value = __mplapack_core__ ("scalar_test_create", "0.125", 128);
%!   assert (strcmp (typeinfo (value), expected_type));
%!   assert (__mplapack_core__ ("scalar_test_equal", first, value));
%! endfor

%!error <expects 2 arguments>
%! __mplapack_core__ ("scalar_test_create", "1");

%!error <scalar text must be a string>
%! __mplapack_core__ ("scalar_test_create", 1, 128);

%!error <precision must be a real numeric scalar>
%! __mplapack_core__ ("scalar_test_create", "1", "128");

%!error <precision must be an integer>
%! __mplapack_core__ ("scalar_test_create", "1", 128.5);

%!error <precision must be an integer>
%! __mplapack_core__ ("scalar_test_create", "1", 0);

%!error <precision must be an integer>
%! __mplapack_core__ ("scalar_test_create", "1", -1);

%!error <precision must be an integer>
%! __mplapack_core__ ("scalar_test_create", "1", Inf);

%!error <invalid scalar text>
%! __mplapack_core__ ("scalar_test_create", "not-a-number", 128);

%!error <expected an internal MPLAPACK MPFR scalar>
%! __mplapack_core__ ("scalar_test_info", 1.0);

%!error <expected an internal MPLAPACK MPFR scalar>
%! __mplapack_core__ ("scalar_test_clone", "ordinary string");

%!error <expected an internal MPLAPACK MPFR scalar>
%! __mplapack_core__ ("scalar_test_equal", {}, struct ());

%!error <expected an internal MPLAPACK MPFR scalar>
%! __mplapack_core__ ("scalar_test_equal_string", {1}, "1");

%!error <invalid scalar text>
%! v = __mplapack_core__ ("scalar_test_create", "1.5", 256);
%! __mplapack_core__ ("scalar_test_equal_string", v, "invalid");

%!error <unknown __mplapack_core__ command>
%! __mplapack_core__ ("not_a_command");
