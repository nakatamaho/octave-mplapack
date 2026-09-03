// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_rank.h"

#include <algorithm>
#include <limits>
#include <stdexcept>
#include <vector>

#include <mplapack_mpfr.h>

#include "mp_complex_blas.h"
#include "mp_complex_precision.h"

namespace
{

octave_mplapack::MpfrComplexMatrixStorage::MplapackInteger
checked_workspace_length (const mpfrxx::mpfr_class& query)
{
  if (mpfr_nan_p (query.mpfr_data ()) != 0
      || mpfr_inf_p (query.mpfr_data ()) != 0
      || mpfr_integer_p (query.mpfr_data ()) == 0
      || mpfr_sgn (query.mpfr_data ()) <= 0)
    throw std::invalid_argument (
      "MPLAPACK Cgelsy workspace query returned an invalid size");

  const auto max_mplapack
    = std::numeric_limits<octave_mplapack::MpfrComplexMatrixStorage::
                             MplapackInteger>::max ();
  const auto max_size = std::numeric_limits<std::size_t>::max ();
  if (mpfr_cmp_ui (query.mpfr_data (),
                   static_cast<unsigned long> (max_mplapack)) > 0
      || mpfr_cmp_ui (query.mpfr_data (),
                      static_cast<unsigned long> (max_size)) > 0)
    throw std::overflow_error (
      "MPLAPACK Cgelsy workspace exceeds allocation limits");
  return static_cast<octave_mplapack::MpfrComplexMatrixStorage::
                       MplapackInteger> (
    mpfr_get_ui (query.mpfr_data (), MPFR_RNDZ));
}

} // namespace

namespace octave_mplapack
{

void
require_mplapack_mpc_rank_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexMatrixStorage& a_work,
  const MpfrComplexMatrixStorage& b_work,
  const mpfrxx::mpfr_class& rcond,
  const MpfrComplexMatrixStorage& work,
  const MpfrMatrixStorage& rwork)
{
  if (operation_precision < MPFR_PREC_MIN
      || operation_precision > MPFR_PREC_MAX)
    throw std::invalid_argument (
      "MPLAPACK MPC rank precision is outside the MPFR range");

  const auto precision_override = mpfrxx::mpc_precision_override_storage ();
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && precision_override.active
      && precision_override.real_precision_bits == operation_precision
      && precision_override.imag_precision_bits == operation_precision
      && a_work.precision_bits () == operation_precision
      && b_work.precision_bits () == operation_precision
      && a_work.all_elements_have_uniform_precision ()
      && b_work.all_elements_have_uniform_precision ()
      && rcond.precision () == operation_precision
      && work.precision_bits () == operation_precision
      && work.all_elements_have_uniform_precision ()
      && rwork.precision_bits () == operation_precision
      && rwork.all_elements_have_uniform_precision ();
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK complex precision contract mismatch at Cgelsy boundary");
}

MpcRankRevealingSolveResult
mplapack_mpc_matrix_rank_solve (const MpfrComplexMatrixStorage& lhs,
                                const MpfrComplexMatrixStorage& rhs)
{
  if (lhs.rows () == lhs.columns ())
    throw std::invalid_argument (
      "MPLAPACK Cgelsy is only used for rectangular matrices");
  if (rhs.rows () != lhs.rows ())
    throw std::invalid_argument ("matrix solve dimensions must agree");

  const mpfr_prec_t operation_precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());
  const std::size_t m = lhs.rows ();
  const std::size_t n = lhs.columns ();
  const std::size_t nrhs = rhs.columns ();
  const std::size_t padded_rows = std::max (m, n);
  if (nrhs == 0 || std::min (m, n) == 0)
    return {MpfrComplexMatrixStorage (n, nrhs, operation_precision), 0};

  const auto m_arg = MpfrComplexMatrixStorage::checked_mplapack_dimension (m);
  const auto n_arg = MpfrComplexMatrixStorage::checked_mplapack_dimension (n);
  const auto nrhs_arg
    = MpfrComplexMatrixStorage::checked_mplapack_dimension (nrhs);

  auto fill_rhs = [] (MpfrComplexMatrixStorage& destination,
                      const MpfrComplexMatrixStorage& source)
  {
    for (std::size_t index = 0; index < destination.numel (); ++index)
      mpc_set_ui_ui (destination.data ()[index].mpc_data (), 0, 0,
                     MPC_RND (MPFR_RNDN, MPFR_RNDN));
    for (std::size_t column = 0; column < source.columns (); ++column)
      for (std::size_t row = 0; row < source.rows (); ++row)
        mpc_set (destination.at (row, column).mpc_data (),
                 source.at (row, column).mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
  };

  auto query_a = mplapack_mpc_matrix_copy_at_precision (
    lhs, operation_precision);
  MpfrComplexMatrixStorage query_b (padded_rows, nrhs, operation_precision);
  fill_rhs (query_b, rhs);
  std::vector<MpfrComplexMatrixStorage::MplapackInteger> query_jpvt (n, 0);
  MpfrComplexMatrixStorage query_work (1, 1, operation_precision);
  MpfrMatrixStorage query_rwork (2 * n, 1, operation_precision);
  MpfrComplexMatrixStorage::MplapackInteger query_rank = 0;
  MpfrComplexMatrixStorage::MplapackInteger query_info = 0;

  {
    MpfrMpcPrecisionScope scope (operation_precision);
    mpfrxx::mpfr_class rcond
      = mpfrxx::mpfr_class::with_precision (operation_precision);
    const mpfrxx::mpfr_class epsilon = Rlamch_mpfr ("E");
    mpfr_set (rcond.mpfr_data (), epsilon.mpfr_data (), MPFR_RNDN);
    require_mplapack_mpc_rank_precision_contract (
      operation_precision, query_a, query_b, rcond, query_work, query_rwork);
    Cgelsy (m_arg, n_arg, nrhs_arg, query_a.data (), query_a.leading_dimension (),
            query_b.data (), query_b.leading_dimension (), query_jpvt.data (),
            rcond, query_rank, query_work.data (), -1, query_rwork.data (),
            query_info);
    require_mplapack_mpc_rank_precision_contract (
      operation_precision, query_a, query_b, rcond, query_work, query_rwork);
  }
  if (query_info != 0)
    throw MpcCgelsyError (
      query_info > 0 ? MpcCgelsyError::Kind::convergence
                     : MpcCgelsyError::Kind::invalid_argument,
      query_info,
      query_info > 0 ? "MPLAPACK Cgelsy workspace query failed"
                     : "MPLAPACK Cgelsy rejected a workspace query argument");
  const auto lwork = checked_workspace_length (
    query_work.at (0, 0).real ());

  auto a_work = mplapack_mpc_matrix_copy_at_precision (
    lhs, operation_precision);
  MpfrComplexMatrixStorage b_work (padded_rows, nrhs, operation_precision);
  fill_rhs (b_work, rhs);
  std::vector<MpfrComplexMatrixStorage::MplapackInteger> jpvt (n, 0);
  MpfrComplexMatrixStorage work (static_cast<std::size_t> (lwork), 1,
                                 operation_precision);
  MpfrMatrixStorage rwork (2 * n, 1, operation_precision);
  MpfrComplexMatrixStorage::MplapackInteger rank = 0;
  MpfrComplexMatrixStorage::MplapackInteger info = 0;

  {
    MpfrMpcPrecisionScope scope (operation_precision);
    mpfrxx::mpfr_class rcond
      = mpfrxx::mpfr_class::with_precision (operation_precision);
    const mpfrxx::mpfr_class epsilon = Rlamch_mpfr ("E");
    mpfr_set (rcond.mpfr_data (), epsilon.mpfr_data (), MPFR_RNDN);
    require_mplapack_mpc_rank_precision_contract (
      operation_precision, a_work, b_work, rcond, work, rwork);
    Cgelsy (m_arg, n_arg, nrhs_arg, a_work.data (), a_work.leading_dimension (),
            b_work.data (), b_work.leading_dimension (), jpvt.data (), rcond,
            rank, work.data (), lwork, rwork.data (), info);
    require_mplapack_mpc_rank_precision_contract (
      operation_precision, a_work, b_work, rcond, work, rwork);
  }

  if (info < 0)
    throw MpcCgelsyError (MpcCgelsyError::Kind::invalid_argument, info,
                          "MPLAPACK Cgelsy rejected an argument");
  if (info > 0)
    throw MpcCgelsyError (MpcCgelsyError::Kind::convergence, info,
                          "MPLAPACK Cgelsy failed to converge");
  const auto max_rank = static_cast<
    MpfrComplexMatrixStorage::MplapackInteger> (std::min (m, n));
  if (rank < 0 || rank > max_rank)
    throw MpcCgelsyError (MpcCgelsyError::Kind::internal, 0,
                          "MPLAPACK Cgelsy returned an invalid rank");

  MpfrComplexMatrixStorage result (n, nrhs, operation_precision);
  for (std::size_t column = 0; column < nrhs; ++column)
    for (std::size_t row = 0; row < n; ++row)
      mpc_set (result.at (row, column).mpc_data (),
               b_work.at (row, column).mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return {std::move (result), rank};
}

} // namespace octave_mplapack
