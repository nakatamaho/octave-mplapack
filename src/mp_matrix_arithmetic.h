// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_MATRIX_ARITHMETIC_H
#define OCTAVE_MPLAPACK_MP_MATRIX_ARITHMETIC_H

#include <cstddef>

#include "mp_matrix_storage.h"
#include "mp_scalar_storage.h"

namespace octave_mplapack
{

enum class MpfrElementwiseBinaryOperation
{
  add,
  subtract,
  multiply,
  divide
};

struct MpfrElementwiseOperand
{
  const MpfrScalarStorage *scalar = nullptr;
  const MpfrMatrixStorage *matrix = nullptr;

  static MpfrElementwiseOperand from_scalar (
    const MpfrScalarStorage& value) noexcept;
  static MpfrElementwiseOperand from_matrix (
    const MpfrMatrixStorage& value) noexcept;

  bool is_scalar () const noexcept;
  mpfr_prec_t precision_bits () const;
  std::size_t rows () const;
  std::size_t columns () const;
  const MpfrMatrixStorage::NativeScalar& at (std::size_t row,
                                             std::size_t column) const;
};

MpfrMatrixStorage mpfr_matrix_elementwise_binary (
  const MpfrElementwiseOperand& lhs,
  const MpfrElementwiseOperand& rhs,
  MpfrElementwiseBinaryOperation operation);

MpfrMatrixStorage mpfr_matrix_negate (
  const MpfrMatrixStorage& source);

} // namespace octave_mplapack

#endif
