// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_MATRIX_CONCAT_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_MATRIX_CONCAT_H

#include <cstddef>
#include <functional>
#include <vector>

#include "mp_complex_matrix_storage.h"

namespace octave_mplapack
{

// A complex concatenation operand copies existing real or complex values into
// a uniformly precisioned MPC destination.  The callback is structural and
// never consults the ambient precision.
struct MpcConcatOperand
{
  using CopyElement = std::function<void (
    MpfrComplexMatrixStorage::NativeScalar&, std::size_t, std::size_t)>;

  std::size_t rows = 0;
  std::size_t columns = 0;
  mpfr_prec_t precision_bits = 0;
  bool has_mp_precision = false;
  CopyElement copy_element;
};

MpfrComplexMatrixStorage mpc_matrix_concatenate (
  const std::vector<MpcConcatOperand>& operands,
  int dimension,
  std::size_t result_rows,
  std::size_t result_columns,
  mpfr_prec_t result_precision);

} // namespace octave_mplapack

#endif
