// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_arithmetic.h"

#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace
{

using octave_mplapack::MpfrElementwiseBinaryOperation;
using octave_mplapack::MpfrElementwiseOperand;
using octave_mplapack::MpfrMatrixStorage;

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

void
check_text (const MpfrMatrixStorage& value,
            const std::vector<std::string>& expected)
{
  check (value.numel () == expected.size (), "unexpected element count");
  for (std::size_t column = 0; column < value.columns (); ++column)
    for (std::size_t row = 0; row < value.rows (); ++row)
      {
        const std::size_t index = row + column * value.rows ();
        check (value.element_exactly_equal_text (row, column, expected[index]),
               "unexpected element value");
      }
}

MpfrMatrixStorage
binary (const MpfrMatrixStorage& lhs, const MpfrMatrixStorage& rhs,
        MpfrElementwiseBinaryOperation operation)
{
  return octave_mplapack::mpfr_matrix_elementwise_binary (
    MpfrElementwiseOperand::from_matrix (lhs),
    MpfrElementwiseOperand::from_matrix (rhs), operation);
}

} // namespace

int
main ()
{
  try
    {
      const MpfrMatrixStorage values (
        2, 3, 256,
        std::vector<std::string> {"1", "4", "2", "5", "3", "6"});
      const MpfrMatrixStorage other (
        2, 3, 512,
        std::vector<std::string> {"10", "40", "20", "50", "30", "60"});

      const auto sum = binary (values, other,
                               MpfrElementwiseBinaryOperation::add);
      check (sum.precision_bits () == 512, "addition precision mismatch");
      check_text (sum, {"11", "44", "22", "55", "33", "66"});

      const auto difference = binary (
        other, values, MpfrElementwiseBinaryOperation::subtract);
      check_text (difference, {"9", "36", "18", "45", "27", "54"});

      const auto product = binary (
        values, other, MpfrElementwiseBinaryOperation::multiply);
      check_text (product, {"10", "160", "40", "250", "90", "360"});

      const auto quotient = binary (
        other, values, MpfrElementwiseBinaryOperation::divide);
      check_text (quotient, {"10", "10", "10", "10", "10", "10"});

      const MpfrMatrixStorage row (
        1, 3, 256, std::vector<std::string> {"10", "20", "30"});
      const MpfrMatrixStorage column (
        2, 1, 256, std::vector<std::string> {"100", "200"});
      const auto broadcast = binary (
        column, row, MpfrElementwiseBinaryOperation::add);
      check (broadcast.rows () == 2 && broadcast.columns () == 3,
             "broadcast shape mismatch");
      check_text (broadcast, {"110", "210", "120", "220", "130", "230"});

      const octave_mplapack::MpfrScalarStorage scalar_value ("2", 256);
      const MpfrElementwiseOperand scalar
        = MpfrElementwiseOperand::from_scalar (scalar_value);
      const auto scaled = octave_mplapack::mpfr_matrix_elementwise_binary (
        MpfrElementwiseOperand::from_matrix (values), scalar,
        MpfrElementwiseBinaryOperation::multiply);
      check_text (scaled, {"2", "8", "4", "10", "6", "12"});

      const auto negated = octave_mplapack::mpfr_matrix_negate (values);
      check_text (negated, {"-1", "-4", "-2", "-5", "-3", "-6"});

      const MpfrMatrixStorage empty (2, 0, 333);
      const MpfrMatrixStorage empty_row (1, 0, 333);
      const auto empty_result = binary (
        empty, empty_row, MpfrElementwiseBinaryOperation::add);
      check (empty_result.rows () == 2 && empty_result.columns () == 0,
             "empty broadcast shape mismatch");
      check (empty_result.precision_bits () == 333,
             "empty broadcast precision mismatch");

      bool mismatch = false;
      try
        {
          const MpfrMatrixStorage bad (4, 3, 256);
          (void) binary (values, bad,
                         MpfrElementwiseBinaryOperation::add);
        }
      catch (const std::invalid_argument&)
        {
          mismatch = true;
        }
      check (mismatch, "incompatible shape unexpectedly succeeded");

      std::cout << "PASS: native element-wise arithmetic, broadcasting, "
                   "precision, empty shapes, and error handling\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
