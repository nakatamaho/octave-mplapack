// SPDX-License-Identifier: BSD-2-Clause

#include "mp_script_structure.h"

#include <algorithm>
#include <cstdint>
#include <limits>
#include <stdexcept>

#include "mp_complex_precision.h"

namespace
{

std::size_t
diagonal_length (std::size_t rows, std::size_t columns,
                 std::int64_t diagonal)
{
  const std::int64_t row_start = diagonal < 0 ? -diagonal : 0;
  const std::int64_t column_start = diagonal > 0 ? diagonal : 0;
  if (row_start >= static_cast<std::int64_t> (rows)
      || column_start >= static_cast<std::int64_t> (columns))
    return 0;
  return std::min (rows - static_cast<std::size_t> (row_start),
                   columns - static_cast<std::size_t> (column_start));
}

std::size_t
square_diagonal_dimension (std::size_t length, std::int64_t diagonal)
{
  const std::uint64_t magnitude
    = diagonal < 0
      ? static_cast<std::uint64_t> (-(diagonal + 1)) + 1
      : static_cast<std::uint64_t> (diagonal);
  if (magnitude > std::numeric_limits<std::size_t>::max () - length)
    throw std::overflow_error ("diagonal matrix dimension overflow");
  return length + static_cast<std::size_t> (magnitude);
}

int
normalize_rot90 (int turns)
{
  const int normalized = turns % 4;
  return normalized < 0 ? normalized + 4 : normalized;
}

} // namespace

namespace octave_mplapack
{

MpfrMatrixStorage
mpfr_script_diag (const MpfrMatrixStorage& source, bool vector_input,
                  std::int64_t diagonal)
{
  if (vector_input)
    {
      const std::size_t length = source.numel ();
      const std::size_t dimension
        = square_diagonal_dimension (length, diagonal);
      MpfrMatrixStorage result (dimension, dimension,
                                source.precision_bits ());
      const std::size_t row_start
        = diagonal < 0 ? static_cast<std::size_t> (-diagonal) : 0;
      const std::size_t column_start
        = diagonal > 0 ? static_cast<std::size_t> (diagonal) : 0;
      for (std::size_t index = 0; index < length; ++index)
        mpfr_set (result.at (row_start + index, column_start + index).mpfr_data (),
                  source.data ()[index].mpfr_data (), MPFR_RNDN);
      return result;
    }

  const std::size_t length
    = diagonal_length (source.rows (), source.columns (), diagonal);
  MpfrMatrixStorage result (length, 1, source.precision_bits ());
  const std::size_t row_start
    = diagonal < 0 ? static_cast<std::size_t> (-diagonal) : 0;
  const std::size_t column_start
    = diagonal > 0 ? static_cast<std::size_t> (diagonal) : 0;
  for (std::size_t index = 0; index < length; ++index)
    mpfr_set (result.at (index, 0).mpfr_data (),
              source.at (row_start + index, column_start + index).mpfr_data (),
              MPFR_RNDN);
  return result;
}

MpfrComplexMatrixStorage
mpc_script_diag (const MpfrComplexMatrixStorage& source, bool vector_input,
                 std::int64_t diagonal)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  if (vector_input)
    {
      const std::size_t length = source.numel ();
      const std::size_t dimension
        = square_diagonal_dimension (length, diagonal);
      MpfrComplexMatrixStorage result (dimension, dimension,
                                       source.precision_bits ());
      const std::size_t row_start
        = diagonal < 0 ? static_cast<std::size_t> (-diagonal) : 0;
      const std::size_t column_start
        = diagonal > 0 ? static_cast<std::size_t> (diagonal) : 0;
      for (std::size_t index = 0; index < length; ++index)
        mpc_set (result.at (row_start + index, column_start + index).mpc_data (),
                 source.data ()[index].mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
      return result;
    }

  const std::size_t length
    = diagonal_length (source.rows (), source.columns (), diagonal);
  MpfrComplexMatrixStorage result (length, 1, source.precision_bits ());
  const std::size_t row_start
    = diagonal < 0 ? static_cast<std::size_t> (-diagonal) : 0;
  const std::size_t column_start
    = diagonal > 0 ? static_cast<std::size_t> (diagonal) : 0;
  for (std::size_t index = 0; index < length; ++index)
    mpc_set (result.at (index, 0).mpc_data (),
             source.at (row_start + index, column_start + index).mpc_data (),
             MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

MpfrMatrixStorage
mpfr_script_triangular (const MpfrMatrixStorage& source,
                        std::int64_t diagonal, bool upper)
{
  MpfrMatrixStorage result (source.rows (), source.columns (),
                            source.precision_bits ());
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      {
        const std::int64_t difference
          = static_cast<std::int64_t> (column)
            - static_cast<std::int64_t> (row);
        const bool keep = upper ? difference >= diagonal
                                : difference <= diagonal;
        if (keep)
          mpfr_set (result.at (row, column).mpfr_data (),
                    source.at (row, column).mpfr_data (), MPFR_RNDN);
        else
          mpfr_set_zero (result.at (row, column).mpfr_data (), 0);
      }
  return result;
}

MpfrComplexMatrixStorage
mpc_script_triangular (const MpfrComplexMatrixStorage& source,
                       std::int64_t diagonal, bool upper)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (source.rows (), source.columns (),
                                   source.precision_bits ());
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      {
        const std::int64_t difference
          = static_cast<std::int64_t> (column)
            - static_cast<std::int64_t> (row);
        const bool keep = upper ? difference >= diagonal
                                : difference <= diagonal;
        if (keep)
          mpc_set (result.at (row, column).mpc_data (),
                   source.at (row, column).mpc_data (),
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
        else
          mpc_set_ui (result.at (row, column).mpc_data (), 0,
                      MPC_RND (MPFR_RNDN, MPFR_RNDN));
      }
  return result;
}

MpfrMatrixStorage
mpfr_script_repmat (const MpfrMatrixStorage& source,
                    std::size_t row_repetitions,
                    std::size_t column_repetitions)
{
  if (source.rows () != 0 && row_repetitions
      > std::numeric_limits<std::size_t>::max () / source.rows ())
    throw std::overflow_error ("repmat row dimension overflow");
  if (source.columns () != 0 && column_repetitions
      > std::numeric_limits<std::size_t>::max () / source.columns ())
    throw std::overflow_error ("repmat column dimension overflow");
  const std::size_t rows = source.rows () * row_repetitions;
  const std::size_t columns = source.columns () * column_repetitions;
  MpfrMatrixStorage result (rows, columns, source.precision_bits ());
  if (source.rows () == 0 || source.columns () == 0)
    return result;
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      mpfr_set (result.at (row, column).mpfr_data (),
                source.at (row % source.rows (), column % source.columns ())
                  .mpfr_data (), MPFR_RNDN);
  return result;
}

MpfrComplexMatrixStorage
mpc_script_repmat (const MpfrComplexMatrixStorage& source,
                   std::size_t row_repetitions,
                   std::size_t column_repetitions)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  if (source.rows () != 0 && row_repetitions
      > std::numeric_limits<std::size_t>::max () / source.rows ())
    throw std::overflow_error ("repmat row dimension overflow");
  if (source.columns () != 0 && column_repetitions
      > std::numeric_limits<std::size_t>::max () / source.columns ())
    throw std::overflow_error ("repmat column dimension overflow");
  const std::size_t rows = source.rows () * row_repetitions;
  const std::size_t columns = source.columns () * column_repetitions;
  MpfrComplexMatrixStorage result (rows, columns, source.precision_bits ());
  if (source.rows () == 0 || source.columns () == 0)
    return result;
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      mpc_set (result.at (row, column).mpc_data (),
               source.at (row % source.rows (), column % source.columns ())
                 .mpc_data (), MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

MpfrMatrixStorage
mpfr_script_flip (const MpfrMatrixStorage& source, int dimension)
{
  if (dimension != 1 && dimension != 2)
    throw std::invalid_argument ("flip dimension must be 1 or 2");
  MpfrMatrixStorage result (source.rows (), source.columns (),
                            source.precision_bits ());
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      {
        const std::size_t source_row
          = dimension == 1 ? source.rows () - 1 - row : row;
        const std::size_t source_column
          = dimension == 2 ? source.columns () - 1 - column : column;
        mpfr_set (result.at (row, column).mpfr_data (),
                  source.at (source_row, source_column).mpfr_data (), MPFR_RNDN);
      }
  return result;
}

MpfrComplexMatrixStorage
mpc_script_flip (const MpfrComplexMatrixStorage& source, int dimension)
{
  if (dimension != 1 && dimension != 2)
    throw std::invalid_argument ("flip dimension must be 1 or 2");
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (source.rows (), source.columns (),
                                  source.precision_bits ());
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      {
        const std::size_t source_row
          = dimension == 1 ? source.rows () - 1 - row : row;
        const std::size_t source_column
          = dimension == 2 ? source.columns () - 1 - column : column;
        mpc_set (result.at (row, column).mpc_data (),
                 source.at (source_row, source_column).mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
      }
  return result;
}

MpfrMatrixStorage
mpfr_script_rot90 (const MpfrMatrixStorage& source, int turns)
{
  const int normalized = normalize_rot90 (turns);
  const std::size_t result_rows = normalized % 2 == 0
    ? source.rows () : source.columns ();
  const std::size_t result_columns = normalized % 2 == 0
    ? source.columns () : source.rows ();
  MpfrMatrixStorage result (result_rows, result_columns,
                            source.precision_bits ());
  for (std::size_t column = 0; column < result_columns; ++column)
    for (std::size_t row = 0; row < result_rows; ++row)
      {
        std::size_t source_row = row;
        std::size_t source_column = column;
        if (normalized == 1)
          { source_row = column; source_column = source.columns () - 1 - row; }
        else if (normalized == 2)
          { source_row = source.rows () - 1 - row;
            source_column = source.columns () - 1 - column; }
        else if (normalized == 3)
          { source_row = source.rows () - 1 - column; source_column = row; }
        mpfr_set (result.at (row, column).mpfr_data (),
                  source.at (source_row, source_column).mpfr_data (), MPFR_RNDN);
      }
  return result;
}

MpfrComplexMatrixStorage
mpc_script_rot90 (const MpfrComplexMatrixStorage& source, int turns)
{
  const int normalized = normalize_rot90 (turns);
  const std::size_t result_rows = normalized % 2 == 0
    ? source.rows () : source.columns ();
  const std::size_t result_columns = normalized % 2 == 0
    ? source.columns () : source.rows ();
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (result_rows, result_columns,
                                   source.precision_bits ());
  for (std::size_t column = 0; column < result_columns; ++column)
    for (std::size_t row = 0; row < result_rows; ++row)
      {
        std::size_t source_row = row;
        std::size_t source_column = column;
        if (normalized == 1)
          { source_row = column; source_column = source.columns () - 1 - row; }
        else if (normalized == 2)
          { source_row = source.rows () - 1 - row;
            source_column = source.columns () - 1 - column; }
        else if (normalized == 3)
          { source_row = source.rows () - 1 - column; source_column = row; }
        mpc_set (result.at (row, column).mpc_data (),
                 source.at (source_row, source_column).mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
      }
  return result;
}

} // namespace octave_mplapack
