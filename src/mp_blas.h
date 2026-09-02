// SPDX-License-Identifier: BSD-2-Clause

#ifndef OCTAVE_MPLAPACK_MP_BLAS_H
#define OCTAVE_MPLAPACK_MP_BLAS_H

#include <mplapack_gmpfrxx_mkII_config.h>
#include <mplapack_mpfr_precision.h>
#include <mpfrxx_mkII.h>

#include "mp_matrix_storage.h"

namespace octave_mplapack
{

void require_mplapack_mpfr_precision_contract (
  mpfr_prec_t operation_precision,
  const mpfrxx::mpfr_class& alpha,
  const MpfrMatrixStorage& a_work,
  const MpfrMatrixStorage& b_work,
  const mpfrxx::mpfr_class& beta,
  const MpfrMatrixStorage& c);

MpfrMatrixStorage mplapack_mpfr_matrix_multiply (
  const MpfrMatrixStorage& lhs, const MpfrMatrixStorage& rhs);

MpfrMatrixStorage mplapack_mpfr_matrix_scale (
  const MpfrMatrixStorage& matrix,
  const mpfrxx::mpfr_class& scalar);

MpfrMatrixStorage mplapack_mpfr_matrix_scale (
  const MpfrMatrixStorage& matrix, double scalar);

} // namespace octave_mplapack

#endif
