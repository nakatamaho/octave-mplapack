## SPDX-License-Identifier: BSD-2-Clause

assert (! isempty (which ("mp")));
assert (! isempty (which ("__mplapack_core__")));

original = mp ("1.25");
assigned = original;
copied = mp (original);
collection = {original, assigned};
record.value = copied;

assert (__mplapack_core__ ("module_test_locked"));
clear original __mplapack_core__;

assigned_info = __mplapack_core__ ("scalar_test_info", assigned);
copied_info = __mplapack_core__ ("scalar_test_info", copied);
cell_info = __mplapack_core__ ("scalar_test_info", collection{1});
struct_info = __mplapack_core__ ("scalar_test_info", record.value);

for info = {assigned_info, copied_info, cell_info, struct_info}
  assert (info{1}.precision_bits, int64 (128));
endfor
assert (__mplapack_core__ (
  "scalar_test_equal_string", assigned, "1.25"));
assert (__mplapack_core__ ("scalar_test_equal", assigned, copied));
assert (__mplapack_core__ ("module_test_locked"));

clear assigned copied collection record;
assert (__mplapack_core__ ("module_test_locked"));
fprintf ("PASS: public wrapper clear and native payload lifecycle\n");
