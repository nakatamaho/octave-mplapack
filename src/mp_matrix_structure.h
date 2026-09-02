// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_MATRIX_STRUCTURE_H
#define OCTAVE_MPLAPACK_MP_MATRIX_STRUCTURE_H

#include "mp_matrix_storage.h"

namespace octave_mplapack
{

MpfrMatrixStorage mpfr_matrix_transpose (
  const MpfrMatrixStorage& source);

MpfrMatrixStorage mpfr_matrix_reshape (
  const MpfrMatrixStorage& source,
  std::size_t rows,
  std::size_t columns);

} // namespace octave_mplapack

#endif
