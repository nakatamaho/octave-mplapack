// SPDX-License-Identifier: BSD-2-Clause

#include "mp_lapack.h"

#include <algorithm>
#include <cstdint>
#include <limits>
#include <stdexcept>
#include <vector>

#include <gmp.h>
#include <mplapack_mpfr.h>

namespace
{

void
validate_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument (
      "MPLAPACK MPFR precision is outside the MPFR range");
}

mpfrxx::mpfr_class
make_scalar_at_precision (const mpfrxx::mpfr_class& source,
                          mpfr_prec_t precision_bits)
{
  mpfrxx::mpfr_class result
    = mpfrxx::mpfr_class::with_precision (precision_bits);
  mpfr_set (result.mpfr_data (), source.mpfr_data (), MPFR_RNDN);
  return result;
}

mpfrxx::mpfr_class
make_scalar_at_precision (double source, mpfr_prec_t precision_bits)
{
  mpfrxx::mpfr_class result
    = mpfrxx::mpfr_class::with_precision (precision_bits);
  mpfr_set_d (result.mpfr_data (), source, MPFR_RNDN);
  return result;
}

octave_mplapack::MpfrMatrixStorage::MplapackInteger
checked_workspace_length (const mpfrxx::mpfr_class& query)
{
  if (mpfr_nan_p (query.mpfr_data ()) != 0
      || mpfr_inf_p (query.mpfr_data ()) != 0
      || mpfr_integer_p (query.mpfr_data ()) == 0
      || mpfr_sgn (query.mpfr_data ()) <= 0)
    throw std::invalid_argument ("MPLAPACK workspace query returned an invalid size");

  mpz_t value;
  mpz_t max_mplapack;
  mpz_t max_size;
  mpz_init (value);
  mpz_init (max_mplapack);
  mpz_init (max_size);
  mpfr_get_z (value, query.mpfr_data (), MPFR_RNDZ);
  const auto mplapack_max
    = std::numeric_limits<octave_mplapack::MpfrMatrixStorage::MplapackInteger>::max ();
  const auto size_max = std::numeric_limits<std::size_t>::max ();
  mpz_import (max_mplapack, 1, -1, sizeof (mplapack_max), 0, 0,
              &mplapack_max);
  mpz_import (max_size, 1, -1, sizeof (size_max), 0, 0, &size_max);
  const bool fits = mpz_cmp (value, max_mplapack) <= 0
                    && mpz_cmp (value, max_size) <= 0;
  if (! fits)
    {
      mpz_clear (value);
      mpz_clear (max_mplapack);
      mpz_clear (max_size);
      throw std::overflow_error ("MPLAPACK Rgels workspace exceeds allocation limits");
    }
  const auto result
    = static_cast<octave_mplapack::MpfrMatrixStorage::MplapackInteger> (
      mpfr_get_uj (query.mpfr_data (), MPFR_RNDZ));
  mpz_clear (value);
  mpz_clear (max_mplapack);
  mpz_clear (max_size);
  return result;
}

} // namespace

namespace octave_mplapack
{

void
require_mplapack_mpfr_solve_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrMatrixStorage& a_work,
  const MpfrMatrixStorage& b_work)
{
  validate_precision (operation_precision);
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && a_work.precision_bits () == operation_precision
      && b_work.precision_bits () == operation_precision;
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at Rgesv boundary");
}

void
require_mplapack_mpfr_rgels_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrMatrixStorage& a_work,
  const MpfrMatrixStorage& b_work,
  const MpfrMatrixStorage& work)
{
  validate_precision (operation_precision);
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && a_work.precision_bits () == operation_precision
      && b_work.precision_bits () == operation_precision
      && work.precision_bits () == operation_precision;
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at Rgels boundary");
}

void
require_mplapack_mpfr_rank_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrMatrixStorage& a_work,
  const MpfrMatrixStorage& b_work,
  const mpfrxx::mpfr_class& rcond,
  const MpfrMatrixStorage& singular_values,
  const MpfrMatrixStorage& work)
{
  validate_precision (operation_precision);
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && a_work.precision_bits () == operation_precision
      && b_work.precision_bits () == operation_precision
      && rcond.precision () == operation_precision
      && singular_values.precision_bits () == operation_precision
      && work.precision_bits () == operation_precision;
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at rank-revealing boundary");
}

void
require_mplapack_mpfr_rpotrf_precision_contract (
  mpfr_prec_t operation_precision, const MpfrMatrixStorage& a_work)
{
  validate_precision (operation_precision);
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && a_work.precision_bits () == operation_precision;
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at Rpotrf boundary");
}

void
require_mplapack_mpfr_qr_precision_contract (
  mpfr_prec_t operation_precision, const MpfrMatrixStorage& a_work,
  const MpfrMatrixStorage& tau, const MpfrMatrixStorage& work)
{
  validate_precision (operation_precision);
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && a_work.precision_bits () == operation_precision
      && tau.precision_bits () == operation_precision
      && work.precision_bits () == operation_precision;
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at QR boundary");
}

MpfrMatrixStorage
mplapack_mpfr_matrix_solve (const MpfrMatrixStorage& lhs,
                            const MpfrMatrixStorage& rhs)
{
  if (lhs.rows () != lhs.columns ())
    throw std::invalid_argument (
      "MPLAPACK Rgesv requires a square coefficient matrix");
  if (rhs.rows () != lhs.rows ())
    throw std::invalid_argument ("matrix solve dimensions must agree");

  const mpfr_prec_t operation_precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());
  validate_precision (operation_precision);

  // Rgesv overwrites both arguments.  Keep public immutable values isolated
  // in operation-owned, uniformly precisioned working buffers.
  MpfrMatrixStorage a_work (lhs.rows (), lhs.columns (), operation_precision,
                            lhs);
  MpfrMatrixStorage b_work (rhs.rows (), rhs.columns (), operation_precision,
                            rhs);

  const std::size_t n = lhs.rows ();
  const std::size_t nrhs = rhs.columns ();
  if (n == 0 || nrhs == 0)
    return b_work;

  std::vector<MpfrMatrixStorage::MplapackInteger> pivots (n);
  const auto n_arg = MpfrMatrixStorage::checked_mplapack_dimension (n);
  const auto nrhs_arg = MpfrMatrixStorage::checked_mplapack_dimension (nrhs);
  const auto lda = a_work.leading_dimension ();
  const auto ldb = b_work.leading_dimension ();
  MpfrMatrixStorage::MplapackInteger info = 0;

  {
    // MPLAPACK MPFR requires one uniform operation precision.  The scope
    // supplies p to default-constructed temporaries in the LAPACK path.
    MplapackMpfrPrecisionScope precision_scope (operation_precision);
    require_mplapack_mpfr_solve_precision_contract (
      operation_precision, a_work, b_work);
    Rgesv (n_arg, nrhs_arg, a_work.data (), lda, pivots.data (),
           b_work.data (), ldb, info);
    if (mpfrxx::default_precision_bits () != operation_precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rgesv changed the current-thread default precision");
  }

  if (info > 0)
    throw MpfrRgesvError (MpfrRgesvError::Kind::singular,
                          static_cast<int> (info),
                          "MPLAPACK Rgesv reported a singular matrix");
  if (info < 0)
    throw MpfrRgesvError (MpfrRgesvError::Kind::invalid_argument,
                          static_cast<int> (info),
                          "MPLAPACK Rgesv rejected an argument");

  return b_work;
}

MpfrMatrixStorage
mplapack_mpfr_matrix_rectangular_solve (const MpfrMatrixStorage& lhs,
                                        const MpfrMatrixStorage& rhs)
{
  if (lhs.rows () == lhs.columns ())
    throw std::invalid_argument (
      "MPLAPACK Rgels is only used for rectangular matrices");
  if (rhs.rows () != lhs.rows ())
    throw std::invalid_argument ("matrix solve dimensions must agree");

  const mpfr_prec_t operation_precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());
  validate_precision (operation_precision);
  const std::size_t m = lhs.rows ();
  const std::size_t n = lhs.columns ();
  const std::size_t nrhs = rhs.columns ();
  const std::size_t padded_rows = std::max (m, n);

  // Rgels overwrites A and B.  Use operation-owned, uniformly p_op-precision
  // buffers; B is padded because LAPACK returns the n-row solution in it.
  if (nrhs == 0 || std::min (m, n) == 0)
    {
      MpfrMatrixStorage empty_result (n, nrhs, operation_precision);
      return empty_result;
    }

  const auto m_arg = MpfrMatrixStorage::checked_mplapack_dimension (m);
  const auto n_arg = MpfrMatrixStorage::checked_mplapack_dimension (n);
  const auto nrhs_arg = MpfrMatrixStorage::checked_mplapack_dimension (nrhs);
  MpfrMatrixStorage query_a (m, n, operation_precision, lhs);
  MpfrMatrixStorage query_b (padded_rows, nrhs, operation_precision);
  for (std::size_t index = 0; index < query_b.numel (); ++index)
    mpfr_set_zero (query_b.data ()[index].mpfr_data (), 0);
  for (std::size_t column = 0; column < nrhs; ++column)
    for (std::size_t row = 0; row < m; ++row)
      mpfr_set (query_b.at (row, column).mpfr_data (),
                rhs.at (row, column).mpfr_data (), MPFR_RNDN);

  const auto lda = query_a.leading_dimension ();
  const auto ldb = query_b.leading_dimension ();
  MpfrMatrixStorage query_work (1, 1, operation_precision);
  MpfrMatrixStorage::MplapackInteger query_info = 0;
  MpfrMatrixStorage::MplapackInteger lwork = 0;
  {
    // Rgels has nested QR/LQ routines and default REAL temporaries; keep the
    // complete workspace-query call inside the uniform operation scope.
    MplapackMpfrPrecisionScope precision_scope (operation_precision);
    require_mplapack_mpfr_rgels_precision_contract (
      operation_precision, query_a, query_b, query_work);
    Rgels ("N", m_arg, n_arg, nrhs_arg, query_a.data (), lda,
           query_b.data (), ldb, query_work.data (), -1, query_info);
    if (mpfrxx::default_precision_bits () != operation_precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rgels changed the current-thread default precision");
  }
  if (query_info != 0)
    {
      if (query_info > 0)
        throw MpfrRgelsError (
          MpfrRgelsError::Kind::rank_deficient,
          static_cast<int> (query_info),
          "MPLAPACK Rgels reported a rank-deficient workspace query");
      throw MpfrRgelsError (
        MpfrRgelsError::Kind::invalid_argument,
        static_cast<int> (query_info),
        "MPLAPACK Rgels rejected a workspace query argument");
    }
  lwork = checked_workspace_length (query_work.data ()[0]);

  // Recreate both inputs after the query: this is safe even for an
  // implementation that writes scratch values during a workspace query.
  MpfrMatrixStorage a_work (m, n, operation_precision, lhs);
  MpfrMatrixStorage b_work (padded_rows, nrhs, operation_precision);
  for (std::size_t index = 0; index < b_work.numel (); ++index)
    mpfr_set_zero (b_work.data ()[index].mpfr_data (), 0);
  for (std::size_t column = 0; column < nrhs; ++column)
    for (std::size_t row = 0; row < m; ++row)
      mpfr_set (b_work.at (row, column).mpfr_data (),
                rhs.at (row, column).mpfr_data (), MPFR_RNDN);
  const auto actual_lda = a_work.leading_dimension ();
  const auto actual_ldb = b_work.leading_dimension ();
  MpfrMatrixStorage work (static_cast<std::size_t> (lwork), 1,
                          operation_precision);
  MpfrMatrixStorage::MplapackInteger info = 0;
  {
    MplapackMpfrPrecisionScope precision_scope (operation_precision);
    require_mplapack_mpfr_rgels_precision_contract (
      operation_precision, a_work, b_work, work);
    Rgels ("N", m_arg, n_arg, nrhs_arg, a_work.data (), actual_lda,
           b_work.data (), actual_ldb, work.data (), lwork, info);
    if (mpfrxx::default_precision_bits () != operation_precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rgels changed the current-thread default precision");
  }

  if (info > 0)
    throw MpfrRgelsError (MpfrRgelsError::Kind::rank_deficient,
                          static_cast<int> (info),
                          "MPLAPACK Rgels reported a rank-deficient system");
  if (info < 0)
    throw MpfrRgelsError (MpfrRgelsError::Kind::invalid_argument,
                          static_cast<int> (info),
                          "MPLAPACK Rgels rejected an argument");

  MpfrMatrixStorage result (n, nrhs, operation_precision);
  for (std::size_t column = 0; column < nrhs; ++column)
    for (std::size_t row = 0; row < n; ++row)
      mpfr_set (result.at (row, column).mpfr_data (),
                b_work.at (row, column).mpfr_data (), MPFR_RNDN);
  return result;
}

MpfrRankRevealingSolveResult
mplapack_mpfr_matrix_rank_revealing_solve (
  const MpfrMatrixStorage& lhs, const MpfrMatrixStorage& rhs)
{
  if (lhs.rows () == lhs.columns ())
    throw std::invalid_argument (
      "rank-revealing MPLAPACK solve is only used for rectangular matrices");
  if (rhs.rows () != lhs.rows ())
    throw std::invalid_argument ("matrix solve dimensions must agree");

  const mpfr_prec_t operation_precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());
  validate_precision (operation_precision);
  const std::size_t m = lhs.rows ();
  const std::size_t n = lhs.columns ();
  const std::size_t nrhs = rhs.columns ();
  const std::size_t padded_rows = std::max (m, n);
  const MpfrMatrixStorage::MplapackInteger zero_rank = 0;

  if (nrhs == 0 || std::min (m, n) == 0)
    return {MpfrMatrixStorage (n, nrhs, operation_precision), zero_rank};

  const auto m_arg = MpfrMatrixStorage::checked_mplapack_dimension (m);
  const auto n_arg = MpfrMatrixStorage::checked_mplapack_dimension (n);
  const auto nrhs_arg = MpfrMatrixStorage::checked_mplapack_dimension (nrhs);

  auto fill_rhs = [&] (MpfrMatrixStorage& destination)
  {
    for (std::size_t index = 0; index < destination.numel (); ++index)
      mpfr_set_zero (destination.data ()[index].mpfr_data (), 0);
    for (std::size_t column = 0; column < nrhs; ++column)
      for (std::size_t row = 0; row < m; ++row)
        mpfr_set (destination.at (row, column).mpfr_data (),
                  rhs.at (row, column).mpfr_data (), MPFR_RNDN);
  };

  MpfrMatrixStorage query_a (m, n, operation_precision, lhs);
  MpfrMatrixStorage query_b (padded_rows, nrhs, operation_precision);
  fill_rhs (query_b);
  MpfrMatrixStorage query_s (std::min (m, n), 1, operation_precision);
  MpfrMatrixStorage query_work (1, 1, operation_precision);
  MpfrMatrixStorage::MplapackInteger query_info = 0;
  MpfrMatrixStorage::MplapackInteger query_rank = 0;
  {
    // Rank-revealing MPLAPACK calls require one p_op and default REAL
    // temporaries inherit it from this scope.
    MplapackMpfrPrecisionScope precision_scope (operation_precision);
    mpfrxx::mpfr_class rcond
      = mpfrxx::mpfr_class::with_precision (operation_precision);
    const mpfrxx::mpfr_class epsilon = Rlamch_mpfr ("E");
    mpfr_set (rcond.mpfr_data (), epsilon.mpfr_data (), MPFR_RNDN);
    require_mplapack_mpfr_rank_precision_contract (
      operation_precision, query_a, query_b, rcond, query_s, query_work);
    Rgelss (m_arg, n_arg, nrhs_arg, query_a.data (), query_a.leading_dimension (),
            query_b.data (), query_b.leading_dimension (), query_s.data (),
            rcond, query_rank, query_work.data (), -1, query_info);
    if (mpfrxx::default_precision_bits () != operation_precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rgelss changed the current-thread default precision");
  }
  if (query_info != 0)
    throw MpfrRankRevealingError (
      query_info > 0 ? MpfrRankRevealingError::Kind::convergence
                     : MpfrRankRevealingError::Kind::invalid_argument,
      static_cast<int> (query_info),
      query_info > 0 ? "MPLAPACK Rgelss workspace query failed to converge"
                     : "MPLAPACK Rgelss rejected a workspace query argument");
  const auto lwork = checked_workspace_length (query_work.data ()[0]);

  // Recreate destructive inputs after querying so query-side writes cannot
  // affect the actual rank-revealing solve.
  MpfrMatrixStorage a_work (m, n, operation_precision, lhs);
  MpfrMatrixStorage b_work (padded_rows, nrhs, operation_precision);
  fill_rhs (b_work);
  MpfrMatrixStorage singular_values (std::min (m, n), 1,
                                     operation_precision);
  MpfrMatrixStorage work (static_cast<std::size_t> (lwork), 1,
                          operation_precision);
  MpfrMatrixStorage::MplapackInteger rank = 0;
  MpfrMatrixStorage::MplapackInteger info = 0;
  {
    MplapackMpfrPrecisionScope precision_scope (operation_precision);
    mpfrxx::mpfr_class rcond
      = mpfrxx::mpfr_class::with_precision (operation_precision);
    const mpfrxx::mpfr_class epsilon = Rlamch_mpfr ("E");
    mpfr_set (rcond.mpfr_data (), epsilon.mpfr_data (), MPFR_RNDN);
    require_mplapack_mpfr_rank_precision_contract (
      operation_precision, a_work, b_work, rcond, singular_values, work);
    Rgelss (m_arg, n_arg, nrhs_arg, a_work.data (), a_work.leading_dimension (),
            b_work.data (), b_work.leading_dimension (), singular_values.data (),
            rcond, rank, work.data (), lwork, info);
    if (mpfrxx::default_precision_bits () != operation_precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rgelss changed the current-thread default precision");
  }

  if (info < 0)
    throw MpfrRankRevealingError (
      MpfrRankRevealingError::Kind::invalid_argument, static_cast<int> (info),
      "MPLAPACK Rgelss rejected an argument");
  if (info > 0)
    throw MpfrRankRevealingError (
      MpfrRankRevealingError::Kind::convergence, static_cast<int> (info),
      "MPLAPACK Rgelss failed to converge");
  const auto max_rank = static_cast<MpfrMatrixStorage::MplapackInteger> (
    std::min (m, n));
  if (rank < 0 || rank > max_rank)
    throw MpfrRankRevealingError (
      MpfrRankRevealingError::Kind::internal, 0,
      "MPLAPACK Rgelss returned an invalid effective rank");

  MpfrMatrixStorage result (n, nrhs, operation_precision);
  for (std::size_t column = 0; column < nrhs; ++column)
    for (std::size_t row = 0; row < n; ++row)
      mpfr_set (result.at (row, column).mpfr_data (),
                b_work.at (row, column).mpfr_data (), MPFR_RNDN);
  return {std::move (result), rank};
}

MpfrCholeskyResult
mplapack_mpfr_matrix_cholesky (const MpfrMatrixStorage& input, bool lower)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument (
      "MPLAPACK Rpotrf requires a square coefficient matrix");

  const mpfr_prec_t operation_precision = input.precision_bits ();
  validate_precision (operation_precision);
  const std::size_t n = input.rows ();
  MpfrMatrixStorage a_work (n, n, operation_precision, input);
  if (n == 0)
    return {std::move (a_work), 0};

  const auto n_arg = MpfrMatrixStorage::checked_mplapack_dimension (n);
  const auto lda = a_work.leading_dimension ();
  MpfrMatrixStorage::MplapackInteger info = 0;
  {
    // Rpotrf overwrites its input. Factor an operation-owned p_op copy
    // so public mp values retain value semantics.
    MplapackMpfrPrecisionScope precision_scope (operation_precision);
    require_mplapack_mpfr_rpotrf_precision_contract (
      operation_precision, a_work);
    Rpotrf (lower ? "L" : "U", n_arg, a_work.data (), lda, info);
    if (mpfrxx::default_precision_bits () != operation_precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rpotrf changed the current-thread default precision");
  }

  if (info < 0)
    throw MpfrRpotrfError (MpfrRpotrfError::Kind::invalid_argument,
                           static_cast<int> (info),
                           "MPLAPACK Rpotrf rejected an argument");
  if (info == 0)
    {
      for (std::size_t column = 0; column < n; ++column)
        for (std::size_t row = 0; row < n; ++row)
          if (lower ? column > row : row > column)
            mpfr_set_zero (a_work.at (row, column).mpfr_data (), 0);
      return {std::move (a_work), info};
    }

  if (static_cast<std::uintmax_t> (info) > n)
    throw MpfrRpotrfError (MpfrRpotrfError::Kind::internal,
                           static_cast<int> (info),
                           "MPLAPACK Rpotrf returned an invalid failure index");

  // Dense chol's two-output form returns the leading factor before the first
  // non-positive pivot; one-output callers turn the same status into an error.
  const std::size_t completed = static_cast<std::size_t> (info - 1);
  MpfrMatrixStorage partial (completed, completed, operation_precision);
  for (std::size_t column = 0; column < completed; ++column)
    for (std::size_t row = 0; row < completed; ++row)
      {
        if (lower ? column > row : row > column)
          mpfr_set_zero (partial.at (row, column).mpfr_data (), 0);
        else
          mpfr_set (partial.at (row, column).mpfr_data (),
                    a_work.at (row, column).mpfr_data (), MPFR_RNDN);
      }
  return {std::move (partial), info};
}

MpfrQrResult
mplapack_mpfr_matrix_qr (const MpfrMatrixStorage& input, bool economy,
                         bool want_q)
{
  const mpfr_prec_t operation_precision = input.precision_bits ();
  validate_precision (operation_precision);
  const std::size_t m = input.rows ();
  const std::size_t n = input.columns ();
  const std::size_t k = std::min (m, n);
  const bool tall_economy = economy && m > n;
  const std::size_t q_columns = tall_economy ? n : m;
  const std::size_t r_rows = tall_economy ? n : m;

  // LAPACK has no useful pointer contract for zero-size arrays.  The
  // structural result is unambiguous, so handle these shapes without a call.
  if (m == 0 || n == 0)
    {
      MpfrMatrixStorage q (m, q_columns, operation_precision);
      MpfrMatrixStorage r (r_rows, n, operation_precision);
      return {std::move (q), std::move (r)};
    }

  const auto m_arg = MpfrMatrixStorage::checked_mplapack_dimension (m);
  const auto n_arg = MpfrMatrixStorage::checked_mplapack_dimension (n);
  const auto k_arg = MpfrMatrixStorage::checked_mplapack_dimension (k);

  MpfrMatrixStorage query_a (m, n, operation_precision, input);
  MpfrMatrixStorage query_tau (k, 1, operation_precision);
  MpfrMatrixStorage query_work (1, 1, operation_precision);
  MpfrMatrixStorage::MplapackInteger query_info = 0;
  {
    // Rgeqrf overwrites A and uses default-constructed REAL temporaries.
    MplapackMpfrPrecisionScope precision_scope (operation_precision);
    require_mplapack_mpfr_qr_precision_contract (
      operation_precision, query_a, query_tau, query_work);
    Rgeqrf (m_arg, n_arg, query_a.data (), query_a.leading_dimension (),
            query_tau.data (), query_work.data (), -1, query_info);
    if (mpfrxx::default_precision_bits () != operation_precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rgeqrf changed the current-thread default precision");
  }
  if (query_info != 0)
    throw std::runtime_error (query_info < 0
                                ? "MPLAPACK Rgeqrf rejected a workspace query argument"
                                : "MPLAPACK Rgeqrf workspace query failed");
  const auto rgeqrf_lwork = checked_workspace_length (query_work.at (0, 0));

  // Recreate all destructive inputs after the query.  This remains safe if a
  // vendor implementation writes scratch values during a query.
  MpfrMatrixStorage a_fact (m, n, operation_precision, input);
  MpfrMatrixStorage tau (k, 1, operation_precision);
  MpfrMatrixStorage rgeqrf_work (
    static_cast<std::size_t> (rgeqrf_lwork), 1, operation_precision);
  MpfrMatrixStorage::MplapackInteger info = 0;
  {
    MplapackMpfrPrecisionScope precision_scope (operation_precision);
    require_mplapack_mpfr_qr_precision_contract (
      operation_precision, a_fact, tau, rgeqrf_work);
    Rgeqrf (m_arg, n_arg, a_fact.data (), a_fact.leading_dimension (),
            tau.data (), rgeqrf_work.data (), rgeqrf_lwork, info);
    if (mpfrxx::default_precision_bits () != operation_precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rgeqrf changed the current-thread default precision");
  }
  if (info < 0)
    throw std::runtime_error ("MPLAPACK Rgeqrf rejected an argument");
  if (info > 0)
    throw std::runtime_error ("MPLAPACK Rgeqrf failed");

  MpfrMatrixStorage r (r_rows, n, operation_precision);
  for (std::size_t column = 0; column < n; ++column)
    for (std::size_t row = 0; row < r_rows; ++row)
      {
        if (row < k && row <= column)
          mpfr_set (r.at (row, column).mpfr_data (),
                    a_fact.at (row, column).mpfr_data (), MPFR_RNDN);
        else
          mpfr_set_zero (r.at (row, column).mpfr_data (), 0);
      }

  if (! want_q)
    return {MpfrMatrixStorage (0, 0, operation_precision), std::move (r)};

  const auto q_columns_arg
    = MpfrMatrixStorage::checked_mplapack_dimension (q_columns);
  MpfrMatrixStorage query_q (m, q_columns, operation_precision);
  for (std::size_t column = 0; column < q_columns; ++column)
    for (std::size_t row = 0; row < m; ++row)
      {
        if (column < n)
          mpfr_set (query_q.at (row, column).mpfr_data (),
                    a_fact.at (row, column).mpfr_data (), MPFR_RNDN);
        else
          mpfr_set_zero (query_q.at (row, column).mpfr_data (), 0);
      }
  MpfrMatrixStorage query_tau_q (tau);
  MpfrMatrixStorage query_orgqr_work (1, 1, operation_precision);
  MpfrMatrixStorage::MplapackInteger query_orgqr_info = 0;
  {
    MplapackMpfrPrecisionScope precision_scope (operation_precision);
    require_mplapack_mpfr_qr_precision_contract (
      operation_precision, query_q, query_tau_q, query_orgqr_work);
    Rorgqr (m_arg, q_columns_arg, k_arg, query_q.data (),
            query_q.leading_dimension (), query_tau_q.data (),
            query_orgqr_work.data (), -1, query_orgqr_info);
    if (mpfrxx::default_precision_bits () != operation_precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rorgqr changed the current-thread default precision");
  }
  if (query_orgqr_info != 0)
    throw std::runtime_error (query_orgqr_info < 0
                                ? "MPLAPACK Rorgqr rejected a workspace query argument"
                                : "MPLAPACK Rorgqr workspace query failed");
  const auto orgqr_lwork
    = checked_workspace_length (query_orgqr_work.at (0, 0));

  MpfrMatrixStorage q_work (m, q_columns, operation_precision);
  for (std::size_t column = 0; column < q_columns; ++column)
    for (std::size_t row = 0; row < m; ++row)
      {
        if (column < n)
          mpfr_set (q_work.at (row, column).mpfr_data (),
                    a_fact.at (row, column).mpfr_data (), MPFR_RNDN);
        else
          mpfr_set_zero (q_work.at (row, column).mpfr_data (), 0);
      }
  MpfrMatrixStorage tau_q (tau);
  MpfrMatrixStorage orgqr_work (
    static_cast<std::size_t> (orgqr_lwork), 1, operation_precision);
  MpfrMatrixStorage::MplapackInteger orgqr_info = 0;
  {
    MplapackMpfrPrecisionScope precision_scope (operation_precision);
    require_mplapack_mpfr_qr_precision_contract (
      operation_precision, q_work, tau_q, orgqr_work);
    Rorgqr (m_arg, q_columns_arg, k_arg, q_work.data (),
            q_work.leading_dimension (), tau_q.data (), orgqr_work.data (),
            orgqr_lwork, orgqr_info);
    if (mpfrxx::default_precision_bits () != operation_precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rorgqr changed the current-thread default precision");
  }
  if (orgqr_info < 0)
    throw std::runtime_error ("MPLAPACK Rorgqr rejected an argument");
  if (orgqr_info > 0)
    throw std::runtime_error ("MPLAPACK Rorgqr failed");

  return {std::move (q_work), std::move (r)};
}

MpfrMatrixStorage
mplapack_mpfr_matrix_left_divide (const MpfrMatrixStorage& rhs,
                                  const mpfrxx::mpfr_class& lhs)
{
  const mpfr_prec_t operation_precision
    = std::max (rhs.precision_bits (), lhs.precision ());
  validate_precision (operation_precision);
  MpfrMatrixStorage result (rhs.rows (), rhs.columns (), operation_precision,
                            rhs);
  const mpfrxx::mpfr_class lhs_work
    = make_scalar_at_precision (lhs, operation_precision);
  MplapackMpfrPrecisionScope precision_scope (operation_precision);
  for (std::size_t index = 0; index < result.numel (); ++index)
    mpfr_div (result.data ()[index].mpfr_data (),
              rhs.data ()[index].mpfr_data (), lhs_work.mpfr_data (),
              MPFR_RNDN);
  return result;
}

MpfrMatrixStorage
mplapack_mpfr_matrix_left_divide (const MpfrMatrixStorage& rhs, double lhs)
{
  const mpfr_prec_t operation_precision = rhs.precision_bits ();
  validate_precision (operation_precision);
  MpfrMatrixStorage result (rhs.rows (), rhs.columns (), operation_precision,
                            rhs);
  const mpfrxx::mpfr_class lhs_work
    = make_scalar_at_precision (lhs, operation_precision);
  MplapackMpfrPrecisionScope precision_scope (operation_precision);
  for (std::size_t index = 0; index < result.numel (); ++index)
    mpfr_div (result.data ()[index].mpfr_data (),
              rhs.data ()[index].mpfr_data (), lhs_work.mpfr_data (),
              MPFR_RNDN);
  return result;
}

} // namespace octave_mplapack
