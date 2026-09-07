// SPDX-License-Identifier: BSD-2-Clause

#include "mp_det_inv.h"

#include <cmath>
#include <cstdint>
#include <limits>
#include <stdexcept>
#include <vector>

#include <gmp.h>
#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>

#include "mp_complex_blas.h"
#include "mp_complex_precision.h"

namespace
{

using octave_mplapack::MpfrComplexMatrixStorage;
using octave_mplapack::MpfrMatrixStorage;

void
validate_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument (
      "MPLAPACK determinant/inverse precision is outside MPFR limits");
}

std::size_t
checked_workspace_length (const mpfrxx::mpfr_class& query)
{
  if (mpfr_nan_p (query.mpfr_data ()) != 0
      || mpfr_inf_p (query.mpfr_data ()) != 0
      || mpfr_integer_p (query.mpfr_data ()) == 0
      || mpfr_sgn (query.mpfr_data ()) <= 0)
    throw std::runtime_error (
      "MPLAPACK inverse returned an invalid workspace query");

  mpz_t value;
  mpz_t maximum;
  mpz_init (value);
  mpz_init (maximum);
  mpfr_get_z (value, query.mpfr_data (), MPFR_RNDZ);
  const auto limit = std::numeric_limits<std::size_t>::max ();
  mpz_import (maximum, 1, -1, sizeof (limit), 0, 0, &limit);
  const bool fits = mpz_cmp (value, maximum) <= 0;
  if (! fits)
    {
      mpz_clear (value);
      mpz_clear (maximum);
      throw std::overflow_error (
        "MPLAPACK inverse workspace exceeds allocation limits");
    }
  const auto result = static_cast<std::size_t> (
    mpfr_get_uj (query.mpfr_data (), MPFR_RNDZ));
  mpz_clear (value);
  mpz_clear (maximum);
  return result;
}

struct RealFactorization
{
  MpfrMatrixStorage factors;
  std::vector<MpfrMatrixStorage::MplapackInteger> pivots;
  MpfrMatrixStorage::MplapackInteger info;
};

RealFactorization
factor_real (const MpfrMatrixStorage& input)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  validate_precision (precision_bits);
  const std::size_t n = input.rows ();
  MpfrMatrixStorage factors (n, n, precision_bits, input);
  std::vector<MpfrMatrixStorage::MplapackInteger> pivots (n);
  MpfrMatrixStorage::MplapackInteger info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision_bits);
    if (mpfrxx::default_precision_bits () != precision_bits
        || factors.precision_bits () != precision_bits
        || ! factors.all_elements_have_uniform_precision ())
      throw std::runtime_error (
        "MPLAPACK MPFR precision contract mismatch at Rgetrf boundary");
    Rgetrf (MpfrMatrixStorage::checked_mplapack_dimension (n),
            MpfrMatrixStorage::checked_mplapack_dimension (n), factors.data (),
            factors.leading_dimension (), pivots.data (), info);
    if (mpfrxx::default_precision_bits () != precision_bits)
      throw std::runtime_error (
        "MPLAPACK Rgetrf changed the current-thread default precision");
  }
  if (info < 0)
    throw octave_mplapack::MpfrDetInvError (
      octave_mplapack::MpfrDetInvError::Kind::invalid_argument, info,
      "MPLAPACK Rgetrf rejected an argument");
  if (info > static_cast<MpfrMatrixStorage::MplapackInteger> (n))
    throw octave_mplapack::MpfrDetInvError (
      octave_mplapack::MpfrDetInvError::Kind::internal, info,
      "MPLAPACK Rgetrf returned an invalid INFO value");
  return {std::move (factors), std::move (pivots), info};
}

struct ComplexFactorization
{
  MpfrComplexMatrixStorage factors;
  std::vector<MpfrComplexMatrixStorage::MplapackInteger> pivots;
  MpfrComplexMatrixStorage::MplapackInteger info;
};

ComplexFactorization
factor_complex (const MpfrComplexMatrixStorage& input)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  validate_precision (precision_bits);
  const std::size_t n = input.rows ();
  auto factors = octave_mplapack::mplapack_mpc_matrix_copy_at_precision (
    input, precision_bits);
  std::vector<MpfrComplexMatrixStorage::MplapackInteger> pivots (n);
  MpfrComplexMatrixStorage::MplapackInteger info = 0;
  {
    octave_mplapack::MpfrMpcPrecisionScope scope (precision_bits);
    const auto override_state = mpfrxx::mpc_precision_override_storage ();
    if (mpfrxx::default_precision_bits () != precision_bits
        || ! override_state.active
        || override_state.real_precision_bits != precision_bits
        || override_state.imag_precision_bits != precision_bits
        || factors.precision_bits () != precision_bits
        || ! factors.all_elements_have_uniform_precision ())
      throw std::runtime_error (
        "MPLAPACK MPC precision contract mismatch at Cgetrf boundary");
    Cgetrf (MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            factors.data (), factors.leading_dimension (), pivots.data (),
            info);
    const auto after = mpfrxx::mpc_precision_override_storage ();
    if (mpfrxx::default_precision_bits () != precision_bits
        || ! after.active || after.real_precision_bits != precision_bits
        || after.imag_precision_bits != precision_bits)
      throw std::runtime_error (
        "MPLAPACK Cgetrf changed the current-thread precision");
  }
  if (info < 0)
    throw octave_mplapack::MpcDetInvError (
      octave_mplapack::MpcDetInvError::Kind::invalid_argument, info,
      "MPLAPACK Cgetrf rejected an argument");
  if (info > static_cast<MpfrComplexMatrixStorage::MplapackInteger> (n))
    throw octave_mplapack::MpcDetInvError (
      octave_mplapack::MpcDetInvError::Kind::internal, info,
      "MPLAPACK Cgetrf returned an invalid INFO value");
  return {std::move (factors), std::move (pivots), info};
}

void
require_real_inverse_contract (mpfr_prec_t precision_bits,
                               const MpfrMatrixStorage& factors,
                               const MpfrMatrixStorage& work)
{
  if (mpfrxx::default_precision_bits () != precision_bits
      || factors.precision_bits () != precision_bits
      || work.precision_bits () != precision_bits
      || ! factors.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ())
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at Rgetri boundary");
}

void
require_complex_inverse_contract (mpfr_prec_t precision_bits,
                                  const MpfrComplexMatrixStorage& factors,
                                  const MpfrComplexMatrixStorage& work)
{
  const auto state = mpfrxx::mpc_precision_override_storage ();
  if (mpfrxx::default_precision_bits () != precision_bits || ! state.active
      || state.real_precision_bits != precision_bits
      || state.imag_precision_bits != precision_bits
      || factors.precision_bits () != precision_bits
      || work.precision_bits () != precision_bits
      || ! factors.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ())
    throw std::runtime_error (
      "MPLAPACK MPC precision contract mismatch at Cgetri boundary");
}

std::size_t
checked_complex_workspace_length (
  const MpfrComplexMatrixStorage::NativeScalar& query,
  mpfr_prec_t precision_bits)
{
  if (mpfr_nan_p (mpc_imagref (query.mpc_data ())) != 0
      || mpfr_zero_p (mpc_imagref (query.mpc_data ())) == 0)
    throw std::runtime_error (
      "MPLAPACK complex inverse returned a non-real workspace query");
  auto real_query = mpfrxx::mpfr_class::with_precision (precision_bits);
  mpfr_set (real_query.mpfr_data (), mpc_realref (query.mpc_data ()),
            MPFR_RNDN);
  return checked_workspace_length (real_query);
}

void
set_real_one (mpfrxx::mpfr_class& value)
{
  mpfr_set_ui (value.mpfr_data (), 1, MPFR_RNDN);
}

void
set_complex_one (mpfrxx::mpc_class& value)
{
  mpc_set_ui_ui (value.mpc_data (), 1, 0, MPC_RND (MPFR_RNDN, MPFR_RNDN));
}

} // namespace

namespace octave_mplapack
{

MpfrScalarStorage
mplapack_mpfr_matrix_det (const MpfrMatrixStorage& input)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument ("det requires a square matrix");
  const mpfr_prec_t precision_bits = input.precision_bits ();
  validate_precision (precision_bits);
  if (input.rows () == 0)
    {
      auto value = mpfrxx::mpfr_class::with_precision (precision_bits);
      set_real_one (value);
      return MpfrScalarStorage (std::move (value));
    }

  const auto factorization = factor_real (input);
  auto determinant = mpfrxx::mpfr_class::with_precision (precision_bits);
  if (factorization.info > 0)
    mpfr_set_zero (determinant.mpfr_data (), 1);
  else
    {
      set_real_one (determinant);
      const std::size_t n = input.rows ();
      for (std::size_t index = 0; index < n; ++index)
        mpfr_mul (determinant.mpfr_data (), determinant.mpfr_data (),
                  factorization.factors.at (index, index).mpfr_data (),
                  MPFR_RNDN);
      bool odd = false;
      for (std::size_t index = 0; index < n; ++index)
        if (factorization.pivots[index]
            != static_cast<MpfrMatrixStorage::MplapackInteger> (index + 1))
          odd = ! odd;
      if (odd)
        mpfr_neg (determinant.mpfr_data (), determinant.mpfr_data (),
                  MPFR_RNDN);
    }
  return MpfrScalarStorage (std::move (determinant));
}

MpfrMatrixStorage
mplapack_mpfr_matrix_inverse (const MpfrMatrixStorage& input)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument ("inv requires a square matrix");
  const mpfr_prec_t precision_bits = input.precision_bits ();
  validate_precision (precision_bits);
  const std::size_t n = input.rows ();
  if (n == 0)
    return MpfrMatrixStorage (0, 0, precision_bits);

  auto first = factor_real (input);
  if (first.info > 0)
    throw MpfrDetInvError (MpfrDetInvError::Kind::singular, first.info,
                           "MPLAPACK Rgetrf reported a singular matrix");

  MpfrMatrixStorage query_work (1, 1, precision_bits);
  MpfrMatrixStorage::MplapackInteger query_info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision_bits);
    require_real_inverse_contract (precision_bits, first.factors, query_work);
    Rgetri (MpfrMatrixStorage::checked_mplapack_dimension (n),
            first.factors.data (), first.factors.leading_dimension (),
            first.pivots.data (), query_work.data (), -1, query_info);
    require_real_inverse_contract (precision_bits, first.factors, query_work);
  }
  if (query_info != 0)
    throw MpfrDetInvError (query_info < 0
                             ? MpfrDetInvError::Kind::invalid_argument
                             : MpfrDetInvError::Kind::internal,
                           query_info,
                           "MPLAPACK Rgetri workspace query failed");
  const std::size_t lwork = checked_workspace_length (query_work.at (0, 0));

  // Re-factor after the query because LAPACK work-query calls are not part of
  // the public operation and are not relied upon to preserve factor storage.
  auto factorization = factor_real (input);
  MpfrMatrixStorage work (lwork, 1, precision_bits);
  MpfrMatrixStorage::MplapackInteger info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision_bits);
    require_real_inverse_contract (precision_bits, factorization.factors,
                                   work);
    Rgetri (MpfrMatrixStorage::checked_mplapack_dimension (n),
            factorization.factors.data (), factorization.factors.leading_dimension (),
            factorization.pivots.data (), work.data (),
            static_cast<MpfrMatrixStorage::MplapackInteger> (lwork), info);
    require_real_inverse_contract (precision_bits, factorization.factors, work);
  }
  if (info > 0)
    throw MpfrDetInvError (MpfrDetInvError::Kind::singular, info,
                           "MPLAPACK Rgetri reported a singular matrix");
  if (info < 0)
    throw MpfrDetInvError (MpfrDetInvError::Kind::invalid_argument, info,
                           "MPLAPACK Rgetri rejected an argument");
  return std::move (factorization.factors);
}

MpfrComplexScalarStorage
mplapack_mpc_matrix_det (const MpfrComplexMatrixStorage& input)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument ("det requires a square matrix");
  const mpfr_prec_t precision_bits = input.precision_bits ();
  validate_precision (precision_bits);
  if (input.rows () == 0)
    {
      auto value = mpfrxx::mpc_class::with_precision (precision_bits);
      set_complex_one (value);
      return MpfrComplexScalarStorage (std::move (value));
    }

  const auto factorization = factor_complex (input);
  auto determinant = mpfrxx::mpc_class::with_precision (precision_bits);
  if (factorization.info > 0)
    mpc_set_ui_ui (determinant.mpc_data (), 0, 0,
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
  else
    {
      set_complex_one (determinant);
      const std::size_t n = input.rows ();
      for (std::size_t index = 0; index < n; ++index)
        mpc_mul (determinant.mpc_data (), determinant.mpc_data (),
                 factorization.factors.at (index, index).mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
      bool odd = false;
      for (std::size_t index = 0; index < n; ++index)
        if (factorization.pivots[index]
            != static_cast<MpfrComplexMatrixStorage::MplapackInteger> (index + 1))
          odd = ! odd;
      if (odd)
        mpc_neg (determinant.mpc_data (), determinant.mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
    }
  return MpfrComplexScalarStorage (std::move (determinant));
}

MpfrComplexMatrixStorage
mplapack_mpc_matrix_inverse (const MpfrComplexMatrixStorage& input)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument ("inv requires a square matrix");
  const mpfr_prec_t precision_bits = input.precision_bits ();
  validate_precision (precision_bits);
  const std::size_t n = input.rows ();
  if (n == 0)
    return MpfrComplexMatrixStorage (0, 0, precision_bits);

  auto first = factor_complex (input);
  if (first.info > 0)
    throw MpcDetInvError (MpcDetInvError::Kind::singular, first.info,
                          "MPLAPACK Cgetrf reported a singular matrix");

  MpfrComplexMatrixStorage query_work (1, 1, precision_bits);
  MpfrComplexMatrixStorage::MplapackInteger query_info = 0;
  {
    MpfrMpcPrecisionScope scope (precision_bits);
    require_complex_inverse_contract (precision_bits, first.factors,
                                      query_work);
    Cgetri (MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            first.factors.data (), first.factors.leading_dimension (),
            first.pivots.data (), query_work.data (), -1, query_info);
    require_complex_inverse_contract (precision_bits, first.factors,
                                     query_work);
  }
  if (query_info != 0)
    throw MpcDetInvError (query_info < 0
                            ? MpcDetInvError::Kind::invalid_argument
                            : MpcDetInvError::Kind::internal,
                          query_info,
                          "MPLAPACK Cgetri workspace query failed");
  const std::size_t lwork = checked_complex_workspace_length (
    query_work.at (0, 0), precision_bits);

  auto factorization = factor_complex (input);
  MpfrComplexMatrixStorage work (lwork, 1, precision_bits);
  MpfrComplexMatrixStorage::MplapackInteger info = 0;
  {
    MpfrMpcPrecisionScope scope (precision_bits);
    require_complex_inverse_contract (precision_bits, factorization.factors,
                                      work);
    Cgetri (MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            factorization.factors.data (), factorization.factors.leading_dimension (),
            factorization.pivots.data (), work.data (),
            static_cast<MpfrComplexMatrixStorage::MplapackInteger> (lwork),
            info);
    require_complex_inverse_contract (precision_bits, factorization.factors,
                                      work);
  }
  if (info > 0)
    throw MpcDetInvError (MpcDetInvError::Kind::singular, info,
                          "MPLAPACK Cgetri reported a singular matrix");
  if (info < 0)
    throw MpcDetInvError (MpcDetInvError::Kind::invalid_argument, info,
                          "MPLAPACK Cgetri rejected an argument");
  return std::move (factorization.factors);
}

} // namespace octave_mplapack
