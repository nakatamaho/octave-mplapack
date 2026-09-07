// SPDX-License-Identifier: BSD-2-Clause

#include "mp_general_eig.h"

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
      "MPLAPACK general eig precision is outside MPFR limits");
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
fill_diagonal (MpfrComplexMatrixStorage& diagonal,
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
require_real_contract (mpfr_prec_t precision, const MpfrMatrixStorage& a,
                       const MpfrMatrixStorage& wr,
                       const MpfrMatrixStorage& wi,
                       const MpfrMatrixStorage& vl,
                       const MpfrMatrixStorage& vr,
                       const MpfrMatrixStorage& scale,
                       const MpfrMatrixStorage& rconde,
                       const MpfrMatrixStorage& rcondv,
                       const MpfrMatrixStorage& work,
                       const MpfrScalarStorage::NativeScalar& abnrm)
{
  if (mpfrxx::default_precision_bits () != precision
      || a.precision_bits () != precision || wr.precision_bits () != precision
      || wi.precision_bits () != precision || vl.precision_bits () != precision
      || vr.precision_bits () != precision || scale.precision_bits () != precision
      || rconde.precision_bits () != precision
      || rcondv.precision_bits () != precision
      || work.precision_bits () != precision
      || ! a.all_elements_have_uniform_precision ()
      || ! wr.all_elements_have_uniform_precision ()
      || ! wi.all_elements_have_uniform_precision ()
      || ! vl.all_elements_have_uniform_precision ()
      || ! vr.all_elements_have_uniform_precision ()
      || ! scale.all_elements_have_uniform_precision ()
      || ! rconde.all_elements_have_uniform_precision ()
      || ! rcondv.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ()
      || abnrm.precision () != precision)
    throw std::runtime_error (
      "MPLAPACK MPFR precision contract mismatch at Rgeevx boundary");
}

void
require_complex_contract (mpfr_prec_t precision,
                          const MpfrComplexMatrixStorage& a,
                          const MpfrComplexMatrixStorage& w,
                          const MpfrComplexMatrixStorage& vl,
                          const MpfrComplexMatrixStorage& vr,
                          const MpfrComplexMatrixStorage& work,
                          const MpfrMatrixStorage& rwork,
                          const MpfrMatrixStorage& scale,
                          const MpfrMatrixStorage& rconde,
                          const MpfrMatrixStorage& rcondv,
                          const MpfrScalarStorage::NativeScalar& abnrm)
{
  const auto state = mpfrxx::mpc_precision_override_storage ();
  if (mpfrxx::default_precision_bits () != precision
      || ! state.active || state.real_precision_bits != precision
      || state.imag_precision_bits != precision
      || a.precision_bits () != precision || w.precision_bits () != precision
      || vl.precision_bits () != precision || vr.precision_bits () != precision
      || work.precision_bits () != precision
      || rwork.precision_bits () != precision
      || scale.precision_bits () != precision
      || rconde.precision_bits () != precision
      || rcondv.precision_bits () != precision
      || ! a.all_elements_have_uniform_precision ()
      || ! w.all_elements_have_uniform_precision ()
      || ! vl.all_elements_have_uniform_precision ()
      || ! vr.all_elements_have_uniform_precision ()
      || ! work.all_elements_have_uniform_precision ()
      || ! rwork.all_elements_have_uniform_precision ()
      || ! scale.all_elements_have_uniform_precision ()
      || ! rconde.all_elements_have_uniform_precision ()
      || ! rcondv.all_elements_have_uniform_precision ()
      || abnrm.precision () != precision)
    throw std::runtime_error (
      "MPLAPACK MPC precision contract mismatch at Cgeevx boundary");
}

void
convert_real_eigenpair_column (MpfrComplexMatrixStorage& destination,
                               const MpfrMatrixStorage& source,
                               std::size_t destination_column,
                               std::size_t source_column)
{
  for (std::size_t row = 0; row < source.rows (); ++row)
    set_complex_from_real (destination.at (row, destination_column),
                           source.at (row, source_column));
}

void
convert_real_eigenvectors (MpfrComplexMatrixStorage& destination,
                           const MpfrMatrixStorage& source,
                           const MpfrMatrixStorage& wi)
{
  const std::size_t n = source.columns ();
  std::size_t column = 0;
  while (column < n)
    {
      const int sign = mpfr_sgn (wi.at (column, 0).mpfr_data ());
      if (sign > 0 && column + 1 < n
          && mpfr_sgn (wi.at (column + 1, 0).mpfr_data ()) < 0)
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
               && mpfr_sgn (wi.at (column - 1, 0).mpfr_data ()) > 0)
        ++column;
      else
        {
          convert_real_eigenpair_column (destination, source, column, column);
          ++column;
        }
    }
}

MpfrComplexMatrixStorage
make_real_complex_values (const MpfrMatrixStorage& wr,
                          const MpfrMatrixStorage& wi)
{
  const std::size_t n = wr.rows ();
  MpfrComplexMatrixStorage result (n, 1, wr.precision_bits ());
  for (std::size_t index = 0; index < n; ++index)
    set_complex_from_real (result.at (index, 0), wr.at (index, 0),
                           wi.at (index, 0));
  return result;
}

} // namespace

namespace octave_mplapack
{

MpfrGeneralEigResult
mplapack_mpfr_matrix_general_eig (const MpfrMatrixStorage& input, bool balance)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument ("general eig requires a square real matrix");
  const mpfr_prec_t precision = input.precision_bits ();
  validate_precision (precision);
  const std::size_t n = input.rows ();
  MpfrGeneralEigResult result {
    MpfrComplexMatrixStorage (n, 1, precision),
    MpfrComplexMatrixStorage (n, n, precision),
    MpfrComplexMatrixStorage (n, n, precision),
    MpfrComplexMatrixStorage (n, n, precision)
  };
  if (n == 0)
    return result;

  MpfrMatrixStorage a_work (n, n, precision, input);
  MpfrMatrixStorage wr (n, 1, precision);
  MpfrMatrixStorage wi (n, 1, precision);
  MpfrMatrixStorage vl (n, n, precision);
  MpfrMatrixStorage vr (n, n, precision);
  MpfrMatrixStorage query_work (1, 1, precision);
  MpfrMatrixStorage scale (n, 1, precision);
  MpfrMatrixStorage rconde (n, 1, precision);
  MpfrMatrixStorage rcondv (n, 1, precision);
  MpfrScalarStorage::NativeScalar abnrm
    = MpfrScalarStorage::NativeScalar::with_precision (precision);
  std::vector<MpfrMatrixStorage::MplapackInteger> iwork (std::max<std::size_t> (1, n));
  MpfrMatrixStorage::MplapackInteger ilo = 0;
  MpfrMatrixStorage::MplapackInteger ihi = 0;
  MpfrMatrixStorage::MplapackInteger info = 0;
  const char *balanc = balance ? "B" : "N";
  {
    MplapackMpfrPrecisionScope scope (precision);
    require_real_contract (precision, a_work, wr, wi, vl, vr, scale, rconde,
                           rcondv, query_work, abnrm);
    Rgeevx (balanc, "V", "V", "N",
            MpfrMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), wr.data (), wi.data (),
            vl.data (), vl.leading_dimension (), vr.data (), vr.leading_dimension (),
            ilo, ihi, scale.data (), abnrm, rconde.data (), rcondv.data (),
            query_work.data (), -1, iwork.data (), info);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK Rgeevx changed the current-thread default precision");
  }
  if (info < 0)
    throw MpfrGeneralEigError (-static_cast<int> (info),
                              "MPLAPACK Rgeevx rejected a workspace query");
  if (info > 0)
    throw MpfrGeneralEigError (static_cast<int> (info),
                              "MPLAPACK Rgeevx workspace query failed");
  const std::size_t lwork
    = checked_workspace_length (query_work.at (0, 0), "MPLAPACK Rgeevx");
  MpfrMatrixStorage work (lwork, 1, precision);
  a_work = MpfrMatrixStorage (n, n, precision, input);
  wr = MpfrMatrixStorage (n, 1, precision);
  wi = MpfrMatrixStorage (n, 1, precision);
  vl = MpfrMatrixStorage (n, n, precision);
  vr = MpfrMatrixStorage (n, n, precision);
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    require_real_contract (precision, a_work, wr, wi, vl, vr, scale, rconde,
                           rcondv, work, abnrm);
    Rgeevx (balanc, "V", "V", "N",
            MpfrMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), wr.data (), wi.data (),
            vl.data (), vl.leading_dimension (), vr.data (), vr.leading_dimension (),
            ilo, ihi, scale.data (), abnrm, rconde.data (), rcondv.data (),
            work.data (), static_cast<MpfrMatrixStorage::MplapackInteger> (lwork),
            iwork.data (), info);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK Rgeevx changed the current-thread default precision");
  }
  if (info != 0)
    throw MpfrGeneralEigError (static_cast<int> (info),
                              info < 0 ? "MPLAPACK Rgeevx rejected an argument"
                                       : "MPLAPACK Rgeevx failed to converge");

  result.eigenvalues = make_real_complex_values (wr, wi);
  convert_real_eigenvectors (result.right_vectors, vr, wi);
  convert_real_eigenvectors (result.left_vectors, vl, wi);
  fill_diagonal (result.diagonal, result.eigenvalues);
  return result;
}

MpcGeneralEigResult
mplapack_mpc_matrix_general_eig (const MpfrComplexMatrixStorage& input,
                                 bool balance)
{
  if (input.rows () != input.columns ())
    throw std::invalid_argument (
      "general eig requires a square complex matrix");
  const mpfr_prec_t precision = input.precision_bits ();
  validate_precision (precision);
  const std::size_t n = input.rows ();
  MpcGeneralEigResult result {
    MpfrComplexMatrixStorage (n, 1, precision),
    MpfrComplexMatrixStorage (n, n, precision),
    MpfrComplexMatrixStorage (n, n, precision),
    MpfrComplexMatrixStorage (n, n, precision)
  };
  if (n == 0)
    return result;

  MpfrComplexMatrixStorage a_work = input;
  MpfrComplexMatrixStorage w (n, 1, precision);
  MpfrComplexMatrixStorage vl (n, n, precision);
  MpfrComplexMatrixStorage vr (n, n, precision);
  MpfrComplexMatrixStorage query_work (1, 1, precision);
  MpfrMatrixStorage rwork (std::max<std::size_t> (1, 2 * n), 1, precision);
  MpfrMatrixStorage scale (n, 1, precision);
  MpfrMatrixStorage rconde (n, 1, precision);
  MpfrMatrixStorage rcondv (n, 1, precision);
  MpfrScalarStorage::NativeScalar abnrm
    = MpfrScalarStorage::NativeScalar::with_precision (precision);
  MpfrComplexMatrixStorage::MplapackInteger ilo = 0;
  MpfrComplexMatrixStorage::MplapackInteger ihi = 0;
  MpfrComplexMatrixStorage::MplapackInteger info = 0;
  const char *balanc = balance ? "B" : "N";
  {
    MpfrMpcPrecisionScope scope (precision);
    require_complex_contract (precision, a_work, w, vl, vr, query_work, rwork,
                              scale, rconde, rcondv, abnrm);
    Cgeevx (balanc, "V", "V", "N",
            MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), w.data (),
            vl.data (), vl.leading_dimension (), vr.data (), vr.leading_dimension (),
            ilo, ihi, scale.data (), abnrm, rconde.data (), rcondv.data (),
            query_work.data (), -1, rwork.data (), info);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK Cgeevx changed the current-thread default precision");
  }
  if (info < 0)
    throw MpcGeneralEigError (-static_cast<int> (info),
                             "MPLAPACK Cgeevx rejected a workspace query");
  if (info > 0)
    throw MpcGeneralEigError (static_cast<int> (info),
                             "MPLAPACK Cgeevx workspace query failed");
  const std::size_t lwork = checked_complex_workspace_length (
    query_work.at (0, 0), "MPLAPACK Cgeevx");
  MpfrComplexMatrixStorage work (lwork, 1, precision);
  a_work = input;
  w = MpfrComplexMatrixStorage (n, 1, precision);
  vl = MpfrComplexMatrixStorage (n, n, precision);
  vr = MpfrComplexMatrixStorage (n, n, precision);
  rwork = MpfrMatrixStorage (std::max<std::size_t> (1, 2 * n), 1, precision);
  info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    require_complex_contract (precision, a_work, w, vl, vr, work, rwork,
                              scale, rconde, rcondv, abnrm);
    Cgeevx (balanc, "V", "V", "N",
            MpfrComplexMatrixStorage::checked_mplapack_dimension (n),
            a_work.data (), a_work.leading_dimension (), w.data (),
            vl.data (), vl.leading_dimension (), vr.data (), vr.leading_dimension (),
            ilo, ihi, scale.data (), abnrm, rconde.data (), rcondv.data (),
            work.data (), static_cast<MpfrComplexMatrixStorage::MplapackInteger> (lwork),
            rwork.data (), info);
    if (mpfrxx::default_precision_bits () != precision)
      throw std::runtime_error (
        "MPLAPACK Cgeevx changed the current-thread default precision");
  }
  if (info != 0)
    throw MpcGeneralEigError (static_cast<int> (info),
                             info < 0 ? "MPLAPACK Cgeevx rejected an argument"
                                      : "MPLAPACK Cgeevx failed to converge");

  result.eigenvalues = std::move (w);
  result.right_vectors = std::move (vr);
  result.left_vectors = std::move (vl);
  fill_diagonal (result.diagonal, result.eigenvalues);
  return result;
}

} // namespace octave_mplapack
