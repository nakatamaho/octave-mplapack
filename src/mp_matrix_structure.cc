// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_structure.h"

#include <stdexcept>

namespace octave_mplapack
{

MpfrMatrixStorage
mpfr_matrix_transpose (const MpfrMatrixStorage& source)
{
  MpfrMatrixStorage result (source.columns (), source.rows (),
                            source.precision_bits ());
  // Structural copies preserve the source precision; ambient defaults are
  // intentionally irrelevant.
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      mpfr_set (result.at (column, row).mpfr_data (),
                source.at (row, column).mpfr_data (), MPFR_RNDN);
  return result;
}

MpfrMatrixStorage
mpfr_matrix_reshape (const MpfrMatrixStorage& source,
                     std::size_t rows,
                     std::size_t columns)
{
  if (MpfrMatrixStorage::checked_element_count (rows, columns)
      != source.numel ())
    throw std::invalid_argument ("reshape element count does not match");

  MpfrMatrixStorage result (rows, columns, source.precision_bits ());
  // Reshape keeps the existing contiguous column-major linear order.
  for (std::size_t index = 0; index < source.numel (); ++index)
    mpfr_set (result.data ()[index].mpfr_data (),
              source.data ()[index].mpfr_data (), MPFR_RNDN);
  return result;
}

} // namespace octave_mplapack
