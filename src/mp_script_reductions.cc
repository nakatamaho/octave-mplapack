// SPDX-License-Identifier: BSD-2-Clause

#include "mp_script_reductions.h"

#include <algorithm>
#include <stdexcept>
#include <utility>

#include <mpfr.h>

#include "mp_complex_precision.h"

namespace
{

using namespace octave_mplapack;

std::size_t
reduced_length (const MpfrMatrixStorage& source, std::size_t dimension)
{ return dimension == 1 ? source.rows () : source.columns (); }

std::size_t
result_rows (const MpfrMatrixStorage& source, const MpScriptReductionOptions& options)
{ return options.all ? 1 : (options.dimension == 1 ? 1 : source.rows ()); }

std::size_t
result_columns (const MpfrMatrixStorage& source,
                const MpScriptReductionOptions& options)
{ return options.all ? 1 : (options.dimension == 1 ? source.columns () : 1); }

void
validate_options (const MpScriptReductionOptions& options)
{
  if (options.dimension != 1 && options.dimension != 2)
    throw std::invalid_argument ("reduction dimension must be 1 or 2");
}

void
validate_nonempty_dimension (const MpfrMatrixStorage& source,
                             const MpScriptReductionOptions& options)
{
  validate_options (options);
  if (options.all)
    return;
  (void) reduced_length (source, options.dimension);
}

bool
real_nan (mpfr_srcptr value) noexcept
{ return mpfr_nan_p (value) != 0; }

bool
complex_nan (mpc_srcptr value) noexcept
{ return mpfr_nan_p (mpc_realref (value)) || mpfr_nan_p (mpc_imagref (value)); }

void
set_real_identity (mpfr_ptr value, bool product)
{ mpfr_set_ui (value, product ? 1 : 0, MPFR_RNDN); }

void
set_complex_identity (mpc_ptr value, bool product)
{ mpc_set_ui (value, product ? 1 : 0, MPC_RND (MPFR_RNDN, MPFR_RNDN)); }

void
real_accumulate (mpfr_ptr accumulator, mpfr_srcptr value,
                 MpScriptReductionOperation operation)
{
  if (operation == MpScriptReductionOperation::sum
      || operation == MpScriptReductionOperation::cumsum)
    mpfr_add (accumulator, accumulator, value, MPFR_RNDN);
  else if (operation == MpScriptReductionOperation::prod
           || operation == MpScriptReductionOperation::cumprod)
    mpfr_mul (accumulator, accumulator, value, MPFR_RNDN);
  else
    mpfr_fma (accumulator, value, value, accumulator, MPFR_RNDN);
}

void
complex_accumulate (mpc_ptr accumulator, mpc_srcptr value,
                    MpScriptReductionOperation operation)
{
  const mpc_rnd_t rounding = MPC_RND (MPFR_RNDN, MPFR_RNDN);
  if (operation == MpScriptReductionOperation::sum
      || operation == MpScriptReductionOperation::cumsum)
    mpc_add (accumulator, accumulator, value, rounding);
  else
    mpc_mul (accumulator, accumulator, value, rounding);
}

void
complex_sumsq_accumulate (mpfr_ptr accumulator, mpc_srcptr value)
{
  mpfr_t magnitude;
  mpfr_init2 (magnitude, mpfr_get_prec (accumulator));
  mpc_abs (magnitude, value, MPFR_RNDN);
  mpfr_fma (accumulator, magnitude, magnitude, accumulator, MPFR_RNDN);
  mpfr_clear (magnitude);
}

MpfrMatrixStorage
mpfr_reduce_general (const MpfrMatrixStorage& source,
                      MpScriptReductionOperation operation,
                      const MpScriptReductionOptions& options)
{
  validate_nonempty_dimension (source, options);
  if (operation == MpScriptReductionOperation::cumsum
      || operation == MpScriptReductionOperation::cumprod)
    {
      MpfrMatrixStorage result (source.rows (), source.columns (),
                                source.precision_bits ());
      const std::size_t length = reduced_length (source, options.dimension);
      const bool product = operation == MpScriptReductionOperation::cumprod;
      for (std::size_t fixed = 0; fixed < (options.dimension == 1
                                            ? source.columns () : source.rows ());
           ++fixed)
        {
          typename MpfrMatrixStorage::NativeScalar accumulator
            = MpfrMatrixStorage::NativeScalar::with_precision (
                source.precision_bits ());
          set_real_identity (accumulator.mpfr_data (), product);
          for (std::size_t step = 0; step < length; ++step)
            {
              const std::size_t position
                = options.reverse ? length - 1 - step : step;
              const std::size_t row = options.dimension == 1 ? position : fixed;
              const std::size_t column = options.dimension == 1 ? fixed : position;
              const auto& value = source.at (row, column);
              if (! (options.omit_nan && real_nan (value.mpfr_data ())))
                real_accumulate (accumulator.mpfr_data (), value.mpfr_data (),
                                 operation);
              mpfr_set (result.at (row, column).mpfr_data (),
                        accumulator.mpfr_data (), MPFR_RNDN);
            }
        }
      return result;
    }

  MpfrMatrixStorage result (result_rows (source, options),
                            result_columns (source, options),
                            source.precision_bits ());
  const bool product = operation == MpScriptReductionOperation::prod;
  if (options.all)
    {
      auto& output = result.at (0, 0);
      set_real_identity (output.mpfr_data (), product);
      for (std::size_t index = 0; index < source.numel (); ++index)
        {
          const auto& value = source.data ()[index];
          if (! (options.omit_nan && real_nan (value.mpfr_data ())))
            real_accumulate (output.mpfr_data (), value.mpfr_data (), operation);
        }
      return result;
    }

  const std::size_t length = reduced_length (source, options.dimension);
  for (std::size_t fixed = 0; fixed < (options.dimension == 1
                                        ? source.columns () : source.rows ());
       ++fixed)
    {
      const std::size_t row = options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.dimension == 1 ? fixed : 0;
      auto& output = result.at (row, column);
      set_real_identity (output.mpfr_data (), product);
      for (std::size_t step = 0; step < length; ++step)
        {
          const std::size_t position
            = options.reverse ? length - 1 - step : step;
          const std::size_t source_row = options.dimension == 1 ? position : fixed;
          const std::size_t source_column = options.dimension == 1 ? fixed : position;
          const auto& value = source.at (source_row, source_column);
          if (! (options.omit_nan && real_nan (value.mpfr_data ())))
            real_accumulate (output.mpfr_data (), value.mpfr_data (), operation);
        }
    }
  return result;
}

MpfrComplexMatrixStorage
mpc_reduce_general (const MpfrComplexMatrixStorage& source,
                     MpScriptReductionOperation operation,
                     const MpScriptReductionOptions& options)
{
  validate_options (options);
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  if (operation == MpScriptReductionOperation::cumsum
      || operation == MpScriptReductionOperation::cumprod)
    {
      MpfrComplexMatrixStorage result (source.rows (), source.columns (),
                                       source.precision_bits ());
      const std::size_t length = options.dimension == 1 ? source.rows () : source.columns ();
      const bool product = operation == MpScriptReductionOperation::cumprod;
      for (std::size_t fixed = 0; fixed < (options.dimension == 1
                                            ? source.columns () : source.rows ());
           ++fixed)
        {
          auto accumulator
            = MpfrComplexMatrixStorage::NativeScalar::with_precision (
                source.precision_bits ());
          set_complex_identity (accumulator.mpc_data (), product);
          for (std::size_t step = 0; step < length; ++step)
            {
              const std::size_t position
                = options.reverse ? length - 1 - step : step;
              const std::size_t row = options.dimension == 1 ? position : fixed;
              const std::size_t column = options.dimension == 1 ? fixed : position;
              const auto& value = source.at (row, column);
              if (! (options.omit_nan && complex_nan (value.mpc_data ())))
                complex_accumulate (accumulator.mpc_data (), value.mpc_data (),
                                    operation);
              mpc_set (result.at (row, column).mpc_data (), accumulator.mpc_data (),
                       MPC_RND (MPFR_RNDN, MPFR_RNDN));
            }
        }
      return result;
    }

  MpfrComplexMatrixStorage result (
    options.all ? 1 : (options.dimension == 1 ? 1 : source.rows ()),
    options.all ? 1 : (options.dimension == 1 ? source.columns () : 1),
    source.precision_bits ());
  const bool product = operation == MpScriptReductionOperation::prod;
  if (options.all)
    {
      auto& output = result.at (0, 0);
      set_complex_identity (output.mpc_data (), product);
      for (std::size_t index = 0; index < source.numel (); ++index)
        {
          const auto& value = source.data ()[index];
          if (! (options.omit_nan && complex_nan (value.mpc_data ())))
            complex_accumulate (output.mpc_data (), value.mpc_data (), operation);
        }
      return result;
    }

  const std::size_t length = options.dimension == 1 ? source.rows () : source.columns ();
  for (std::size_t fixed = 0; fixed < (options.dimension == 1
                                        ? source.columns () : source.rows ());
       ++fixed)
    {
      const std::size_t row = options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.dimension == 1 ? fixed : 0;
      auto& output = result.at (row, column);
      set_complex_identity (output.mpc_data (), product);
      for (std::size_t step = 0; step < length; ++step)
        {
          const std::size_t position
            = options.reverse ? length - 1 - step : step;
          const std::size_t source_row = options.dimension == 1 ? position : fixed;
          const std::size_t source_column = options.dimension == 1 ? fixed : position;
          const auto& value = source.at (source_row, source_column);
          if (! (options.omit_nan && complex_nan (value.mpc_data ())))
            complex_accumulate (output.mpc_data (), value.mpc_data (), operation);
        }
    }
  return result;
}

int
compare_real (mpfr_srcptr lhs, mpfr_srcptr rhs,
              MpScriptExtremumOperation operation)
{
  const int compared = mpfr_cmp (lhs, rhs);
  if (operation == MpScriptExtremumOperation::minimum)
    return compared < 0 ? -1 : compared > 0;
  return compared > 0 ? -1 : compared < 0;
}

int
compare_complex (mpc_srcptr lhs, mpc_srcptr rhs,
                 MpScriptExtremumOperation operation,
                 MpScriptComparisonMethod method)
{
  mpfr_t left_key;
  mpfr_t right_key;
  mpfr_init2 (left_key, mpfr_get_prec (mpc_realref (lhs)));
  mpfr_init2 (right_key, mpfr_get_prec (mpc_realref (rhs)));
  if (method == MpScriptComparisonMethod::real)
    {
      mpfr_set (left_key, mpc_realref (lhs), MPFR_RNDN);
      mpfr_set (right_key, mpc_realref (rhs), MPFR_RNDN);
    }
  else
    {
      mpc_abs (left_key, lhs, MPFR_RNDN);
      mpc_abs (right_key, rhs, MPFR_RNDN);
    }
  int result = compare_real (left_key, right_key, operation);
  if (result == 0
      && (method == MpScriptComparisonMethod::automatic
          || method == MpScriptComparisonMethod::absolute))
    {
      mpfr_atan2 (left_key, mpc_imagref (lhs), mpc_realref (lhs), MPFR_RNDN);
      mpfr_atan2 (right_key, mpc_imagref (rhs), mpc_realref (rhs), MPFR_RNDN);
      result = compare_real (left_key, right_key, operation);
    }
  if (result == 0 && method == MpScriptComparisonMethod::real)
    result = compare_real (mpc_imagref (lhs), mpc_imagref (rhs), operation);
  mpfr_clear (left_key);
  mpfr_clear (right_key);
  return result;
}

} // namespace

namespace octave_mplapack
{

MpfrMatrixStorage
mpfr_script_reduce (const MpfrMatrixStorage& source,
                    MpScriptReductionOperation operation,
                    const MpScriptReductionOptions& options)
{ return mpfr_reduce_general (source, operation, options); }

MpfrComplexMatrixStorage
mpc_script_reduce (const MpfrComplexMatrixStorage& source,
                   MpScriptReductionOperation operation,
                   const MpScriptReductionOptions& options)
{ return mpc_reduce_general (source, operation, options); }

MpfrMatrixStorage
mpc_script_sumsq (const MpfrComplexMatrixStorage& source,
                  const MpScriptReductionOptions& options)
{
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  validate_options (options);
  MpfrMatrixStorage result (
    options.all ? 1 : (options.dimension == 1 ? 1 : source.rows ()),
    options.all ? 1 : (options.dimension == 1 ? source.columns () : 1),
    source.precision_bits ());
  if (options.all)
    {
      auto& output = result.at (0, 0);
      set_real_identity (output.mpfr_data (), false);
      for (std::size_t index = 0; index < source.numel (); ++index)
        if (! (options.omit_nan && complex_nan (source.data ()[index].mpc_data ())))
          complex_sumsq_accumulate (output.mpfr_data (),
                                    source.data ()[index].mpc_data ());
      return result;
    }
  const std::size_t length = options.dimension == 1 ? source.rows () : source.columns ();
  for (std::size_t fixed = 0; fixed < (options.dimension == 1
                                        ? source.columns () : source.rows ());
       ++fixed)
    {
      const std::size_t row = options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.dimension == 1 ? fixed : 0;
      auto& output = result.at (row, column);
      set_real_identity (output.mpfr_data (), false);
      for (std::size_t step = 0; step < length; ++step)
        {
          const std::size_t position
            = options.reverse ? length - 1 - step : step;
          const std::size_t source_row = options.dimension == 1 ? position : fixed;
          const std::size_t source_column = options.dimension == 1 ? fixed : position;
          const auto& value = source.at (source_row, source_column);
          if (! (options.omit_nan && complex_nan (value.mpc_data ())))
            complex_sumsq_accumulate (output.mpfr_data (), value.mpc_data ());
        }
    }
  return result;
}

MpfrMatrixStorage
mpfr_script_reduce (const MpfrMatrixStorage& source,
                    MpScriptReductionOperation operation,
                    const MpScriptReductionOptions& options);

MpScriptExtremumResultReal
mpfr_script_extremum (const MpfrMatrixStorage& source,
                      MpScriptExtremumOperation operation,
                      const MpScriptExtremumOptions& options)
{
  validate_options (options);
  MpfrMatrixStorage result (
    options.all ? 1 : (options.dimension == 1 ? 1 : source.rows ()),
    options.all ? 1 : (options.dimension == 1 ? source.columns () : 1),
    source.precision_bits ());
  std::vector<std::size_t> indices (result.numel (), 0);
  const auto choose = [&] (mpfr_ptr output, std::size_t& selected,
                           const std::vector<std::size_t>& candidates)
  {
    bool initialized = false;
    for (const std::size_t index : candidates)
      {
        const auto& value = source.data ()[index];
        if (options.omit_nan && real_nan (value.mpfr_data ()))
          continue;
        const bool value_is_nan = real_nan (value.mpfr_data ());
        if (value_is_nan && ! options.omit_nan)
          {
            mpfr_set (output, value.mpfr_data (), MPFR_RNDN);
            selected = index;
            initialized = true;
            break;
          }
        if (! initialized || real_nan (output)
            || (! value_is_nan
                && compare_real (value.mpfr_data (), output, operation) < 0))
          {
            mpfr_set (output, value.mpfr_data (), MPFR_RNDN);
            selected = index;
            initialized = true;
          }
        if (real_nan (value.mpfr_data ()))
          break;
      }
    if (! initialized)
      mpfr_set_nan (output);
  };

  if (options.all)
    {
      std::vector<std::size_t> candidates (source.numel ());
      for (std::size_t index = 0; index < source.numel (); ++index)
        candidates[index] = index;
      std::size_t selected = 0;
      choose (result.at (0, 0).mpfr_data (), selected, candidates);
      indices[0] = (real_nan (result.at (0, 0).mpfr_data ())
                    && options.omit_nan) ? 0 : selected + 1;
      return {std::move (result), std::move (indices)};
    }

  const std::size_t length = options.dimension == 1 ? source.rows () : source.columns ();
  for (std::size_t fixed = 0; fixed < (options.dimension == 1
                                        ? source.columns () : source.rows ());
       ++fixed)
    {
      std::vector<std::size_t> candidates;
      candidates.reserve (length);
      for (std::size_t position = 0; position < length; ++position)
        candidates.push_back (options.dimension == 1
          ? position + fixed * source.rows ()
          : fixed + position * source.rows ());
      const std::size_t row = options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.dimension == 1 ? fixed : 0;
      std::size_t selected = 0;
      choose (result.at (row, column).mpfr_data (), selected, candidates);
      indices[row + column * result.rows ()]
        = (real_nan (result.at (row, column).mpfr_data ())
           && options.omit_nan)
          ? 0 : (options.dimension == 1 ? selected % source.rows ()
                                        : selected / source.rows ()) + 1;
    }
  return {std::move (result), std::move (indices)};
}

MpScriptExtremumResultComplex
mpc_script_extremum (const MpfrComplexMatrixStorage& source,
                     MpScriptExtremumOperation operation,
                     const MpScriptExtremumOptions& options)
{
  validate_options (options);
  MpfrMpcPrecisionScope scope (source.precision_bits ());
  MpfrComplexMatrixStorage result (
    options.all ? 1 : (options.dimension == 1 ? 1 : source.rows ()),
    options.all ? 1 : (options.dimension == 1 ? source.columns () : 1),
    source.precision_bits ());
  std::vector<std::size_t> indices (result.numel (), 0);
  const auto choose = [&] (mpc_ptr output, std::size_t& selected,
                           const std::vector<std::size_t>& candidates)
  {
    bool initialized = false;
    for (const std::size_t index : candidates)
      {
        const auto& value = source.data ()[index];
        if (options.omit_nan && complex_nan (value.mpc_data ()))
          continue;
        const bool value_is_nan = complex_nan (value.mpc_data ());
        const bool output_is_nan = complex_nan (output);
        if (value_is_nan && ! options.omit_nan)
          {
            mpc_set (output, value.mpc_data (), MPC_RND (MPFR_RNDN, MPFR_RNDN));
            selected = index;
            initialized = true;
            break;
          }
        if (! initialized || output_is_nan
            || (! value_is_nan
                && compare_complex (value.mpc_data (), output, operation,
                                    options.comparison) < 0))
          {
            mpc_set (output, value.mpc_data (), MPC_RND (MPFR_RNDN, MPFR_RNDN));
            selected = index;
            initialized = true;
          }
        if (value_is_nan)
          break;
      }
    if (! initialized)
      mpc_set_nan (output);
  };

  if (options.all)
    {
      std::vector<std::size_t> candidates (source.numel ());
      for (std::size_t index = 0; index < source.numel (); ++index)
        candidates[index] = index;
      std::size_t selected = 0;
      choose (result.at (0, 0).mpc_data (), selected, candidates);
      indices[0] = (complex_nan (result.at (0, 0).mpc_data ())
                    && options.omit_nan) ? 0 : selected + 1;
      return {std::move (result), std::move (indices)};
    }

  const std::size_t length = options.dimension == 1 ? source.rows () : source.columns ();
  for (std::size_t fixed = 0; fixed < (options.dimension == 1
                                        ? source.columns () : source.rows ());
       ++fixed)
    {
      std::vector<std::size_t> candidates;
      candidates.reserve (length);
      for (std::size_t position = 0; position < length; ++position)
        candidates.push_back (options.dimension == 1
          ? position + fixed * source.rows ()
          : fixed + position * source.rows ());
      const std::size_t row = options.dimension == 1 ? 0 : fixed;
      const std::size_t column = options.dimension == 1 ? fixed : 0;
      std::size_t selected = 0;
      choose (result.at (row, column).mpc_data (), selected, candidates);
      indices[row + column * result.rows ()]
        = (complex_nan (result.at (row, column).mpc_data ())
           && options.omit_nan)
          ? 0 : (options.dimension == 1 ? selected % source.rows ()
                                        : selected / source.rows ()) + 1;
    }
  return {std::move (result), std::move (indices)};
}

MpScriptExtremumResultReal
mpfr_script_extremum_pair (const MpfrMatrixStorage& lhs,
                           const MpfrMatrixStorage& rhs,
                           MpScriptExtremumOperation operation,
                           const MpScriptExtremumOptions& options)
{
  if (lhs.rows () != rhs.rows () && lhs.rows () != 1 && rhs.rows () != 1)
    throw std::invalid_argument ("nonconformant row dimensions for min/max");
  if (lhs.columns () != rhs.columns () && lhs.columns () != 1
      && rhs.columns () != 1)
    throw std::invalid_argument ("nonconformant column dimensions for min/max");
  const std::size_t rows = std::max (lhs.rows (), rhs.rows ());
  const std::size_t columns = std::max (lhs.columns (), rhs.columns ());
  MpfrMatrixStorage result (rows, columns, std::max (lhs.precision_bits (), rhs.precision_bits ()));
  std::vector<std::size_t> indices (result.numel (), 1);
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      {
        const auto& left = lhs.at (lhs.rows () == 1 ? 0 : row,
                                   lhs.columns () == 1 ? 0 : column);
        const auto& right = rhs.at (rhs.rows () == 1 ? 0 : row,
                                    rhs.columns () == 1 ? 0 : column);
        const bool left_nan = real_nan (left.mpfr_data ());
        const bool right_nan = real_nan (right.mpfr_data ());
        bool choose_right = false;
        if (options.omit_nan && (left_nan || right_nan))
          choose_right = left_nan && ! right_nan;
        else if (left_nan || right_nan)
          choose_right = right_nan && ! left_nan;
        else
          choose_right
            = compare_real (right.mpfr_data (), left.mpfr_data (), operation) < 0;
        mpfr_set (result.at (row, column).mpfr_data (),
                  (choose_right ? right : left).mpfr_data (), MPFR_RNDN);
        indices[row + column * rows] = choose_right ? 2 : 1;
      }
  return {std::move (result), std::move (indices)};
}

MpScriptExtremumResultComplex
mpc_script_extremum_pair (const MpfrComplexMatrixStorage& lhs,
                          const MpfrComplexMatrixStorage& rhs,
                          MpScriptExtremumOperation operation,
                          const MpScriptExtremumOptions& options)
{
  if (lhs.rows () != rhs.rows () && lhs.rows () != 1 && rhs.rows () != 1)
    throw std::invalid_argument ("nonconformant row dimensions for min/max");
  if (lhs.columns () != rhs.columns () && lhs.columns () != 1
      && rhs.columns () != 1)
    throw std::invalid_argument ("nonconformant column dimensions for min/max");
  const std::size_t rows = std::max (lhs.rows (), rhs.rows ());
  const std::size_t columns = std::max (lhs.columns (), rhs.columns ());
  const mpfr_prec_t precision
    = std::max (lhs.precision_bits (), rhs.precision_bits ());
  MpfrMpcPrecisionScope scope (precision);
  MpfrComplexMatrixStorage result (rows, columns, precision);
  std::vector<std::size_t> indices (result.numel (), 1);
  for (std::size_t column = 0; column < columns; ++column)
    for (std::size_t row = 0; row < rows; ++row)
      {
        const auto& left = lhs.at (lhs.rows () == 1 ? 0 : row,
                                   lhs.columns () == 1 ? 0 : column);
        const auto& right = rhs.at (rhs.rows () == 1 ? 0 : row,
                                    rhs.columns () == 1 ? 0 : column);
        const bool left_nan = complex_nan (left.mpc_data ());
        const bool right_nan = complex_nan (right.mpc_data ());
        bool choose_right = false;
        if (options.omit_nan && (left_nan || right_nan))
          choose_right = left_nan && ! right_nan;
        else if (left_nan || right_nan)
          choose_right = right_nan && ! left_nan;
        else
          choose_right
            = compare_complex (right.mpc_data (), left.mpc_data (), operation,
                               options.comparison) < 0;
        mpc_set (result.at (row, column).mpc_data (),
                 (choose_right ? right : left).mpc_data (),
                 MPC_RND (MPFR_RNDN, MPFR_RNDN));
        indices[row + column * rows] = choose_right ? 2 : 1;
      }
  return {std::move (result), std::move (indices)};
}

} // namespace octave_mplapack
