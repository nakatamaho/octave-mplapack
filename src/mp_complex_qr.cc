// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_qr.h"

#include <algorithm>
#include <cstdint>
#include <limits>
#include <stdexcept>
#include <string>

#include <mplapack_mpfr.h>

#include "mp_complex_blas.h"
#include "mp_complex_precision.h"

namespace octave_mplapack
{

namespace
{

mplapackint
checked_workspace_length (const mpfrxx::mpc_class& query,
                          const char *routine)
{
  const mpfr_prec_t precision = query.real_precision ();
  if (precision < MPFR_PREC_MIN || precision > MPFR_PREC_MAX)
    throw std::runtime_error (std::string (routine)
                              + " returned an invalid workspace precision");
  if (mpfr_sgn (mpc_imagref (query.mpc_data ())) != 0
      || mpfr_sgn (mpc_realref (query.mpc_data ())) < 0
      || ! mpfr_integer_p (mpc_realref (query.mpc_data ())))
    throw std::runtime_error (std::string (routine)
                              + " returned a non-integral workspace size");
  const unsigned long value
    = mpfr_get_ui (mpc_realref (query.mpc_data ()), MPFR_RNDZ);
  if (value == 0
      || static_cast<std::uintmax_t> (value)
           > static_cast<std::uintmax_t> (
               std::numeric_limits<mplapackint>::max ()))
    throw std::overflow_error (std::string (routine)
                               + " workspace size is out of range");
  return static_cast<mplapackint> (value);
}

MpcQrResult
make_qr_result_from_factorization (MpfrComplexMatrixStorage a_fact,
                                    MpfrComplexMatrixStorage tau,
                                    bool economy, bool want_q)
{
  const mpfr_prec_t operation_precision = a_fact.precision_bits ();
  const std::size_t m = a_fact.rows ();
  const std::size_t n = a_fact.columns ();
  const std::size_t k = std::min (m, n);
  const bool tall_economy = economy && m > n;
  const std::size_t q_columns = tall_economy ? n : m;
  const std::size_t r_rows = tall_economy ? n : m;

  MpfrComplexMatrixStorage r (r_rows, n, operation_precision);
  for (std::size_t column = 0; column < n; ++column)
    for (std::size_t row = 0; row < r_rows; ++row)
      {
        if (row < k && row <= column)
          mpc_set (r.at (row, column).mpc_data (),
                   a_fact.at (row, column).mpc_data (),
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
        else
          mpc_set_ui (r.at (row, column).mpc_data (), 0,
                      MPC_RND (MPFR_RNDN, MPFR_RNDN));
      }

  if (! want_q)
    return {MpfrComplexMatrixStorage (0, 0, operation_precision),
            std::move (r)};

  const auto m_arg = MpfrComplexMatrixStorage::checked_mplapack_dimension (m);
  const auto k_arg = MpfrComplexMatrixStorage::checked_mplapack_dimension (k);
  const auto q_columns_arg
    = MpfrComplexMatrixStorage::checked_mplapack_dimension (q_columns);
  MpfrComplexMatrixStorage query_q (m, q_columns, operation_precision);
  for (std::size_t column = 0; column < q_columns; ++column)
    for (std::size_t row = 0; row < m; ++row)
      {
        if (column < n)
          mpc_set (query_q.at (row, column).mpc_data (),
                   a_fact.at (row, column).mpc_data (),
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
        else
          mpc_set_ui (query_q.at (row, column).mpc_data (), 0,
                      MPC_RND (MPFR_RNDN, MPFR_RNDN));
      }
  MpfrComplexMatrixStorage query_tau (tau);
  MpfrComplexMatrixStorage query_work (1, 1, operation_precision);
  MpfrComplexMatrixStorage::MplapackInteger query_info = 0;
  {
    MpfrMpcPrecisionScope scope (operation_precision);
    require_mplapack_mpc_qr_precision_contract (
      operation_precision, query_q, query_tau, query_work);
    Cungqr (m_arg, q_columns_arg, k_arg, query_q.data (),
            query_q.leading_dimension (), query_tau.data (),
            query_work.data (), -1, query_info);
    require_mplapack_mpc_qr_precision_contract (
      operation_precision, query_q, query_tau, query_work);
  }
  if (query_info != 0)
    throw MpcQrError (MpcQrError::Kind::invalid_argument, query_info,
                      "MPLAPACK Cungqr rejected a workspace query argument");
  const auto cungqr_lwork
    = checked_workspace_length (query_work.at (0, 0), "Cungqr");

  MpfrComplexMatrixStorage q (std::move (query_q));
  MpfrComplexMatrixStorage q_tau (std::move (query_tau));
  MpfrComplexMatrixStorage cungqr_work (
    static_cast<std::size_t> (cungqr_lwork), 1, operation_precision);
  MpfrComplexMatrixStorage::MplapackInteger info = 0;
  {
    MpfrMpcPrecisionScope scope (operation_precision);
    require_mplapack_mpc_qr_precision_contract (
      operation_precision, q, q_tau, cungqr_work);
    Cungqr (m_arg, q_columns_arg, k_arg, q.data (), q.leading_dimension (),
            q_tau.data (), cungqr_work.data (), cungqr_lwork, info);
    require_mplapack_mpc_qr_precision_contract (
      operation_precision, q, q_tau, cungqr_work);
  }
  if (info < 0)
    throw MpcQrError (MpcQrError::Kind::invalid_argument, info,
                      "MPLAPACK Cungqr rejected an argument");
  if (info > 0)
    throw MpcQrError (MpcQrError::Kind::internal, info,
                      "MPLAPACK Cungqr failed");
  return {std::move (q), std::move (r)};
}

} // namespace

void
require_mplapack_mpc_qr_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexMatrixStorage& a_work,
  const MpfrComplexMatrixStorage& tau,
  const MpfrComplexMatrixStorage& work)
{
  if (operation_precision < MPFR_PREC_MIN
      || operation_precision > MPFR_PREC_MAX)
    throw std::invalid_argument (
      "MPLAPACK MPC QR precision is outside the MPFR range");

  const auto precision_override = mpfrxx::mpc_precision_override_storage ();
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && precision_override.active
      && precision_override.real_precision_bits == operation_precision
      && precision_override.imag_precision_bits == operation_precision
      && a_work.precision_bits () == operation_precision
      && tau.precision_bits () == operation_precision
      && work.precision_bits () == operation_precision
      && a_work.all_elements_have_uniform_precision ()
      && tau.all_elements_have_uniform_precision ()
      && work.all_elements_have_uniform_precision ();
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK complex precision contract mismatch at QR boundary");
}

MpcQrResult
mplapack_mpc_matrix_qr (const MpfrComplexMatrixStorage& input, bool economy,
                        bool want_q)
{
  const mpfr_prec_t operation_precision = input.precision_bits ();
  if (operation_precision < MPFR_PREC_MIN
      || operation_precision > MPFR_PREC_MAX)
    throw std::invalid_argument (
      "complex QR precision is outside the MPFR range");
  const std::size_t m = input.rows ();
  const std::size_t n = input.columns ();
  const std::size_t k = std::min (m, n);
  const bool tall_economy = economy && m > n;
  const std::size_t q_columns = tall_economy ? n : m;
  const std::size_t r_rows = tall_economy ? n : m;

  if (m == 0 || n == 0)
    return {MpfrComplexMatrixStorage (m, q_columns, operation_precision),
            MpfrComplexMatrixStorage (r_rows, n, operation_precision)};

  const auto m_arg = MpfrComplexMatrixStorage::checked_mplapack_dimension (m);
  const auto n_arg = MpfrComplexMatrixStorage::checked_mplapack_dimension (n);
  MpfrComplexMatrixStorage query_a
    = mplapack_mpc_matrix_copy_at_precision (input, operation_precision);
  MpfrComplexMatrixStorage query_tau (k, 1, operation_precision);
  MpfrComplexMatrixStorage query_work (1, 1, operation_precision);
  MpfrComplexMatrixStorage::MplapackInteger query_info = 0;
  {
    MpfrMpcPrecisionScope scope (operation_precision);
    require_mplapack_mpc_qr_precision_contract (
      operation_precision, query_a, query_tau, query_work);
    Cgeqrf (m_arg, n_arg, query_a.data (), query_a.leading_dimension (),
            query_tau.data (), query_work.data (), -1, query_info);
    require_mplapack_mpc_qr_precision_contract (
      operation_precision, query_a, query_tau, query_work);
  }
  if (query_info != 0)
    throw MpcQrError (MpcQrError::Kind::invalid_argument, query_info,
                      "MPLAPACK Cgeqrf rejected a workspace query argument");
  const auto cgeqrf_lwork
    = checked_workspace_length (query_work.at (0, 0), "Cgeqrf");

  MpfrComplexMatrixStorage a_fact
    = mplapack_mpc_matrix_copy_at_precision (input, operation_precision);
  MpfrComplexMatrixStorage tau (k, 1, operation_precision);
  MpfrComplexMatrixStorage cgeqrf_work (
    static_cast<std::size_t> (cgeqrf_lwork), 1, operation_precision);
  MpfrComplexMatrixStorage::MplapackInteger info = 0;
  {
    MpfrMpcPrecisionScope scope (operation_precision);
    require_mplapack_mpc_qr_precision_contract (
      operation_precision, a_fact, tau, cgeqrf_work);
    Cgeqrf (m_arg, n_arg, a_fact.data (), a_fact.leading_dimension (),
            tau.data (), cgeqrf_work.data (), cgeqrf_lwork, info);
    require_mplapack_mpc_qr_precision_contract (
      operation_precision, a_fact, tau, cgeqrf_work);
  }
  if (info < 0)
    throw MpcQrError (MpcQrError::Kind::invalid_argument, info,
                      "MPLAPACK Cgeqrf rejected an argument");
  if (info > 0)
    throw MpcQrError (MpcQrError::Kind::internal, info,
                      "MPLAPACK Cgeqrf failed");

  return make_qr_result_from_factorization (
    std::move (a_fact), std::move (tau), economy, want_q);
}

} // namespace octave_mplapack
