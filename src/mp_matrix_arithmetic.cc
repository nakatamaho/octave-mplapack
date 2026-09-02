// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_arithmetic.h"

#include <algorithm>
#include <string>
#include <stdexcept>

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
{
  return source_dimension == 1 ? 0 : result_index;
}

void
apply_binary (mpfr_ptr destination, mpfr_srcptr lhs, mpfr_srcptr rhs,
              octave_mplapack::MpfrElementwiseBinaryOperation operation)
{
  switch (operation)
    {
    case octave_mplapack::MpfrElementwiseBinaryOperation::add:
      mpfr_add (destination, lhs, rhs, MPFR_RNDN);
      return;
    case octave_mplapack::MpfrElementwiseBinaryOperation::subtract:
      mpfr_sub (destination, lhs, rhs, MPFR_RNDN);
      return;
    case octave_mplapack::MpfrElementwiseBinaryOperation::multiply:
      mpfr_mul (destination, lhs, rhs, MPFR_RNDN);
      return;
    case octave_mplapack::MpfrElementwiseBinaryOperation::divide:
      mpfr_div (destination, lhs, rhs, MPFR_RNDN);
      return;
    }
  throw std::logic_error ("unknown element-wise operation");
}

} // namespace

namespace octave_mplapack
{

MpfrElementwiseOperand
MpfrElementwiseOperand::from_scalar (const MpfrScalarStorage& value) noexcept
{
  return {&value, nullptr};
}

MpfrElementwiseOperand
MpfrElementwiseOperand::from_matrix (const MpfrMatrixStorage& value) noexcept
{
  return {nullptr, &value};
}

bool
MpfrElementwiseOperand::is_scalar () const noexcept
{
  return scalar != nullptr;
}

mpfr_prec_t
MpfrElementwiseOperand::precision_bits () const
{
  if (scalar)
    return scalar->precision_bits ();
  if (matrix)
    return matrix->precision_bits ();
  throw std::invalid_argument ("empty element-wise operand");
}

std::size_t
MpfrElementwiseOperand::rows () const
{
  if (scalar)
    return 1;
  if (matrix)
    return matrix->rows ();
  throw std::invalid_argument ("empty element-wise operand");
}

std::size_t
MpfrElementwiseOperand::columns () const
{
  if (scalar)
    return 1;
  if (matrix)
    return matrix->columns ();
  throw std::invalid_argument ("empty element-wise operand");
}

const MpfrMatrixStorage::NativeScalar&
MpfrElementwiseOperand::at (std::size_t row, std::size_t column) const
{
  if (scalar)
    return scalar->native_value ();
  if (matrix)
    return matrix->at (row, column);
  throw std::invalid_argument ("empty element-wise operand");
}

MpfrMatrixStorage
mpfr_matrix_elementwise_binary (
  const MpfrElementwiseOperand& lhs,
  const MpfrElementwiseOperand& rhs,
  MpfrElementwiseBinaryOperation operation)
{
  const std::size_t result_rows
    = compatible_dimension (lhs.rows (), rhs.rows (), "row");
  const std::size_t result_columns
    = compatible_dimension (lhs.columns (), rhs.columns (), "column");
  const mpfr_prec_t result_precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());

  MpfrMatrixStorage result (result_rows, result_columns, result_precision);
  for (std::size_t column = 0; column < result_columns; ++column)
    for (std::size_t row = 0; row < result_rows; ++row)
      {
        const std::size_t lhs_row
          = broadcast_index (row, lhs.rows ());
        const std::size_t lhs_column
          = broadcast_index (column, lhs.columns ());
        const std::size_t rhs_row
          = broadcast_index (row, rhs.rows ());
        const std::size_t rhs_column
          = broadcast_index (column, rhs.columns ());
        apply_binary (result.at (row, column).mpfr_data (),
                      lhs.at (lhs_row, lhs_column).mpfr_data (),
                      rhs.at (rhs_row, rhs_column).mpfr_data (), operation);
      }
  return result;
}

MpfrMatrixStorage
mpfr_matrix_negate (const MpfrMatrixStorage& source)
{
  MpfrMatrixStorage result (source.rows (), source.columns (),
                            source.precision_bits ());
  for (std::size_t index = 0; index < source.numel (); ++index)
    mpfr_neg (result.data ()[index].mpfr_data (),
              source.data ()[index].mpfr_data (), MPFR_RNDN);
  return result;
}

} // namespace octave_mplapack
