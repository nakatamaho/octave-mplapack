// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_concat.h"

#include <stdexcept>

namespace octave_mplapack
{

MpfrMatrixStorage
mpfr_matrix_concatenate (
  const std::vector<MpfrConcatOperand>& operands,
  int dimension,
  std::size_t result_rows,
  std::size_t result_columns,
  mpfr_prec_t result_precision)
{
  if (operands.empty ())
    throw std::invalid_argument ("concatenation requires at least one operand");
  if (dimension != 0 && dimension != 1)
    throw std::invalid_argument ("concatenation dimension must be 0 or 1");

  MpfrMatrixStorage result (result_rows, result_columns, result_precision);
  std::size_t offset = 0;

  for (const MpfrConcatOperand& operand : operands)
    {
      if (! operand.copy_element)
        throw std::invalid_argument ("concatenation operand has no copier");

      // Octave's concatenation skips empty inputs once the result has a
      // non-empty payload.  The validated result shape already accounts for
      // their structural dimensions, so there is no element data to copy.
      if (operand.rows == 0 || operand.columns == 0)
        continue;

      if (dimension == 1)
        {
          if (operand.rows != result_rows)
            throw std::invalid_argument ("horizontal concatenation row mismatch");
          if (offset > result_columns
              || operand.columns > result_columns - offset)
            throw std::invalid_argument (
              "horizontal concatenation result dimensions mismatch");
          for (std::size_t column = 0; column < operand.columns; ++column)
            for (std::size_t row = 0; row < operand.rows; ++row)
              operand.copy_element (result.at (row, offset + column), row,
                                    column);
          offset += operand.columns;
        }
      else
        {
          if (operand.columns != result_columns)
            throw std::invalid_argument ("vertical concatenation column mismatch");
          if (offset > result_rows
              || operand.rows > result_rows - offset)
            throw std::invalid_argument (
              "vertical concatenation result dimensions mismatch");
          for (std::size_t column = 0; column < operand.columns; ++column)
            for (std::size_t row = 0; row < operand.rows; ++row)
              operand.copy_element (result.at (offset + row, column), row,
                                    column);
          offset += operand.rows;
        }
    }

  const std::size_t expected_offset
    = dimension == 1 ? result_columns : result_rows;
  if (result.numel () != 0 && offset != expected_offset)
    throw std::invalid_argument ("concatenation result dimensions mismatch");

  return result;
}

} // namespace octave_mplapack
