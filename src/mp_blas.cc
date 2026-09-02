// SPDX-License-Identifier: BSD-2-Clause

#include "mp_blas.h"

#include <algorithm>
#include <stdexcept>

#include <mpblas_mpfr.h>

namespace
{

void
validate_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument ("MPLAPACK MPFR precision is outside the MPFR range");
}

void
set_zero (octave_mplapack::MpfrMatrixStorage& matrix)
{
  for (std::size_t index = 0; index < matrix.numel (); ++index)
    mpfr_set_zero (matrix.data ()[index].mpfr_data (), 1);
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

} // namespace

namespace octave_mplapack
{

void
require_mplapack_mpfr_precision_contract (
  mpfr_prec_t operation_precision,
  const mpfrxx::mpfr_class& alpha,
  const MpfrMatrixStorage& a_work,
  const MpfrMatrixStorage& b_work,
  const mpfrxx::mpfr_class& beta,
  const MpfrMatrixStorage& c)
{
  validate_precision (operation_precision);
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && alpha.precision () == operation_precision
      && beta.precision () == operation_precision
      && a_work.precision_bits () == operation_precision
      && b_work.precision_bits () == operation_precision
      && c.precision_bits () == operation_precision;
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at Rgemm boundary");
}

MpfrMatrixStorage
mplapack_mpfr_matrix_multiply (const MpfrMatrixStorage& lhs,
                               const MpfrMatrixStorage& rhs)
{
  if (lhs.columns () != rhs.rows ())
    throw std::invalid_argument ("matrix multiplication dimension mismatch");

  const mpfr_prec_t operation_precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());
  validate_precision (operation_precision);
  MpfrMatrixStorage a_work (lhs.rows (), lhs.columns (), operation_precision,
                            lhs);
  MpfrMatrixStorage b_work (rhs.rows (), rhs.columns (), operation_precision,
                            rhs);
  MpfrMatrixStorage result (lhs.rows (), rhs.columns (), operation_precision);

  // No arithmetic call is needed for an empty product.  In particular, this
  // avoids passing a null data pointer to Rgemm while retaining result shape
  // and explicit operation precision metadata.
  if (result.numel () == 0 || lhs.columns () == 0)
    {
      set_zero (result);
      return result;
    }

  mpfrxx::mpfr_class alpha
    = mpfrxx::mpfr_class::with_precision (operation_precision);
  mpfrxx::mpfr_class beta
    = mpfrxx::mpfr_class::with_precision (operation_precision);
  mpfr_set_ui (alpha.mpfr_data (), 1, MPFR_RNDN);
  mpfr_set_zero (beta.mpfr_data (), 1);

  {
    MplapackMpfrPrecisionScope precision_scope (operation_precision);
    require_mplapack_mpfr_precision_contract (
      operation_precision, alpha, a_work, b_work, beta, result);
    Rgemm ("N", "N",
           MpfrMatrixStorage::checked_mplapack_dimension (lhs.rows ()),
           MpfrMatrixStorage::checked_mplapack_dimension (rhs.columns ()),
           MpfrMatrixStorage::checked_mplapack_dimension (lhs.columns ()),
           alpha, a_work.data (), a_work.leading_dimension (), b_work.data (),
           b_work.leading_dimension (), beta, result.data (),
           result.leading_dimension ());
    if (mpfrxx::default_precision_bits () != operation_precision)
      throw std::runtime_error (
        "MPLAPACK MPFR Rgemm changed the current-thread default precision");
  }
  return result;
}

MpfrMatrixStorage
mplapack_mpfr_matrix_scale (const MpfrMatrixStorage& matrix,
                            const mpfrxx::mpfr_class& scalar)
{
  const mpfr_prec_t operation_precision
    = std::max (matrix.precision_bits (), scalar.precision ());
  validate_precision (operation_precision);
  MpfrMatrixStorage result (matrix.rows (), matrix.columns (),
                            operation_precision, matrix);
  const mpfrxx::mpfr_class scalar_work
    = make_scalar_at_precision (scalar, operation_precision);

  MplapackMpfrPrecisionScope precision_scope (operation_precision);
  for (std::size_t index = 0; index < result.numel (); ++index)
    mpfr_mul (result.data ()[index].mpfr_data (),
              result.data ()[index].mpfr_data (), scalar_work.mpfr_data (),
              MPFR_RNDN);
  return result;
}

MpfrMatrixStorage
mplapack_mpfr_matrix_scale (const MpfrMatrixStorage& matrix, double scalar)
{
  const mpfr_prec_t operation_precision = matrix.precision_bits ();
  validate_precision (operation_precision);
  MpfrMatrixStorage result (matrix.rows (), matrix.columns (),
                            operation_precision, matrix);
  const mpfrxx::mpfr_class scalar_work
    = make_scalar_at_precision (scalar, operation_precision);

  MplapackMpfrPrecisionScope precision_scope (operation_precision);
  for (std::size_t index = 0; index < result.numel (); ++index)
    mpfr_mul (result.data ()[index].mpfr_data (),
              result.data ()[index].mpfr_data (), scalar_work.mpfr_data (),
              MPFR_RNDN);
  return result;
}

} // namespace octave_mplapack
