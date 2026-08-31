## SPDX-License-Identifier: BSD-2-Clause

assert (! isempty (which ("__mplapack_core__")));

value = __mplapack_core__ ("scalar_test_create", "0.125", 128);
assigned = value;
cloned = __mplapack_core__ ("scalar_test_clone", value);
collection = {value, assigned, cloned};

assert (__mplapack_core__ ("module_test_locked"));
clear value __mplapack_core__;
assert (strcmp (typeinfo (assigned), "mplapack_mpfr_scalar_internal"));
printed = evalc ("disp (assigned)");
assert (! isempty (strfind (printed, "internal MPLAPACK MPFR scalar")));
clear printed;
assert (__mplapack_core__ ("module_test_locked"));

assigned_info = __mplapack_core__ ("scalar_test_info", assigned);
clone_info = __mplapack_core__ ("scalar_test_info", cloned);
cell_info = __mplapack_core__ ("scalar_test_info", collection{1});

assert (assigned_info.precision_bits == 128);
assert (clone_info.precision_bits == 128);
assert (cell_info.precision_bits == 128);
assert (__mplapack_core__ (
  "scalar_test_equal_string", assigned, "0.125"));
assert (__mplapack_core__ ("scalar_test_equal", assigned, cloned));

clear assigned cloned collection assigned_info clone_info cell_info;
assert (__mplapack_core__ ("module_test_locked"));
fprintf ("PASS: locked-module clear and live-value lifecycle\n");
