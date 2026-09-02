// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_MATRIX_ASSIGNMENT_H
#define OCTAVE_MPLAPACK_MP_MATRIX_ASSIGNMENT_H

#include <cstddef>
#include <functional>
#include <vector>

#include "mp_matrix_storage.h"

namespace octave_mplapack
{

// An assignment RHS supplies structural copies of its existing values.  The
// callback never performs arithmetic or consults the ambient MPFR default.
struct MpfrAssignmentOperand
{
  using CopyElement = std::function<void (
    MpfrMatrixStorage::NativeScalar&, std::size_t, std::size_t)>;

  std::size_t rows = 0;
  std::size_t columns = 0;
  mpfr_prec_t precision_bits = 0;
  bool has_mp_precision = false;
  CopyElement copy_element;
};

MpfrMatrixStorage mpfr_matrix_assign_two_subscript (
  const MpfrMatrixStorage& source,
  const std::vector<std::size_t>& row_indices,
  const std::vector<std::size_t>& column_indices,
  const MpfrAssignmentOperand& rhs,
  mpfr_prec_t result_precision);

MpfrMatrixStorage mpfr_matrix_assign_linear (
  const MpfrMatrixStorage& source,
  const std::vector<std::size_t>& indices,
  const MpfrAssignmentOperand& rhs,
  mpfr_prec_t result_precision);

} // namespace octave_mplapack

#endif
