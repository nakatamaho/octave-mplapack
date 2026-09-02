// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_structure.h"

#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

namespace
{

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
               "unexpected structural value");
      }
}

} // namespace

int
main ()
{
  try
    {
      const MpfrMatrixStorage source (
        2, 3, 256,
        std::vector<std::string> {"11", "21", "12", "22", "13", "23"});

      const auto transposed = octave_mplapack::mpfr_matrix_transpose (source);
      check (transposed.rows () == 3 && transposed.columns () == 2,
             "transpose shape mismatch");
      check (transposed.precision_bits () == 256,
             "transpose precision mismatch");
      check_text (transposed, {"11", "12", "13", "21", "22", "23"});

      const auto reshaped = octave_mplapack::mpfr_matrix_reshape (source, 3, 2);
      check (reshaped.rows () == 3 && reshaped.columns () == 2,
             "reshape shape mismatch");
      check_text (reshaped, {"11", "21", "12", "22", "13", "23"});

      const auto row = octave_mplapack::mpfr_matrix_reshape (source, 1, 6);
      check_text (row, {"11", "21", "12", "22", "13", "23"});
      const auto column = octave_mplapack::mpfr_matrix_reshape (source, 6, 1);
      check_text (column, {"11", "21", "12", "22", "13", "23"});
      const auto round_trip
        = octave_mplapack::mpfr_matrix_reshape (row, 2, 3);
      check (round_trip.element_exactly_equal (1, 2, source, 1, 2),
             "reshape round-trip mismatch");

      const MpfrMatrixStorage precise (
        1, 2, 1024, std::vector<std::string> {
          "1.00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001",
          "1"});
      const auto precise_transpose
        = octave_mplapack::mpfr_matrix_transpose (precise);
      check (precise_transpose.precision_bits () == 1024,
             "high precision transpose lost precision");
      check (precise_transpose.element_exactly_equal (0, 0, precise, 0, 0),
             "high precision transpose changed value");

      const MpfrMatrixStorage empty_row (0, 3, 333);
      const auto empty_column
        = octave_mplapack::mpfr_matrix_transpose (empty_row);
      check (empty_column.rows () == 3 && empty_column.columns () == 0,
             "empty transpose shape mismatch");
      check (empty_column.precision_bits () == 333,
             "empty transpose precision mismatch");

      const MpfrMatrixStorage empty (0, 0, 512);
      const auto empty_again = octave_mplapack::mpfr_matrix_reshape (empty, 0, 0);
      check (empty_again.rows () == 0 && empty_again.columns () == 0,
             "empty reshape shape mismatch");

      bool mismatch = false;
      try
        {
          (void) octave_mplapack::mpfr_matrix_reshape (source, 4, 2);
        }
      catch (const std::invalid_argument&)
        {
          mismatch = true;
        }
      check (mismatch, "invalid reshape element count unexpectedly succeeded");

      std::cout << "PASS: native transpose, reshape, exact copies, empty shapes, and errors\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
