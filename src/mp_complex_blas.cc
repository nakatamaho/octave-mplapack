// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_blas.h"

#include <algorithm>
#include <stdexcept>
#include <utility>

#include <mpblas_mpfr.h>

#include "mp_complex_precision.h"

namespace octave_mplapack
{

namespace
{

void
validate_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument (
      "MPLAPACK MPC precision is outside the MPFR range");
}

void
set_zero (MpfrComplexMatrixStorage& matrix)
{
  for (std::size_t index = 0; index < matrix.numel (); ++index)
    mpc_set_ui_ui (matrix.data ()[index].mpc_data (), 0, 0,
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
}

} // namespace

void
require_mplapack_mpc_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexScalarStorage& alpha,
  const MpfrComplexMatrixStorage& a_work,
  const MpfrComplexMatrixStorage& b_work,
  const MpfrComplexScalarStorage& beta,
  const MpfrComplexMatrixStorage& c)
{
  validate_precision (operation_precision);
  const auto precision_override = mpfrxx::mpc_precision_override_storage ();
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && precision_override.active
      && precision_override.real_precision_bits == operation_precision
      && precision_override.imag_precision_bits == operation_precision
      && alpha.precision_bits () == operation_precision
      && beta.precision_bits () == operation_precision
      && a_work.precision_bits () == operation_precision
      && b_work.precision_bits () == operation_precision
      && c.precision_bits () == operation_precision
      && a_work.all_elements_have_uniform_precision ()
      && b_work.all_elements_have_uniform_precision ()
      && c.all_elements_have_uniform_precision ();
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK complex precision contract mismatch at Cgemm boundary");
}

MpfrComplexMatrixStorage
mplapack_mpc_matrix_copy_at_precision (
  const MpfrComplexMatrixStorage& source,
  mpfr_prec_t precision_bits)
{
  validate_precision (precision_bits);
  MpfrMpcPrecisionScope scope (precision_bits);
  MpfrComplexMatrixStorage result (source.rows (), source.columns (),
                                   precision_bits);
  for (std::size_t index = 0; index < source.numel (); ++index)
    mpc_set (result.data ()[index].mpc_data (),
             source.data ()[index].mpc_data (),
             MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

MpfrComplexMatrixStorage
mplapack_mpc_matrix_from_real (const MpfrMatrixStorage& source,
                               mpfr_prec_t precision_bits)
{
  validate_precision (precision_bits);
  MpfrMpcPrecisionScope scope (precision_bits);
  MpfrComplexMatrixStorage result (source.rows (), source.columns (),
                                   precision_bits);
  for (std::size_t index = 0; index < source.numel (); ++index)
    mpc_set_fr (result.data ()[index].mpc_data (),
                source.data ()[index].mpfr_data (),
                MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

MpfrComplexScalarStorage
mplapack_mpc_scalar_copy_at_precision (
  const MpfrComplexScalarStorage& source,
  mpfr_prec_t precision_bits)
{
  validate_precision (precision_bits);
  MpfrMpcPrecisionScope scope (precision_bits);
  MpfrComplexScalarStorage::NativeScalar result
    = MpfrComplexScalarStorage::NativeScalar::with_precision (precision_bits);
  mpc_set (result.mpc_data (), source.native_value ().mpc_data (),
           MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return MpfrComplexScalarStorage (std::move (result));
}

MpfrComplexScalarStorage
mplapack_mpc_scalar_from_real (const MpfrScalarStorage& source,
                               mpfr_prec_t precision_bits)
{
  validate_precision (precision_bits);
  MpfrMpcPrecisionScope scope (precision_bits);
  MpfrComplexScalarStorage::NativeScalar result
    = MpfrComplexScalarStorage::NativeScalar::with_precision (precision_bits);
  mpc_set_fr (result.mpc_data (), source.native_value ().mpfr_data (),
              MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return MpfrComplexScalarStorage (std::move (result));
}

MpfrComplexMatrixStorage
mplapack_mpc_matrix_multiply (const MpfrComplexMatrixStorage& lhs,
                              const MpfrComplexMatrixStorage& rhs)
{
  if (lhs.columns () != rhs.rows ())
    throw std::invalid_argument ("complex matrix multiplication dimension mismatch");

  const mpfr_prec_t operation_precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());
  validate_precision (operation_precision);
  auto a_work = mplapack_mpc_matrix_copy_at_precision (lhs,
                                                       operation_precision);
  auto b_work = mplapack_mpc_matrix_copy_at_precision (rhs,
                                                       operation_precision);
  MpfrComplexMatrixStorage result (lhs.rows (), rhs.columns (),
                                   operation_precision);
  if (result.numel () == 0 || lhs.columns () == 0)
    {
      set_zero (result);
      return result;
    }

  MpfrComplexScalarStorage alpha (1.0, 0.0, operation_precision);
  MpfrComplexScalarStorage beta (0.0, 0.0, operation_precision);
  MpfrMpcPrecisionScope scope (operation_precision);
  require_mplapack_mpc_precision_contract (
    operation_precision, alpha, a_work, b_work, beta, result);
  Cgemm ("N", "N",
         MpfrComplexMatrixStorage::checked_mplapack_dimension (lhs.rows ()),
         MpfrComplexMatrixStorage::checked_mplapack_dimension (rhs.columns ()),
         MpfrComplexMatrixStorage::checked_mplapack_dimension (lhs.columns ()),
         alpha.native_value (), a_work.data (), a_work.leading_dimension (),
         b_work.data (), b_work.leading_dimension (), beta.native_value (),
         result.data (), result.leading_dimension ());
  if (mpfrxx::default_precision_bits () != operation_precision)
    throw std::runtime_error (
      "MPLAPACK Cgemm changed the current-thread default precision");
  return result;
}

MpfrComplexMatrixStorage
mplapack_mpc_matrix_scale (const MpfrComplexMatrixStorage& matrix,
                           const MpfrComplexScalarStorage& scalar)
{
  const mpfr_prec_t operation_precision
    = std::max (matrix.precision_bits (), scalar.precision_bits ());
  validate_precision (operation_precision);
  auto matrix_work = mplapack_mpc_matrix_copy_at_precision (
    matrix, operation_precision);
  auto scalar_work = mplapack_mpc_scalar_copy_at_precision (
    scalar, operation_precision);
  MpfrMpcPrecisionScope scope (operation_precision);
  MpfrComplexMatrixStorage result (matrix.rows (), matrix.columns (),
                                   operation_precision);
  for (std::size_t index = 0; index < result.numel (); ++index)
    mpc_mul (result.data ()[index].mpc_data (),
             matrix_work.data ()[index].mpc_data (),
             scalar_work.native_value ().mpc_data (),
             MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

MpfrComplexScalarStorage
mplapack_mpc_scalar_multiply (const MpfrComplexScalarStorage& lhs,
                             const MpfrComplexScalarStorage& rhs)
{
  const mpfr_prec_t operation_precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());
  validate_precision (operation_precision);
  auto lhs_work = mplapack_mpc_scalar_copy_at_precision (
    lhs, operation_precision);
  auto rhs_work = mplapack_mpc_scalar_copy_at_precision (
    rhs, operation_precision);
  MpfrMpcPrecisionScope scope (operation_precision);
  MpfrComplexScalarStorage::NativeScalar result
    = MpfrComplexScalarStorage::NativeScalar::with_precision (
        operation_precision);
  mpc_mul (result.mpc_data (), lhs_work.native_value ().mpc_data (),
           rhs_work.native_value ().mpc_data (),
           MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return MpfrComplexScalarStorage (std::move (result));
}

} // namespace octave_mplapack
