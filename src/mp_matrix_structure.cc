// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_structure.h"

#include <stdexcept>

#include "mp_complex_precision.h"

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

MpfrMatrixStorage
mpfr_complex_matrix_real (const MpfrComplexMatrixStorage& source)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrMatrixStorage result (source.rows (), source.columns (),
                            source.precision_bits ());
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      mpfr_set (result.at (row, column).mpfr_data (),
                mpc_realref (source.at (row, column).mpc_data ()),
                MPFR_RNDN);
  return result;
}

MpfrMatrixStorage
mpfr_complex_matrix_imag (const MpfrComplexMatrixStorage& source)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrMatrixStorage result (source.rows (), source.columns (),
                            source.precision_bits ());
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      mpfr_set (result.at (row, column).mpfr_data (),
                mpc_imagref (source.at (row, column).mpc_data ()),
                MPFR_RNDN);
  return result;
}

MpfrComplexMatrixStorage
mpfr_complex_matrix_conj (const MpfrComplexMatrixStorage& source)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (source.rows (), source.columns (),
                                   source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    mpc_conj (result.data ()[index].mpc_data (),
              source.data ()[index].mpc_data (),
              MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

MpfrComplexMatrixStorage
mpfr_complex_matrix_transpose (const MpfrComplexMatrixStorage& source)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (source.columns (), source.rows (),
                                   source.precision_bits ());
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      mpc_set (result.at (column, row).mpc_data (),
               source.at (row, column).mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

MpfrComplexMatrixStorage
mpfr_complex_matrix_ctranspose (const MpfrComplexMatrixStorage& source)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (source.columns (), source.rows (),
                                   source.precision_bits ());
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      mpc_conj (result.at (column, row).mpc_data (),
                source.at (row, column).mpc_data (),
                MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

} // namespace octave_mplapack
