// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_cholesky.h"

#include <algorithm>
#include <cstdint>
#include <stdexcept>

#include <mplapack_mpfr.h>

#include "mp_complex_blas.h"
#include "mp_complex_precision.h"

namespace octave_mplapack
{

void
require_mplapack_mpc_cpotrf_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexMatrixStorage& a_work)
{
  if (operation_precision < MPFR_PREC_MIN
      || operation_precision > MPFR_PREC_MAX)
    throw std::invalid_argument (
      "MPLAPACK MPC Cholesky precision is outside the MPFR range");

  const auto precision_override = mpfrxx::mpc_precision_override_storage ();
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && precision_override.active
      && precision_override.real_precision_bits == operation_precision
      && precision_override.imag_precision_bits == operation_precision
      && a_work.precision_bits () == operation_precision
      && a_work.all_elements_have_uniform_precision ();
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK complex precision contract mismatch at Cpotrf boundary");
}

MpcCholeskyResult
mplapack_mpc_matrix_cholesky (const MpfrComplexMatrixStorage& input,
                              bool lower)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument (
      "MPLAPACK Cpotrf requires a square coefficient matrix");

  const mpfr_prec_t operation_precision = input.precision_bits ();
  const std::size_t n = input.rows ();
  auto a_work = mplapack_mpc_matrix_copy_at_precision (
    input, operation_precision);
  if (n == 0)
    return {std::move (a_work), 0};

  const auto n_arg = MpfrComplexMatrixStorage::checked_mplapack_dimension (n);
  const auto lda = a_work.leading_dimension ();
  MpfrComplexMatrixStorage::MplapackInteger info = 0;
  {
    // Cpotrf overwrites the selected triangle.  Keep the public value
    // immutable by factoring an operation-owned copy at p_op.
    MpfrMpcPrecisionScope scope (operation_precision);
    require_mplapack_mpc_cpotrf_precision_contract (
      operation_precision, a_work);
    Cpotrf (lower ? "L" : "U", n_arg, a_work.data (), lda, info);
    require_mplapack_mpc_cpotrf_precision_contract (
      operation_precision, a_work);
  }

  if (info < 0)
    throw MpcCpotrfError (MpcCpotrfError::Kind::invalid_argument, info,
                          "MPLAPACK Cpotrf rejected an argument");
  if (static_cast<std::uintmax_t> (info) > n)
    throw MpcCpotrfError (MpcCpotrfError::Kind::internal, info,
                          "MPLAPACK Cpotrf returned an invalid failure index");

  const std::size_t completed
    = info == 0 ? n : static_cast<std::size_t> (info - 1);
  MpfrComplexMatrixStorage result (completed, completed,
                                   operation_precision);
  for (std::size_t column = 0; column < completed; ++column)
    for (std::size_t row = 0; row < completed; ++row)
      {
        if (lower ? column > row : row > column)
          mpc_set_ui (result.at (row, column).mpc_data (), 0,
                      MPC_RND (MPFR_RNDN, MPFR_RNDN));
        else
          mpc_set (result.at (row, column).mpc_data (),
                   a_work.at (row, column).mpc_data (),
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
      }
  return {std::move (result), info};
}

} // namespace octave_mplapack
