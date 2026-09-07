// SPDX-License-Identifier: BSD-2-Clause

#include "mp_script_logic.h"

#include <algorithm>
#include <stdexcept>
#include <string>

namespace
{

std::size_t
compatible_dimension (std::size_t lhs, std::size_t rhs, const char *axis)
{
  if (lhs != rhs && lhs != 1 && rhs != 1)
    throw std::invalid_argument (std::string ("nonconformant ") + axis
                                 + " dimensions for logical operation");
  return std::max (lhs, rhs);
}

std::size_t
broadcast_index (std::size_t index, std::size_t dimension)
{
  return dimension == 1 ? 0 : index;
}

octave_mplapack::MpScriptLogicalResult
make_result (std::size_t rows, std::size_t columns)
{
  octave_mplapack::MpScriptLogicalResult result;
  result.rows = rows;
  result.columns = columns;
  result.values.assign (rows * columns, 0);
  return result;
}

bool
compare_real (mpfr_srcptr lhs, mpfr_srcptr rhs,
              octave_mplapack::MpScriptComparisonOperation operation)
{
  const bool nan = mpfr_nan_p (lhs) != 0 || mpfr_nan_p (rhs) != 0;
  if (nan)
    return operation == octave_mplapack::MpScriptComparisonOperation::not_equal;

  const int comparison = mpfr_cmp (lhs, rhs);
  switch (operation)
    {
    case octave_mplapack::MpScriptComparisonOperation::equal:
      return comparison == 0;
    case octave_mplapack::MpScriptComparisonOperation::not_equal:
      return comparison != 0;
    case octave_mplapack::MpScriptComparisonOperation::less:
      return comparison < 0;
    case octave_mplapack::MpScriptComparisonOperation::less_equal:
      return comparison <= 0;
    case octave_mplapack::MpScriptComparisonOperation::greater:
      return comparison > 0;
    case octave_mplapack::MpScriptComparisonOperation::greater_equal:
      return comparison >= 0;
    }
  throw std::logic_error ("unknown MPFR comparison operation");
}

bool
complex_equal (const mpc_ptr lhs, const mpc_ptr rhs)
{
  const bool nan = mpfr_nan_p (mpc_realref (lhs)) != 0
                   || mpfr_nan_p (mpc_imagref (lhs)) != 0
                   || mpfr_nan_p (mpc_realref (rhs)) != 0
                   || mpfr_nan_p (mpc_imagref (rhs)) != 0;
  if (nan)
    return false;
  return mpfr_cmp (mpc_realref (lhs), mpc_realref (rhs)) == 0
         && mpfr_cmp (mpc_imagref (lhs), mpc_imagref (rhs)) == 0;
}

bool
complex_nonzero (const mpc_ptr value)
{
  return mpfr_zero_p (mpc_realref (value)) == 0
         || mpfr_zero_p (mpc_imagref (value)) == 0;
}

} // namespace

namespace octave_mplapack
{

MpScriptLogicalResult
mpfr_script_compare (const MpfrElementwiseOperand& lhs,
                     const MpfrElementwiseOperand& rhs,
                     MpScriptComparisonOperation operation)
{
  const std::size_t rows = compatible_dimension (lhs.rows (), rhs.rows (),
                                                 "row");
  const std::size_t columns = compatible_dimension (lhs.columns (),
                                                    rhs.columns (), "column");
  MpScriptLogicalResult result = make_result (rows, columns);
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      result.values[row + column * rows]
        = compare_real (
            lhs.at (broadcast_index (row, lhs.rows ()),
                        broadcast_index (column, lhs.columns ())).mpfr_data (),
            rhs.at (broadcast_index (row, rhs.rows ()),
                    broadcast_index (column, rhs.columns ())).mpfr_data (),
            operation);
  return result;
}

MpScriptLogicalResult
mpc_script_compare (const MpcElementwiseOperand& lhs,
                    const MpcElementwiseOperand& rhs,
                    MpScriptComparisonOperation operation)
{
  if (operation != MpScriptComparisonOperation::equal
      && operation != MpScriptComparisonOperation::not_equal)
    throw std::invalid_argument (
      "ordered comparison is undefined for complex mp values");

  const std::size_t rows = compatible_dimension (lhs.rows (), rhs.rows (),
                                                 "row");
  const std::size_t columns = compatible_dimension (lhs.columns (),
                                                    rhs.columns (), "column");
  const mpfr_prec_t precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());
  MpScriptLogicalResult result = make_result (rows, columns);
  auto lhs_value = MpfrComplexMatrixStorage::NativeScalar::with_precision (
    precision);
  auto rhs_value = MpfrComplexMatrixStorage::NativeScalar::with_precision (
    precision);
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      {
        lhs.copy_to (lhs_value,
                     broadcast_index (row, lhs.rows ()),
                     broadcast_index (column, lhs.columns ()));
        rhs.copy_to (rhs_value,
                     broadcast_index (row, rhs.rows ()),
                     broadcast_index (column, rhs.columns ()));
        const bool equal = complex_equal (lhs_value.mpc_data (),
                                          rhs_value.mpc_data ());
        result.values[row + column * rows]
          = operation == MpScriptComparisonOperation::equal ? equal : ! equal;
      }
  return result;
}

MpScriptLogicalResult
mpfr_script_logical (const MpfrElementwiseOperand& source)
{
  MpScriptLogicalResult result = make_result (source.rows (), source.columns ());
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      result.values[row + column * result.rows]
        = mpfr_zero_p (source.at (row, column).mpfr_data ()) == 0;
  return result;
}

MpScriptLogicalResult
mpc_script_logical (const MpcElementwiseOperand& source)
{
  const mpfr_prec_t precision = source.precision_bits ();
  MpScriptLogicalResult result = make_result (source.rows (), source.columns ());
  auto value = MpfrComplexMatrixStorage::NativeScalar::with_precision (precision);
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      {
        source.copy_to (value, row, column);
        result.values[row + column * result.rows]
          = complex_nonzero (value.mpc_data ());
      }
  return result;
}

MpScriptLogicalResult
mpfr_script_logical_binary (const MpfrElementwiseOperand& lhs,
                            const MpfrElementwiseOperand& rhs,
                            MpScriptLogicalOperation operation)
{
  const std::size_t rows = compatible_dimension (lhs.rows (), rhs.rows (),
                                                 "row");
  const std::size_t columns = compatible_dimension (lhs.columns (),
                                                    rhs.columns (), "column");
  MpScriptLogicalResult result = make_result (rows, columns);
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      {
        const bool left = mpfr_zero_p (
          lhs.at (broadcast_index (row, lhs.rows ()),
                  broadcast_index (column, lhs.columns ())).mpfr_data ()) == 0;
        const bool right = mpfr_zero_p (
          rhs.at (broadcast_index (row, rhs.rows ()),
                  broadcast_index (column, rhs.columns ())).mpfr_data ()) == 0;
        bool value = false;
        if (operation == MpScriptLogicalOperation::and_op)
          value = left && right;
        else if (operation == MpScriptLogicalOperation::or_op)
          value = left || right;
        else
          value = left != right;
        result.values[row + column * rows] = value;
      }
  return result;
}

MpScriptLogicalResult
mpc_script_logical_binary (const MpcElementwiseOperand& lhs,
                           const MpcElementwiseOperand& rhs,
                           MpScriptLogicalOperation operation)
{
  const std::size_t rows = compatible_dimension (lhs.rows (), rhs.rows (),
                                                 "row");
  const std::size_t columns = compatible_dimension (lhs.columns (),
                                                    rhs.columns (), "column");
  const mpfr_prec_t precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());
  MpScriptLogicalResult result = make_result (rows, columns);
  auto lhs_value = MpfrComplexMatrixStorage::NativeScalar::with_precision (
    precision);
  auto rhs_value = MpfrComplexMatrixStorage::NativeScalar::with_precision (
    precision);
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      {
        lhs.copy_to (lhs_value,
                     broadcast_index (row, lhs.rows ()),
                     broadcast_index (column, lhs.columns ()));
        rhs.copy_to (rhs_value,
                     broadcast_index (row, rhs.rows ()),
                     broadcast_index (column, rhs.columns ()));
        const bool left = complex_nonzero (lhs_value.mpc_data ());
        const bool right = complex_nonzero (rhs_value.mpc_data ());
        bool value = false;
        if (operation == MpScriptLogicalOperation::and_op)
          value = left && right;
        else if (operation == MpScriptLogicalOperation::or_op)
          value = left || right;
        else
          value = left != right;
        result.values[row + column * rows] = value;
      }
  return result;
}

} // namespace octave_mplapack
