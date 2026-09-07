// SPDX-License-Identifier: BSD-2-Clause

#include "mp_rank_condition.h"

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <limits>
#include <optional>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#include <gmp.h>
#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>

#include "mp_complex_blas.h"
#include "mp_complex_precision.h"
#include "mp_norm.h"

namespace
{

using octave_mplapack::MpfrComplexMatrixStorage;
using octave_mplapack::MpfrConditionKind;
using octave_mplapack::MpfrMatrixStorage;
using octave_mplapack::MpfrScalarStorage;

void
validate_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument (
      "MPLAPACK rank/condition precision is outside MPFR limits");
}

MpfrMatrixStorage
copy_real_at_precision (const MpfrMatrixStorage& source,
                        mpfr_prec_t precision_bits)
{
  validate_precision (precision_bits);
  MpfrMatrixStorage result (source.rows (), source.columns (), precision_bits);
  for (std::size_t index = 0; index < source.numel (); ++index)
    mpfr_set (result.data ()[index].mpfr_data (),
              source.data ()[index].mpfr_data (), MPFR_RNDN);
  return result;
}

MpfrScalarStorage::NativeScalar
make_zero (mpfr_prec_t precision_bits)
{
  auto result = MpfrScalarStorage::NativeScalar::with_precision (
    precision_bits);
  mpfr_set_zero (result.mpfr_data (), 1);
  return result;
}

MpfrScalarStorage::NativeScalar
make_infinity (mpfr_prec_t precision_bits)
{
  auto result = MpfrScalarStorage::NativeScalar::with_precision (
    precision_bits);
  mpfr_set_inf (result.mpfr_data (), 1);
  return result;
}

void
set_nonnegative_product (mpfrxx::mpfr_class& result, std::size_t dimension,
                         const mpfrxx::mpfr_class& sigma_max,
                         const mpfrxx::mpfr_class& epsilon)
{
  mpfr_set_ui (result.mpfr_data (),
               static_cast<unsigned long> (dimension), MPFR_RNDN);
  mpfr_mul (result.mpfr_data (), result.mpfr_data (), sigma_max.mpfr_data (),
            MPFR_RNDN);
  mpfr_mul (result.mpfr_data (), result.mpfr_data (), epsilon.mpfr_data (),
            MPFR_RNDN);
}

template <typename Matrix>
MpfrScalarStorage
condition_from_singular_values (const Matrix& input, MpfrConditionKind kind,
                                const MpfrMatrixStorage& singular_values)
{
  const mpfr_prec_t precision_bits = input.precision_bits ();
  if (input.rows () == 0 || input.columns () == 0)
    return MpfrScalarStorage (make_zero (precision_bits));

  if (kind == MpfrConditionKind::two)
    {
      auto result = MpfrScalarStorage::NativeScalar::with_precision (
        precision_bits);
      mpfr_set (result.mpfr_data (),
                singular_values.at (0, 0).mpfr_data (), MPFR_RNDN);
      const auto last = std::min (input.rows (), input.columns ()) - 1;
      if (mpfr_zero_p (singular_values.at (last, 0).mpfr_data ()) != 0)
        mpfr_set_inf (result.mpfr_data (), 1);
      else
        mpfr_div (result.mpfr_data (), result.mpfr_data (),
                  singular_values.at (last, 0).mpfr_data (), MPFR_RNDN);
      return MpfrScalarStorage (std::move (result));
    }

  if (kind != MpfrConditionKind::frobenius)
    throw std::invalid_argument ("singular values do not provide this norm");

  auto left = MpfrScalarStorage::NativeScalar::with_precision (precision_bits);
  auto right = MpfrScalarStorage::NativeScalar::with_precision (precision_bits);
  mpfr_set_zero (left.mpfr_data (), 1);
  mpfr_set_zero (right.mpfr_data (), 1);
  for (std::size_t index = 0; index < singular_values.rows (); ++index)
    {
      const auto& sigma = singular_values.at (index, 0);
      if (mpfr_zero_p (sigma.mpfr_data ()) != 0)
        return MpfrScalarStorage (make_infinity (precision_bits));
      mpfr_fma (left.mpfr_data (), sigma.mpfr_data (), sigma.mpfr_data (),
                left.mpfr_data (), MPFR_RNDN);
      auto reciprocal = MpfrScalarStorage::NativeScalar::with_precision (
        precision_bits);
      mpfr_ui_div (reciprocal.mpfr_data (), 1, sigma.mpfr_data (),
                   MPFR_RNDN);
      mpfr_fma (right.mpfr_data (), reciprocal.mpfr_data (),
                reciprocal.mpfr_data (), right.mpfr_data (), MPFR_RNDN);
    }
  mpfr_sqrt (left.mpfr_data (), left.mpfr_data (), MPFR_RNDN);
  mpfr_sqrt (right.mpfr_data (), right.mpfr_data (), MPFR_RNDN);
  mpfr_mul (left.mpfr_data (), left.mpfr_data (), right.mpfr_data (),
            MPFR_RNDN);
  return MpfrScalarStorage (std::move (left));
}

template <typename Matrix>
MpfrMatrixStorage::MplapackInteger
rank_from_singular_values (const Matrix& input,
                           const MpfrScalarStorage *tolerance,
                           const MpfrMatrixStorage& singular_values)
{
  const mpfr_prec_t precision_bits = singular_values.precision_bits ();
  auto threshold = MpfrScalarStorage::NativeScalar::with_precision (
    precision_bits);
  if (tolerance)
    mpfr_set (threshold.mpfr_data (), tolerance->native_value ().mpfr_data (),
              MPFR_RNDN);
  else
    {
      auto epsilon = MpfrScalarStorage::NativeScalar::with_precision (
        precision_bits);
      {
        MplapackMpfrPrecisionScope scope (precision_bits);
        auto native_epsilon = Rlamch_mpfr ("E");
        mpfr_set (epsilon.mpfr_data (), native_epsilon.mpfr_data (),
                  MPFR_RNDN);
      }
      set_nonnegative_product (threshold,
                               std::max (input.rows (), input.columns ()),
                               singular_values.rows () == 0
                                 ? epsilon
                                 : singular_values.at (0, 0),
                               epsilon);
    }

  MpfrMatrixStorage::MplapackInteger result = 0;
  for (std::size_t index = 0; index < singular_values.rows (); ++index)
    if (mpfr_cmp (singular_values.at (index, 0).mpfr_data (),
                  threshold.mpfr_data ()) > 0)
      ++result;
  return result;
}

MpfrScalarStorage
real_gecon (const MpfrMatrixStorage& input, char norm_code)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument (
      "condition number norm requires a square matrix");
  const mpfr_prec_t precision_bits = input.precision_bits ();
  validate_precision (precision_bits);
  const std::size_t n = input.rows ();
  if (n == 0)
    return MpfrScalarStorage (make_infinity (precision_bits));

  auto factors = copy_real_at_precision (input, precision_bits);
  std::vector<MpfrMatrixStorage::MplapackInteger> pivots (n);
  MpfrMatrixStorage::MplapackInteger factor_info = 0;
  MpfrMatrixStorage norm_work (std::max<std::size_t> (n, 1), 1,
                               precision_bits);
  auto anorm = MpfrScalarStorage::NativeScalar::with_precision (
    precision_bits);
  {
    MplapackMpfrPrecisionScope scope (precision_bits);
    anorm = Rlange (&norm_code,
                    MpfrMatrixStorage::checked_mplapack_dimension (n),
                    MpfrMatrixStorage::checked_mplapack_dimension (n),
                    factors.data (), factors.leading_dimension (),
                    norm_work.data ());
  }
  factors = copy_real_at_precision (input, precision_bits);
  {
    MplapackMpfrPrecisionScope scope (precision_bits);
    Rgetrf (MpfrMatrixStorage::checked_mplapack_dimension (n),
            MpfrMatrixStorage::checked_mplapack_dimension (n), factors.data (),
            factors.leading_dimension (), pivots.data (), factor_info);
    if (mpfrxx::default_precision_bits () != precision_bits)
      throw std::runtime_error ("MPLAPACK Rgetrf changed current precision");
  }
  if (factor_info < 0)
    throw octave_mplapack::MpfrRankConditionError (
      octave_mplapack::MpfrRankConditionError::Kind::invalid_argument,
      factor_info, "MPLAPACK Rgetrf rejected a condition-number argument");

  // Rgecon's Rlacn2 vector, RHS vector, and two triangular-solve column-norm
  // areas occupy four contiguous blocks of n real values.
  MpfrMatrixStorage work (4 * n, 1, precision_bits);
  std::vector<MpfrMatrixStorage::MplapackInteger> iwork (n);
  auto rcond = MpfrScalarStorage::NativeScalar::with_precision (
    precision_bits);
  MpfrMatrixStorage::MplapackInteger info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision_bits);
    Rgecon (&norm_code, MpfrMatrixStorage::checked_mplapack_dimension (n),
            factors.data (), factors.leading_dimension (), anorm, rcond,
            work.data (), iwork.data (), info);
    if (mpfrxx::default_precision_bits () != precision_bits)
      throw std::runtime_error ("MPLAPACK Rgecon changed current precision");
  }
  if (info < 0)
    throw octave_mplapack::MpfrRankConditionError (
      octave_mplapack::MpfrRankConditionError::Kind::invalid_argument, info,
      "MPLAPACK Rgecon rejected a condition-number argument");
  return MpfrScalarStorage (std::move (rcond));
}

MpfrScalarStorage
complex_gecon (const MpfrComplexMatrixStorage& input, char norm_code)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument (
      "condition number norm requires a square matrix");
  const mpfr_prec_t precision_bits = input.precision_bits ();
  validate_precision (precision_bits);
  const std::size_t n = input.rows ();
  if (n == 0)
    return MpfrScalarStorage (make_infinity (precision_bits));

  auto factors = octave_mplapack::mplapack_mpc_matrix_copy_at_precision (
    input, precision_bits);
  std::vector<MpfrComplexMatrixStorage::MplapackInteger> pivots (n);
  MpfrComplexMatrixStorage::MplapackInteger factor_info = 0;
  MpfrMatrixStorage norm_work (std::max<std::size_t> (n, 1), 1,
                               precision_bits);
  auto anorm = MpfrScalarStorage::NativeScalar::with_precision (
    precision_bits);
  {
    octave_mplapack::MpfrMpcPrecisionScope scope (precision_bits);
    anorm = Clange (&norm_code,
                    MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
                    MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
                    factors.data (), factors.leading_dimension (),
                    norm_work.data ());
  }
  factors = octave_mplapack::mplapack_mpc_matrix_copy_at_precision (
    input, precision_bits);
  {
    octave_mplapack::MpfrMpcPrecisionScope scope (precision_bits);
    Cgetrf (MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            factors.data (), factors.leading_dimension (), pivots.data (),
            factor_info);
    if (mpfrxx::default_precision_bits () != precision_bits)
      throw std::runtime_error ("MPLAPACK Cgetrf changed current precision");
  }
  if (factor_info < 0)
    throw octave_mplapack::MpcRankConditionError (
      octave_mplapack::MpcRankConditionError::Kind::invalid_argument,
      factor_info, "MPLAPACK Cgetrf rejected a condition-number argument");

  MpfrComplexMatrixStorage work (2 * n, 1, precision_bits);
  MpfrMatrixStorage rwork (2 * n, 1, precision_bits);
  auto rcond = MpfrScalarStorage::NativeScalar::with_precision (
    precision_bits);
  MpfrComplexMatrixStorage::MplapackInteger info = 0;
  {
    octave_mplapack::MpfrMpcPrecisionScope scope (precision_bits);
    Cgecon (&norm_code,
            MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            factors.data (), factors.leading_dimension (), anorm, rcond,
            work.data (), rwork.data (), info);
    if (mpfrxx::default_precision_bits () != precision_bits)
      throw std::runtime_error ("MPLAPACK Cgecon changed current precision");
  }
  if (info < 0)
    throw octave_mplapack::MpcRankConditionError (
      octave_mplapack::MpcRankConditionError::Kind::invalid_argument, info,
      "MPLAPACK Cgecon rejected a condition-number argument");
  return MpfrScalarStorage (std::move (rcond));
}

template <typename Matrix>
MpfrScalarStorage
reciprocal_to_condition (const MpfrScalarStorage& reciprocal,
                         const Matrix& input)
{
  auto result = MpfrScalarStorage::NativeScalar::with_precision (
    input.precision_bits ());
  if (mpfr_zero_p (reciprocal.native_value ().mpfr_data ()) != 0)
    mpfr_set_inf (result.mpfr_data (), 1);
  else
    mpfr_ui_div (result.mpfr_data (), 1,
                 reciprocal.native_value ().mpfr_data (), MPFR_RNDN);
  return MpfrScalarStorage (std::move (result));
}

} // namespace

namespace octave_mplapack
{

MpfrMatrixStorage::MplapackInteger
mplapack_mpfr_matrix_rank (const MpfrMatrixStorage& input,
                           const MpfrScalarStorage *tolerance)
{
  const mpfr_prec_t operation_precision
    = std::max (input.precision_bits (),
                tolerance ? tolerance->precision_bits () : MPFR_PREC_MIN);
  validate_precision (operation_precision);
  auto work = copy_real_at_precision (input, operation_precision);
  std::optional<MpfrScalarStorage> promoted_tolerance;
  if (tolerance)
    {
      auto native = MpfrScalarStorage::NativeScalar::with_precision (
        operation_precision);
      mpfr_set (native.mpfr_data (), tolerance->native_value ().mpfr_data (),
                MPFR_RNDN);
      promoted_tolerance.emplace (std::move (native));
    }
  const auto singular_values = mplapack_mpfr_singular_values (work);
  return rank_from_singular_values (work,
                                    promoted_tolerance
                                      ? &*promoted_tolerance : nullptr,
                                    singular_values);
}

MpfrComplexMatrixStorage::MplapackInteger
mplapack_mpc_matrix_rank (const MpfrComplexMatrixStorage& input,
                          const MpfrScalarStorage *tolerance)
{
  const mpfr_prec_t operation_precision
    = std::max (input.precision_bits (),
                tolerance ? tolerance->precision_bits () : MPFR_PREC_MIN);
  validate_precision (operation_precision);
  auto work = mplapack_mpc_matrix_copy_at_precision (
    input, operation_precision);
  std::optional<MpfrScalarStorage> promoted_tolerance;
  if (tolerance)
    {
      auto native = MpfrScalarStorage::NativeScalar::with_precision (
        operation_precision);
      mpfr_set (native.mpfr_data (), tolerance->native_value ().mpfr_data (),
                MPFR_RNDN);
      promoted_tolerance.emplace (std::move (native));
    }
  const auto singular_values = mplapack_mpc_singular_values (work);
  return rank_from_singular_values (work,
                                    promoted_tolerance
                                      ? &*promoted_tolerance : nullptr,
                                    singular_values);
}

MpfrScalarStorage
mplapack_mpfr_matrix_condition (const MpfrMatrixStorage& input,
                                MpfrConditionKind kind)
{
  if ((kind == MpfrConditionKind::one
       || kind == MpfrConditionKind::infinity)
      && input.rows () != input.columns ())
    throw std::invalid_argument (
      "condition number norm requires a square matrix");
  if (kind == MpfrConditionKind::frobenius
      && input.rows () != input.columns ())
    throw std::invalid_argument (
      "Frobenius condition number requires a square matrix");
  if (kind == MpfrConditionKind::one || kind == MpfrConditionKind::infinity)
    {
      auto reciprocal = real_gecon (input,
                                    kind == MpfrConditionKind::one ? '1' : 'I');
      return reciprocal_to_condition (reciprocal, input);
    }
  return condition_from_singular_values (
    input, kind, mplapack_mpfr_singular_values (input));
}

MpfrScalarStorage
mplapack_mpc_matrix_condition (const MpfrComplexMatrixStorage& input,
                               MpfrConditionKind kind)
{
  if ((kind == MpfrConditionKind::one
       || kind == MpfrConditionKind::infinity)
      && input.rows () != input.columns ())
    throw std::invalid_argument (
      "condition number norm requires a square matrix");
  if (kind == MpfrConditionKind::frobenius
      && input.rows () != input.columns ())
    throw std::invalid_argument (
      "Frobenius condition number requires a square matrix");
  if (kind == MpfrConditionKind::one || kind == MpfrConditionKind::infinity)
    {
      auto reciprocal = complex_gecon (
        input, kind == MpfrConditionKind::one ? '1' : 'I');
      return reciprocal_to_condition (reciprocal, input);
    }
  return condition_from_singular_values (
    input, kind, mplapack_mpc_singular_values (input));
}

MpfrScalarStorage
mplapack_mpfr_matrix_rcond (const MpfrMatrixStorage& input)
{
  return real_gecon (input, '1');
}

MpfrScalarStorage
mplapack_mpc_matrix_rcond (const MpfrComplexMatrixStorage& input)
{
  return complex_gecon (input, '1');
}

} // namespace octave_mplapack
