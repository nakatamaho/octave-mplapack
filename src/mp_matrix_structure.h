// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_MATRIX_STRUCTURE_H
#define OCTAVE_MPLAPACK_MP_MATRIX_STRUCTURE_H

#include "mp_matrix_storage.h"
#include "mp_complex_matrix_storage.h"

namespace octave_mplapack
{

MpfrMatrixStorage mpfr_matrix_transpose (
  const MpfrMatrixStorage& source);

MpfrMatrixStorage mpfr_matrix_reshape (
  const MpfrMatrixStorage& source,
  std::size_t rows,
  std::size_t columns);

MpfrMatrixStorage mpfr_complex_matrix_real (
  const MpfrComplexMatrixStorage& source);

MpfrMatrixStorage mpfr_complex_matrix_imag (
  const MpfrComplexMatrixStorage& source);

MpfrComplexMatrixStorage mpfr_complex_matrix_conj (
  const MpfrComplexMatrixStorage& source);

MpfrComplexMatrixStorage mpfr_complex_matrix_transpose (
  const MpfrComplexMatrixStorage& source);

MpfrComplexMatrixStorage mpfr_complex_matrix_ctranspose (
  const MpfrComplexMatrixStorage& source);

} // namespace octave_mplapack

#endif
