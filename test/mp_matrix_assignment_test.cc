// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_assignment.h"

#include <cassert>
#include <cstddef>
#include <stdexcept>
#include <string>
#include <vector>

namespace
{

using Storage = octave_mplapack::MpfrMatrixStorage;
using Operand = octave_mplapack::MpfrAssignmentOperand;

Operand
scalar_rhs (const std::string& text, mpfr_prec_t precision)
{
  auto value = Storage::NativeScalar::with_precision (precision);
  assert (mpfr_set_str (value.mpfr_data (), text.c_str (), 10, MPFR_RNDN) == 0);
  Operand operand;
  operand.rows = 1;
  operand.columns = 1;
  operand.precision_bits = precision;
  operand.has_mp_precision = true;
  operand.copy_element
    = [value] (Storage::NativeScalar& destination, std::size_t, std::size_t)
    {
      mpfr_set (destination.mpfr_data (), value.mpfr_data (), MPFR_RNDN);
    };
  return operand;
}

Operand
matrix_rhs (const Storage& source)
{
  Operand operand;
  operand.rows = source.rows ();
  operand.columns = source.columns ();
  operand.precision_bits = source.precision_bits ();
  operand.has_mp_precision = true;
  operand.copy_element
    = [&source] (Storage::NativeScalar& destination, std::size_t row,
                 std::size_t column)
    {
      mpfr_set (destination.mpfr_data (), source.at (row, column).mpfr_data (),
                MPFR_RNDN);
    };
  return operand;
}

Storage
make_source ()
{
  Storage source (2, 2, 128);
  assert (mpfr_set_ui (source.at (0, 0).mpfr_data (), 1, MPFR_RNDN) == 0);
  assert (mpfr_set_ui (source.at (1, 0).mpfr_data (), 2, MPFR_RNDN) == 0);
  assert (mpfr_set_ui (source.at (0, 1).mpfr_data (), 3, MPFR_RNDN) == 0);
  assert (mpfr_set_ui (source.at (1, 1).mpfr_data (), 4, MPFR_RNDN) == 0);
  return source;
}

} // namespace

int
main ()
{
  Storage source = make_source ();
  const std::vector<std::size_t> all_rows {0, 1};
  const std::vector<std::size_t> first_column {0};
  Storage changed = octave_mplapack::mpfr_matrix_assign_two_subscript (
    source, all_rows, first_column, scalar_rhs ("9", 128), 128);
  assert (changed.element_exactly_equal_text (0, 0, "9"));
  assert (changed.element_exactly_equal_text (1, 0, "9"));
  assert (source.element_exactly_equal_text (0, 0, "1"));
  assert (source.element_exactly_equal_text (1, 0, "2"));

  Storage rhs (2, 1, 256);
  assert (mpfr_set_ui (rhs.at (0, 0).mpfr_data (), 7, MPFR_RNDN) == 0);
  assert (mpfr_set_ui (rhs.at (1, 0).mpfr_data (), 8, MPFR_RNDN) == 0);
  Storage widened = octave_mplapack::mpfr_matrix_assign_two_subscript (
    source, all_rows, first_column, matrix_rhs (rhs), 256);
  assert (widened.precision_bits () == 256);
  assert (widened.at (0, 0).precision () == 256);
  assert (widened.element_exactly_equal_text (0, 0, "7"));
  assert (widened.element_exactly_equal_text (1, 0, "8"));
  assert (widened.element_exactly_equal_text (0, 1, "3"));

  Storage linear = octave_mplapack::mpfr_matrix_assign_linear (
    source, std::vector<std::size_t> {1, 3},
    scalar_rhs ("5", 128), 128);
  assert (linear.element_exactly_equal_text (1, 0, "5"));
  assert (linear.element_exactly_equal_text (1, 1, "5"));
  assert (linear.element_exactly_equal_text (0, 0, "1"));

  Storage linear_rhs_storage (2, 2, 256);
  assert (mpfr_set_ui (linear_rhs_storage.at (0, 0).mpfr_data (), 11,
                       MPFR_RNDN) == 0);
  assert (mpfr_set_ui (linear_rhs_storage.at (1, 0).mpfr_data (), 12,
                       MPFR_RNDN) == 0);
  assert (mpfr_set_ui (linear_rhs_storage.at (0, 1).mpfr_data (), 13,
                       MPFR_RNDN) == 0);
  assert (mpfr_set_ui (linear_rhs_storage.at (1, 1).mpfr_data (), 14,
                       MPFR_RNDN) == 0);
  Storage colon = octave_mplapack::mpfr_matrix_assign_linear (
    source, std::vector<std::size_t> {0, 1, 2, 3},
    matrix_rhs (linear_rhs_storage), 256);
  assert (colon.precision_bits () == 256);
  assert (colon.element_exactly_equal_text (0, 0, "11"));
  assert (colon.element_exactly_equal_text (1, 0, "12"));

  bool rejected = false;
  try
    {
      (void) octave_mplapack::mpfr_matrix_assign_two_subscript (
        source, all_rows, first_column, matrix_rhs (linear_rhs_storage), 128);
    }
  catch (const std::invalid_argument&)
    {
      rejected = true;
    }
  assert (rejected);
  return 0;
}
