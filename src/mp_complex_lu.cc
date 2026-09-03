// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_lu.h"

#include <algorithm>
#include <limits>
#include <numeric>
#include <stdexcept>
#include <vector>

#include <mplapack_mpfr.h>

#include "mp_complex_blas.h"
#include "mp_complex_precision.h"

namespace octave_mplapack
{

void
require_mplapack_mpc_lu_precision_contract (
  mpfr_prec_t operation_precision,
  const MpfrComplexMatrixStorage& a_work)
{
  if (operation_precision < MPFR_PREC_MIN
      || operation_precision > MPFR_PREC_MAX)
    throw std::invalid_argument (
      "MPLAPACK MPC LU precision is outside the MPFR range");

  const auto precision_override = mpfrxx::mpc_precision_override_storage ();
  const bool matches
    = mpfrxx::default_precision_bits () == operation_precision
      && precision_override.active
      && precision_override.real_precision_bits == operation_precision
      && precision_override.imag_precision_bits == operation_precision
      && a_work.precision_bits () == operation_precision
      && a_work.all_elements_have_uniform_precision ();
  if (! matches)
    throw std::runtime_error (
      "MPLAPACK complex precision contract mismatch at Cgetrf boundary");
}

namespace
{

void
set_zero (mpc_ptr value)
{
  mpc_set_ui_ui (value, 0, 0, MPC_RND (MPFR_RNDN, MPFR_RNDN));
}

void
set_one (mpc_ptr value)
{
  mpc_set_ui_ui (value, 1, 0, MPC_RND (MPFR_RNDN, MPFR_RNDN));
}

} // namespace

MpcLuResult
mplapack_mpc_matrix_lu (const MpfrComplexMatrixStorage& input)
{
  const mpfr_prec_t operation_precision = input.precision_bits ();
  if (operation_precision < MPFR_PREC_MIN
      || operation_precision > MPFR_PREC_MAX)
    throw std::invalid_argument ("complex LU precision is outside the MPFR range");

  const std::size_t m = input.rows ();
  const std::size_t n = input.columns ();
  const std::size_t k = std::min (m, n);

  // Match the real M21 interface: every zero-dimensional input is normalized
  // to empty 0x0 outputs, and no zero-sized array is passed to Cgetrf.
  if (m == 0 || n == 0)
    return {MpfrComplexMatrixStorage (0, 0, operation_precision),
            MpfrComplexMatrixStorage (0, 0, operation_precision),
            MpfrComplexMatrixStorage (0, 0, operation_precision),
            std::vector<MpfrComplexMatrixStorage::MplapackInteger> (), 0};

  const auto m_arg = MpfrComplexMatrixStorage::checked_mplapack_dimension (m);
  const auto n_arg = MpfrComplexMatrixStorage::checked_mplapack_dimension (n);
  if (k > std::numeric_limits<std::size_t>::max ()
          / sizeof (MpfrComplexMatrixStorage::MplapackInteger)
      || m > std::numeric_limits<std::size_t>::max ()
           / sizeof (MpfrComplexMatrixStorage::MplapackInteger))
    throw std::overflow_error ("complex LU pivot allocation size overflow");

  // Cgetrf destructively overwrites A.  This is an operation-owned copy so
  // the public mp value retains value semantics even for singular factors.
  MpfrComplexMatrixStorage a_work
    = mplapack_mpc_matrix_copy_at_precision (input, operation_precision);
  std::vector<MpfrComplexMatrixStorage::MplapackInteger> ipiv (k);
  MpfrComplexMatrixStorage::MplapackInteger info = 0;
  {
    MpfrMpcPrecisionScope scope (operation_precision);
    require_mplapack_mpc_lu_precision_contract (operation_precision, a_work);
    Cgetrf (m_arg, n_arg, a_work.data (), a_work.leading_dimension (),
            ipiv.data (), info);
    require_mplapack_mpc_lu_precision_contract (operation_precision, a_work);
  }

  if (info < 0)
    throw MpcCgetrfError (MpcCgetrfError::Kind::invalid_argument, info,
                          "MPLAPACK Cgetrf rejected an argument");
  if (info > static_cast<MpfrComplexMatrixStorage::MplapackInteger> (k))
    throw MpcCgetrfError (MpcCgetrfError::Kind::internal, info,
                          "MPLAPACK Cgetrf returned an invalid INFO value");

  // IPIV is a sequence of swaps.  Replay it so permutation[d] is the source
  // row at destination row d, which is the public P*A and A(p,:) contract.
  std::vector<MpfrComplexMatrixStorage::MplapackInteger> permutation (m);
  std::iota (permutation.begin (), permutation.end (),
             static_cast<MpfrComplexMatrixStorage::MplapackInteger> (1));
  for (std::size_t step = 0; step < k; ++step)
    {
      const auto pivot = ipiv[step];
      if (pivot < 1 || pivot > m_arg)
        throw MpcCgetrfError (MpcCgetrfError::Kind::internal, 0,
                              "MPLAPACK Cgetrf returned an invalid pivot");
      std::swap (permutation[step],
                 permutation[static_cast<std::size_t> (pivot - 1)]);
    }

  std::vector<bool> seen (m, false);
  for (const auto source : permutation)
    {
      if (source < 1 || source > m_arg
          || seen[static_cast<std::size_t> (source - 1)])
        throw MpcCgetrfError (
          MpcCgetrfError::Kind::internal, 0,
          "MPLAPACK Cgetrf returned an invalid final permutation");
      seen[static_cast<std::size_t> (source - 1)] = true;
    }

  MpfrComplexMatrixStorage lower (m, k, operation_precision);
  MpfrComplexMatrixStorage upper (k, n, operation_precision);
  for (std::size_t column = 0; column < k; ++column)
    for (std::size_t row = 0; row < m; ++row)
      {
        if (row == column)
          set_one (lower.at (row, column).mpc_data ());
        else if (row > column)
          mpc_set (lower.at (row, column).mpc_data (),
                   a_work.at (row, column).mpc_data (),
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
        else
          set_zero (lower.at (row, column).mpc_data ());
      }
  for (std::size_t column = 0; column < n; ++column)
    for (std::size_t row = 0; row < k; ++row)
      {
        if (row <= column)
          mpc_set (upper.at (row, column).mpc_data (),
                   a_work.at (row, column).mpc_data (),
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
        else
          set_zero (upper.at (row, column).mpc_data ());
      }

  return {std::move (a_work), std::move (lower), std::move (upper),
          std::move (permutation), info};
}

} // namespace octave_mplapack
