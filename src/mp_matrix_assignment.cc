// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_assignment.h"

#include <limits>
#include <stdexcept>

namespace
{

std::size_t
checked_product (std::size_t lhs, std::size_t rhs)
{
  if (lhs != 0 && rhs > std::numeric_limits<std::size_t>::max () / lhs)
    throw std::overflow_error ("assignment selection size overflow");
  return lhs * rhs;
}

bool
is_scalar (const octave_mplapack::MpfrAssignmentOperand& rhs)
{
  return rhs.rows == 1 && rhs.columns == 1;
}

bool
is_vector (const octave_mplapack::MpfrAssignmentOperand& rhs)
{
  return rhs.rows == 1 || rhs.columns == 1;
}

void
validate_rhs (const octave_mplapack::MpfrAssignmentOperand& rhs)
{
  if (! rhs.copy_element)
    throw std::invalid_argument ("assignment RHS has no copier");
  (void) checked_product (rhs.rows, rhs.columns);
}

void
copy_rhs_element (octave_mplapack::MpfrMatrixStorage::NativeScalar& destination,
                  const octave_mplapack::MpfrAssignmentOperand& rhs,
                  std::size_t row, std::size_t column)
{
  rhs.copy_element (destination, row, column);
}

} // namespace

namespace octave_mplapack
{

MpfrMatrixStorage
mpfr_matrix_assign_two_subscript (
  const MpfrMatrixStorage& source,
  const std::vector<std::size_t>& row_indices,
  const std::vector<std::size_t>& column_indices,
  const MpfrAssignmentOperand& rhs,
  mpfr_prec_t result_precision)
{
  validate_rhs (rhs);
  const std::size_t selected_count
    = checked_product (row_indices.size (), column_indices.size ());

  // An empty selection is a structural no-op.  Empty RHS deletion is rejected
  // by the bridge before reaching this native operation.
  if (selected_count == 0)
    {
      if (! is_scalar (rhs) && checked_product (rhs.rows, rhs.columns) != 0)
        throw std::invalid_argument (
          "non-scalar RHS is not conformant with an empty selection");
      MpfrMatrixStorage result (source.rows (), source.columns (),
                                result_precision, source);
      return result;
    }

  const bool scalar_rhs = is_scalar (rhs);
  const bool exact_shape
    = rhs.rows == row_indices.size ()
      && rhs.columns == column_indices.size ();
  const bool vector_shape
    = ! exact_shape && ! scalar_rhs
      && (row_indices.size () == 1 || column_indices.size () == 1)
      && is_vector (rhs)
      && checked_product (rhs.rows, rhs.columns) == selected_count;
  if (! scalar_rhs && ! exact_shape && ! vector_shape)
    throw std::invalid_argument (
      "assignment RHS dimensions are not conformant with the selection");

  for (const std::size_t row : row_indices)
    if (row >= source.rows ())
      throw std::out_of_range ("assignment index is out of bounds");
  for (const std::size_t column : column_indices)
    if (column >= source.columns ())
      throw std::out_of_range ("assignment index is out of bounds");

  MpfrMatrixStorage result (source.rows (), source.columns (),
                            result_precision, source);
  for (std::size_t column = 0; column < column_indices.size (); ++column)
    for (std::size_t row = 0; row < row_indices.size (); ++row)
      {
        const std::size_t target_row = row_indices[row];
        const std::size_t target_column = column_indices[column];

        std::size_t rhs_row = 0;
        std::size_t rhs_column = 0;
        if (! scalar_rhs)
          {
            if (exact_shape)
              {
                rhs_row = row;
                rhs_column = column;
              }
            else
              {
                const std::size_t linear = row + column * row_indices.size ();
                rhs_row = linear % rhs.rows;
                rhs_column = linear / rhs.rows;
              }
          }
        copy_rhs_element (result.at (target_row, target_column), rhs,
                          rhs_row, rhs_column);
      }

  return result;
}

MpfrMatrixStorage
mpfr_matrix_assign_linear (const MpfrMatrixStorage& source,
                           const std::vector<std::size_t>& indices,
                           const MpfrAssignmentOperand& rhs,
                           mpfr_prec_t result_precision)
{
  validate_rhs (rhs);
  const std::size_t selected_count = indices.size ();
  if (selected_count == 0)
    {
      if (! is_scalar (rhs) && checked_product (rhs.rows, rhs.columns) != 0)
        throw std::invalid_argument (
          "non-scalar RHS is not conformant with an empty selection");
      MpfrMatrixStorage result (source.rows (), source.columns (),
                                result_precision, source);
      return result;
    }

  const bool scalar_rhs = is_scalar (rhs);
  const std::size_t rhs_count = checked_product (rhs.rows, rhs.columns);
  if (! scalar_rhs && rhs_count != selected_count)
    throw std::invalid_argument (
      "assignment RHS element count does not match linear selection");

  for (const std::size_t index : indices)
    if (index >= source.numel ())
      throw std::out_of_range ("assignment index is out of bounds");

  MpfrMatrixStorage result (source.rows (), source.columns (),
                            result_precision, source);
  for (std::size_t index = 0; index < selected_count; ++index)
    {
      std::size_t rhs_row = 0;
      std::size_t rhs_column = 0;
      if (! scalar_rhs)
        {
          rhs_row = index % rhs.rows;
          rhs_column = index / rhs.rows;
        }
      copy_rhs_element (result.data ()[indices[index]], rhs, rhs_row,
                        rhs_column);
    }

  return result;
}

} // namespace octave_mplapack
