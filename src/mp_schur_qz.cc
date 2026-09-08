// SPDX-License-Identifier: BSD-2-Clause

#include "mp_schur_qz.h"

#include <mpfr.h>

#include <algorithm>
#include <cstddef>
#include <limits>
#include <memory>
#include <stdexcept>
#include <string>

#include <gmp.h>
#include <mplapack_mpfr.h>

#include "mp_complex_precision.h"

namespace octave_mplapack
{

namespace
{

using Integer = MpfrMatrixStorage::MplapackInteger;

bool
mpfr_no_selection (mpfr_class, mpfr_class)
{
  return false;
}

bool
mpc_no_selection (mpc_class)
{
  return false;
}

bool
mpfr_qz_no_selection (mpfr_class, mpfr_class, mpfr_class)
{
  return false;
}

bool
mpc_qz_no_selection (mpc_class, mpc_class)
{
  return false;
}

void
require_square (std::size_t rows, std::size_t columns, const char *routine)
{
  if (rows != columns)
    throw std::invalid_argument (std::string (routine)
                                 + " requires a square matrix");
}

std::size_t
checked_workspace (const MpfrScalarStorage::NativeScalar& query,
                   const char *routine)
{
  if (mpfr_nan_p (query.mpfr_data ()) != 0
      || mpfr_inf_p (query.mpfr_data ()) != 0
      || mpfr_integer_p (query.mpfr_data ()) == 0
      || mpfr_sgn (query.mpfr_data ()) <= 0)
    throw std::runtime_error (std::string (routine)
                              + " returned an invalid workspace query");

  mpz_t value;
  mpz_t maximum;
  mpz_init (value);
  mpz_init (maximum);
  mpfr_get_z (value, query.mpfr_data (), MPFR_RNDZ);
  const auto limit = std::numeric_limits<std::size_t>::max ();
  mpz_import (maximum, 1, -1, sizeof (limit), 0, 0, &limit);
  if (mpz_cmp (value, maximum) > 0)
    {
      mpz_clear (value);
      mpz_clear (maximum);
      throw std::overflow_error (std::string (routine)
                                 + " workspace exceeds allocation limits");
    }
  const std::size_t result = static_cast<std::size_t> (
    mpfr_get_uj (query.mpfr_data (), MPFR_RNDZ));
  mpz_clear (value);
  mpz_clear (maximum);
  return std::max<std::size_t> (result, 1);
}

std::size_t
checked_complex_workspace (const MpfrComplexMatrixStorage::NativeScalar& query,
                           const char *routine)
{
  if (mpfr_sgn (mpc_imagref (query.mpc_data ())) != 0)
    throw std::runtime_error (std::string (routine)
                              + " returned a complex workspace query");
  auto real_query = MpfrScalarStorage::NativeScalar::with_precision (
    query.real_precision ());
  mpfr_set (real_query.mpfr_data (),
            mpc_realref (query.mpc_data ()), MPFR_RNDN);
  return checked_workspace (real_query, routine);
}

void
check_info (Integer info, const char *routine)
{
  if (info != 0)
    throw std::runtime_error (std::string ("MPLAPACK ") + routine
                              + " failed (info " + std::to_string (info)
                              + ")");
}

void
make_identity (MpfrMatrixStorage& value)
{
  for (std::size_t column = 0; column < value.columns (); ++column)
    for (std::size_t row = 0; row < value.rows (); ++row)
      if (row == column)
        mpfr_set_ui (value.at (row, column).mpfr_data (), 1, MPFR_RNDN);
      else
        mpfr_set_zero (value.at (row, column).mpfr_data (), 1);
}

void
make_identity (MpfrComplexMatrixStorage& value)
{
  for (std::size_t column = 0; column < value.columns (); ++column)
    for (std::size_t row = 0; row < value.rows (); ++row)
      if (row == column)
        mpc_set_ui (value.at (row, column).mpc_data (), 1,
                    MPC_RND (MPFR_RNDN, MPFR_RNDN));
      else
        mpc_set_ui (value.at (row, column).mpc_data (), 0,
                    MPC_RND (MPFR_RNDN, MPFR_RNDN));
}

MpfrMatrixStorage
transpose (const MpfrMatrixStorage& input)
{
  MpfrMatrixStorage result (input.columns (), input.rows (),
                            input.precision_bits ());
  for (std::size_t column = 0; column < input.columns (); ++column)
    for (std::size_t row = 0; row < input.rows (); ++row)
      mpfr_set (result.at (column, row).mpfr_data (),
                input.at (row, column).mpfr_data (), MPFR_RNDN);
  return result;
}

MpfrComplexMatrixStorage
conjugate_transpose (const MpfrComplexMatrixStorage& input)
{
  MpfrComplexMatrixStorage result (input.columns (), input.rows (),
                                    input.precision_bits ());
  for (std::size_t column = 0; column < input.columns (); ++column)
    for (std::size_t row = 0; row < input.rows (); ++row)
      mpc_conj (result.at (column, row).mpc_data (),
                input.at (row, column).mpc_data (),
                MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

MpfrComplexMatrixStorage
promote (const MpfrMatrixStorage& input)
{
  MpfrComplexMatrixStorage result (input.rows (), input.columns (),
                                    input.precision_bits ());
  for (std::size_t column = 0; column < input.columns (); ++column)
    for (std::size_t row = 0; row < input.rows (); ++row)
      {
        mpc_set_fr (result.at (row, column).mpc_data (),
                    input.at (row, column).mpfr_data (),
                    MPC_RND (MPFR_RNDN, MPFR_RNDN));
      }
  return result;
}

MpfrMatrixStorage
run_mpfr_hess (const MpfrMatrixStorage& input, MpfrMatrixStorage& p)
{
  const auto precision = input.precision_bits ();
  const std::size_t n = input.rows ();
  MpfrMatrixStorage h (n, n, precision, input);
  MpfrMatrixStorage tau_storage (n, 1, precision);
  MpfrMatrixStorage query (1, 1, precision);
  Integer info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgehrd (static_cast<Integer> (n), 1, static_cast<Integer> (n),
            h.data (), h.leading_dimension (), tau_storage.data (),
            query.data (), -1, info);
  }
  check_info (info, "Rgehrd workspace query");
  const std::size_t lwork = checked_workspace (query.at (0, 0), "Rgehrd");
  MpfrMatrixStorage work (lwork, 1, precision);
  h = MpfrMatrixStorage (n, n, precision, input);
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgehrd (static_cast<Integer> (n), 1, static_cast<Integer> (n),
            h.data (), h.leading_dimension (), tau_storage.data (),
            work.data (), static_cast<Integer> (lwork), info);
  }
  check_info (info, "Rgehrd");
  p = MpfrMatrixStorage (n, n, precision, h);
  query = MpfrMatrixStorage (1, 1, precision);
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rorghr (static_cast<Integer> (n), 1, static_cast<Integer> (n),
            p.data (), p.leading_dimension (), tau_storage.data (),
            query.data (), -1, info);
  }
  check_info (info, "Rorghr workspace query");
  const std::size_t lwork_q = checked_workspace (query.at (0, 0), "Rorghr");
  MpfrMatrixStorage work_q (lwork_q, 1, precision);
  p = MpfrMatrixStorage (n, n, precision, p);
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rorghr (static_cast<Integer> (n), 1, static_cast<Integer> (n),
            p.data (), p.leading_dimension (), tau_storage.data (),
            work_q.data (), static_cast<Integer> (lwork_q), info);
  }
  check_info (info, "Rorghr");
  for (std::size_t column = 0; column < n; ++column)
    for (std::size_t row = column + 2; row < n; ++row)
      mpfr_set_zero (h.at (row, column).mpfr_data (), 1);
  return h;
}

MpfrComplexMatrixStorage
run_mpc_hess (const MpfrComplexMatrixStorage& input,
              MpfrComplexMatrixStorage& p)
{
  const auto precision = input.precision_bits ();
  const std::size_t n = input.rows ();
  MpfrComplexMatrixStorage h (input);
  MpfrComplexMatrixStorage tau (n, 1, precision);
  MpfrComplexMatrixStorage query (1, 1, precision);
  Integer info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    Cgehrd (static_cast<Integer> (n), 1, static_cast<Integer> (n),
            h.data (), h.leading_dimension (), tau.data (), query.data (),
            -1, info);
  }
  check_info (info, "Cgehrd workspace query");
  const std::size_t lwork = checked_complex_workspace (
    query.at (0, 0), "Cgehrd");
  MpfrComplexMatrixStorage work (lwork, 1, precision);
  h = input;
  info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    Cgehrd (static_cast<Integer> (n), 1, static_cast<Integer> (n),
            h.data (), h.leading_dimension (), tau.data (), work.data (),
            static_cast<Integer> (lwork), info);
  }
  check_info (info, "Cgehrd");
  p = h;
  query = MpfrComplexMatrixStorage (1, 1, precision);
  info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    Cunghr (static_cast<Integer> (n), 1, static_cast<Integer> (n),
            p.data (), p.leading_dimension (), tau.data (), query.data (),
            -1, info);
  }
  check_info (info, "Cunghr workspace query");
  const std::size_t lwork_q = checked_complex_workspace (
    query.at (0, 0), "Cunghr");
  MpfrComplexMatrixStorage work_q (lwork_q, 1, precision);
  // The workspace query leaves the reflector representation intact; the
  // second call deliberately reuses that operation-owned copy.
  info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    Cunghr (static_cast<Integer> (n), 1, static_cast<Integer> (n),
            p.data (), p.leading_dimension (), tau.data (), work_q.data (),
            static_cast<Integer> (lwork_q), info);
  }
  check_info (info, "Cunghr");
  for (std::size_t column = 0; column < n; ++column)
    for (std::size_t row = column + 2; row < n; ++row)
      mpc_set_ui (h.at (row, column).mpc_data (), 0,
                  MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return h;
}

MpfrMatrixStorage
run_mpfr_schur (const MpfrMatrixStorage& input, MpfrMatrixStorage& u)
{
  const auto precision = input.precision_bits ();
  const std::size_t n = input.rows ();
  MpfrMatrixStorage s (n, n, precision, input);
  MpfrMatrixStorage wr (n, 1, precision);
  MpfrMatrixStorage wi (n, 1, precision);
  MpfrMatrixStorage vs (n, n, precision);
  MpfrMatrixStorage query (1, 1, precision);
  MpfrMatrixStorage work_dummy (1, 1, precision);
  std::unique_ptr<bool[]> bwork (new bool[std::max<std::size_t> (n, 1)]);
  Integer sdim = 0;
  Integer info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgees ("V", "N", mpfr_no_selection, static_cast<Integer> (n), s.data (),
           s.leading_dimension (), sdim, wr.data (), wi.data (), vs.data (),
           vs.leading_dimension (), query.data (), -1, bwork.get (), info);
  }
  check_info (info, "Rgees workspace query");
  const std::size_t lwork = checked_workspace (query.at (0, 0), "Rgees");
  MpfrMatrixStorage work (lwork, 1, precision);
  s = MpfrMatrixStorage (n, n, precision, input);
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgees ("V", "N", mpfr_no_selection, static_cast<Integer> (n), s.data (),
           s.leading_dimension (), sdim, wr.data (), wi.data (), vs.data (),
           vs.leading_dimension (), work.data (), static_cast<Integer> (lwork),
           bwork.get (), info);
  }
  check_info (info, "Rgees");
  // LAPACK's Schur vectors satisfy A = VS*T*VS'.  Octave returns U=VS so
  // that S=U'*A*U.
  u = vs;
  return s;
}

MpfrComplexMatrixStorage
run_mpc_schur (const MpfrComplexMatrixStorage& input,
               MpfrComplexMatrixStorage& u)
{
  const auto precision = input.precision_bits ();
  const std::size_t n = input.rows ();
  MpfrComplexMatrixStorage s (input);
  MpfrComplexMatrixStorage w (n, 1, precision);
  MpfrComplexMatrixStorage vs (n, n, precision);
  MpfrComplexMatrixStorage query (1, 1, precision);
  MpfrMatrixStorage rwork (n, 1, precision);
  std::unique_ptr<bool[]> bwork (new bool[std::max<std::size_t> (n, 1)]);
  Integer sdim = 0;
  Integer info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    Cgees ("V", "N", mpc_no_selection, static_cast<Integer> (n), s.data (),
           s.leading_dimension (), sdim, w.data (), vs.data (),
           vs.leading_dimension (), query.data (), -1, rwork.data (),
           bwork.get (), info);
  }
  check_info (info, "Cgees workspace query");
  const std::size_t lwork = checked_complex_workspace (
    query.at (0, 0), "Cgees");
  MpfrComplexMatrixStorage work (lwork, 1, precision);
  s = input;
  info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    Cgees ("V", "N", mpc_no_selection, static_cast<Integer> (n), s.data (),
           s.leading_dimension (), sdim, w.data (), vs.data (),
           vs.leading_dimension (), work.data (), static_cast<Integer> (lwork),
           rwork.data (), bwork.get (), info);
  }
  check_info (info, "Cgees");
  u = vs;
  return s;
}

MpQzResult
run_mpfr_qz (const MpfrMatrixStorage& input_a,
             const MpfrMatrixStorage& input_b)
{
  const auto precision = input_a.precision_bits ();
  const std::size_t n = input_a.rows ();
  MpQzResult result { MpfrMatrixStorage (n, n, precision, input_a),
                      MpfrMatrixStorage (n, n, precision, input_b),
                      MpfrMatrixStorage (n, n, precision),
                      MpfrMatrixStorage (n, n, precision) };
  MpfrMatrixStorage alphar (n, 1, precision);
  MpfrMatrixStorage alphai (n, 1, precision);
  MpfrMatrixStorage beta (n, 1, precision);
  MpfrMatrixStorage vsl (n, n, precision);
  MpfrMatrixStorage vsr (n, n, precision);
  MpfrMatrixStorage query (1, 1, precision);
  std::unique_ptr<bool[]> bwork (new bool[std::max<std::size_t> (n, 1)]);
  Integer sdim = 0;
  Integer info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgges ("V", "V", "N", mpfr_qz_no_selection, static_cast<Integer> (n),
           result.aa.data (), result.aa.leading_dimension (), result.bb.data (),
           result.bb.leading_dimension (), sdim, alphar.data (), alphai.data (),
           beta.data (), vsl.data (), vsl.leading_dimension (), vsr.data (),
           vsr.leading_dimension (), query.data (), -1, bwork.get (), info);
  }
  check_info (info, "Rgges workspace query");
  const std::size_t lwork = checked_workspace (query.at (0, 0), "Rgges");
  MpfrMatrixStorage work (lwork, 1, precision);
  result.aa = MpfrMatrixStorage (n, n, precision, input_a);
  result.bb = MpfrMatrixStorage (n, n, precision, input_b);
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rgges ("V", "V", "N", mpfr_qz_no_selection, static_cast<Integer> (n),
           result.aa.data (), result.aa.leading_dimension (), result.bb.data (),
           result.bb.leading_dimension (), sdim, alphar.data (), alphai.data (),
           beta.data (), vsl.data (), vsl.leading_dimension (), vsr.data (),
           vsr.leading_dimension (), work.data (), static_cast<Integer> (lwork),
           bwork.get (), info);
  }
  check_info (info, "Rgges");
  result.q = transpose (vsl);
  result.z = vsr;
  return result;
}

MpcQzResult
run_mpc_qz (const MpfrComplexMatrixStorage& input_a,
            const MpfrComplexMatrixStorage& input_b)
{
  const auto precision = input_a.precision_bits ();
  const std::size_t n = input_a.rows ();
  MpcQzResult result { input_a, input_b,
                       MpfrComplexMatrixStorage (n, n, precision),
                       MpfrComplexMatrixStorage (n, n, precision) };
  MpfrComplexMatrixStorage alpha (n, 1, precision);
  MpfrComplexMatrixStorage beta (n, 1, precision);
  MpfrComplexMatrixStorage vsl (n, n, precision);
  MpfrComplexMatrixStorage vsr (n, n, precision);
  MpfrComplexMatrixStorage query (1, 1, precision);
  // Cgges follows LAPACK's 8*N real-workspace requirement, even when the
  // selected ordering is disabled.
  MpfrMatrixStorage rwork (std::max<std::size_t> (8 * n, 1), 1, precision);
  std::unique_ptr<bool[]> bwork (new bool[std::max<std::size_t> (n, 1)]);
  Integer sdim = 0;
  Integer info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    Cgges ("V", "V", "N", mpc_qz_no_selection, static_cast<Integer> (n),
           result.aa.data (), result.aa.leading_dimension (), result.bb.data (),
           result.bb.leading_dimension (), sdim, alpha.data (), beta.data (),
           vsl.data (), vsl.leading_dimension (), vsr.data (),
           vsr.leading_dimension (), query.data (), -1, rwork.data (),
           bwork.get (), info);
  }
  check_info (info, "Cgges workspace query");
  const std::size_t lwork = checked_complex_workspace (
    query.at (0, 0), "Cgges");
  MpfrComplexMatrixStorage work (lwork, 1, precision);
  result.aa = input_a;
  result.bb = input_b;
  info = 0;
  {
    MpfrMpcPrecisionScope scope (precision);
    Cgges ("V", "V", "N", mpc_qz_no_selection, static_cast<Integer> (n),
           result.aa.data (), result.aa.leading_dimension (), result.bb.data (),
           result.bb.leading_dimension (), sdim, alpha.data (), beta.data (),
           vsl.data (), vsl.leading_dimension (), vsr.data (),
           vsr.leading_dimension (), work.data (), static_cast<Integer> (lwork),
           rwork.data (), bwork.get (), info);
  }
  check_info (info, "Cgges");
  result.q = conjugate_transpose (vsl);
  result.z = vsr;
  return result;
}

} // namespace

MpHessResult
mplapack_mpfr_hess (const MpfrMatrixStorage& input)
{
  require_square (input.rows (), input.columns (), "hess");
  MpHessResult result { MpfrMatrixStorage (input.rows (), input.columns (),
                                            input.precision_bits ()),
                        MpfrMatrixStorage (input.rows (), input.columns (),
                                            input.precision_bits ()) };
  if (input.rows () == 0)
    {
      make_identity (result.p);
      return result;
    }
  result.h = run_mpfr_hess (input, result.p);
  return result;
}

MpcHessResult
mplapack_mpc_hess (const MpfrComplexMatrixStorage& input)
{
  require_square (input.rows (), input.columns (), "hess");
  MpcHessResult result {
    MpfrComplexMatrixStorage (input.rows (), input.columns (),
                              input.precision_bits ()),
    MpfrComplexMatrixStorage (input.rows (), input.columns (),
                              input.precision_bits ()) };
  if (input.rows () == 0)
    {
      make_identity (result.p);
      return result;
    }
  result.h = run_mpc_hess (input, result.p);
  return result;
}

MpSchurResult
mplapack_mpfr_schur (const MpfrMatrixStorage& input)
{
  require_square (input.rows (), input.columns (), "schur");
  MpSchurResult result { MpfrMatrixStorage (input.rows (), input.columns (),
                                             input.precision_bits ()),
                         MpfrMatrixStorage (input.rows (), input.columns (),
                                             input.precision_bits ()) };
  if (input.rows () == 0)
    {
      make_identity (result.u);
      return result;
    }
  result.s = run_mpfr_schur (input, result.u);
  return result;
}

MpcSchurResult
mplapack_mpc_schur (const MpfrComplexMatrixStorage& input)
{
  require_square (input.rows (), input.columns (), "schur");
  MpcSchurResult result {
    MpfrComplexMatrixStorage (input.rows (), input.columns (),
                               input.precision_bits()),
    MpfrComplexMatrixStorage (input.rows (), input.columns (),
                               input.precision_bits ()) };
  if (input.rows () == 0)
    {
      make_identity (result.u);
      return result;
    }
  result.s = run_mpc_schur (input, result.u);
  return result;
}

MpQzResult
mplapack_mpfr_qz (const MpfrMatrixStorage& input_a,
                  const MpfrMatrixStorage& input_b)
{
  require_square (input_a.rows (), input_a.columns (), "qz");
  require_square (input_b.rows (), input_b.columns (), "qz");
  if (input_a.rows () != input_b.rows ())
    throw std::invalid_argument ("qz requires equally sized matrix pairs");
  return run_mpfr_qz (input_a, input_b);
}

MpcQzResult
mplapack_mpc_qz (const MpfrComplexMatrixStorage& input_a,
                 const MpfrComplexMatrixStorage& input_b)
{
  require_square (input_a.rows (), input_a.columns (), "qz");
  require_square (input_b.rows (), input_b.columns (), "qz");
  if (input_a.rows () != input_b.rows ())
    throw std::invalid_argument ("qz requires equally sized matrix pairs");
  return run_mpc_qz (input_a, input_b);
}

} // namespace octave_mplapack
