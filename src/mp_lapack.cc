// SPDX-License-Identifier: BSD-2-Clause

#include "mp_lapack.h"

#include <algorithm>
#include <stdexcept>
#include <vector>

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
