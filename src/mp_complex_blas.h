// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_COMPLEX_BLAS_H
#define OCTAVE_MPLAPACK_MP_COMPLEX_BLAS_H

#include "mp_complex_matrix_storage.h"
#include "mp_complex_scalar_storage.h"
#include "mp_matrix_storage.h"

namespace octave_mplapack
{

void require_mplapack_mpc_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexScalarStorage& alpha,
  const MpfrComplexMatrixStorage& a_work,
  const MpfrComplexMatrixStorage& b_work,
  const MpfrComplexScalarStorage& beta,
  const MpfrComplexMatrixStorage& c);

MpfrComplexMatrixStorage mplapack_mpc_matrix_copy_at_precision (
  const MpfrComplexMatrixStorage& source,
  mpfr_prec_t precision_bits);

MpfrComplexMatrixStorage mplapack_mpc_matrix_from_real (
  const MpfrMatrixStorage& source,
  mpfr_prec_t precision_bits);

MpfrComplexScalarStorage mplapack_mpc_scalar_copy_at_precision (
  const MpfrComplexScalarStorage& source,
  mpfr_prec_t precision_bits);

MpfrComplexScalarStorage mplapack_mpc_scalar_from_real (
  const MpfrScalarStorage& source,
  mpfr_prec_t precision_bits);

MpfrComplexMatrixStorage mplapack_mpc_matrix_multiply (
  const MpfrComplexMatrixStorage& lhs,
  const MpfrComplexMatrixStorage& rhs);

MpfrComplexMatrixStorage mplapack_mpc_matrix_scale (
  const MpfrComplexMatrixStorage& matrix,
  const MpfrComplexScalarStorage& scalar);

MpfrComplexScalarStorage mplapack_mpc_scalar_multiply (
  const MpfrComplexScalarStorage& lhs,
  const MpfrComplexScalarStorage& rhs);

} // namespace octave_mplapack

#endif
