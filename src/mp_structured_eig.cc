// SPDX-License-Identifier: BSD-2-Clause

#include "mp_structured_eig.h"

#include <algorithm>
#include <cstddef>
#include <limits>
#include <mpfr.h>
#include <stdexcept>
#include <string>
#include <vector>

#include <gmp.h>
#include <mplapack_mpfr.h>

#include "mp_complex_precision.h"
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
    throw std::invalid_argument (
      "MPLAPACK structured eig precision is outside MPFR limits");
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
checked_integer_workspace_length (MpfrMatrixStorage::MplapackInteger value,
                                  const char *routine)
{
  if (value <= 0)
    throw std::runtime_error (std::string (routine)
                              + " returned an invalid integer workspace query");
  return static_cast<std::size_t> (value);
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

bool
is_exactly_symmetric (const MpfrMatrixStorage& input)
{
  for (std::size_t column = 0; column < input.columns (); ++column)
    for (std::size_t row = column + 1; row < input.rows (); ++row)
      if (mpfr_equal_p (input.at (row, column).mpfr_data (),
                        input.at (column, row).mpfr_data ()) == 0)
        return false;
  return true;
}

bool
is_exactly_hermitian (const MpfrComplexMatrixStorage& input)
{
  for (std::size_t column = 0; column < input.columns (); ++column)
    {
      if (mpfr_zero_p (mpc_imagref (input.at (column, column).mpc_data ()))
          == 0)
        return false;
      for (std::size_t row = column + 1; row < input.rows (); ++row)
        {
          const auto& lhs = input.at (row, column);
          const auto& rhs = input.at (column, row);
          if (mpfr_equal_p (mpc_realref (lhs.mpc_data ()),
                            mpc_realref (rhs.mpc_data ())) == 0)
            return false;
          auto negated_imag = MpfrScalarStorage::NativeScalar::with_precision (
            lhs.imag_precision ());
          mpfr_neg (negated_imag.mpfr_data (),
                    mpc_imagref (lhs.mpc_data ()), MPFR_RNDN);
          if (mpfr_equal_p (negated_imag.mpfr_data (),
                            mpc_imagref (rhs.mpc_data ())) == 0)
            return false;
        }
    }
  return true;
}

void
require_real_contract (mpfr_prec_t precision, const MpfrMatrixStorage& a,
                       const MpfrMatrixStorage& w,
                       const MpfrMatrixStorage& work)
{
  if (mpfrxx::default_precision_bits () != precision
      || a.precision_bits () != precision || w.precision_bits () != precision
      || work.precision_bits () != precision
      || ! a.all_elements_have_uniform_precision ()
      || ! w.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ())
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at Rsyevd boundary");
}

void
require_complex_contract (mpfr_prec_t precision,
                          const MpfrComplexMatrixStorage& a,
                          const MpfrMatrixStorage& w,
                          const MpfrComplexMatrixStorage& work,
                          const MpfrMatrixStorage& rwork)
{
  const auto state = mpfrxx::mpc_precision_override_storage ();
  if (mpfrxx::default_precision_bits () != precision
      || ! state.active || state.real_precision_bits != precision
      || state.imag_precision_bits != precision
      || a.precision_bits () != precision || w.precision_bits () != precision
      || work.precision_bits () != precision
      || rwork.precision_bits () != precision
      || ! a.all_elements_have_uniform_precision ()
      || ! w.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ()
      || ! rwork.all_elements_have_uniform_precision ())
    throw std::runtime_error (
      "MPLAPACK MPC precision contract mismatch at Cheevd boundary");
}

void
fill_diagonal (MpfrMatrixStorage& diagonal,
               const MpfrMatrixStorage& eigenvalues)
{
  for (std::size_t column = 0; column < diagonal.columns (); ++column)
    for (std::size_t row = 0; row < diagonal.rows (); ++row)
      {
        if (row == column)
          mpfr_set (diagonal.at (row, column).mpfr_data (),
                    eigenvalues.at (row, 0).mpfr_data (), MPFR_RNDN);
        else
          mpfr_set_zero (diagonal.at (row, column).mpfr_data (), 1);
      }
}

} // namespace

namespace octave_mplapack
{

MpfrStructuredEigResult
mplapack_mpfr_matrix_structured_eig (const MpfrMatrixStorage& input)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument (
      "structured eig requires a square real matrix");
  if (! is_exactly_symmetric (input))
    throw std::invalid_argument (
      "eig currently requires an exactly symmetric real mp matrix");

  const mpfr_prec_t precision = input.precision_bits ();
  validate_precision (precision);
  const std::size_t n = input.rows ();
  MpfrStructuredEigResult result {
    MpfrMatrixStorage (n, 1, precision),
    MpfrMatrixStorage (n, n, precision),
    MpfrMatrixStorage (n, n, precision)
  };
  if (n == 0)
    return result;

  MpfrMatrixStorage a_work (n, n, precision, input);
  MpfrMatrixStorage query_w (n, 1, precision);
  MpfrMatrixStorage query_work (1, 1, precision);
  std::vector<MpfrMatrixStorage::MplapackInteger> query_iwork (1);
  MpfrMatrixStorage::MplapackInteger info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    require_real_contract (precision, a_work, query_w, query_work);
    Rsyevd ("V", "U", MpfrMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), query_w.data (),
            query_work.data (), -1, query_iwork.data (), -1, info);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK Rsyevd changed the current-thread default precision");
  }
  if (info < 0)
    throw MpfrStructuredEigError (
      -static_cast<int> (info), "MPLAPACK Rsyevd rejected a workspace query");
  if (info > 0)
    throw MpfrStructuredEigError (
      static_cast<int> (info), "MPLAPACK Rsyevd workspace query failed");

  const std::size_t lwork
    = checked_workspace_length (query_work.at (0, 0), "MPLAPACK Rsyevd");
  const std::size_t liwork = checked_integer_workspace_length (
    query_iwork.at (0), "MPLAPACK Rsyevd");
  MpfrMatrixStorage work (lwork, 1, precision);
  a_work = MpfrMatrixStorage (n, n, precision, input);
  MpfrMatrixStorage eigenvalues (n, 1, precision);
  std::vector<MpfrMatrixStorage::MplapackInteger> iwork (liwork);
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    require_real_contract (precision, a_work, eigenvalues, work);
    Rsyevd ("V", "U", MpfrMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), eigenvalues.data (),
            work.data (), static_cast<MpfrMatrixStorage::MplapackInteger> (lwork),
            iwork.data (), static_cast<MpfrMatrixStorage::MplapackInteger> (liwork),
            info);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK Rsyevd changed the current-thread default precision");
  }
  if (info != 0)
    throw MpfrStructuredEigError (
      static_cast<int> (info), info < 0 ? "MPLAPACK Rsyevd rejected an argument"
                                       : "MPLAPACK Rsyevd failed to converge");

  result.eigenvalues = std::move (eigenvalues);
  result.vectors = std::move (a_work);
  fill_diagonal (result.diagonal, result.eigenvalues);
  return result;
}

MpcStructuredEigResult
mplapack_mpc_matrix_structured_eig (const MpfrComplexMatrixStorage& input)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument (
      "structured eig requires a square complex matrix");
  if (! is_exactly_hermitian (input))
    throw std::invalid_argument (
      "eig currently requires an exactly Hermitian complex mp matrix");

  const mpfr_prec_t precision = input.precision_bits ();
  validate_precision (precision);
  const std::size_t n = input.rows ();
  MpcStructuredEigResult result {
    MpfrMatrixStorage (n, 1, precision),
    MpfrComplexMatrixStorage (n, n, precision),
    MpfrMatrixStorage (n, n, precision)
  };
  if (n == 0)
    return result;

  MpfrComplexMatrixStorage a_work = input;
  MpfrMatrixStorage query_w (n, 1, precision);
  MpfrComplexMatrixStorage query_work (1, 1, precision);
  MpfrMatrixStorage query_rwork (1, 1, precision);
  std::vector<MpfrComplexMatrixStorage::MplapackInteger> query_iwork (1);
  MpfrComplexMatrixStorage::MplapackInteger info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    require_complex_contract (precision, a_work, query_w, query_work,
                              query_rwork);
    Cheevd ("V", "U", MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), query_w.data (),
            query_work.data (), -1, query_rwork.data (), -1,
            query_iwork.data (), -1, info);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK Cheevd changed the current-thread default precision");
  }
  if (info < 0)
    throw MpcStructuredEigError (
      -static_cast<int> (info), "MPLAPACK Cheevd rejected a workspace query");
  if (info > 0)
    throw MpcStructuredEigError (
      static_cast<int> (info), "MPLAPACK Cheevd workspace query failed");

  const std::size_t lwork = checked_complex_workspace_length (
    query_work.at (0, 0), "MPLAPACK Cheevd");
  const std::size_t lrwork = checked_workspace_length (
    query_rwork.at (0, 0), "MPLAPACK Cheevd real workspace");
  const std::size_t liwork = checked_integer_workspace_length (
    query_iwork.at (0), "MPLAPACK Cheevd");
  MpfrComplexMatrixStorage work (lwork, 1, precision);
  MpfrMatrixStorage rwork (lrwork, 1, precision);
  MpfrComplexMatrixStorage::MplapackInteger info2 = 0;
  std::vector<MpfrComplexMatrixStorage::MplapackInteger> iwork (liwork);
  a_work = input;
  MpfrMatrixStorage eigenvalues (n, 1, precision);
  {
    MpfrMpcPrecisionScope scope (precision);
    require_complex_contract (precision, a_work, eigenvalues, work, rwork);
    Cheevd ("V", "U", MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), eigenvalues.data (),
            work.data (), static_cast<MpfrComplexMatrixStorage::MplapackInteger> (lwork),
            rwork.data (), static_cast<MpfrComplexMatrixStorage::MplapackInteger> (lrwork),
            iwork.data (), static_cast<MpfrComplexMatrixStorage::MplapackInteger> (liwork),
            info2);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK Cheevd changed the current-thread default precision");
  }
  if (info2 != 0)
    throw MpcStructuredEigError (
      static_cast<int> (info2), info2 < 0 ? "MPLAPACK Cheevd rejected an argument"
                                         : "MPLAPACK Cheevd failed to converge");

  result.eigenvalues = std::move (eigenvalues);
  result.vectors = std::move (a_work);
  fill_diagonal (result.diagonal, result.eigenvalues);
  return result;
}

} // namespace octave_mplapack
