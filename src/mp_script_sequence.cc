// SPDX-License-Identifier: BSD-2-Clause

#include "mp_script_sequence.h"

#include <algorithm>
#include <cmath>
#include <limits>
#include <stdexcept>
#include <utility>

#include "mp_complex_precision.h"

namespace
{

using namespace octave_mplapack;
using Real = MpfrScalarStorage::NativeScalar;
using Complex = MpfrComplexScalarStorage::NativeScalar;

bool
real_nan (const Real& value) noexcept
{
  return mpfr_nan_p (value.mpfr_data ()) != 0;
}

bool
complex_nan (const Complex& value) noexcept
{
  return mpfr_nan_p (mpc_realref (value.mpc_data ())) != 0
         || mpfr_nan_p (mpc_imagref (value.mpc_data ())) != 0;
}

int
compare_real (const Real& lhs, const Real& rhs) noexcept
{
  const bool lhs_nan = real_nan (lhs);
  const bool rhs_nan = real_nan (rhs);
  if (lhs_nan != rhs_nan)
    return lhs_nan ? 1 : -1;
  if (lhs_nan)
    return 0;
  return mpfr_cmp (lhs.mpfr_data (), rhs.mpfr_data ());
}

int
compare_complex (const Complex& lhs, const Complex& rhs)
{
  const bool lhs_nan = complex_nan (lhs);
  const bool rhs_nan = complex_nan (rhs);
  if (lhs_nan != rhs_nan)
    return lhs_nan ? 1 : -1;
  if (lhs_nan)
    return 0;

  const mpfr_prec_t precision
    = std::max (mpfr_get_prec (mpc_realref (lhs.mpc_data ())),
                mpfr_get_prec (mpc_realref (rhs.mpc_data ())));
  mpfr_t lhs_key;
  mpfr_t rhs_key;
  mpfr_init2 (lhs_key, precision);
  mpfr_init2 (rhs_key, precision);
  mpc_abs (lhs_key, lhs.mpc_data (), MPFR_RNDN);
  mpc_abs (rhs_key, rhs.mpc_data (), MPFR_RNDN);
  int result = mpfr_cmp (lhs_key, rhs_key);
  if (result == 0)
    {
      mpfr_atan2 (lhs_key, mpc_imagref (lhs.mpc_data ()),
                  mpc_realref (lhs.mpc_data ()), MPFR_RNDN);
      mpfr_atan2 (rhs_key, mpc_imagref (rhs.mpc_data ()),
                  mpc_realref (rhs.mpc_data ()), MPFR_RNDN);
      result = mpfr_cmp (lhs_key, rhs_key);
    }
  mpfr_clear (lhs_key);
  mpfr_clear (rhs_key);
  return result;
}

template <typename Storage>
std::size_t
input_index (const Storage& source, std::size_t position,
             std::size_t fixed, std::size_t dimension)
{
  return dimension == 1
    ? position + fixed * source.rows ()
    : fixed + position * source.rows ();
}

template <typename Storage>
std::size_t
sort_length (const Storage& source, std::size_t dimension)
{
  if (dimension != 1 && dimension != 2)
    throw std::invalid_argument ("sort dimension must be 1 or 2");
  return dimension == 1 ? source.rows () : source.columns ();
}

template <typename Storage>
std::size_t
sort_slices (const Storage& source, std::size_t dimension)
{
  return dimension == 1 ? source.columns () : source.rows ();
}

std::size_t
sort_output_index (std::size_t position, std::size_t fixed,
                   std::size_t rows, std::size_t dimension)
{
  return dimension == 1 ? position + fixed * rows : fixed + position * rows;
}

template <typename Compare, typename Storage, typename SetValue>
std::vector<std::size_t>
sort_indices (const Storage& source, std::size_t dimension, bool descending,
             Compare compare, SetValue set_value)
{
  const std::size_t length = sort_length (source, dimension);
  const std::size_t slices = sort_slices (source, dimension);
  std::vector<std::size_t> result (source.numel ());
  std::vector<std::size_t> order;
  order.reserve (length);
  for (std::size_t fixed = 0; fixed < slices; ++fixed)
    {
      order.clear ();
      for (std::size_t position = 0; position < length; ++position)
        order.push_back (input_index (source, position, fixed, dimension));
      std::stable_sort (order.begin (), order.end (),
                        [&] (std::size_t lhs, std::size_t rhs)
      {
        const int compared = compare (source.data ()[lhs], source.data ()[rhs]);
        return descending ? compared > 0 : compared < 0;
      });
      for (std::size_t position = 0; position < length; ++position)
        {
          const std::size_t destination
            = sort_output_index (position, fixed, source.rows (), dimension);
          // Public sort indices are one-based positions within the sorted
          // dimension, as in Octave (not global linear indices).
          result[destination] = dimension == 1
            ? order[position] % source.rows () + 1
            : order[position] / source.rows () + 1;
          set_value (destination, source.data ()[order[position]]);
        }
    }
  return result;
}

template <typename Storage, typename SetValue>
Storage
diff_once (const Storage& source, std::size_t dimension, SetValue set_value)
{
  if (dimension != 1 && dimension != 2)
    throw std::invalid_argument ("diff dimension must be 1 or 2");

  const std::size_t rows = source.rows ();
  const std::size_t columns = source.columns ();
  const std::size_t result_rows = dimension == 1 && rows > 0 ? rows - 1 : rows;
  const std::size_t result_columns
    = dimension == 2 && columns > 0 ? columns - 1 : columns;
  Storage result (result_rows, result_columns, source.precision_bits ());
  for (std::size_t column = 0; column < result_columns; ++column)
    for (std::size_t row = 0; row < result_rows; ++row)
      {
        const std::size_t lhs_row = dimension == 1 ? row + 1 : row;
        const std::size_t lhs_column = dimension == 1 ? column : column + 1;
        const std::size_t rhs_row = row;
        const std::size_t rhs_column = column;
        set_value (result.at (row, column), source.at (lhs_row, lhs_column),
                   source.at (rhs_row, rhs_column));
      }
  return result;
}

template <typename Storage, typename SetValue>
Storage
diff_result (const Storage& source, std::size_t order, std::size_t dimension,
             SetValue set_value)
{
  if (dimension != 1 && dimension != 2)
    throw std::invalid_argument ("diff dimension must be 1 or 2");
  if (order == 0)
    return source;

  Storage result = source;
  for (std::size_t iteration = 0; iteration < order; ++iteration)
    {
      if ((dimension == 1 && result.rows () == 0)
          || (dimension == 2 && result.columns () == 0))
        break;
      result = diff_once (result, dimension, set_value);
    }
  return result;
}

} // namespace

namespace octave_mplapack
{

MpScriptSortRealResult
mpfr_script_sort (const MpfrMatrixStorage& source, std::size_t dimension,
                  bool descending)
{
  MpfrMatrixStorage values (source.rows (), source.columns (),
                            source.precision_bits ());
  auto set_value = [&] (std::size_t destination, const auto& value)
  {
    mpfr_set (values.data ()[destination].mpfr_data (), value.mpfr_data (),
              MPFR_RNDN);
  };
  auto indices = sort_indices (source, dimension, descending,
                               [] (const auto& lhs, const auto& rhs)
                               { return compare_real (lhs, rhs); },
                               set_value);
  return {std::move (values), std::move (indices)};
}

MpScriptSortComplexResult
mpc_script_sort (const MpfrComplexMatrixStorage& source,
                 std::size_t dimension, bool descending)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage values (source.rows (), source.columns (),
                                   source.precision_bits ());
  auto set_value = [&] (std::size_t destination, const auto& value)
  {
    mpc_set (values.data ()[destination].mpc_data (), value.mpc_data (),
             MPC_RND (MPFR_RNDN, MPFR_RNDN));
  };
  auto indices = sort_indices (source, dimension, descending,
                               [] (const auto& lhs, const auto& rhs)
                               { return compare_complex (lhs, rhs); },
                               set_value);
  return {std::move (values), std::move (indices)};
}

MpfrMatrixStorage
mpfr_script_diff (const MpfrMatrixStorage& source, std::size_t order,
                  std::size_t dimension)
{
  return diff_result (source, order, dimension,
                      [] (auto& destination, const auto& lhs, const auto& rhs)
  {
    mpfr_sub (destination.mpfr_data (), lhs.mpfr_data (), rhs.mpfr_data (),
              MPFR_RNDN);
  });
}

MpfrComplexMatrixStorage
mpc_script_diff (const MpfrComplexMatrixStorage& source, std::size_t order,
                 std::size_t dimension)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  return diff_result (source, order, dimension,
                      [] (auto& destination, const auto& lhs, const auto& rhs)
  {
    mpc_sub (destination.mpc_data (), lhs.mpc_data (), rhs.mpc_data (),
             MPC_RND (MPFR_RNDN, MPFR_RNDN));
  });
}

} // namespace octave_mplapack
