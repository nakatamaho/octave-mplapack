// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_concat.h"

#include <cassert>
#include <iostream>
#include <string>
#include <vector>

using octave_mplapack::MpfrConcatOperand;
using octave_mplapack::MpfrMatrixStorage;

namespace
{

MpfrConcatOperand
from_matrix (const MpfrMatrixStorage& source)
{
  MpfrConcatOperand operand;
  operand.rows = source.rows ();
  operand.columns = source.columns ();
  operand.precision_bits = source.precision_bits ();
  operand.has_mp_precision = true;
  operand.copy_element
    = [&source] (MpfrMatrixStorage::NativeScalar& destination,
                 std::size_t row, std::size_t column)
    {
      mpfr_set (destination.mpfr_data (),
                source.at (row, column).mpfr_data (), MPFR_RNDN);
    };
  return operand;
}

MpfrConcatOperand
from_double_matrix (const std::vector<double>& values,
                    std::size_t rows, std::size_t columns)
{
  MpfrConcatOperand operand;
  operand.rows = rows;
  operand.columns = columns;
  operand.copy_element
    = [&values, rows] (MpfrMatrixStorage::NativeScalar& destination,
                       std::size_t row, std::size_t column)
    {
      mpfr_set_d (destination.mpfr_data (), values[row + column * rows],
                  MPFR_RNDN);
    };
  return operand;
}

void
assert_text (const MpfrMatrixStorage& matrix, std::size_t row,
             std::size_t column, const char *text)
{
  assert (matrix.element_exactly_equal_text (row, column, text));
}

} // namespace

int
main ()
{
  const MpfrMatrixStorage left (
    2, 2, 256, std::vector<std::string> {"11", "21", "12", "22"});
  const MpfrMatrixStorage right (
    2, 3, 1024,
    std::vector<std::string> {"31", "41", "32", "42", "33", "43"});

  const MpfrMatrixStorage horizontal
    = octave_mplapack::mpfr_matrix_concatenate (
      std::vector<MpfrConcatOperand> {from_matrix (left), from_matrix (right)},
      1, 2, 5, 1024);
  assert (horizontal.rows () == 2 && horizontal.columns () == 5);
  assert (horizontal.precision_bits () == 1024);
  assert_text (horizontal, 0, 0, "11");
  assert_text (horizontal, 1, 1, "22");
  assert_text (horizontal, 0, 2, "31");
  assert_text (horizontal, 1, 4, "43");

  const MpfrMatrixStorage vertical
    = octave_mplapack::mpfr_matrix_concatenate (
      std::vector<MpfrConcatOperand> {from_matrix (left), from_matrix (left)},
      0, 4, 2, 256);
  assert (vertical.rows () == 4 && vertical.columns () == 2);
  assert_text (vertical, 2, 0, "11");
  assert_text (vertical, 3, 1, "22");

  const std::vector<double> doubles {0.125, -0.0, 2.0, 3.0};
  const MpfrMatrixStorage mixed
    = octave_mplapack::mpfr_matrix_concatenate (
      std::vector<MpfrConcatOperand> {
        from_double_matrix (doubles, 2, 2), from_matrix (left)
      }, 1, 2, 4, 256);
  assert (mixed.element_exactly_equal_double (0, 0, 0.125));
  assert (mixed.element_exactly_equal_double (1, 0, -0.0));
  assert_text (mixed, 0, 2, "11");

  const MpfrMatrixStorage empty (0, 2, 2048);
  const MpfrMatrixStorage empty_result
    = octave_mplapack::mpfr_matrix_concatenate (
      std::vector<MpfrConcatOperand> {from_matrix (empty)}, 1, 0, 2, 2048);
  assert (empty_result.rows () == 0 && empty_result.columns () == 2);
  assert (empty_result.precision_bits () == 2048);

  std::cout << "PASS: native mp matrix concatenation tests\n";
  return 0;
}
