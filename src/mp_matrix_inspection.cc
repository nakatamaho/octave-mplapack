// SPDX-License-Identifier: BSD-2-Clause

#include "mp_matrix_inspection.h"

#include <sstream>
#include <stdexcept>
#include <utility>

namespace octave_mplapack
{

MpfrMatrixStorage
select_matrix (const MpfrMatrixStorage& source,
               const std::vector<std::size_t>& row_indices,
               const std::vector<std::size_t>& column_indices)
{
  MpfrMatrixStorage result (row_indices.size (), column_indices.size (),
                            source.precision_bits ());
  for (std::size_t column = 0; column < column_indices.size (); ++column)
    {
      if (column_indices[column] >= source.columns ())
        throw std::out_of_range ("matrix column index out of range");
      for (std::size_t row = 0; row < row_indices.size (); ++row)
        {
          if (row_indices[row] >= source.rows ())
            throw std::out_of_range ("matrix row index out of range");
          mpfr_set (result.at (row, column).mpfr_data (),
                    source.at (row_indices[row], column_indices[column]).mpfr_data (),
                    MPFR_RNDN);
        }
    }
  return result;
}

MpfrMatrixStorage
select_linear (const MpfrMatrixStorage& source,
               const std::vector<std::size_t>& indices)
{
  MpfrMatrixStorage result (indices.size (), 1, source.precision_bits ());
  for (std::size_t row = 0; row < indices.size (); ++row)
    {
      if (indices[row] >= source.numel ())
        throw std::out_of_range ("matrix linear index out of range");
      mpfr_set (result.at (row, 0).mpfr_data (),
                source.data ()[indices[row]].mpfr_data (), MPFR_RNDN);
    }
  return result;
}

std::string
format_matrix (const MpfrMatrixStorage& source)
{
  std::ostringstream output;
  if (source.rows () == 0 || source.columns () == 0)
    {
      output << "mp " << source.rows () << 'x' << source.columns ()
             << " matrix []";
      return output.str ();
    }

  output << '[';
  for (std::size_t row = 0; row < source.rows (); ++row)
    {
      if (row != 0)
        output << "\n ";
      for (std::size_t column = 0; column < source.columns (); ++column)
        {
          if (column != 0)
            output << ' ';
          MpfrScalarStorage scalar (
            MpfrMatrixStorage::NativeScalar (source.at (row, column)));
          output << scalar.to_canonical_string ();
        }
    }
  output << ']';
  return output.str ();
}

} // namespace octave_mplapack
