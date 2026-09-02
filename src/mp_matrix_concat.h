// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_MATRIX_CONCAT_H
#define OCTAVE_MPLAPACK_MP_MATRIX_CONCAT_H

#include <cstddef>
#include <functional>
#include <vector>

#include "mp_matrix_storage.h"

namespace octave_mplapack
{

// A concatenation operand is a two-dimensional source whose elements can be
// copied directly into a uniformly precisioned destination.  The callback is
// intentionally structural: it must copy one existing value, not perform
// arithmetic or consult the MPFR default precision.
struct MpfrConcatOperand
{
  using CopyElement = std::function<void (
    MpfrMatrixStorage::NativeScalar&, std::size_t, std::size_t)>;

  std::size_t rows = 0;
  std::size_t columns = 0;
  mpfr_prec_t precision_bits = 0;
  bool has_mp_precision = false;
  CopyElement copy_element;
};

MpfrMatrixStorage mpfr_matrix_concatenate (
  const std::vector<MpfrConcatOperand>& operands,
  // Octave's dim_vector uses dimension 1 for horizontal and 0 for vertical
  // concatenation (the first dimension is the row dimension).
  int dimension,
  std::size_t result_rows,
  std::size_t result_columns,
  mpfr_prec_t result_precision);

} // namespace octave_mplapack

#endif
