// SPDX-License-Identifier: BSD-2-Clause

#include "mp_script_sequence.h"

#include <complex>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace
{

using namespace octave_mplapack;

void
require (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

bool
complex_equals (const MpfrComplexScalarStorage::NativeScalar& value,
                long real, long imag)
{
  return mpfr_cmp_si (mpc_realref (value.mpc_data ()), real) == 0
         && mpfr_cmp_si (mpc_imagref (value.mpc_data ()), imag) == 0;
}

void
check_real_sort ()
{
  const MpfrMatrixStorage source (
    2, 3, 256, std::vector<std::string> {
      "3", "2", "1", "NaN", "2", "4" });
  const auto ascending = mpfr_script_sort (source, 1, false);
  require (ascending.values.element_exactly_equal_text (0, 0, "2"),
           "real sort ascending first column mismatch");
  require (ascending.values.element_exactly_equal_text (1, 0, "3"),
           "real sort ascending second row mismatch");
  require (ascending.values.element_exactly_equal_text (0, 1, "1"),
           "real sort ascending second column mismatch");
  require (mpfr_nan_p (ascending.values.at (1, 1).mpfr_data ()) != 0,
           "real sort must place NaN last in ascending order");
  require (ascending.indices == std::vector<std::size_t> {2, 1, 1, 2, 1, 2},
           "real sort indices mismatch");

  const auto descending = mpfr_script_sort (source, 2, true);
  require (descending.values.element_exactly_equal_text (0, 0, "3"),
           "real row sort first row mismatch");
  require (descending.values.element_exactly_equal_text (0, 1, "2"),
           "real row sort first row second value mismatch");
  require (mpfr_nan_p (descending.values.at (1, 0).mpfr_data ()) != 0,
           "real descending sort value mismatch");
  require (descending.indices
             == std::vector<std::size_t> {1, 2, 3, 3, 2, 1},
           "real descending sort indices mismatch");
}

void
check_complex_sort ()
{
  const MpfrComplexMatrixStorage source (
    1, 6, 256, std::vector<std::complex<double>> {
      {1, 1}, {-1, 1}, {-1, -1}, {1, -1}, {2, 0}, {0, 2} });
  const auto result = mpc_script_sort (source, 2, false);
  require (result.indices == std::vector<std::size_t> {3, 4, 1, 2, 5, 6},
           "complex magnitude/phase sort indices mismatch");
  require (complex_equals (result.values.data ()[0], -1, -1),
           "complex sort first value mismatch");
  require (complex_equals (result.values.data ()[4], 2, 0),
           "complex sort magnitude tie-break mismatch");
}

void
check_diff ()
{
  const MpfrMatrixStorage source (
    2, 2, 256, std::vector<std::string> {"1", "2", "3", "5"});
  const auto row_difference = mpfr_script_diff (source, 1, 1);
  require (row_difference.rows () == 1 && row_difference.columns () == 2,
           "real row diff shape mismatch");
  require (row_difference.element_exactly_equal_text (0, 0, "1")
           && row_difference.element_exactly_equal_text (0, 1, "2"),
           "real row diff values mismatch");
  const auto column_difference = mpfr_script_diff (source, 1, 2);
  require (column_difference.rows () == 2 && column_difference.columns () == 1,
           "real column diff shape mismatch");
  require (column_difference.element_exactly_equal_text (0, 0, "2")
           && column_difference.element_exactly_equal_text (1, 0, "3"),
           "real column diff values mismatch");
  const auto second_difference = mpfr_script_diff (
    MpfrMatrixStorage (1, 4, 256,
                       std::vector<std::string> {"1", "4", "9", "16"}),
    2, 2);
  require (second_difference.element_exactly_equal_text (0, 0, "2")
           && second_difference.element_exactly_equal_text (0, 1, "2"),
           "real second diff values mismatch");

  const MpfrComplexMatrixStorage complex_source (
    3, 1, 256, std::vector<std::complex<double>> {
      {1, 2}, {3, 4}, {8, 1} });
  const auto complex_difference = mpc_script_diff (complex_source, 1, 1);
  require (complex_equals (complex_difference.data ()[0], 2, 2),
           "complex diff first value mismatch");
  require (complex_equals (complex_difference.data ()[1], 5, -3),
           "complex diff second value mismatch");
}

} // namespace

int
main ()
{
  try
    {
      check_real_sort ();
      check_complex_sort ();
      check_diff ();
      std::cout << "PASS: native MPFR/MPC sort and diff sequence tests\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
