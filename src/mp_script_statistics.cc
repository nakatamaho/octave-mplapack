// SPDX-License-Identifier: BSD-2-Clause

#include "mp_script_statistics.h"

#include <algorithm>
#include <limits>
#include <stdexcept>
#include <utility>
#include <vector>

#include "mp_complex_precision.h"

namespace
{

using namespace octave_mplapack;
using Real = MpfrScalarStorage::NativeScalar;
using Complex = MpfrComplexScalarStorage::NativeScalar;

bool
real_nan (const Real& value) noexcept
{ return mpfr_nan_p (value.mpfr_data ()) != 0; }

bool
complex_nan (const Complex& value) noexcept
{
  return mpfr_nan_p (mpc_realref (value.mpc_data ()))
         || mpfr_nan_p (mpc_imagref (value.mpc_data ()));
}

std::pair<std::size_t, std::size_t>
result_shape (std::size_t rows, std::size_t columns,
              const MpScriptStatisticsOptions& options)
{
  if (options.all)
    return {1, 1};
  if (options.dimension == 1)
    return {1, columns};
  if (options.dimension == 2)
    return {rows, 1};
  throw std::invalid_argument ("statistics dimension must be 1 or 2");
}

std::size_t
slice_count (std::size_t rows, std::size_t columns,
             const MpScriptStatisticsOptions& options)
{
  return options.all ? 1 : options.dimension == 1 ? columns : rows;
}

std::vector<std::size_t>
slice_indices (std::size_t rows, std::size_t columns,
               const MpScriptStatisticsOptions& options,
               std::size_t fixed)
{
  if (options.all)
    {
      std::vector<std::size_t> result;
      result.reserve (rows * columns);
      for (std::size_t index = 0; index < rows * columns; ++index)
        result.push_back (index);
      return result;
    }

  const std::size_t length = options.dimension == 1 ? rows : columns;
  std::vector<std::size_t> result;
  result.reserve (length);
  for (std::size_t position = 0; position < length; ++position)
    result.push_back (options.dimension == 1
      ? position + fixed * rows : fixed + position * rows);
  return result;
}

void
divide_by_count (mpfr_ptr value, std::size_t count)
{
  if (count > std::numeric_limits<unsigned long>::max ())
    throw std::overflow_error ("statistics count exceeds MPFR divisor range");
  mpfr_div_ui (value, value, static_cast<unsigned long> (count), MPFR_RNDN);
}

void
divide_complex_by_count (mpc_ptr value, std::size_t count)
{
  if (count > std::numeric_limits<unsigned long>::max ())
    throw std::overflow_error ("statistics count exceeds MPC divisor range");
  mpc_div_ui (value, value, static_cast<unsigned long> (count),
              MPC_RND (MPFR_RNDN, MPFR_RNDN));
}

bool
select_nan_policy_real (const MpfrMatrixStorage& source,
                        const std::vector<std::size_t>& indices,
                        const MpScriptStatisticsOptions& options,
                        std::size_t& used)
{
  used = 0;
  for (const std::size_t index : indices)
    {
      if (real_nan (source.data ()[index]))
        {
          if (! options.omit_nan)
            return true;
        }
      else
        ++used;
    }
  return false;
}

bool
select_nan_policy_complex (const MpfrComplexMatrixStorage& source,
                           const std::vector<std::size_t>& indices,
                           const MpScriptStatisticsOptions& options,
                           std::size_t& used)
{
  used = 0;
  for (const std::size_t index : indices)
    {
      if (complex_nan (source.data ()[index]))
        {
          if (! options.omit_nan)
            return true;
        }
      else
        ++used;
    }
  return false;
}

void
set_real_nan (mpfr_ptr value)
{ mpfr_set_nan (value); }

void
set_complex_nan (mpc_ptr value)
{ mpc_set_nan (value); }

Real
real_slice_mean (const MpfrMatrixStorage& source,
                 const std::vector<std::size_t>& indices,
                 const MpScriptStatisticsOptions& options,
                 std::size_t& used)
{
  Real result = Real::with_precision (source.precision_bits ());
  if (select_nan_policy_real (source, indices, options, used))
    {
      set_real_nan (result.mpfr_data ());
      return result;
    }
  mpfr_set_zero (result.mpfr_data (), 1);
  if (used == 0)
    {
      set_real_nan (result.mpfr_data ());
      return result;
    }
  for (const std::size_t index : indices)
    if (! real_nan (source.data ()[index]))
      mpfr_add (result.mpfr_data (), result.mpfr_data (),
                source.data ()[index].mpfr_data (), MPFR_RNDN);
  divide_by_count (result.mpfr_data (), used);
  return result;
}

Complex
complex_slice_mean (const MpfrComplexMatrixStorage& source,
                    const std::vector<std::size_t>& indices,
                    const MpScriptStatisticsOptions& options,
                    std::size_t& used)
{
  Complex result = Complex::with_precision (source.precision_bits ());
  if (select_nan_policy_complex (source, indices, options, used))
    {
      set_complex_nan (result.mpc_data ());
      return result;
    }
  mpc_set_ui (result.mpc_data (), 0, MPC_RND (MPFR_RNDN, MPFR_RNDN));
  if (used == 0)
    {
      set_complex_nan (result.mpc_data ());
      return result;
    }
  for (const std::size_t index : indices)
    if (! complex_nan (source.data ()[index]))
      mpc_add (result.mpc_data (), result.mpc_data (),
               source.data ()[index].mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
  divide_complex_by_count (result.mpc_data (), used);
  return result;
}

int
compare_complex (const Complex& lhs, const Complex& rhs)
{
  const mpfr_prec_t precision
    = std::max (mpfr_get_prec (mpc_realref (lhs.mpc_data ())),
                mpfr_get_prec (mpc_realref (rhs.mpc_data ())));
  mpfr_t left_key;
  mpfr_t right_key;
  mpfr_init2 (left_key, precision);
  mpfr_init2 (right_key, precision);
  mpc_abs (left_key, lhs.mpc_data (), MPFR_RNDN);
  mpc_abs (right_key, rhs.mpc_data (), MPFR_RNDN);
  int result = mpfr_cmp (left_key, right_key);
  if (result == 0)
    {
      mpfr_atan2 (left_key, mpc_imagref (lhs.mpc_data ()),
                  mpc_realref (lhs.mpc_data ()), MPFR_RNDN);
      mpfr_atan2 (right_key, mpc_imagref (rhs.mpc_data ()),
                  mpc_realref (rhs.mpc_data ()), MPFR_RNDN);
      result = mpfr_cmp (left_key, right_key);
    }
  mpfr_clear (left_key);
  mpfr_clear (right_key);
  return result;
}

template <typename Storage>
std::vector<std::size_t>
filtered_indices (const Storage& source,
                  const std::vector<std::size_t>& indices,
                  const MpScriptStatisticsOptions& options);

template <>
std::vector<std::size_t>
filtered_indices (const MpfrMatrixStorage& source,
                  const std::vector<std::size_t>& indices,
                  const MpScriptStatisticsOptions& options)
{
  std::vector<std::size_t> result;
  result.reserve (indices.size ());
  for (const std::size_t index : indices)
    if (! options.omit_nan || ! real_nan (source.data ()[index]))
      result.push_back (index);
  return result;
}

template <>
std::vector<std::size_t>
filtered_indices (const MpfrComplexMatrixStorage& source,
                  const std::vector<std::size_t>& indices,
                  const MpScriptStatisticsOptions& options)
{
  std::vector<std::size_t> result;
  result.reserve (indices.size ());
  for (const std::size_t index : indices)
    if (! options.omit_nan || ! complex_nan (source.data ()[index]))
      result.push_back (index);
  return result;
}

template <typename Storage>
bool
has_nan (const Storage& source, const std::vector<std::size_t>& indices);

template <>
bool
has_nan (const MpfrMatrixStorage& source,
         const std::vector<std::size_t>& indices)
{
  for (const std::size_t index : indices)
    if (real_nan (source.data ()[index]))
      return true;
  return false;
}

template <>
bool
has_nan (const MpfrComplexMatrixStorage& source,
         const std::vector<std::size_t>& indices)
{
  for (const std::size_t index : indices)
    if (complex_nan (source.data ()[index]))
      return true;
  return false;
}

} // namespace

namespace octave_mplapack
{

MpfrMatrixStorage
mpfr_script_mean (const MpfrMatrixStorage& source,
                  const MpScriptStatisticsOptions& options)
{
  const auto shape = result_shape (source.rows (), source.columns (), options);
  MpfrMatrixStorage result (shape.first, shape.second,
                            source.precision_bits ());
  const std::size_t slices = slice_count (source.rows (), source.columns (), options);
  for (std::size_t fixed = 0; fixed < slices; ++fixed)
    {
      const auto indices = slice_indices (source.rows (), source.columns (),
                                          options, fixed);
      std::size_t used = 0;
      const Real value = real_slice_mean (source, indices, options, used);
      const std::size_t row = options.all ? 0 : options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.all ? 0 : options.dimension == 1 ? fixed : 0;
      mpfr_set (result.at (row, column).mpfr_data (), value.mpfr_data (), MPFR_RNDN);
    }
  return result;
}

MpfrComplexMatrixStorage
mpc_script_mean (const MpfrComplexMatrixStorage& source,
                 const MpScriptStatisticsOptions& options)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  const auto shape = result_shape (source.rows (), source.columns (), options);
  MpfrComplexMatrixStorage result (shape.first, shape.second,
                                   source.precision_bits ());
  const std::size_t slices = slice_count (source.rows (), source.columns (), options);
  for (std::size_t fixed = 0; fixed < slices; ++fixed)
    {
      const auto indices = slice_indices (source.rows (), source.columns (),
                                          options, fixed);
      std::size_t used = 0;
      const Complex value = complex_slice_mean (source, indices, options, used);
      const std::size_t row = options.all ? 0 : options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.all ? 0 : options.dimension == 1 ? fixed : 0;
      mpc_set (result.at (row, column).mpc_data (), value.mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
    }
  return result;
}

MpfrMatrixStorage
mpfr_script_median (const MpfrMatrixStorage& source,
                    const MpScriptStatisticsOptions& options)
{
  const auto shape = result_shape (source.rows (), source.columns (), options);
  MpfrMatrixStorage result (shape.first, shape.second,
                            source.precision_bits ());
  const std::size_t slices = slice_count (source.rows (), source.columns (), options);
  for (std::size_t fixed = 0; fixed < slices; ++fixed)
    {
      const auto original = slice_indices (source.rows (), source.columns (),
                                           options, fixed);
      const bool nan = has_nan (source, original);
      auto indices = filtered_indices (source, original, options);
      const std::size_t row = options.all ? 0 : options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.all ? 0 : options.dimension == 1 ? fixed : 0;
      auto& output = result.at (row, column);
      if ((nan && ! options.omit_nan) || indices.empty ())
        {
          set_real_nan (output.mpfr_data ());
          continue;
        }
      std::stable_sort (indices.begin (), indices.end (), [&] (std::size_t lhs,
                                                                 std::size_t rhs)
      { return mpfr_cmp (source.data ()[lhs].mpfr_data (),
                         source.data ()[rhs].mpfr_data ()) < 0; });
      const std::size_t middle = indices.size () / 2;
      if (indices.size () % 2 != 0)
        mpfr_set (output.mpfr_data (), source.data ()[indices[middle]].mpfr_data (),
                  MPFR_RNDN);
      else
        {
          mpfr_add (output.mpfr_data (), source.data ()[indices[middle - 1]].mpfr_data (),
                    source.data ()[indices[middle]].mpfr_data (), MPFR_RNDN);
          divide_by_count (output.mpfr_data (), 2);
        }
    }
  return result;
}

MpfrComplexMatrixStorage
mpc_script_median (const MpfrComplexMatrixStorage& source,
                   const MpScriptStatisticsOptions& options)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  const auto shape = result_shape (source.rows (), source.columns (), options);
  MpfrComplexMatrixStorage result (shape.first, shape.second,
                                   source.precision_bits ());
  const std::size_t slices = slice_count (source.rows (), source.columns (), options);
  for (std::size_t fixed = 0; fixed < slices; ++fixed)
    {
      const auto original = slice_indices (source.rows (), source.columns (),
                                           options, fixed);
      const bool nan = has_nan (source, original);
      auto indices = filtered_indices (source, original, options);
      const std::size_t row = options.all ? 0 : options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.all ? 0 : options.dimension == 1 ? fixed : 0;
      auto& output = result.at (row, column);
      if ((nan && ! options.omit_nan) || indices.empty ())
        {
          set_complex_nan (output.mpc_data ());
          continue;
        }
      std::stable_sort (indices.begin (), indices.end (), [&] (std::size_t lhs,
                                                                 std::size_t rhs)
      { return compare_complex (source.data ()[lhs], source.data ()[rhs]) < 0; });
      const std::size_t middle = indices.size () / 2;
      if (indices.size () % 2 != 0)
        mpc_set (output.mpc_data (), source.data ()[indices[middle]].mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
      else
        {
          mpc_add (output.mpc_data (), source.data ()[indices[middle - 1]].mpc_data (),
                   source.data ()[indices[middle]].mpc_data (),
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
          divide_complex_by_count (output.mpc_data (), 2);
        }
    }
  return result;
}

MpScriptVarianceRealResult
mpfr_script_variance (const MpfrMatrixStorage& source,
                      const MpScriptStatisticsOptions& options,
                      bool standard_deviation)
{
  const auto shape = result_shape (source.rows (), source.columns (), options);
  MpfrMatrixStorage values (shape.first, shape.second, source.precision_bits ());
  MpfrMatrixStorage means (shape.first, shape.second, source.precision_bits ());
  const std::size_t slices = slice_count (source.rows (), source.columns (), options);
  for (std::size_t fixed = 0; fixed < slices; ++fixed)
    {
      const auto indices = slice_indices (source.rows (), source.columns (),
                                          options, fixed);
      std::size_t used = 0;
      const Real mean = real_slice_mean (source, indices, options, used);
      const std::size_t row = options.all ? 0 : options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.all ? 0 : options.dimension == 1 ? fixed : 0;
      auto& output_mean = means.at (row, column);
      mpfr_set (output_mean.mpfr_data (), mean.mpfr_data (), MPFR_RNDN);
      auto& output = values.at (row, column);
      if (mpfr_nan_p (mean.mpfr_data ()) || used == 0)
        {
          set_real_nan (output.mpfr_data ());
          continue;
        }
      if (used == 1)
        {
          mpfr_set_zero (output.mpfr_data (), 1);
          continue;
        }
      Real sum = Real::with_precision (source.precision_bits ());
      Real delta = Real::with_precision (source.precision_bits ());
      mpfr_set_zero (sum.mpfr_data (), 1);
      for (const std::size_t index : indices)
        if (! real_nan (source.data ()[index]))
          {
            mpfr_sub (delta.mpfr_data (), source.data ()[index].mpfr_data (),
                      mean.mpfr_data (), MPFR_RNDN);
            mpfr_fma (sum.mpfr_data (), delta.mpfr_data (), delta.mpfr_data (),
                      sum.mpfr_data (), MPFR_RNDN);
          }
      const std::size_t denominator
        = options.correction == 0 ? used - 1 : used;
      if (denominator == 0)
        set_real_nan (output.mpfr_data ());
      else
        {
          mpfr_set (output.mpfr_data (), sum.mpfr_data (), MPFR_RNDN);
          divide_by_count (output.mpfr_data (), denominator);
          if (standard_deviation)
            mpfr_sqrt (output.mpfr_data (), output.mpfr_data (), MPFR_RNDN);
        }
    }
  return {std::move (values), std::move (means)};
}

MpScriptVarianceComplexResult
mpc_script_variance (const MpfrComplexMatrixStorage& source,
                     const MpScriptStatisticsOptions& options,
                     bool standard_deviation)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  const auto shape = result_shape (source.rows (), source.columns (), options);
  MpfrMatrixStorage values (shape.first, shape.second, source.precision_bits ());
  MpfrComplexMatrixStorage means (shape.first, shape.second,
                                  source.precision_bits ());
  const std::size_t slices = slice_count (source.rows (), source.columns (), options);
  for (std::size_t fixed = 0; fixed < slices; ++fixed)
    {
      const auto indices = slice_indices (source.rows (), source.columns (),
                                          options, fixed);
      std::size_t used = 0;
      const Complex mean = complex_slice_mean (source, indices, options, used);
      const std::size_t row = options.all ? 0 : options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.all ? 0 : options.dimension == 1 ? fixed : 0;
      mpc_set (means.at (row, column).mpc_data (), mean.mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
      auto& output = values.at (row, column);
      if (mpfr_nan_p (mpc_realref (mean.mpc_data ()))
          || mpfr_nan_p (mpc_imagref (mean.mpc_data ())) || used == 0)
        {
          set_real_nan (output.mpfr_data ());
          continue;
        }
      if (used == 1)
        {
          mpfr_set_zero (output.mpfr_data (), 1);
          continue;
        }
      Real sum = Real::with_precision (source.precision_bits ());
      Real delta = Real::with_precision (source.precision_bits ());
      Real magnitude = Real::with_precision (source.precision_bits ());
      mpfr_set_zero (sum.mpfr_data (), 1);
      Complex difference = Complex::with_precision (source.precision_bits ());
      for (const std::size_t index : indices)
        if (! complex_nan (source.data ()[index]))
          {
            mpc_sub (difference.mpc_data (), source.data ()[index].mpc_data (),
                     mean.mpc_data (), MPC_RND (MPFR_RNDN, MPFR_RNDN));
            mpc_abs (magnitude.mpfr_data (), difference.mpc_data (), MPFR_RNDN);
            mpfr_mul (delta.mpfr_data (), magnitude.mpfr_data (),
                      magnitude.mpfr_data (), MPFR_RNDN);
            mpfr_add (sum.mpfr_data (), sum.mpfr_data (), delta.mpfr_data (),
                      MPFR_RNDN);
          }
      const std::size_t denominator
        = options.correction == 0 ? used - 1 : used;
      if (denominator == 0)
        set_real_nan (output.mpfr_data ());
      else
        {
          mpfr_set (output.mpfr_data (), sum.mpfr_data (), MPFR_RNDN);
          divide_by_count (output.mpfr_data (), denominator);
          if (standard_deviation)
            mpfr_sqrt (output.mpfr_data (), output.mpfr_data (), MPFR_RNDN);
        }
    }
  return {std::move (values), std::move (means)};
}

MpfrMatrixStorage
mpfr_script_range (const MpfrMatrixStorage& source,
                   const MpScriptStatisticsOptions& options)
{
  const auto bounds = mpfr_script_bounds (source, options);
  MpfrMatrixStorage result (bounds.lower.rows (), bounds.lower.columns (),
                            source.precision_bits ());
  for (std::size_t index = 0; index < result.numel (); ++index)
    mpfr_sub (result.data ()[index].mpfr_data (), bounds.upper.data ()[index].mpfr_data (),
              bounds.lower.data ()[index].mpfr_data (), MPFR_RNDN);
  return result;
}

MpfrComplexMatrixStorage
mpc_script_range (const MpfrComplexMatrixStorage& source,
                  const MpScriptStatisticsOptions& options)
{
  const auto bounds = mpc_script_bounds (source, options);
  MpfrComplexMatrixStorage result (bounds.lower.rows (), bounds.lower.columns (),
                                   source.precision_bits ());
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  for (std::size_t index = 0; index < result.numel (); ++index)
    mpc_sub (result.data ()[index].mpc_data (), bounds.upper.data ()[index].mpc_data (),
             bounds.lower.data ()[index].mpc_data (),
             MPC_RND (MPFR_RNDN, MPFR_RNDN));
  return result;
}

MpScriptBoundsRealResult
mpfr_script_bounds (const MpfrMatrixStorage& source,
                    const MpScriptStatisticsOptions& options)
{
  const auto shape = result_shape (source.rows (), source.columns (), options);
  MpfrMatrixStorage lower (shape.first, shape.second, source.precision_bits ());
  MpfrMatrixStorage upper (shape.first, shape.second, source.precision_bits ());
  const std::size_t slices = slice_count (source.rows (), source.columns (), options);
  for (std::size_t fixed = 0; fixed < slices; ++fixed)
    {
      const auto original = slice_indices (source.rows (), source.columns (),
                                           options, fixed);
      const bool nan = has_nan (source, original);
      const auto indices = filtered_indices (source, original, options);
      const std::size_t row = options.all ? 0 : options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.all ? 0 : options.dimension == 1 ? fixed : 0;
      auto& lo = lower.at (row, column);
      auto& hi = upper.at (row, column);
      if ((nan && ! options.omit_nan) || indices.empty ())
        {
          set_real_nan (lo.mpfr_data ());
          set_real_nan (hi.mpfr_data ());
          continue;
        }
      mpfr_set (lo.mpfr_data (), source.data ()[indices.front ()].mpfr_data (), MPFR_RNDN);
      mpfr_set (hi.mpfr_data (), lo.mpfr_data (), MPFR_RNDN);
      for (const std::size_t index : indices)
        {
          if (mpfr_cmp (source.data ()[index].mpfr_data (), lo.mpfr_data ()) < 0)
            mpfr_set (lo.mpfr_data (), source.data ()[index].mpfr_data (), MPFR_RNDN);
          if (mpfr_cmp (source.data ()[index].mpfr_data (), hi.mpfr_data ()) > 0)
            mpfr_set (hi.mpfr_data (), source.data ()[index].mpfr_data (), MPFR_RNDN);
        }
    }
  return {std::move (lower), std::move (upper)};
}

MpScriptBoundsComplexResult
mpc_script_bounds (const MpfrComplexMatrixStorage& source,
                   const MpScriptStatisticsOptions& options)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  const auto shape = result_shape (source.rows (), source.columns (), options);
  MpfrComplexMatrixStorage lower (shape.first, shape.second,
                                  source.precision_bits ());
  MpfrComplexMatrixStorage upper (shape.first, shape.second,
                                  source.precision_bits ());
  const std::size_t slices = slice_count (source.rows (), source.columns (), options);
  for (std::size_t fixed = 0; fixed < slices; ++fixed)
    {
      const auto original = slice_indices (source.rows (), source.columns (),
                                           options, fixed);
      const bool nan = has_nan (source, original);
      const auto indices = filtered_indices (source, original, options);
      const std::size_t row = options.all ? 0 : options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.all ? 0 : options.dimension == 1 ? fixed : 0;
      auto& lo = lower.at (row, column);
      auto& hi = upper.at (row, column);
      if ((nan && ! options.omit_nan) || indices.empty ())
        {
          set_complex_nan (lo.mpc_data ());
          set_complex_nan (hi.mpc_data ());
          continue;
        }
      mpc_set (lo.mpc_data (), source.data ()[indices.front ()].mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
      mpc_set (hi.mpc_data (), lo.mpc_data (), MPC_RND (MPFR_RNDN, MPFR_RNDN));
      for (const std::size_t index : indices)
        {
          if (compare_complex (source.data ()[index], lo) < 0)
            mpc_set (lo.mpc_data (), source.data ()[index].mpc_data (),
                    MPC_RND (MPFR_RNDN, MPFR_RNDN));
          if (compare_complex (source.data ()[index], hi) > 0)
            mpc_set (hi.mpc_data (), source.data ()[index].mpc_data (),
                    MPC_RND (MPFR_RNDN, MPFR_RNDN));
        }
    }
  return {std::move (lower), std::move (upper)};
}

} // namespace octave_mplapack
