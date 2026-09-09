// SPDX-License-Identifier: BSD-2-Clause

#include "mp_svd.h"

#include <algorithm>
#include <cstddef>
#include <limits>
#include <stdexcept>
#include <string>
#include <utility>

#include <gmp.h>
#include <mplapack_mpfr.h>

#include "mp_complex_precision.h"
#include "mp_complex_blas.h"
#include "mp_norm.h"
#include "mp_precision.h"

namespace
{

using octave_mplapack::MpfrComplexMatrixStorage;
using octave_mplapack::MpfrMatrixStorage;
using octave_mplapack::MpfrScalarStorage;

void
validate_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument ("MPLAPACK SVD precision is outside MPFR limits");
}

std::size_t
checked_workspace_length (const MpfrScalarStorage::NativeScalar& query,
                          const char *routine)
{
  if (mpfr_nan_p (query.mpfr_data ()) != 0
      || mpfr_inf_p (query.mpfr_data ()) != 0
      || mpfr_integer_p (query.mpfr_data ()) == 0
      || mpfr_sgn (query.mpfr_data ()) <= 0)
    throw std::runtime_error (std::string (routine)
                              + " returned an invalid workspace query");

  mpz_t value;
  mpz_t max_mplapack;
  mpz_t max_size;
  mpz_init (value);
  mpz_init (max_mplapack);
  mpz_init (max_size);
  mpfr_get_z (value, query.mpfr_data (), MPFR_RNDZ);
  const auto mplapack_max =
    std::numeric_limits<MpfrMatrixStorage::MplapackInteger>::max ();
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
      throw std::overflow_error (std::string (routine)
                                 + " workspace exceeds allocation limits");
    }

  const auto result = static_cast<std::size_t> (
    mpfr_get_uj (query.mpfr_data (), MPFR_RNDZ));
  mpz_clear (value);
  mpz_clear (max_mplapack);
  mpz_clear (max_size);
  return result;
}

std::size_t
checked_complex_workspace_length (
  const MpfrComplexMatrixStorage::NativeScalar& query, const char *routine)
{
  if (mpfr_sgn (mpc_imagref (query.mpc_data ())) != 0)
    throw std::runtime_error (std::string (routine)
                              + " returned a complex workspace query");
  auto real_query = MpfrScalarStorage::NativeScalar::with_precision (
    query.real_precision ());
  mpfr_set (real_query.mpfr_data (), mpc_realref (query.mpc_data ()),
            MPFR_RNDN);
  return checked_workspace_length (real_query, routine);
}

void
zero_matrix (MpfrMatrixStorage& matrix)
{
  for (std::size_t index = 0; index < matrix.numel (); ++index)
    mpfr_set_zero (matrix.data ()[index].mpfr_data (), 1);
}

void
require_real_svd_precision_contract (mpfr_prec_t precision,
                                     const MpfrMatrixStorage& a,
                                     const MpfrMatrixStorage& s,
                                     const MpfrMatrixStorage& u,
                                     const MpfrMatrixStorage& vt,
                                     const MpfrMatrixStorage& work)
{
  if (mpfrxx::default_precision_bits () != precision
      || a.precision_bits () != precision
      || s.precision_bits () != precision
      || u.precision_bits () != precision
      || vt.precision_bits () != precision
      || work.precision_bits () != precision
      || ! a.all_elements_have_uniform_precision ()
      || ! s.all_elements_have_uniform_precision ()
      || ! u.all_elements_have_uniform_precision ()
      || ! vt.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ())
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at Rgesvd boundary");
}

void
require_complex_svd_precision_contract (
  mpfr_prec_t precision, const MpfrComplexMatrixStorage& a,
  const MpfrMatrixStorage& s, const MpfrComplexMatrixStorage& u,
  const MpfrComplexMatrixStorage& vt, const MpfrComplexMatrixStorage& work,
  const MpfrMatrixStorage& rwork)
{
  if (mpfrxx::default_precision_bits () != precision
      || a.precision_bits () != precision
      || s.precision_bits () != precision
      || u.precision_bits () != precision
      || vt.precision_bits () != precision
      || work.precision_bits () != precision
      || rwork.precision_bits () != precision
      || ! a.all_elements_have_uniform_precision ()
      || ! s.all_elements_have_uniform_precision ()
      || ! u.all_elements_have_uniform_precision ()
      || ! vt.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ()
      || ! rwork.all_elements_have_uniform_precision ())
    throw std::runtime_error (
      "MPLAPACK MPC precision contract mismatch at Cgesvd boundary");
}

void
fill_real_s (MpfrMatrixStorage& destination,
             const MpfrMatrixStorage& singular_values)
{
  zero_matrix (destination);
  for (std::size_t index = 0; index < singular_values.rows (); ++index)
    mpfr_set (destination.at (index, index).mpfr_data (),
              singular_values.at (index, 0).mpfr_data (), MPFR_RNDN);
}

void
fill_real_v (MpfrMatrixStorage& v, const MpfrMatrixStorage& vt)
{
  for (std::size_t column = 0; column < v.columns (); ++column)
    for (std::size_t row = 0; row < v.rows (); ++row)
      mpfr_set (v.at (row, column).mpfr_data (),
                vt.at (column, row).mpfr_data (), MPFR_RNDN);
}

void
fill_complex_v (MpfrComplexMatrixStorage& v,
                const MpfrComplexMatrixStorage& vt)
{
  for (std::size_t column = 0; column < v.columns (); ++column)
    for (std::size_t row = 0; row < v.rows (); ++row)
      mpc_conj (v.at (row, column).mpc_data (),
                vt.at (column, row).mpc_data (),
                MPC_RND (MPFR_RNDN, MPFR_RNDN));
}

} // namespace

namespace octave_mplapack
{

MpfrSvdResult
mplapack_mpfr_matrix_svd (const MpfrMatrixStorage& input, bool economy)
{
  const mpfr_prec_t precision = input.precision_bits ();
  validate_precision (precision);
  const std::size_t m = input.rows ();
  const std::size_t n = input.columns ();
  const std::size_t k = std::min (m, n);
  const std::size_t u_columns = economy ? k : m;
  const std::size_t vt_rows = economy ? k : n;
  const std::size_t s_rows = economy ? k : m;
  const std::size_t s_columns = economy ? k : n;

  MpfrSvdResult result {
    MpfrMatrixStorage (m, u_columns, precision),
    MpfrMatrixStorage (s_rows, s_columns, precision),
    MpfrMatrixStorage (n, economy ? k : n, precision)
  };
  if (m == 0 || n == 0)
    return result;

  MpfrMatrixStorage a_work (m, n, precision, input);
  MpfrMatrixStorage singular_values (k, 1, precision);
  MpfrMatrixStorage u (m, u_columns, precision);
  MpfrMatrixStorage vt (vt_rows, n, precision);
  MpfrMatrixStorage query_work (1, 1, precision);
  const char *job = economy ? "S" : "A";
  MpfrMatrixStorage::MplapackInteger info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    require_real_svd_precision_contract (
      precision, a_work, singular_values, u, vt, query_work);
    Rgesvd (job, job,
            MpfrMatrixStorage::checked_mplapack_dimension (m),
            MpfrMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), singular_values.data (),
            u.data (), u.leading_dimension (), vt.data (), vt.leading_dimension (),
            query_work.data (), -1, info);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rgesvd changed the current-thread default precision");
  }
  if (info < 0)
    throw MpfrSvdError (MpfrSvdError::Kind::invalid_argument, -info,
                        "MPLAPACK Rgesvd rejected a workspace query argument");
  if (info > 0)
    throw MpfrSvdError (MpfrSvdError::Kind::convergence, info,
                        "MPLAPACK Rgesvd workspace query failed");

  const std::size_t lwork = checked_workspace_length (
    query_work.at (0, 0), "MPLAPACK Rgesvd");
  MpfrMatrixStorage work (lwork, 1, precision);
  a_work = MpfrMatrixStorage (m, n, precision, input);
  singular_values = MpfrMatrixStorage (k, 1, precision);
  u = MpfrMatrixStorage (m, u_columns, precision);
  vt = MpfrMatrixStorage (vt_rows, n, precision);
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    require_real_svd_precision_contract (
      precision, a_work, singular_values, u, vt, work);
    Rgesvd (job, job,
            MpfrMatrixStorage::checked_mplapack_dimension (m),
            MpfrMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), singular_values.data (),
            u.data (), u.leading_dimension (), vt.data (), vt.leading_dimension (),
            work.data (), static_cast<MpfrMatrixStorage::MplapackInteger> (lwork),
            info);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rgesvd changed the current-thread default precision");
  }
  if (info < 0)
    throw MpfrSvdError (MpfrSvdError::Kind::invalid_argument, -info,
                        "MPLAPACK Rgesvd rejected an argument");
  if (info > 0)
    throw MpfrSvdError (MpfrSvdError::Kind::convergence, info,
                        "MPLAPACK Rgesvd failed to converge");

  result.u = std::move (u);
  result.s = MpfrMatrixStorage (s_rows, s_columns, precision);
  fill_real_s (result.s, singular_values);
  MpfrMatrixStorage v (n, economy ? k : n, precision);
  fill_real_v (v, vt);
  result.v = std::move (v);
  return result;
}

MpcSvdResult
mplapack_mpc_matrix_svd (const MpfrComplexMatrixStorage& input, bool economy)
{
  const mpfr_prec_t precision = input.precision_bits ();
  validate_precision (precision);
  const std::size_t m = input.rows ();
  const std::size_t n = input.columns ();
  const std::size_t k = std::min (m, n);
  const std::size_t u_columns = economy ? k : m;
  const std::size_t vt_rows = economy ? k : n;
  const std::size_t s_rows = economy ? k : m;
  const std::size_t s_columns = economy ? k : n;

  MpcSvdResult result {
    MpfrComplexMatrixStorage (m, u_columns, precision),
    MpfrMatrixStorage (s_rows, s_columns, precision),
    MpfrComplexMatrixStorage (n, economy ? k : n, precision)
  };
  if (m == 0 || n == 0)
    return result;

  MpfrComplexMatrixStorage a_work =
    mplapack_mpc_matrix_copy_at_precision (input, precision);
  MpfrMatrixStorage singular_values (k, 1, precision);
  MpfrComplexMatrixStorage u (m, u_columns, precision);
  MpfrComplexMatrixStorage vt (vt_rows, n, precision);
  MpfrComplexMatrixStorage query_work (1, 1, precision);
  MpfrMatrixStorage rwork (5 * k, 1, precision);
  const char *job = economy ? "S" : "A";
  MpfrComplexMatrixStorage::MplapackInteger info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    require_complex_svd_precision_contract (
      precision, a_work, singular_values, u, vt, query_work, rwork);
    Cgesvd (job, job,
            MpfrComplexMatrixStorage::checked_mplapack_dimension (m),
            MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), singular_values.data (),
            u.data (), u.leading_dimension (), vt.data (), vt.leading_dimension (),
            query_work.data (), -1, rwork.data (), info);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK MPC Cgesvd changed the current-thread default precision");
  }
  if (info < 0)
    throw MpcSvdError (MpcSvdError::Kind::invalid_argument, -info,
                       "MPLAPACK Cgesvd rejected a workspace query argument");
  if (info > 0)
    throw MpcSvdError (MpcSvdError::Kind::convergence, info,
                       "MPLAPACK Cgesvd workspace query failed");

  const std::size_t lwork = checked_complex_workspace_length (
    query_work.at (0, 0), "MPLAPACK Cgesvd");
  MpfrComplexMatrixStorage work (lwork, 1, precision);
  a_work = mplapack_mpc_matrix_copy_at_precision (input, precision);
  singular_values = MpfrMatrixStorage (k, 1, precision);
  u = MpfrComplexMatrixStorage (m, u_columns, precision);
  vt = MpfrComplexMatrixStorage (vt_rows, n, precision);
  rwork = MpfrMatrixStorage (5 * k, 1, precision);
  info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    require_complex_svd_precision_contract (
      precision, a_work, singular_values, u, vt, work, rwork);
    Cgesvd (job, job,
            MpfrComplexMatrixStorage::checked_mplapack_dimension (m),
            MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), singular_values.data (),
            u.data (), u.leading_dimension (), vt.data (), vt.leading_dimension (),
            work.data (), static_cast<MpfrComplexMatrixStorage::MplapackInteger> (
              lwork), rwork.data (), info);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK MPC Cgesvd changed the current-thread default precision");
  }
  if (info < 0)
    throw MpcSvdError (MpcSvdError::Kind::invalid_argument, -info,
                       "MPLAPACK Cgesvd rejected an argument");
  if (info > 0)
    throw MpcSvdError (MpcSvdError::Kind::convergence, info,
                       "MPLAPACK Cgesvd failed to converge");

  result.u = std::move (u);
  result.s = MpfrMatrixStorage (s_rows, s_columns, precision);
  fill_real_s (result.s, singular_values);
  MpfrComplexMatrixStorage v (n, economy ? k : n, precision);
  fill_complex_v (v, vt);
  result.v = std::move (v);
  return result;
}

} // namespace octave_mplapack
