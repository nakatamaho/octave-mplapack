// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_lapack.h"

#include <algorithm>
#include <stdexcept>
#include <vector>

#include <mplapack_mpfr.h>

#include "mp_complex_blas.h"
#include "mp_complex_precision.h"

namespace octave_mplapack
{

void
require_mplapack_mpc_solve_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexMatrixStorage& a_work,
  const MpfrComplexMatrixStorage& b_work)
{
  if (operation_precision < MPFR_PREC_MIN
      || operation_precision > MPFR_PREC_MAX)
    throw std::invalid_argument (
      "MPLAPACK MPC solve precision is outside the MPFR range");

  const auto precision_override = mpfrxx::mpc_precision_override_storage ();
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && precision_override.active
      && precision_override.real_precision_bits == operation_precision
      && precision_override.imag_precision_bits == operation_precision
      && a_work.precision_bits () == operation_precision
      && b_work.precision_bits () == operation_precision
      && a_work.all_elements_have_uniform_precision ()
      && b_work.all_elements_have_uniform_precision ();
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK complex precision contract mismatch at Cgesv boundary");
}

MpfrComplexMatrixStorage
mplapack_mpc_matrix_solve (const MpfrComplexMatrixStorage& lhs,
                           const MpfrComplexMatrixStorage& rhs)
{
  if (lhs.rows () != lhs.columns ())
    throw std::invalid_argument (
      "MPLAPACK Cgesv requires a square coefficient matrix");
  if (rhs.rows () != lhs.rows ())
    throw std::invalid_argument ("matrix solve dimensions must agree");

  const mpfr_prec_t operation_precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());
  auto a_work = mplapack_mpc_matrix_copy_at_precision (
    lhs, operation_precision);
  auto b_work = mplapack_mpc_matrix_copy_at_precision (
    rhs, operation_precision);

  const std::size_t n = lhs.rows ();
  const std::size_t nrhs = rhs.columns ();
  if (n == 0 || nrhs == 0)
    return b_work;

  std::vector<MpfrComplexMatrixStorage::MplapackInteger> pivots (n);
  const auto n_arg = MpfrComplexMatrixStorage::checked_mplapack_dimension (n);
  const auto nrhs_arg
    = MpfrComplexMatrixStorage::checked_mplapack_dimension (nrhs);
  const auto lda = a_work.leading_dimension ();
  const auto ldb = b_work.leading_dimension ();
  MpfrComplexMatrixStorage::MplapackInteger info = 0;

  MpfrMpcPrecisionScope scope (operation_precision);
  require_mplapack_mpc_solve_precision_contract (
    operation_precision, a_work, b_work);
  Cgesv (n_arg, nrhs_arg, a_work.data (), lda, pivots.data (),
         b_work.data (), ldb, info);
  require_mplapack_mpc_solve_precision_contract (
    operation_precision, a_work, b_work);
  if (info > 0)
    throw MpcCgesvError (MpcCgesvError::Kind::singular, info,
                         "MPLAPACK Cgesv reported a singular matrix");
  if (info < 0)
    throw MpcCgesvError (MpcCgesvError::Kind::invalid_argument, info,
                         "MPLAPACK Cgesv rejected an argument");

  return b_work;
}

} // namespace octave_mplapack
