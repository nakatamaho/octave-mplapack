// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_inspection.h"

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
  for (std::size_t index = 0; index < expected.size (); ++index)
    check (value.element_exactly_equal_text (index % value.rows (),
                                             index / value.rows (),
                                             expected[index]),
           "unexpected selected value");
}

} // namespace

int
main ()
{
  try
    {
      const MpfrMatrixStorage source (
        4, 3, 512,
        std::vector<std::string> {"11", "21", "31", "41", "12", "22",
                                  "32", "42", "13", "23", "33", "43"});
      const auto selected = octave_mplapack::select_matrix (
        source, {3, 0}, {2, 0});
      check_text (selected, {"43", "13", "41", "11"});

      const auto linear = octave_mplapack::select_linear (source, {0, 5, 11});
      check_text (linear, {"11", "22", "43"});

      const auto empty = octave_mplapack::select_matrix (source, {}, {0, 1});
      check (empty.rows () == 0 && empty.columns () == 2,
             "empty row selection shape mismatch");
      check (empty.precision_bits () == 512,
             "empty row selection precision mismatch");

      const std::string display = octave_mplapack::format_matrix (selected);
      check (display == "[4.3e+1 4.1e+1\n 1.3e+1 1.1e+1]",
             "matrix display formatting mismatch");
      std::cout << "PASS: native matrix selection, linear order, precision, "
                   "empty shapes, and canonical display\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
