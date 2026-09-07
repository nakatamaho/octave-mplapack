// SPDX-License-Identifier: BSD-2-Clause

#include "mp_generalized_eig.h"

#include <algorithm>
#include <cstddef>
#include <limits>
#include <mpfr.h>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

#include <gmp.h>
#include <mplapack_mpfr.h>

#include "mp_complex_precision.h"
#include "mp_structured_eig.h"

namespace
{

using octave_mplapack::MpfrComplexMatrixStorage;
using octave_mplapack::MpGeneralizedEigResult;
using octave_mplapack::MpfrMatrixStorage;
using octave_mplapack::MpfrScalarStorage;

void
validate_precision (mpfr_prec_t precision_bits)
{
  if (precision_bits < MPFR_PREC_MIN || precision_bits > MPFR_PREC_MAX)
    throw std::invalid_argument (
      "MPLAPACK generalized eig precision is outside MPFR limits");
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
checked_eight_times (std::size_t value, const char *routine)
{
  if (value > std::numeric_limits<std::size_t>::max () / 8)
    throw std::overflow_error (std::string (routine)
                               + " workspace size overflows allocation");
  return std::max<std::size_t> (1, 8 * value);
}

void
fill_real_diagonal (MpfrMatrixStorage& diagonal,
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

void
fill_complex_diagonal (MpfrComplexMatrixStorage& diagonal,
                       const MpfrComplexMatrixStorage& eigenvalues)
{
  for (std::size_t column = 0; column < diagonal.columns (); ++column)
    for (std::size_t row = 0; row < diagonal.rows (); ++row)
      {
        if (row == column)
          mpc_set (diagonal.at (row, column).mpc_data (),
                   eigenvalues.at (row, 0).mpc_data (),
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
        else
          mpc_set_ui (diagonal.at (row, column).mpc_data (), 0,
                      MPC_RND (MPFR_RNDN, MPFR_RNDN));
      }
}

void
set_complex_from_real (MpfrComplexMatrixStorage::NativeScalar& destination,
                       const MpfrMatrixStorage::NativeScalar& real,
                       const MpfrMatrixStorage::NativeScalar& imag)
{
  mpfr_set (mpc_realref (destination.mpc_data ()), real.mpfr_data (),
            MPFR_RNDN);
  mpfr_set (mpc_imagref (destination.mpc_data ()), imag.mpfr_data (),
            MPFR_RNDN);
}

void
set_complex_from_real (MpfrComplexMatrixStorage::NativeScalar& destination,
                       const MpfrMatrixStorage::NativeScalar& real)
{
  mpfr_set (mpc_realref (destination.mpc_data ()), real.mpfr_data (),
            MPFR_RNDN);
  mpfr_set_zero (mpc_imagref (destination.mpc_data ()), 1);
}

void
set_generalized_real_eigenvalue (
  MpfrComplexMatrixStorage::NativeScalar& destination,
  const MpfrMatrixStorage::NativeScalar& alphar,
  const MpfrMatrixStorage::NativeScalar& alphai,
  const MpfrMatrixStorage::NativeScalar& beta)
{
  mpfr_div (mpc_realref (destination.mpc_data ()), alphar.mpfr_data (),
            beta.mpfr_data (), MPFR_RNDN);
  mpfr_div (mpc_imagref (destination.mpc_data ()), alphai.mpfr_data (),
            beta.mpfr_data (), MPFR_RNDN);
}

void
convert_real_generalized_vectors (MpfrComplexMatrixStorage& destination,
                                  const MpfrMatrixStorage& source,
                                  const MpfrMatrixStorage& alphai)
{
  const std::size_t n = source.columns ();
  std::size_t column = 0;
  while (column < n)
    {
      const int sign = mpfr_sgn (alphai.at (column, 0).mpfr_data ());
      if (sign > 0 && column + 1 < n
          && mpfr_sgn (alphai.at (column + 1, 0).mpfr_data ()) < 0)
        {
          for (std::size_t row = 0; row < source.rows (); ++row)
            {
              auto& first = destination.at (row, column);
              set_complex_from_real (first, source.at (row, column),
                                     source.at (row, column + 1));
              auto& second = destination.at (row, column + 1);
              set_complex_from_real (second, source.at (row, column),
                                     source.at (row, column + 1));
              mpfr_neg (mpc_imagref (second.mpc_data ()),
                        mpc_imagref (second.mpc_data ()), MPFR_RNDN);
            }
          column += 2;
        }
      else if (sign < 0 && column > 0
               && mpfr_sgn (alphai.at (column - 1, 0).mpfr_data ()) > 0)
        ++column;
      else
        {
          for (std::size_t row = 0; row < source.rows (); ++row)
            set_complex_from_real (destination.at (row, column),
                                   source.at (row, column));
          ++column;
        }
    }
}

void
require_real_uniform (mpfr_prec_t precision,
                      const MpfrMatrixStorage& a,
                      const MpfrMatrixStorage& b,
                      const MpfrMatrixStorage& alpha,
                      const MpfrMatrixStorage& beta,
                      const MpfrMatrixStorage& vl,
                      const MpfrMatrixStorage& vr,
                      const MpfrMatrixStorage& work)
{
  if (mpfrxx::default_precision_bits () != precision
      || a.precision_bits () != precision || b.precision_bits () != precision
      || alpha.precision_bits () != precision
      || beta.precision_bits () != precision
      || vl.precision_bits () != precision || vr.precision_bits () != precision
      || work.precision_bits () != precision
      || ! a.all_elements_have_uniform_precision ()
      || ! b.all_elements_have_uniform_precision ()
      || ! alpha.all_elements_have_uniform_precision ()
      || ! beta.all_elements_have_uniform_precision ()
      || ! vl.all_elements_have_uniform_precision ()
      || ! vr.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ())
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at generalized Rggev boundary");
}

void
require_complex_uniform (mpfr_prec_t precision,
                         const MpfrComplexMatrixStorage& a,
                         const MpfrComplexMatrixStorage& b,
                         const MpfrComplexMatrixStorage& alpha,
                         const MpfrComplexMatrixStorage& beta,
                         const MpfrComplexMatrixStorage& vl,
                         const MpfrComplexMatrixStorage& vr,
                         const MpfrComplexMatrixStorage& work,
                         const MpfrMatrixStorage& rwork)
{
  const auto state = mpfrxx::mpc_precision_override_storage ();
  if (mpfrxx::default_precision_bits () != precision
      || ! state.active || state.real_precision_bits != precision
      || state.imag_precision_bits != precision
      || a.precision_bits () != precision || b.precision_bits () != precision
      || alpha.precision_bits () != precision
      || beta.precision_bits () != precision
      || vl.precision_bits () != precision || vr.precision_bits () != precision
      || work.precision_bits () != precision
      || rwork.precision_bits () != precision
      || ! a.all_elements_have_uniform_precision ()
      || ! b.all_elements_have_uniform_precision ()
      || ! alpha.all_elements_have_uniform_precision ()
      || ! beta.all_elements_have_uniform_precision ()
      || ! vl.all_elements_have_uniform_precision ()
      || ! vr.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ()
      || ! rwork.all_elements_have_uniform_precision ())
    throw std::runtime_error (
      "MPLAPACK MPC precision contract mismatch at generalized Cggev boundary");
}

void
require_real_definite_uniform (mpfr_prec_t precision,
                               const MpfrMatrixStorage& a,
                               const MpfrMatrixStorage& b,
                               const MpfrMatrixStorage& w,
                               const MpfrMatrixStorage& work)
{
  if (mpfrxx::default_precision_bits () != precision
      || a.precision_bits () != precision || b.precision_bits () != precision
      || w.precision_bits () != precision || work.precision_bits () != precision
      || ! a.all_elements_have_uniform_precision ()
      || ! b.all_elements_have_uniform_precision ()
      || ! w.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ())
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at generalized Rsygvd boundary");
}

void
require_complex_definite_uniform (mpfr_prec_t precision,
                                  const MpfrComplexMatrixStorage& a,
                                  const MpfrComplexMatrixStorage& b,
                                  const MpfrMatrixStorage& w,
                                  const MpfrComplexMatrixStorage& work,
                                  const MpfrMatrixStorage& rwork)
{
  const auto state = mpfrxx::mpc_precision_override_storage ();
  if (mpfrxx::default_precision_bits () != precision
      || ! state.active || state.real_precision_bits != precision
      || state.imag_precision_bits != precision
      || a.precision_bits () != precision || b.precision_bits () != precision
      || w.precision_bits () != precision || work.precision_bits () != precision
      || rwork.precision_bits () != precision
      || ! a.all_elements_have_uniform_precision ()
      || ! b.all_elements_have_uniform_precision ()
      || ! w.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ()
      || ! rwork.all_elements_have_uniform_precision ())
    throw std::runtime_error (
      "MPLAPACK MPC precision contract mismatch at generalized Chegvd boundary");
}

MpGeneralizedEigResult
run_real_definite (const MpfrMatrixStorage& input_a,
                   const MpfrMatrixStorage& input_b)
{
  using Integer = MpfrMatrixStorage::MplapackInteger;
  const auto precision = input_a.precision_bits ();
  const std::size_t n = input_a.rows ();
  MpfrMatrixStorage a (n, n, precision, input_a);
  MpfrMatrixStorage b (n, n, precision, input_b);
  MpfrMatrixStorage w (n, 1, precision);
  MpfrMatrixStorage query_work (1, 1, precision);
  std::vector<Integer> query_iwork (1);
  Integer info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    require_real_definite_uniform (precision, a, b, w, query_work);
    Rsygvd (1, "V", "U", static_cast<Integer> (n), a.data (), a.leading_dimension (),
            b.data (), b.leading_dimension (), w.data (), query_work.data (), -1,
            query_iwork.data (), -1, info);
  }
  if (info != 0)
    throw octave_mplapack::MpGeneralizedEigError (
      static_cast<int> (info), "MPLAPACK Rsygvd workspace query failed");
  const auto lwork = checked_workspace_length (query_work.at (0, 0),
                                                "MPLAPACK Rsygvd");
  const auto liwork = checked_integer_workspace_length (
    query_iwork.at (0), "MPLAPACK Rsygvd");
  MpfrMatrixStorage work (lwork, 1, precision);
  std::vector<Integer> iwork (liwork);
  a = MpfrMatrixStorage (n, n, precision, input_a);
  b = MpfrMatrixStorage (n, n, precision, input_b);
  w = MpfrMatrixStorage (n, 1, precision);
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    require_real_definite_uniform (precision, a, b, w, work);
    Rsygvd (1, "V", "U", static_cast<Integer> (n), a.data (), a.leading_dimension (),
            b.data (), b.leading_dimension (), w.data (), work.data (),
            static_cast<Integer> (lwork), iwork.data (),
            static_cast<Integer> (liwork), info);
  }
  if (info != 0)
    throw octave_mplapack::MpGeneralizedEigError (
      static_cast<int> (info), info > static_cast<Integer> (n)
        ? "MPLAPACK Rsygvd found B not positive definite"
        : "MPLAPACK Rsygvd failed to converge");
  MpfrMatrixStorage diagonal (n, n, precision);
  fill_real_diagonal (diagonal, w);
  MpfrMatrixStorage vectors (n, n, precision, a);
  return octave_mplapack::MpGeneralizedRealDefiniteEigResult {
    std::move (w), std::move (a), std::move (vectors), std::move (diagonal)};
}

MpGeneralizedEigResult
run_complex_definite (const MpfrComplexMatrixStorage& input_a,
                      const MpfrComplexMatrixStorage& input_b)
{
  using Integer = MpfrComplexMatrixStorage::MplapackInteger;
  const auto precision = input_a.precision_bits ();
  const std::size_t n = input_a.rows ();
  MpfrComplexMatrixStorage a (n, n, precision);
  MpfrComplexMatrixStorage b (n, n, precision);
  a = input_a;
  b = input_b;
  MpfrMatrixStorage w (n, 1, precision);
  MpfrComplexMatrixStorage query_work (1, 1, precision);
  MpfrMatrixStorage query_rwork (1, 1, precision);
  std::vector<Integer> query_iwork (1);
  Integer info = 0;
  {
    octave_mplapack::MpfrMpcPrecisionScope scope (precision);
    require_complex_definite_uniform (precision, a, b, w, query_work,
                                      query_rwork);
    Chegvd (1, "V", "U", static_cast<Integer> (n), a.data (), a.leading_dimension (),
            b.data (), b.leading_dimension (), w.data (), query_work.data (), -1,
            query_rwork.data (), -1, query_iwork.data (), -1, info);
  }
  if (info != 0)
    throw octave_mplapack::MpGeneralizedEigError (
      static_cast<int> (info), "MPLAPACK Chegvd workspace query failed");
  const auto lwork = checked_complex_workspace_length (
    query_work.at (0, 0), "MPLAPACK Chegvd");
  const auto lrwork = checked_workspace_length (query_rwork.at (0, 0),
                                                "MPLAPACK Chegvd");
  const auto liwork = checked_integer_workspace_length (
    query_iwork.at (0), "MPLAPACK Chegvd");
  MpfrComplexMatrixStorage work (lwork, 1, precision);
  MpfrMatrixStorage rwork (lrwork, 1, precision);
  std::vector<Integer> iwork (liwork);
  a = input_a;
  b = input_b;
  w = MpfrMatrixStorage (n, 1, precision);
  info = 0;
  {
    octave_mplapack::MpfrMpcPrecisionScope scope (precision);
    require_complex_definite_uniform (precision, a, b, w, work, rwork);
    Chegvd (1, "V", "U", static_cast<Integer> (n), a.data (), a.leading_dimension (),
            b.data (), b.leading_dimension (), w.data (), work.data (),
            static_cast<Integer> (lwork), rwork.data (),
            static_cast<Integer> (lrwork), iwork.data (),
            static_cast<Integer> (liwork), info);
  }
  if (info != 0)
    throw octave_mplapack::MpGeneralizedEigError (
      static_cast<int> (info), info > static_cast<Integer> (n)
        ? "MPLAPACK Chegvd found B not positive definite"
        : "MPLAPACK Chegvd failed to converge");
  MpfrMatrixStorage diagonal (n, n, precision);
  fill_real_diagonal (diagonal, w);
  MpfrComplexMatrixStorage vectors = a;
  return octave_mplapack::MpGeneralizedComplexDefiniteEigResult {
    std::move (w), std::move (a), std::move (vectors), std::move (diagonal)};
}

MpGeneralizedEigResult
run_real_qz (const MpfrMatrixStorage& input_a,
             const MpfrMatrixStorage& input_b)
{
  using Integer = MpfrMatrixStorage::MplapackInteger;
  const auto precision = input_a.precision_bits ();
  const std::size_t n = input_a.rows ();
  MpfrMatrixStorage a (n, n, precision, input_a);
  MpfrMatrixStorage b (n, n, precision, input_b);
  MpfrMatrixStorage alphar (n, 1, precision);
  MpfrMatrixStorage alphai (n, 1, precision);
  MpfrMatrixStorage beta (n, 1, precision);
  MpfrMatrixStorage vl (n, n, precision);
  MpfrMatrixStorage vr (n, n, precision);
  MpfrMatrixStorage query_work (1, 1, precision);
  Integer info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    require_real_uniform (precision, a, b, alphar, beta, vl, vr, query_work);
    Rggev ("V", "V", static_cast<Integer> (n), a.data (), a.leading_dimension (),
           b.data (), b.leading_dimension (), alphar.data (), alphai.data (),
           beta.data (), vl.data (), vl.leading_dimension (), vr.data (),
           vr.leading_dimension (), query_work.data (), -1, info);
  }
  if (info != 0)
    throw octave_mplapack::MpGeneralizedEigError (
      static_cast<int> (info), "MPLAPACK Rggev workspace query failed");
  const auto lwork = checked_workspace_length (query_work.at (0, 0),
                                                "MPLAPACK Rggev");
  MpfrMatrixStorage work (lwork, 1, precision);
  a = MpfrMatrixStorage (n, n, precision, input_a);
  b = MpfrMatrixStorage (n, n, precision, input_b);
  alphar = MpfrMatrixStorage (n, 1, precision);
  alphai = MpfrMatrixStorage (n, 1, precision);
  beta = MpfrMatrixStorage (n, 1, precision);
  vl = MpfrMatrixStorage (n, n, precision);
  vr = MpfrMatrixStorage (n, n, precision);
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    require_real_uniform (precision, a, b, alphar, beta, vl, vr, work);
    Rggev ("V", "V", static_cast<Integer> (n), a.data (), a.leading_dimension (),
           b.data (), b.leading_dimension (), alphar.data (), alphai.data (),
           beta.data (), vl.data (), vl.leading_dimension (), vr.data (),
           vr.leading_dimension (), work.data (), static_cast<Integer> (lwork),
           info);
  }
  if (info != 0)
    throw octave_mplapack::MpGeneralizedEigError (
      static_cast<int> (info), info < 0 ? "MPLAPACK Rggev rejected an argument"
                                       : "MPLAPACK Rggev failed to converge");
  MpfrComplexMatrixStorage eigenvalues (n, 1, precision);
  MpfrComplexMatrixStorage left (n, n, precision);
  MpfrComplexMatrixStorage right (n, n, precision);
  for (std::size_t index = 0; index < n; ++index)
    set_generalized_real_eigenvalue (eigenvalues.at (index, 0),
                                     alphar.at (index, 0),
                                     alphai.at (index, 0),
                                     beta.at (index, 0));
  convert_real_generalized_vectors (right, vr, alphai);
  convert_real_generalized_vectors (left, vl, alphai);
  MpfrComplexMatrixStorage diagonal (n, n, precision);
  fill_complex_diagonal (diagonal, eigenvalues);
  return octave_mplapack::MpGeneralizedQzEigResult {
    std::move (eigenvalues), std::move (right), std::move (left),
    std::move (diagonal)};
}

MpGeneralizedEigResult
run_complex_qz (const MpfrComplexMatrixStorage& input_a,
                const MpfrComplexMatrixStorage& input_b)
{
  using Integer = MpfrComplexMatrixStorage::MplapackInteger;
  const auto precision = input_a.precision_bits ();
  const std::size_t n = input_a.rows ();
  MpfrComplexMatrixStorage a = input_a;
  MpfrComplexMatrixStorage b = input_b;
  MpfrComplexMatrixStorage alpha (n, 1, precision);
  MpfrComplexMatrixStorage beta (n, 1, precision);
  MpfrComplexMatrixStorage vl (n, n, precision);
  MpfrComplexMatrixStorage vr (n, n, precision);
  MpfrComplexMatrixStorage query_work (1, 1, precision);
  MpfrMatrixStorage rwork (checked_eight_times (n, "MPLAPACK Cggev"), 1,
                           precision);
  Integer info = 0;
  {
    octave_mplapack::MpfrMpcPrecisionScope scope (precision);
    require_complex_uniform (precision, a, b, alpha, beta, vl, vr,
                             query_work, rwork);
    Cggev ("V", "V", static_cast<Integer> (n), a.data (), a.leading_dimension (),
           b.data (), b.leading_dimension (), alpha.data (), beta.data (),
           vl.data (), vl.leading_dimension (), vr.data (), vr.leading_dimension (),
           query_work.data (), -1, rwork.data (), info);
  }
  if (info != 0)
    throw octave_mplapack::MpGeneralizedEigError (
      static_cast<int> (info), "MPLAPACK Cggev workspace query failed");
  const auto lwork = checked_complex_workspace_length (
    query_work.at (0, 0), "MPLAPACK Cggev");
  MpfrComplexMatrixStorage work (lwork, 1, precision);
  a = input_a;
  b = input_b;
  alpha = MpfrComplexMatrixStorage (n, 1, precision);
  beta = MpfrComplexMatrixStorage (n, 1, precision);
  vl = MpfrComplexMatrixStorage (n, n, precision);
  vr = MpfrComplexMatrixStorage (n, n, precision);
  rwork = MpfrMatrixStorage (checked_eight_times (n, "MPLAPACK Cggev"), 1,
                             precision);
  info = 0;
  {
    octave_mplapack::MpfrMpcPrecisionScope scope (precision);
    require_complex_uniform (precision, a, b, alpha, beta, vl, vr, work,
                             rwork);
    Cggev ("V", "V", static_cast<Integer> (n), a.data (), a.leading_dimension (),
           b.data (), b.leading_dimension (), alpha.data (), beta.data (),
           vl.data (), vl.leading_dimension (), vr.data (), vr.leading_dimension (),
           work.data (), static_cast<Integer> (lwork), rwork.data (), info);
  }
  if (info != 0)
    throw octave_mplapack::MpGeneralizedEigError (
      static_cast<int> (info), info < 0 ? "MPLAPACK Cggev rejected an argument"
                                       : "MPLAPACK Cggev failed to converge");
  MpfrComplexMatrixStorage eigenvalues (n, 1, precision);
  for (std::size_t index = 0; index < n; ++index)
    mpc_div (eigenvalues.at (index, 0).mpc_data (), alpha.at (index, 0).mpc_data (),
             beta.at (index, 0).mpc_data (), MPC_RND (MPFR_RNDN, MPFR_RNDN));
  MpfrComplexMatrixStorage diagonal (n, n, precision);
  fill_complex_diagonal (diagonal, eigenvalues);
  return octave_mplapack::MpGeneralizedQzEigResult {
    std::move (eigenvalues), std::move (vr), std::move (vl), std::move (diagonal)};
}

} // namespace

namespace octave_mplapack
{

MpGeneralizedEigResult
mplapack_mpfr_matrix_generalized_eig (const MpfrMatrixStorage& a,
                                      const MpfrMatrixStorage& b,
                                      GeneralizedEigAlgorithm algorithm)
{
  if (a.rows () != a.columns () || b.rows () != b.columns ()
      || a.rows () != b.rows ())
    throw std::invalid_argument (
      "generalized eig requires equally sized square real matrices");
  const auto precision = a.precision_bits ();
  if (b.precision_bits () != precision)
    throw std::invalid_argument (
      "generalized eig inputs must have one operation precision");
  validate_precision (precision);
  const std::size_t n = a.rows ();
  if (n == 0)
    return MpGeneralizedQzEigResult {
      MpfrComplexMatrixStorage (0, 1, precision),
      MpfrComplexMatrixStorage (0, 0, precision),
      MpfrComplexMatrixStorage (0, 0, precision),
      MpfrComplexMatrixStorage (0, 0, precision)};

  const bool structured =
    mplapack_mpfr_matrix_is_exactly_symmetric (a)
    && mplapack_mpfr_matrix_is_exactly_symmetric (b);
  if (algorithm == GeneralizedEigAlgorithm::chol && ! structured)
    throw std::invalid_argument (
      "generalized eig chol requires exactly symmetric real A and B");
  if (structured && algorithm != GeneralizedEigAlgorithm::qz)
    {
      try
        {
          return run_real_definite (a, b);
        }
      catch (const MpGeneralizedEigError& exception)
        {
          if (algorithm == GeneralizedEigAlgorithm::chol
              || exception.info () <= static_cast<int> (n))
            throw;
        }
    }
  return run_real_qz (a, b);
}

MpGeneralizedEigResult
mplapack_mpc_matrix_generalized_eig (const MpfrComplexMatrixStorage& a,
                                     const MpfrComplexMatrixStorage& b,
                                     GeneralizedEigAlgorithm algorithm)
{
  if (a.rows () != a.columns () || b.rows () != b.columns ()
      || a.rows () != b.rows ())
    throw std::invalid_argument (
      "generalized eig requires equally sized square complex matrices");
  const auto precision = a.precision_bits ();
  if (b.precision_bits () != precision)
    throw std::invalid_argument (
      "generalized eig inputs must have one operation precision");
  validate_precision (precision);
  const std::size_t n = a.rows ();
  if (n == 0)
    return MpGeneralizedQzEigResult {
      MpfrComplexMatrixStorage (0, 1, precision),
      MpfrComplexMatrixStorage (0, 0, precision),
      MpfrComplexMatrixStorage (0, 0, precision),
      MpfrComplexMatrixStorage (0, 0, precision)};

  const bool structured =
    mplapack_mpc_matrix_is_exactly_hermitian (a)
    && mplapack_mpc_matrix_is_exactly_hermitian (b);
  if (algorithm == GeneralizedEigAlgorithm::chol && ! structured)
    throw std::invalid_argument (
      "generalized eig chol requires exactly Hermitian complex A and B");
  if (structured && algorithm != GeneralizedEigAlgorithm::qz)
    {
      try
        {
          return run_complex_definite (a, b);
        }
      catch (const MpGeneralizedEigError& exception)
        {
          if (algorithm == GeneralizedEigAlgorithm::chol
              || exception.info () <= static_cast<int> (n))
            throw;
        }
    }
  return run_complex_qz (a, b);
}

} // namespace octave_mplapack
