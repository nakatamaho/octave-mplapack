// SPDX-License-Identifier: BSD-2-Clause

#include "mp_script_ranges.h"

#include <algorithm>
#include <cmath>
#include <limits>
#include <stdexcept>
#include <string>

#include "mp_complex_precision.h"

namespace
{

using Real = octave_mplapack::MpfrScalarStorage::NativeScalar;
using Complex = octave_mplapack::MpfrComplexScalarStorage::NativeScalar;

Real
copy_real (const Real& source, mpfr_prec_t precision)
{
  Real result = Real::with_precision (precision);
  mpfr_set (result.mpfr_data (), source.mpfr_data (), MPFR_RNDN);
  return result;
}

Complex
copy_complex (const Complex& source, mpfr_prec_t precision)
{
  Complex result = Complex::with_precision (precision);
  mpc_set (result.mpc_data (), source.mpc_data (),
           MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

std::size_t
compatible_dimension (std::size_t lhs, std::size_t rhs,
                      const char *dimension)
{
  if (lhs == rhs)
    return lhs;
  if (lhs == 1)
    return rhs;
  if (rhs == 1)
    return lhs;
  throw std::invalid_argument (std::string ("nonconformant ") + dimension
                               + " dimensions for utility operation");
}

std::size_t
broadcast_index (std::size_t index, std::size_t source_dimension)
{
  return source_dimension == 1 ? 0 : index;
}

int
normalized_sign (const Real& value)
{
  return mpfr_sgn (value.mpfr_data ());
}

void
check_finite_range_endpoint (const Real& value)
{
  if (mpfr_nan_p (value.mpfr_data ()) || mpfr_inf_p (value.mpfr_data ()))
    throw std::invalid_argument ("range endpoints must be finite");
}

void
check_range_size (std::size_t count)
{
  octave_mplapack::MpfrMatrixStorage::checked_mplapack_dimension (count);
}

} // namespace

namespace octave_mplapack
{

MpfrMatrixStorage
mpfr_script_colon (const MpfrScalarStorage& first,
                   const MpfrScalarStorage& step,
                   const MpfrScalarStorage& last)
{
  const mpfr_prec_t precision = first.precision_bits ();
  check_finite_range_endpoint (first.native_value ());
  check_finite_range_endpoint (step.native_value ());
  check_finite_range_endpoint (last.native_value ());
  if (mpfr_zero_p (step.native_value ().mpfr_data ()))
    throw std::invalid_argument ("range step must not be zero");

  const int step_sign = normalized_sign (step.native_value ());
  const int endpoint_order
    = mpfr_cmp (first.native_value ().mpfr_data (),
                last.native_value ().mpfr_data ());
  if ((step_sign > 0 && endpoint_order > 0)
      || (step_sign < 0 && endpoint_order < 0))
    return MpfrMatrixStorage (1, 0, precision);

  Real current = copy_real (first.native_value (), precision);
  std::size_t count = 0;
  while ((step_sign > 0
          && mpfr_cmp (current.mpfr_data (), last.native_value ().mpfr_data ()) <= 0)
         || (step_sign < 0
             && mpfr_cmp (current.mpfr_data (), last.native_value ().mpfr_data ()) >= 0))
    {
      if (count == std::numeric_limits<std::size_t>::max ())
        throw std::overflow_error ("range element count overflow");
      ++count;
      check_range_size (count);
      Real next = Real::with_precision (precision);
      mpfr_add (next.mpfr_data (), current.mpfr_data (),
                step.native_value ().mpfr_data (), MPFR_RNDN);
      if (mpfr_equal_p (next.mpfr_data (), current.mpfr_data ()))
        throw std::invalid_argument ("range step is too small at this precision");
      current = std::move (next);
    }

  MpfrMatrixStorage result (1, count, precision);
  current = copy_real (first.native_value (), precision);
  for (std::size_t index = 0; index < count; ++index)
    {
      mpfr_set (result.at (0, index).mpfr_data (), current.mpfr_data (),
                MPFR_RNDN);
      Real next = Real::with_precision (precision);
      mpfr_add (next.mpfr_data (), current.mpfr_data (),
                step.native_value ().mpfr_data (), MPFR_RNDN);
      current = std::move (next);
    }
  return result;
}

MpfrMatrixStorage
mpfr_script_linspace (const MpfrScalarStorage& first,
                      const MpfrScalarStorage& last, std::size_t count)
{
  check_range_size (count);
  const mpfr_prec_t precision = first.precision_bits ();
  MpfrMatrixStorage result (1, count, precision);
  if (count == 0)
    return result;
  if (count == 1)
    {
      mpfr_set (result.at (0, 0).mpfr_data (), last.native_value ().mpfr_data (),
                MPFR_RNDN);
      return result;
    }

  Real delta = Real::with_precision (precision);
  mpfr_sub (delta.mpfr_data (), last.native_value ().mpfr_data (),
            first.native_value ().mpfr_data (), MPFR_RNDN);
  for (std::size_t index = 0; index < count; ++index)
    {
      if (index == 0)
        mpfr_set (result.at (0, index).mpfr_data (),
                  first.native_value ().mpfr_data (), MPFR_RNDN);
      else if (index + 1 == count)
        mpfr_set (result.at (0, index).mpfr_data (),
                  last.native_value ().mpfr_data (), MPFR_RNDN);
      else
        {
          Real increment = Real::with_precision (precision);
          mpfr_mul_ui (increment.mpfr_data (), delta.mpfr_data (),
                       static_cast<unsigned long> (index), MPFR_RNDN);
          mpfr_div_ui (increment.mpfr_data (), increment.mpfr_data (),
                       static_cast<unsigned long> (count - 1), MPFR_RNDN);
          mpfr_add (result.at (0, index).mpfr_data (),
                    first.native_value ().mpfr_data (), increment.mpfr_data (),
                    MPFR_RNDN);
        }
    }
  return result;
}

MpfrComplexMatrixStorage
mpc_script_linspace (const MpfrComplexScalarStorage& first,
                     const MpfrComplexScalarStorage& last,
                     std::size_t count)
{
  check_range_size (count);
  const mpfr_prec_t precision = first.precision_bits ();
  MpfrMpcPrecisionScope scope (precision);
  MpfrComplexMatrixStorage result (1, count, precision);
  if (count == 0)
    return result;
  if (count == 1)
    {
      mpc_set (result.at (0, 0).mpc_data (), last.native_value ().mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
      return result;
    }

  Complex delta = Complex::with_precision (precision);
  mpc_sub (delta.mpc_data (), last.native_value ().mpc_data (),
           first.native_value ().mpc_data (), MPC_RND (MPFR_RNDN, MPFR_RNDN));
  for (std::size_t index = 0; index < count; ++index)
    {
      if (index == 0)
        mpc_set (result.at (0, index).mpc_data (),
                 first.native_value ().mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
      else if (index + 1 == count)
        mpc_set (result.at (0, index).mpc_data (),
                 last.native_value ().mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
      else
        {
          Complex increment = Complex::with_precision (precision);
          mpc_mul_ui (increment.mpc_data (), delta.mpc_data (),
                      static_cast<unsigned long> (index),
                      MPC_RND (MPFR_RNDN, MPFR_RNDN));
          mpc_div_ui (increment.mpc_data (), increment.mpc_data (),
                      static_cast<unsigned long> (count - 1),
                      MPC_RND (MPFR_RNDN, MPFR_RNDN));
          mpc_add (result.at (0, index).mpc_data (),
                   first.native_value ().mpc_data (), increment.mpc_data (),
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
        }
    }
  return result;
}

MpfrMatrixStorage
mpfr_script_logspace (const MpfrScalarStorage& first,
                      const MpfrScalarStorage& last, std::size_t count)
{
  check_range_size (count);
  const mpfr_prec_t precision = first.precision_bits ();
  MpfrMatrixStorage result (1, count, precision);
  if (count == 0)
    return result;

  Real ten = Real::with_precision (precision);
  mpfr_set_ui (ten.mpfr_data (), 10, MPFR_RNDN);
  Real pi = Real::with_precision (precision);
  mpfr_const_pi (pi.mpfr_data (), MPFR_RNDN);
  const bool octave_pi_endpoint
    = mpfr_equal_p (last.native_value ().mpfr_data (), pi.mpfr_data ())
      || mpfr_cmp_d (last.native_value ().mpfr_data (), std::acos (-1.0)) == 0;

  if (count == 1)
    {
      if (octave_pi_endpoint)
        mpfr_set (result.at (0, 0).mpfr_data (), last.native_value ().mpfr_data (),
                  MPFR_RNDN);
      else
        mpfr_pow (result.at (0, 0).mpfr_data (), ten.mpfr_data (),
                  last.native_value ().mpfr_data (), MPFR_RNDN);
      return result;
    }

  Real delta = Real::with_precision (precision);
  mpfr_sub (delta.mpfr_data (), last.native_value ().mpfr_data (),
            first.native_value ().mpfr_data (), MPFR_RNDN);
  for (std::size_t index = 0; index < count; ++index)
    {
      if (index + 1 == count && octave_pi_endpoint)
        {
          mpfr_set (result.at (0, index).mpfr_data (),
                    last.native_value ().mpfr_data (), MPFR_RNDN);
          continue;
        }
      Real exponent = Real::with_precision (precision);
      if (index == 0)
        mpfr_set (exponent.mpfr_data (), first.native_value ().mpfr_data (),
                  MPFR_RNDN);
      else if (index + 1 == count)
        mpfr_set (exponent.mpfr_data (), last.native_value ().mpfr_data (),
                  MPFR_RNDN);
      else
        {
          mpfr_mul_ui (exponent.mpfr_data (), delta.mpfr_data (),
                       static_cast<unsigned long> (index), MPFR_RNDN);
          mpfr_div_ui (exponent.mpfr_data (), exponent.mpfr_data (),
                       static_cast<unsigned long> (count - 1), MPFR_RNDN);
          mpfr_add (exponent.mpfr_data (), exponent.mpfr_data (),
                    first.native_value ().mpfr_data (), MPFR_RNDN);
        }
      mpfr_pow (result.at (0, index).mpfr_data (), ten.mpfr_data (),
                exponent.mpfr_data (), MPFR_RNDN);
    }
  return result;
}

MpfrMatrixStorage
mpfr_script_round (const MpfrMatrixStorage& source,
                   MpScriptRoundingOperation operation)
{
  MpfrMatrixStorage result (source.rows (), source.columns (),
                            source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    {
      mpfr_ptr destination = result.data ()[index].mpfr_data ();
      mpfr_srcptr input = source.data ()[index].mpfr_data ();
      switch (operation)
        {
        case MpScriptRoundingOperation::floor: mpfr_floor (destination, input); break;
        case MpScriptRoundingOperation::ceil: mpfr_ceil (destination, input); break;
        case MpScriptRoundingOperation::fix: mpfr_trunc (destination, input); break;
        case MpScriptRoundingOperation::round: mpfr_round (destination, input); break;
        }
    }
  return result;
}

MpfrMatrixStorage
mpfr_script_remainder (const MpfrMatrixStorage& lhs,
                       const MpfrMatrixStorage& rhs, bool modulus)
{
  const std::size_t rows = compatible_dimension (lhs.rows (), rhs.rows (), "row");
  const std::size_t columns
    = compatible_dimension (lhs.columns (), rhs.columns (), "column");
  const mpfr_prec_t precision = std::max (lhs.precision_bits (),
                                          rhs.precision_bits ());
  MpfrMatrixStorage result (rows, columns, precision);
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      {
        const auto& left = lhs.at (broadcast_index (row, lhs.rows ()),
                                   broadcast_index (column, lhs.columns ()));
        const auto& right = rhs.at (broadcast_index (row, rhs.rows ()),
                                    broadcast_index (column, rhs.columns ()));
        Real left_value = copy_real (left, precision);
        Real right_value = copy_real (right, precision);
        Real remainder = Real::with_precision (precision);
        mpfr_fmod (remainder.mpfr_data (), left_value.mpfr_data (),
                   right_value.mpfr_data (), MPFR_RNDN);
        if (modulus && ! mpfr_zero_p (remainder.mpfr_data ())
            && mpfr_signbit (remainder.mpfr_data ())
                 != mpfr_signbit (right_value.mpfr_data ()))
          mpfr_add (remainder.mpfr_data (), remainder.mpfr_data (),
                    right_value.mpfr_data (), MPFR_RNDN);
        mpfr_set (result.at (row, column).mpfr_data (),
                  remainder.mpfr_data (), MPFR_RNDN);
      }
  return result;
}

MpfrMatrixStorage
mpfr_script_hypot (const MpfrMatrixStorage& lhs,
                   const MpfrMatrixStorage& rhs)
{
  const std::size_t rows = compatible_dimension (lhs.rows (), rhs.rows (), "row");
  const std::size_t columns
    = compatible_dimension (lhs.columns (), rhs.columns (), "column");
  const mpfr_prec_t precision = std::max (lhs.precision_bits (),
                                          rhs.precision_bits ());
  MpfrMatrixStorage result (rows, columns, precision);
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      mpfr_hypot (result.at (row, column).mpfr_data (),
                  lhs.at (broadcast_index (row, lhs.rows ()),
                          broadcast_index (column, lhs.columns ())).mpfr_data (),
                  rhs.at (broadcast_index (row, rhs.rows ()),
                          broadcast_index (column, rhs.columns ())).mpfr_data (),
                  MPFR_RNDN);
  return result;
}

MpfrMatrixStorage
mpfr_script_atan2 (const MpfrMatrixStorage& y,
                   const MpfrMatrixStorage& x)
{
  const std::size_t rows = compatible_dimension (y.rows (), x.rows (), "row");
  const std::size_t columns
    = compatible_dimension (y.columns (), x.columns (), "column");
  const mpfr_prec_t precision = std::max (y.precision_bits (),
                                          x.precision_bits ());
  MpfrMatrixStorage result (rows, columns, precision);
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      mpfr_atan2 (result.at (row, column).mpfr_data (),
                  y.at (broadcast_index (row, y.rows ()),
                        broadcast_index (column, y.columns ())).mpfr_data (),
                  x.at (broadcast_index (row, x.rows ()),
                        broadcast_index (column, x.columns ())).mpfr_data (),
                  MPFR_RNDN);
  return result;
}

MpfrMatrixStorage
mpfr_script_eps (const MpfrMatrixStorage& source)
{
  MpfrMatrixStorage result (source.rows (), source.columns (),
                            source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    {
      Real next = copy_real (source.data ()[index],
                             source.precision_bits ());
      mpfr_nextabove (next.mpfr_data ());
      mpfr_sub (result.data ()[index].mpfr_data (), next.mpfr_data (),
                source.data ()[index].mpfr_data (), MPFR_RNDN);
    }
  return result;
}

} // namespace octave_mplapack
