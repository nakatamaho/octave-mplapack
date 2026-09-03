// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_ARITHMETIC_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_ARITHMETIC_H

#include <cstddef>

#include "mp_complex_matrix_storage.h"
#include "mp_complex_scalar_storage.h"
#include "mp_matrix_storage.h"
#include "mp_scalar_storage.h"

namespace octave_mplapack
{

enum class MpcElementwiseBinaryOperation
{
  add,
  subtract,
  multiply,
  divide
};

struct MpcElementwiseOperand
{
  const MpfrScalarStorage *real_scalar = nullptr;
  const MpfrMatrixStorage *real_matrix = nullptr;
  const MpfrComplexScalarStorage *complex_scalar = nullptr;
  const MpfrComplexMatrixStorage *complex_matrix = nullptr;

  static MpcElementwiseOperand from_real_scalar (
    const MpfrScalarStorage& value) noexcept;
  static MpcElementwiseOperand from_real_matrix (
    const MpfrMatrixStorage& value) noexcept;
  static MpcElementwiseOperand from_complex_scalar (
    const MpfrComplexScalarStorage& value) noexcept;
  static MpcElementwiseOperand from_complex_matrix (
    const MpfrComplexMatrixStorage& value) noexcept;

  bool is_scalar () const noexcept;
  bool is_complex () const noexcept;
  mpfr_prec_t precision_bits () const;
  std::size_t rows () const;
  std::size_t columns () const;
  void copy_to (MpfrComplexMatrixStorage::NativeScalar& destination,
                std::size_t row, std::size_t column) const;
};

MpfrComplexMatrixStorage mpc_matrix_elementwise_binary (
  const MpcElementwiseOperand& lhs,
  const MpcElementwiseOperand& rhs,
  MpcElementwiseBinaryOperation operation);

MpfrComplexMatrixStorage mpc_matrix_negate (
  const MpfrComplexMatrixStorage& source);

MpfrComplexScalarStorage mpc_scalar_negate (
  const MpfrComplexScalarStorage& source);

} // namespace octave_mplapack

#endif
