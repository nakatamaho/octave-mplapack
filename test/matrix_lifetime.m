## SPDX-License-Identifier: BSD-2-Clause

matrix = mp ({"1", "2"; "3", "4"});
assigned = matrix;
collection = {matrix};
record.value = matrix;
clear matrix;

assert (size (assigned), [2, 2]);
assert (size (collection{1}), [2, 2]);
assert (size (record.value), [2, 2]);
assert (__mplapack_core__ (
  "matrix_test_element_equal_text", assigned, 2, 2, "4"));
assert (__mplapack_core__ ("module_test_locked"));

clear __mplapack_core__;
assert (size (assigned), [2, 2]);
assert (__mplapack_core__ (
  "matrix_test_element_equal_text", assigned, 1, 2, "2"));
assert (__mplapack_core__ ("module_test_locked"));

for index = 1:1000
  repeated = mp ([1, 2; 3, 4]);
  info = __mplapack_core__ ("matrix_test_info", repeated);
  assert (strcmp (info.internal_type, "mplapack_mpfr_matrix_internal"));
  assert (info.all_elements_same_precision);
endfor

clear repeated info assigned collection record;
assert (__mplapack_core__ ("module_test_locked"));
fprintf ("PASS: M07 matrix clear, copy/container, and repeated type initialization QA\n");
