// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_arithmetic.h"

#include <algorithm>
#include <string>
#include <stdexcept>
#include <utility>

#include "mp_complex_precision.h"

namespace
{

std::size_t
compatible_dimension (std::size_t lhs, std::size_t rhs,
                      const char *dimension_name)
{
  if (lhs == rhs)
    return lhs;
  if (lhs == 1)
    return rhs;
  if (rhs == 1)
    return lhs;
  throw std::invalid_argument (std::string ("nonconformant ")
                               + dimension_name
                               + " dimensions for element-wise operation");
}

std::size_t
broadcast_index (std::size_t result_index, std::size_t source_dimension)
{ return source_dimension == 1 ? 0 : result_index; }

void
apply_binary (mpc_ptr destination, mpc_srcptr lhs, mpc_srcptr rhs,
              octave_mplapack::MpcElementwiseBinaryOperation operation)
{
  const mpc_rnd_t rounding = MPC_RND (MPFR_RNDN, MPFR_RNDN);
  switch (operation)
    {
    case octave_mplapack::MpcElementwiseBinaryOperation::add:
      mpc_add (destination, lhs, rhs, rounding);
      return;
    case octave_mplapack::MpcElementwiseBinaryOperation::subtract:
      mpc_sub (destination, lhs, rhs, rounding);
      return;
    case octave_mplapack::MpcElementwiseBinaryOperation::multiply:
      mpc_mul (destination, lhs, rhs, rounding);
      return;
    case octave_mplapack::MpcElementwiseBinaryOperation::divide:
      mpc_div (destination, lhs, rhs, rounding);
      return;
    }
  throw std::logic_error ("unknown complex element-wise operation");
}

} // namespace

namespace octave_mplapack
{

MpcElementwiseOperand
MpcElementwiseOperand::from_real_scalar (
  const MpfrScalarStorage& value) noexcept
{ return {&value, nullptr, nullptr, nullptr}; }

MpcElementwiseOperand
MpcElementwiseOperand::from_real_matrix (
  const MpfrMatrixStorage& value) noexcept
{ return {nullptr, &value, nullptr, nullptr}; }

MpcElementwiseOperand
MpcElementwiseOperand::from_complex_scalar (
  const MpfrComplexScalarStorage& value) noexcept
{ return {nullptr, nullptr, &value, nullptr}; }

MpcElementwiseOperand
MpcElementwiseOperand::from_complex_matrix (
  const MpfrComplexMatrixStorage& value) noexcept
{ return {nullptr, nullptr, nullptr, &value}; }

bool
MpcElementwiseOperand::is_scalar () const noexcept
{ return real_scalar || complex_scalar; }

bool
MpcElementwiseOperand::is_complex () const noexcept
{ return complex_scalar || complex_matrix; }

mpfr_prec_t
MpcElementwiseOperand::precision_bits () const
{
  if (real_scalar)
    return real_scalar->precision_bits ();
  if (real_matrix)
    return real_matrix->precision_bits ();
  if (complex_scalar)
    return complex_scalar->precision_bits ();
  if (complex_matrix)
    return complex_matrix->precision_bits ();
  throw std::invalid_argument ("empty complex element-wise operand");
}

std::size_t
MpcElementwiseOperand::rows () const
{
  if (is_scalar ())
    return 1;
  if (real_matrix)
    return real_matrix->rows ();
  if (complex_matrix)
    return complex_matrix->rows ();
  throw std::invalid_argument ("empty complex element-wise operand");
}

std::size_t
MpcElementwiseOperand::columns () const
{
  if (is_scalar ())
    return 1;
  if (real_matrix)
    return real_matrix->columns ();
  if (complex_matrix)
    return complex_matrix->columns ();
  throw std::invalid_argument ("empty complex element-wise operand");
}

void
MpcElementwiseOperand::copy_to (
  MpfrComplexMatrixStorage::NativeScalar& destination,
  std::size_t row, std::size_t column) const
{
  if (complex_scalar)
    {
      mpc_set (destination.mpc_data (),
               complex_scalar->native_value ().mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
      return;
    }
  if (complex_matrix)
    {
      mpc_set (destination.mpc_data (),
               complex_matrix->at (row, column).mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
      return;
    }
  if (real_scalar)
    {
      mpc_set_fr (destination.mpc_data (),
                  real_scalar->native_value ().mpfr_data (),
                  MPC_RND (MPFR_RNDN, MPFR_RNDN));
      return;
    }
  if (real_matrix)
    {
      mpc_set_fr (destination.mpc_data (),
                  real_matrix->at (row, column).mpfr_data (),
                  MPC_RND (MPFR_RNDN, MPFR_RNDN));
      return;
    }
  throw std::invalid_argument ("empty complex element-wise operand");
}

MpfrComplexMatrixStorage
mpc_matrix_elementwise_binary (
  const MpcElementwiseOperand& lhs,
  const MpcElementwiseOperand& rhs,
  MpcElementwiseBinaryOperation operation)
{
  const std::size_t result_rows
    = compatible_dimension (lhs.rows (), rhs.rows (), "row");
  const std::size_t result_columns
    = compatible_dimension (lhs.columns (), rhs.columns (), "column");
  const mpfr_prec_t result_precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());

  MpfrMpcPrecisionScope scope (result_precision);
  MpfrComplexMatrixStorage result (result_rows, result_columns,
                                   result_precision);
  auto lhs_value = MpfrComplexMatrixStorage::NativeScalar::with_precision (
    result_precision);
  auto rhs_value = MpfrComplexMatrixStorage::NativeScalar::with_precision (
    result_precision);
  for (std::size_t column = 0; column < result_columns; ++column)
    for (std::size_t row = 0; row < result_rows; ++row)
      {
        lhs.copy_to (lhs_value,
                     broadcast_index (row, lhs.rows ()) ,
                     broadcast_index (column, lhs.columns ()));
        rhs.copy_to (rhs_value,
                     broadcast_index (row, rhs.rows ()) ,
                     broadcast_index (column, rhs.columns ()));
        apply_binary (result.at (row, column).mpc_data (),
                      lhs_value.mpc_data (), rhs_value.mpc_data (), operation);
      }
  return result;
}

MpfrComplexMatrixStorage
mpc_matrix_negate (const MpfrComplexMatrixStorage& source)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (source.rows (), source.columns (),
                                   source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    mpc_neg (result.data ()[index].mpc_data (),
             source.data ()[index].mpc_data (),
             MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

MpfrComplexScalarStorage
mpc_scalar_negate (const MpfrComplexScalarStorage& source)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexScalarStorage::NativeScalar result
    = MpfrComplexScalarStorage::NativeScalar::with_precision (
        source.precision_bits ());
  mpc_neg (result.mpc_data (), source.native_value ().mpc_data (),
           MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return MpfrComplexScalarStorage (std::move (result));
}

} // namespace octave_mplapack
