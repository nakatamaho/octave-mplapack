// SPDX-License-Identifier: BSD-2-Clause

#include <cmath>
#include <cstdint>
#include <algorithm>
#include <array>
#include <exception>
#include <functional>
#include <limits>
#include <mutex>
#include <optional>
#include <stdexcept>
#include <string>
#include <type_traits>
#include <utility>
#include <vector>

#include <octave/oct.h>
#include <octave/interpreter.h>
#include <octave/ov-classdef.h>
#include <octave/ov-fcn.h>
#include <octave/pt-eval.h>
#include <octave/version.h>

#include <mplapack_mpfr.h>

#include "mp_value.h"
#include "mp_matrix_value.h"
#include "mp_complex_value.h"
#include "mp_complex_matrix_value.h"
#include "mp_matrix_inspection.h"
#include "mp_matrix_arithmetic.h"
#include "mp_complex_arithmetic.h"
#include "mp_matrix_structure.h"
#include "mp_complex_structure.h"
#include "mp_matrix_concat.h"
#include "mp_matrix_assignment.h"
#include "mp_blas.h"
#include "mp_complex_blas.h"
#include "mp_complex_lapack.h"
#include "mp_complex_rank.h"
#include "mp_complex_cholesky.h"
#include "mp_complex_qr.h"
#include "mp_lapack.h"
#include "mp_precision.h"

#ifndef MPLAPACK_PKG_VERSION
#error "MPLAPACK_PKG_VERSION must be provided by the build"
#endif

#define MPLAPACK_STRINGIFY_IMPL(value) #value
#define MPLAPACK_STRINGIFY(value) MPLAPACK_STRINGIFY_IMPL(value)

namespace
{

bool
initialize_internal_type (octave::interpreter& interp)
{
  static std::once_flag registration_once;

  // Package unload may remove the function-table lock even though Octave
  // keeps registered native type code resident.  Reassert the lock whenever
  // the entry point is loaded again; type registration itself remains once.
  octave_function *function = interp.get_evaluator ().current_function ();
  if (! function || ! function->is_dld_function ())
    error_with_id ("mplapack:ModuleLifetime",
                   "failed to resolve __mplapack_core__ for module locking");

  function->lock ();
  std::call_once (registration_once, [] ()
  {
    octave_mplapack_mpfr_scalar_internal::register_type ();
    octave_mplapack_mpfr_matrix_internal::register_type ();
    octave_mplapack_mpc_scalar_internal::register_type ();
    octave_mplapack_mpc_matrix_internal::register_type ();
  });

  if (! function->islocked ())
    error_with_id ("mplapack:ModuleLifetime",
                   "failed to lock __mplapack_core__ in memory");

  // Keep the project construction default and the current-thread MPFR
  // default synchronized whenever the native entry point is entered.
  octave_mplapack::synchronize_current_thread_precision ();

  return function->islocked ();
}

void
require_argument_count (const octave_value_list& args, int expected,
                        const std::string& command)
{
  if (args.length () != expected)
    error_with_id ("mplapack:InvalidArguments",
                   "__mplapack_core__(\"%s\") expects %d arguments",
                   command.c_str (), expected - 1);
}

std::string
require_string (const octave_value& value, const char *description)
{
  if (! value.is_string ())
    error_with_id ("mplapack:InvalidArguments", "%s must be a string",
                   description);

  return value.string_value ();
}

mpfr_prec_t
require_precision (const octave_value& value)
{
  if (! value.is_real_scalar ())
    error_with_id ("mplapack:InvalidPrecision",
                   "precision must be a real numeric scalar");

  const double supplied = value.double_value ();
  const long double precision = static_cast<long double> (supplied);

  if (! std::isfinite (supplied) || std::trunc (supplied) != supplied
      || precision < static_cast<long double> (MPFR_PREC_MIN)
      || precision > static_cast<long double> (MPFR_PREC_MAX))
    error_with_id ("mplapack:InvalidPrecision",
                   "precision must be an integer from MPFR_PREC_MIN "
                   "through MPFR_PREC_MAX");

  return static_cast<mpfr_prec_t> (precision);
}

octave_mplapack::precision_count_t
require_precision_count (const octave_value& value, const char *error_id)
{
  using octave_mplapack::precision_count_t;

  if (! value.is_scalar_type () || ! value.isreal () || value.islogical ()
      || value.is_string ())
    error_with_id (error_id, "precision must be a real numeric scalar integer");

  precision_count_t result = 0;
  if (value.is_uint64_type ())
    result = value.uint64_scalar_value ().value ();
  else if (value.isinteger ())
    {
      if (value.is_uint8_type () || value.is_uint16_type ()
          || value.is_uint32_type ())
        result = value.uint64_scalar_value ().value ();
      else
        {
          const std::int64_t supplied
            = value.int64_scalar_value ().value ();
          if (supplied <= 0)
            error_with_id (error_id, "precision must be positive");
          result = static_cast<precision_count_t> (supplied);
        }
    }
  else if (value.is_double_type () || value.is_single_type ())
    {
      const double supplied = value.double_value ();
      const double exact_integer_limit
        = value.is_single_type () ? 16777216.0 : 9007199254740992.0;
      if (! std::isfinite (supplied) || std::trunc (supplied) != supplied)
        error_with_id (error_id, "precision must be a finite integer");
      if (supplied <= 0.0)
        error_with_id (error_id, "precision must be positive");
      if (supplied > exact_integer_limit)
        error_with_id (
          error_id,
          "floating precision exceeds its contiguous exact-integer range");
      result = static_cast<precision_count_t> (supplied);
    }
  else
    error_with_id (error_id, "precision must be a real numeric scalar integer");

  if (result == 0)
    error_with_id (error_id, "precision must be positive");

  return result;
}

octave_value
precision_count_value (octave_mplapack::precision_count_t value)
{
  return octave_value (octave_uint64 (value));
}

octave_value
make_internal_scalar (const std::string& text, mpfr_prec_t precision_bits)
{
  try
    {
      return octave_value (
        new octave_mplapack_mpfr_scalar_internal (text, precision_bits));
    }
  catch (const std::invalid_argument&)
    {
      error_with_id ("mplapack:InvalidScalarText",
                     "invalid scalar text");
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:NativeError", "%s", exception.what ());
    }

  return octave_value ();
}

octave_value
make_internal_scalar (double value, mpfr_prec_t precision_bits)
{
  try
    {
      return octave_value (
        new octave_mplapack_mpfr_scalar_internal (value, precision_bits));
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:NativeError", "%s", exception.what ());
    }

  return octave_value ();
}

octave_value
make_internal_scalar (octave_mplapack::MpfrScalarStorage storage)
{
  return octave_value (
    new octave_mplapack_mpfr_scalar_internal (std::move (storage)));
}

octave_value
make_internal_matrix (octave_mplapack::MpfrMatrixStorage storage)
{
  return octave_value (
    new octave_mplapack_mpfr_matrix_internal (std::move (storage)));
}

octave_value
make_internal_complex_scalar (const std::string& text,
                              mpfr_prec_t precision_bits)
{
  try
    {
      return octave_value (
        new octave_mplapack_mpc_scalar_internal (text, precision_bits));
    }
  catch (const std::invalid_argument&)
    {
      error_with_id ("mplapack:InvalidComplexScalarText",
                     "invalid complex scalar text");
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:NativeError", "%s", exception.what ());
    }
  return octave_value ();
}

octave_value
make_internal_complex_scalar (const Complex& value,
                              mpfr_prec_t precision_bits)
{
  try
    {
      return octave_value (new octave_mplapack_mpc_scalar_internal (
        value.real (), value.imag (), precision_bits));
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:NativeError", "%s", exception.what ());
    }
  return octave_value ();
}

octave_value
make_internal_complex_scalar (
  octave_mplapack::MpfrComplexScalarStorage storage)
{
  return octave_value (
    new octave_mplapack_mpc_scalar_internal (std::move (storage)));
}

octave_value
make_internal_complex_matrix (
  octave_mplapack::MpfrComplexMatrixStorage storage)
{
  return octave_value (
    new octave_mplapack_mpc_matrix_internal (std::move (storage)));
}

double
require_double_scalar (const octave_value& value, const char *description)
{
  if (! value.is_double_type () || ! value.is_real_scalar ())
    error_with_id ("mplapack:InvalidArguments",
                   "%s must be a real double scalar", description);

  return value.double_value ();
}

octave_value
require_mp_payload (const octave_value& value)
{
  if (value.type_id ()
      == octave_mplapack_mpfr_scalar_internal::static_type_id ())
    return value;
  if (value.type_id ()
      == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    return value;
  if (value.type_id ()
      == octave_mplapack_mpc_scalar_internal::static_type_id ())
    return value;
  if (value.type_id ()
      == octave_mplapack_mpc_matrix_internal::static_type_id ())
    return value;

  if (! value.is_classdef_object () || value.class_name () != "mp")
    error_with_id ("mplapack:InvalidNativeValue",
                   "expected an internal MPLAPACK MPFR value or public mp value");

  octave_classdef *object = value.classdef_object_value (true);
  if (! object || ! object->is_instance_of ("mp"))
    error_with_id ("mplapack:InvalidNativeValue",
                   "invalid public mp representation");

  octave_value payload;
  try
    {
      payload = object->get_property (0, "payload_");
    }
  catch (const std::exception&)
    {
      error_with_id ("mplapack:InvalidNativeValue",
                     "public mp value has no valid native payload");
    }

  if (payload.type_id ()
      == octave_mplapack_mpfr_scalar_internal::static_type_id ())
    octave_mplapack_mpfr_scalar_internal::checked_value (payload);
  else if (payload.type_id ()
           == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    octave_mplapack_mpfr_matrix_internal::checked_value (payload);
  else if (payload.type_id ()
           == octave_mplapack_mpc_scalar_internal::static_type_id ())
    octave_mplapack_mpc_scalar_internal::checked_value (payload);
  else if (payload.type_id ()
           == octave_mplapack_mpc_matrix_internal::static_type_id ())
    octave_mplapack_mpc_matrix_internal::checked_value (payload);
  else
    error_with_id ("mplapack:InvalidNativeValue",
                   "public mp value has an unknown native payload");
  return payload;
}

octave_value
require_scalar_payload (const octave_value& value)
{
  if (value.type_id ()
      != octave_mplapack_mpfr_scalar_internal::static_type_id ()
      && value.type_id ()
         != octave_mplapack_mpfr_matrix_internal::static_type_id ()
      && (! value.is_classdef_object () || value.class_name () != "mp"))
    error_with_id ("mplapack:InvalidNativeValue",
                   "expected an internal MPLAPACK MPFR scalar");

  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    error_with_id ("mplapack:mp:MatrixUnsupported",
                   "operation is not implemented for dense mp matrices");
  octave_mplapack_mpfr_scalar_internal::checked_value (payload);
  return payload;
}

octave_value
require_matrix_payload (const octave_value& value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    octave_mplapack_mpfr_matrix_internal::checked_value (payload);
  else if (payload.type_id ()
           == octave_mplapack_mpc_matrix_internal::static_type_id ())
    octave_mplapack_mpc_matrix_internal::checked_value (payload);
  else
    error_with_id ("mplapack:InvalidNativeValue",
                   "expected an internal MPLAPACK matrix");
  return payload;
}

bool
is_matrix_payload (const octave_value& value)
{
  const int type = require_mp_payload (value).type_id ();
  return type == octave_mplapack_mpfr_matrix_internal::static_type_id ()
         || type == octave_mplapack_mpc_matrix_internal::static_type_id ();
}

bool
is_complex_payload (const octave_value& value)
{
  const int type = require_mp_payload (value).type_id ();
  return type == octave_mplapack_mpc_scalar_internal::static_type_id ()
         || type == octave_mplapack_mpc_matrix_internal::static_type_id ();
}

bool
is_mp_value (const octave_value& value)
{
  return (value.type_id ()
          == octave_mplapack_mpfr_scalar_internal::static_type_id ())
         || (value.type_id ()
             == octave_mplapack_mpfr_matrix_internal::static_type_id ())
         || (value.type_id ()
             == octave_mplapack_mpc_scalar_internal::static_type_id ())
         || (value.type_id ()
             == octave_mplapack_mpc_matrix_internal::static_type_id ())
         || (value.is_classdef_object () && value.class_name () == "mp");
}

bool
is_real_double_matrix_operand (const octave_value& value)
{
  return value.is_double_type () && value.isreal ()
         && ! value.is_real_scalar () && value.ndims () == 2;
}

bool
is_double_matrix_operand (const octave_value& value)
{
  return value.is_double_type () && ! value.is_real_scalar ()
         && value.ndims () == 2;
}

octave_value
require_arithmetic_mp_payload (const octave_value& value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    error_with_id ("mplapack:mp:MatrixUnsupported",
                   "this scalar-only arithmetic path does not accept dense mp matrices");
  return require_scalar_payload (payload);
}

double
require_arithmetic_double (const octave_value& value)
{
  if (value.is_double_type ())
    {
      if (! value.isreal ())
        error_with_id ("mplapack:mp:ComplexUnsupported",
                       "complex arithmetic is not supported");
      if (! value.is_real_scalar ())
        error_with_id ("mplapack:mp:MatrixUnsupported",
                       "this scalar-only arithmetic path does not accept matrix operands");
      return value.double_value ();
    }

  if (value.isnumeric () && ! value.isreal ())
    error_with_id ("mplapack:mp:ComplexUnsupported",
                   "complex arithmetic is not supported");

  error_with_id ("mplapack:mp:UnsupportedOperand",
                 "scalar arithmetic supports only mp and real double operands");
  return 0.0;
}

std::size_t
checked_size_dimension (octave_idx_type value)
{
  if (value < 0)
    error_with_id ("mplapack:mp:InvalidDimensions",
                   "matrix dimensions must be nonnegative");

  using UnsignedOctaveIndex = std::make_unsigned_t<octave_idx_type>;
  const auto converted = static_cast<UnsignedOctaveIndex> (value);
  if (converted > std::numeric_limits<std::size_t>::max ())
    error_with_id ("mplapack:mp:DimensionOverflow",
                   "matrix dimension exceeds size_t");

  const std::size_t result = static_cast<std::size_t> (converted);
  try
    {
      octave_mplapack::MpfrMatrixStorage::checked_mplapack_dimension (
        result);
    }
  catch (const std::overflow_error&)
    {
      error_with_id ("mplapack:mp:DimensionOverflow",
                     "matrix dimension exceeds MPLAPACK INTEGER");
    }
  return result;
}

octave_value
make_matrix_from_double (const octave_value& value)
{
  if (! value.is_double_type ())
    error_with_id ("mplapack:mp:InvalidInput",
                   "matrix input must be a real double array");
  if (! value.isreal ())
    error_with_id ("mplapack:mp:ComplexUnsupported",
                   "complex mp matrices are not supported");
  if (value.ndims () != 2)
    error_with_id ("mplapack:mp:MatrixUnsupported",
                   "only two-dimensional mp matrices are supported");

  const Matrix input = value.matrix_value ();
  const std::size_t rows = checked_size_dimension (input.rows ());
  const std::size_t columns = checked_size_dimension (input.columns ());
  std::vector<double> values;
  try
    {
      values.reserve (
        octave_mplapack::MpfrMatrixStorage::checked_element_count (
          rows, columns));
      for (octave_idx_type column = 0; column < input.columns (); ++column)
        for (octave_idx_type row = 0; row < input.rows (); ++row)
          values.push_back (input.xelem (row, column));
      return make_internal_matrix (octave_mplapack::MpfrMatrixStorage (
        rows, columns, octave_mplapack::default_precision_bits (), values));
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:NativeError", "%s", exception.what ());
    }
  return octave_value ();
}

octave_mplapack::MpfrMatrixStorage
make_double_matrix_storage (const octave_value& value,
                            mpfr_prec_t precision_bits)
{
  if (! value.is_double_type () || value.is_real_scalar ())
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "expected a non-scalar real double matrix");
  if (! value.isreal ())
    error_with_id ("mplapack:mp:ComplexUnsupported",
                   "complex matrix multiplication is not supported");
  if (value.ndims () != 2)
    error_with_id ("mplapack:mp:MatrixUnsupported",
                   "only two-dimensional matrix operands are supported");

  const Matrix input = value.matrix_value ();
  const std::size_t rows = checked_size_dimension (input.rows ());
  const std::size_t columns = checked_size_dimension (input.columns ());
  std::vector<double> values;
  values.reserve (octave_mplapack::MpfrMatrixStorage::checked_element_count (
    rows, columns));
  for (octave_idx_type column = 0; column < input.columns (); ++column)
    for (octave_idx_type row = 0; row < input.rows (); ++row)
      values.push_back (input.xelem (row, column));
  return octave_mplapack::MpfrMatrixStorage (rows, columns, precision_bits,
                                              values);
}

octave_mplapack::MpfrComplexMatrixStorage
make_complex_double_matrix_storage (const octave_value& value,
                                     mpfr_prec_t precision_bits)
{
  if (! value.is_double_type () || value.is_real_scalar ())
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "expected a non-scalar double matrix");
  if (value.ndims () != 2)
    error_with_id ("mplapack:mp:MatrixUnsupported",
                   "only two-dimensional matrix operands are supported");

  const std::size_t rows = checked_size_dimension (value.rows ());
  const std::size_t columns = checked_size_dimension (value.columns ());
  std::vector<std::complex<double>> values;
  values.reserve (octave_mplapack::MpfrComplexMatrixStorage::
                  checked_element_count (rows, columns));
  if (value.isreal ())
    {
      const Matrix input = value.matrix_value ();
      for (octave_idx_type column = 0; column < input.columns (); ++column)
        for (octave_idx_type row = 0; row < input.rows (); ++row)
          values.emplace_back (input.xelem (row, column), 0.0);
    }
  else
    {
      const ComplexMatrix input = value.complex_matrix_value ();
      for (octave_idx_type column = 0; column < input.columns (); ++column)
        for (octave_idx_type row = 0; row < input.rows (); ++row)
          values.emplace_back (input.xelem (row, column).real (),
                               input.xelem (row, column).imag ());
    }
  return octave_mplapack::MpfrComplexMatrixStorage (
    rows, columns, precision_bits, values);
}

octave_value
make_matrix_from_text_cell (const octave_value& value)
{
  if (! value.iscell ())
    error_with_id ("mplapack:mp:InvalidInput",
                   "text matrix input must be a cell array");
  if (value.ndims () != 2)
    error_with_id ("mplapack:mp:MatrixUnsupported",
                   "only two-dimensional mp matrices are supported");

  const Cell input = value.cell_value ();
  const std::size_t rows = checked_size_dimension (input.rows ());
  const std::size_t columns = checked_size_dimension (input.columns ());
  for (octave_idx_type column = 0; column < input.columns (); ++column)
    for (octave_idx_type row = 0; row < input.rows (); ++row)
      {
        const octave_value element = input.xelem (row, column);
        if (! element.is_string () || element.rows () != 1
            || element.columns () == 0)
          error_with_id (
            "mplapack:mp:InvalidInput",
            "each matrix cell must contain one nonempty text row");
      }

  std::vector<std::string> values;
  try
    {
      values.reserve (
        octave_mplapack::MpfrMatrixStorage::checked_element_count (
          rows, columns));
      for (octave_idx_type column = 0; column < input.columns (); ++column)
        for (octave_idx_type row = 0; row < input.rows (); ++row)
          {
            const octave_value element = input.xelem (row, column);
            values.push_back (element.string_value ());
          }
      return make_internal_matrix (octave_mplapack::MpfrMatrixStorage (
        rows, columns, octave_mplapack::default_precision_bits (), values));
    }
  catch (const std::invalid_argument&)
    {
      error_with_id ("mplapack:InvalidScalarText",
                     "invalid text in mp matrix constructor");
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:NativeError", "%s", exception.what ());
    }
  return octave_value ();
}

std::size_t
require_matrix_index (const octave_value& value)
{
  if (! value.is_real_scalar ())
    error_with_id ("mplapack:InvalidArguments",
                   "matrix test index must be a real scalar integer");
  const double supplied = value.double_value ();
  if (! std::isfinite (supplied) || std::trunc (supplied) != supplied
      || supplied < 1.0
      || supplied > static_cast<double> (
           std::numeric_limits<std::size_t>::max ()))
    error_with_id ("mplapack:InvalidArguments",
                   "matrix test index must be a positive integer");
  return static_cast<std::size_t> (supplied - 1.0);
}

bool
is_colon_index (const octave_value& value)
{
  if (! value.is_string ())
    return false;

  try
    {
      return value.string_value () == ":";
    }
  catch (...)
    {
      return false;
    }
}

std::vector<std::size_t>
parse_index_vector (const octave_value& value, std::size_t limit,
                   const char *description)
{
  if (is_colon_index (value))
    {
      std::vector<std::size_t> result (limit);
      for (std::size_t index = 0; index < limit; ++index)
        result[index] = index;
      return result;
    }

  if (! value.isnumeric () || value.islogical () || ! value.isreal ()
      || value.ndims () != 2)
    error_with_id ("mplapack:mp:InvalidIndex",
                   "%s must be a real integer scalar or vector",
                   description);

  const octave_idx_type rows = value.rows ();
  const octave_idx_type columns = value.columns ();
  if (rows != 1 && columns != 1 && value.numel () != 0)
    error_with_id ("mplapack:mp:InvalidIndex",
                   "%s must be a real integer scalar or vector",
                   description);

  const NDArray indices = value.array_value ();
  std::vector<std::size_t> result;
  result.reserve (static_cast<std::size_t> (indices.numel ()));
  for (octave_idx_type index = 0; index < indices.numel (); ++index)
    {
      const double supplied = indices(index);
      if (! std::isfinite (supplied) || std::trunc (supplied) != supplied
          || supplied < 1.0)
        error_with_id ("mplapack:mp:InvalidIndex",
                       "%s must contain positive integer indices",
                       description);

      const long double wide = static_cast<long double> (supplied);
      if (wide > static_cast<long double> (std::numeric_limits<std::size_t>::max ()))
        error_with_id ("mplapack:mp:InvalidIndex",
                       "%s index is too large", description);

      const std::size_t zero_based = static_cast<std::size_t> (supplied - 1.0);
      if (zero_based >= limit)
        error_with_id ("mplapack:mp:IndexOutOfBounds",
                       "%s index is out of bounds", description);
      result.push_back (zero_based);
    }
  return result;
}

octave_idx_type
checked_octave_dimension_for_inspection (std::size_t value)
{
  if (value > static_cast<std::size_t> (
        std::numeric_limits<octave_idx_type>::max ()))
    error_with_id ("mplapack:mp:DimensionOverflow",
                   "matrix dimension exceeds octave_idx_type");
  return static_cast<octave_idx_type> (value);
}

octave_value
make_inspection_result (octave_mplapack::MpfrMatrixStorage storage)
{
  if (storage.rows () == 1 && storage.columns () == 1)
    {
      octave_mplapack::MpfrScalarStorage scalar (
        std::move (storage.at (0, 0)));
      return make_internal_scalar (std::move (scalar));
    }
  return make_internal_matrix (std::move (storage));
}

octave_value
make_complex_inspection_result (
  octave_mplapack::MpfrComplexMatrixStorage storage)
{
  if (storage.rows () == 1 && storage.columns () == 1)
    return make_internal_complex_scalar (
      octave_mplapack::MpfrComplexScalarStorage (
        octave_mplapack::MpfrComplexScalarStorage::NativeScalar (
          storage.at (0, 0))));
  return make_internal_complex_matrix (std::move (storage));
}

struct PreparedConcatOperand
{
  octave_mplapack::MpfrConcatOperand descriptor;
};

octave_mplapack::MpfrConcatOperand
prepare_concat_operand (const octave_value& value)
{
  octave_mplapack::MpfrConcatOperand operand;

  if (is_mp_value (value))
    {
      const octave_value payload = require_mp_payload (value);
      if (payload.type_id ()
          == octave_mplapack_mpfr_scalar_internal::static_type_id ())
        {
          operand.rows = 1;
          operand.columns = 1;
          const octave_value kept_payload = payload;
          const auto& scalar
            = octave_mplapack_mpfr_scalar_internal::checked_value (
                kept_payload).storage ();
          operand.precision_bits = scalar.precision_bits ();
          operand.has_mp_precision = true;
          operand.copy_element
            = [kept_payload] (octave_mplapack::MpfrMatrixStorage::NativeScalar&
                                destination,
                              std::size_t, std::size_t)
            {
              const auto& source
                = octave_mplapack_mpfr_scalar_internal::checked_value (
                    kept_payload).storage ();
              mpfr_set (destination.mpfr_data (), source.native_value ()
                        .mpfr_data (), MPFR_RNDN);
            };
          return operand;
        }

      if (payload.type_id ()
          == octave_mplapack_mpfr_matrix_internal::static_type_id ())
        {
          const octave_value kept_payload = payload;
          const auto& matrix
            = octave_mplapack_mpfr_matrix_internal::checked_value (
                kept_payload).storage ();
          operand.rows = matrix.rows ();
          operand.columns = matrix.columns ();
          operand.precision_bits = matrix.precision_bits ();
          operand.has_mp_precision = true;
          operand.copy_element
            = [kept_payload] (octave_mplapack::MpfrMatrixStorage::NativeScalar&
                                destination,
                              std::size_t row, std::size_t column)
            {
              const auto& source
                = octave_mplapack_mpfr_matrix_internal::checked_value (
                    kept_payload).storage ();
              mpfr_set (destination.mpfr_data (),
                        source.at (row, column).mpfr_data (), MPFR_RNDN);
            };
          return operand;
        }

      error_with_id ("mplapack:mp:InvalidNativeValue",
                     "public mp value has an unknown native payload");
    }

  if (! value.is_double_type ())
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "concatenation supports mp and real double operands");
  if (! value.isreal ())
    error_with_id ("mplapack:mp:ComplexUnsupported",
                   "complex concatenation is not supported");
  if (value.issparse ())
    error_with_id ("mplapack:mp:SparseUnsupported",
                   "sparse concatenation is not supported");
  if (! value.is_real_scalar () && value.ndims () != 2)
    error_with_id ("mplapack:mp:MatrixUnsupported",
                   "only two-dimensional concatenation operands are supported");

  if (value.is_real_scalar ())
    {
      const double scalar = value.double_value ();
      operand.rows = 1;
      operand.columns = 1;
      operand.copy_element
        = [scalar] (octave_mplapack::MpfrMatrixStorage::NativeScalar&
                      destination,
                    std::size_t, std::size_t)
        {
          mpfr_set_d (destination.mpfr_data (), scalar, MPFR_RNDN);
        };
      return operand;
    }

  const Matrix input = value.matrix_value ();
  operand.rows = checked_size_dimension (input.rows ());
  operand.columns = checked_size_dimension (input.columns ());
  operand.copy_element
    = [input] (octave_mplapack::MpfrMatrixStorage::NativeScalar& destination,
               std::size_t row, std::size_t column)
    {
      mpfr_set_d (destination.mpfr_data (),
                  input.xelem (static_cast<octave_idx_type> (row),
                               static_cast<octave_idx_type> (column)),
                  MPFR_RNDN);
    };
  return operand;
}

octave_value
matrix_concatenate_result (const octave_value_list& args, int dimension)
{
  if (args.length () < 2)
    error_with_id ("mplapack:InvalidArguments",
                   "concatenation expects at least one operand");

  std::vector<PreparedConcatOperand> prepared;
  prepared.reserve (static_cast<std::size_t> (args.length () - 1));
  bool has_mp_precision = false;
  mpfr_prec_t result_precision = MPFR_PREC_MIN;
  dim_vector result_shape;
  bool shape_initialized = false;

  for (int index = 1; index < args.length (); ++index)
    {
      PreparedConcatOperand current;
      current.descriptor = prepare_concat_operand (args(index));
      if (current.descriptor.has_mp_precision)
        {
          has_mp_precision = true;
          result_precision = std::max (result_precision,
                                       current.descriptor.precision_bits);
        }

      const octave_idx_type rows
        = checked_octave_dimension_for_inspection (
            current.descriptor.rows);
      const octave_idx_type columns
        = checked_octave_dimension_for_inspection (
            current.descriptor.columns);
      const dim_vector current_shape (rows, columns);
      if (! shape_initialized)
        {
          result_shape = current_shape;
          shape_initialized = true;
        }
      else if (! result_shape.hvcat (current_shape, dimension))
        {
          if (dimension == 1)
            error_with_id ("mplapack:mp:DimensionMismatch",
                           "horizontal concatenation dimensions mismatch");
          error_with_id ("mplapack:mp:DimensionMismatch",
                         "vertical concatenation dimensions mismatch");
        }
      prepared.push_back (std::move (current));
    }

  if (! has_mp_precision)
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "concatenation requires at least one mp operand");

  const std::size_t result_rows
    = checked_size_dimension (result_shape.xelem (0));
  const std::size_t result_columns
    = checked_size_dimension (result_shape.xelem (1));
  std::vector<octave_mplapack::MpfrConcatOperand> operands;
  operands.reserve (prepared.size ());
  for (PreparedConcatOperand& current : prepared)
    operands.push_back (std::move (current.descriptor));

  try
    {
      return make_inspection_result (
        octave_mplapack::mpfr_matrix_concatenate (
          operands, dimension, result_rows, result_columns,
          result_precision));
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::invalid_argument& exception)
    {
      error_with_id ("mplapack:mp:DimensionMismatch", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:StructureError", "%s",
                     exception.what ());
    }
  return octave_value ();
}

struct ReshapeDimension
{
  bool inferred;
  std::size_t value;
};

std::size_t
parse_reshape_dimension (const octave_value& value, const char *description)
{
  if (! value.isnumeric () || value.islogical () || ! value.isreal ()
      || ! value.is_real_scalar ())
    error_with_id ("mplapack:mp:InvalidDimension",
                   "%s must be a nonnegative integer scalar", description);

  if (value.is_uint64_type ()
      || (value.isinteger () && (value.is_uint8_type ()
                                  || value.is_uint16_type ()
                                  || value.is_uint32_type ())))
    {
      const std::uint64_t supplied = value.uint64_scalar_value ().value ();
      if (supplied > std::numeric_limits<std::size_t>::max ())
        error_with_id ("mplapack:mp:DimensionOverflow",
                       "%s exceeds the native dimension range", description);
      return static_cast<std::size_t> (supplied);
    }

  if (value.isinteger ())
    {
      const std::int64_t supplied = value.int64_scalar_value ().value ();
      if (supplied < 0)
        error_with_id ("mplapack:mp:InvalidDimension",
                       "%s must be a nonnegative integer scalar", description);
      if (static_cast<std::uint64_t> (supplied)
          > std::numeric_limits<std::size_t>::max ())
        error_with_id ("mplapack:mp:DimensionOverflow",
                       "%s exceeds the native dimension range", description);
      return static_cast<std::size_t> (supplied);
    }

  const double supplied = value.double_value ();
  const double exact_integer_limit
    = value.is_single_type () ? 16777216.0 : 9007199254740992.0;
  if (! std::isfinite (supplied) || std::trunc (supplied) != supplied
      || supplied < 0.0 || supplied > exact_integer_limit)
    error_with_id ("mplapack:mp:InvalidDimension",
                   "%s must be a nonnegative integer scalar", description);

  const long double wide = static_cast<long double> (supplied);
  if (wide > static_cast<long double> (
        std::numeric_limits<std::size_t>::max ()))
    error_with_id ("mplapack:mp:DimensionOverflow",
                   "%s exceeds the native dimension range", description);

  return static_cast<std::size_t> (supplied);
}

ReshapeDimension
parse_reshape_dimension_spec (const octave_value& value,
                               const char *description)
{
  if (value.isnumeric () && ! value.islogical () && value.isreal ()
      && value.isempty ())
    return {true, 0};
  return {false, parse_reshape_dimension (value, description)};
}

std::array<ReshapeDimension, 2>
parse_reshape_vector (const octave_value& value)
{
  if (! value.isnumeric () || value.islogical () || ! value.isreal ()
      || value.ndims () != 2 || value.numel () != 2)
    error_with_id ("mplapack:mp:InvalidDimension",
                   "reshape dimension vector must contain two real integers");

  const NDArray dimensions = value.array_value ();
  return {
    parse_reshape_dimension_spec (dimensions (0), "reshape rows"),
    parse_reshape_dimension_spec (dimensions (1), "reshape columns")
  };
}

std::pair<std::size_t, std::size_t>
resolve_reshape_dimensions (const octave_value& value,
                            const octave_value& first,
                            const octave_value *second)
{
  const octave_value payload = require_mp_payload (value);
  const std::size_t source_numel
    = payload.type_id () == octave_mplapack_mpfr_scalar_internal::static_type_id ()
        ? 1
        : octave_mplapack_mpfr_matrix_internal::checked_value (payload)
            .storage ().numel ();

  std::array<ReshapeDimension, 2> dimensions;
  if (second)
    {
      dimensions = {
        parse_reshape_dimension_spec (first, "reshape rows"),
        parse_reshape_dimension_spec (*second, "reshape columns")
      };
    }
  else
    dimensions = parse_reshape_vector (first);

  if (dimensions[0].inferred && dimensions[1].inferred)
    error_with_id ("mplapack:mp:InvalidDimension",
                   "only one reshape dimension may be inferred");

  if (dimensions[0].inferred)
    {
      if (dimensions[1].value == 0 && source_numel != 0)
        error_with_id ("mplapack:mp:InvalidDimension",
                       "reshape rows cannot be inferred from a zero column dimension");
      dimensions[0].value = dimensions[1].value == 0
        ? 0 : source_numel / dimensions[1].value;
      if (dimensions[1].value != 0
          && source_numel % dimensions[1].value != 0)
        error_with_id ("mplapack:mp:InvalidDimension",
                       "reshape rows cannot be inferred from the element count");
      dimensions[0].inferred = false;
    }
  else if (dimensions[1].inferred)
    {
      if (dimensions[0].value == 0 && source_numel != 0)
        error_with_id ("mplapack:mp:InvalidDimension",
                       "reshape columns cannot be inferred from a zero row dimension");
      dimensions[1].value = dimensions[0].value == 0
        ? 0 : source_numel / dimensions[0].value;
      if (dimensions[0].value != 0
          && source_numel % dimensions[0].value != 0)
        error_with_id ("mplapack:mp:InvalidDimension",
                       "reshape columns cannot be inferred from the element count");
      dimensions[1].inferred = false;
    }

  try
    {
      if (octave_mplapack::MpfrMatrixStorage::checked_element_count (
            dimensions[0].value, dimensions[1].value) != source_numel)
        error_with_id ("mplapack:mp:InvalidDimension",
                       "reshape element count does not match");
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  return {dimensions[0].value, dimensions[1].value};
}

octave_value
complex_real_result (const octave_value& value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      == octave_mplapack_mpc_scalar_internal::static_type_id ())
    return make_internal_scalar (octave_mplapack::mpfr_complex_scalar_real (
      octave_mplapack_mpc_scalar_internal::checked_value (payload).storage ()));

  try
    {
      return make_inspection_result (octave_mplapack::mpfr_complex_matrix_real (
        octave_mplapack_mpc_matrix_internal::checked_value (payload)
          .storage ()));
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:StructureError", "%s", exception.what ());
    }
  return octave_value ();
}

octave_value
complex_imag_result (const octave_value& value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      == octave_mplapack_mpc_scalar_internal::static_type_id ())
    return make_internal_scalar (octave_mplapack::mpfr_complex_scalar_imag (
      octave_mplapack_mpc_scalar_internal::checked_value (payload).storage ()));

  try
    {
      return make_inspection_result (octave_mplapack::mpfr_complex_matrix_imag (
        octave_mplapack_mpc_matrix_internal::checked_value (payload)
          .storage ()));
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:StructureError", "%s", exception.what ());
    }
  return octave_value ();
}

octave_value
complex_conj_result (const octave_value& value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      == octave_mplapack_mpc_scalar_internal::static_type_id ())
    return make_internal_complex_scalar (
      octave_mplapack::mpfr_complex_scalar_conj (
        octave_mplapack_mpc_scalar_internal::checked_value (payload)
          .storage ()));

  try
    {
      return make_complex_inspection_result (
        octave_mplapack::mpfr_complex_matrix_conj (
          octave_mplapack_mpc_matrix_internal::checked_value (payload)
            .storage ()));
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:StructureError", "%s", exception.what ());
    }
  return octave_value ();
}

octave_value
matrix_transpose_result (const octave_value& value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      == octave_mplapack_mpc_scalar_internal::static_type_id ())
    return make_internal_complex_scalar (
      octave_mplapack::mpfr_complex_scalar_transpose (
        octave_mplapack_mpc_scalar_internal::checked_value (payload)
          .storage ()));
  if (payload.type_id ()
      == octave_mplapack_mpc_matrix_internal::static_type_id ())
    {
      try
        {
          return make_complex_inspection_result (
            octave_mplapack::mpfr_complex_matrix_transpose (
              octave_mplapack_mpc_matrix_internal::checked_value (payload)
                .storage ()));
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:mp:StructureError", "%s",
                         exception.what ());
        }
    }
  if (payload.type_id ()
      == octave_mplapack_mpfr_scalar_internal::static_type_id ())
    {
      const auto& source
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload)
            .storage ();
      return make_internal_scalar (octave_mplapack::MpfrScalarStorage (
        octave_mplapack::MpfrScalarStorage::NativeScalar (source.native_value ())));
    }

  try
    {
      return make_internal_matrix (
        octave_mplapack::mpfr_matrix_transpose (
          octave_mplapack_mpfr_matrix_internal::checked_value (payload)
            .storage ()));
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:StructureError", "%s", exception.what ());
    }
  return octave_value ();
}

octave_value
matrix_ctranspose_result (const octave_value& value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      == octave_mplapack_mpc_scalar_internal::static_type_id ())
    return make_internal_complex_scalar (
      octave_mplapack::mpfr_complex_scalar_ctranspose (
        octave_mplapack_mpc_scalar_internal::checked_value (payload)
          .storage ()));
  if (payload.type_id ()
      == octave_mplapack_mpc_matrix_internal::static_type_id ())
    {
      try
        {
          return make_complex_inspection_result (
            octave_mplapack::mpfr_complex_matrix_ctranspose (
              octave_mplapack_mpc_matrix_internal::checked_value (payload)
                .storage ()));
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:mp:StructureError", "%s",
                         exception.what ());
        }
    }
  return matrix_transpose_result (value);
}

octave_value
matrix_reshape_result (const octave_value& value,
                       const octave_value& first,
                       const octave_value *second)
{
  const octave_value payload = require_mp_payload (value);
  const auto dimensions = resolve_reshape_dimensions (value, first, second);

  if (payload.type_id ()
      == octave_mplapack_mpfr_scalar_internal::static_type_id ())
    {
      if (dimensions.first != 1 || dimensions.second != 1)
        error_with_id ("mplapack:mp:InvalidDimension",
                       "a scalar mp value can only be reshaped to 1x1");
      const auto& source
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload)
            .storage ();
      return make_internal_scalar (octave_mplapack::MpfrScalarStorage (
        octave_mplapack::MpfrScalarStorage::NativeScalar (source.native_value ())));
    }

  try
    {
      return make_inspection_result (octave_mplapack::mpfr_matrix_reshape (
        octave_mplapack_mpfr_matrix_internal::checked_value (payload)
          .storage (), dimensions.first, dimensions.second));
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::invalid_argument& exception)
    {
      error_with_id ("mplapack:mp:InvalidDimension", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:StructureError", "%s",
                     exception.what ());
    }
  return octave_value ();
}

octave_value
matrix_subscript_result (const octave_value& value,
                         const octave_value& row_spec,
                         const octave_value& column_spec)
{
  const auto& source
    = octave_mplapack_mpfr_matrix_internal::checked_value (
        require_matrix_payload (value)).storage ();
  const auto row_indices
    = parse_index_vector (row_spec, source.rows (), "row index");
  const auto column_indices
    = parse_index_vector (column_spec, source.columns (), "column index");

  try
    {
      return make_inspection_result (octave_mplapack::select_matrix (
        source, row_indices, column_indices));
    }
  catch (const std::out_of_range& exception)
    {
      error_with_id ("mplapack:mp:IndexOutOfBounds", "%s",
                     exception.what ());
    }
  return octave_value ();
}

octave_value
matrix_linear_subscript_result (const octave_value& value,
                                const octave_value& index_spec)
{
  const auto& source
    = octave_mplapack_mpfr_matrix_internal::checked_value (
        require_matrix_payload (value)).storage ();
  if (is_colon_index (index_spec))
    {
      std::vector<std::size_t> all (source.numel ());
      for (std::size_t index = 0; index < source.numel (); ++index)
        all[index] = index;
      return make_inspection_result (
        octave_mplapack::select_linear (source, all));
    }

  const auto indices = parse_index_vector (index_spec, source.numel (),
                                           "linear index");
  if (indices.size () != 1)
    error_with_id ("mplapack:mp:LinearIndexUnsupported",
                   "general vector linear indexing is not implemented");

  try
    {
      return make_inspection_result (octave_mplapack::select_linear (
        source, indices));
    }
  catch (const std::out_of_range& exception)
    {
      error_with_id ("mplapack:mp:IndexOutOfBounds", "%s",
                     exception.what ());
    }
  return octave_value ();
}

octave_value
complex_matrix_subscript_result (const octave_value& value,
                                 const octave_value& row_spec,
                                 const octave_value& column_spec)
{
  const auto& source
    = octave_mplapack_mpc_matrix_internal::checked_value (
        require_matrix_payload (value)).storage ();
  const auto row_indices
    = parse_index_vector (row_spec, source.rows (), "row index");
  const auto column_indices
    = parse_index_vector (column_spec, source.columns (), "column index");
  try
    {
      return make_complex_inspection_result (
        octave_mplapack::select_complex_matrix (source, row_indices,
                                                column_indices));
    }
  catch (const std::out_of_range& exception)
    {
      error_with_id ("mplapack:mp:IndexOutOfBounds", "%s",
                     exception.what ());
    }
  return octave_value ();
}

octave_value
complex_matrix_linear_subscript_result (const octave_value& value,
                                        const octave_value& index_spec)
{
  const auto& source
    = octave_mplapack_mpc_matrix_internal::checked_value (
        require_matrix_payload (value)).storage ();
  if (is_colon_index (index_spec))
    {
      std::vector<std::size_t> all (source.numel ());
      for (std::size_t index = 0; index < source.numel (); ++index)
        all[index] = index;
      return make_complex_inspection_result (
        octave_mplapack::select_complex_linear (source, all));
    }

  const auto indices = parse_index_vector (index_spec, source.numel (),
                                           "linear index");
  if (indices.size () != 1)
    error_with_id ("mplapack:mp:LinearIndexUnsupported",
                   "general vector linear indexing is not implemented");
  try
    {
      return make_complex_inspection_result (
        octave_mplapack::select_complex_linear (source, indices));
    }
  catch (const std::out_of_range& exception)
    {
      error_with_id ("mplapack:mp:IndexOutOfBounds", "%s",
                     exception.what ());
    }
  return octave_value ();
}

struct PreparedComplexAssignmentOperand
{
  std::size_t rows = 0;
  std::size_t columns = 0;
  mpfr_prec_t precision_bits = MPFR_PREC_MIN;
  bool has_mp_precision = false;
  std::function<void (mpfrxx::mpc_class&, std::size_t, std::size_t)>
    copy_element;
};

bool
complex_assignment_scalar (const PreparedComplexAssignmentOperand& rhs)
{
  return rhs.rows == 1 && rhs.columns == 1;
}

std::size_t
checked_complex_assignment_product (std::size_t lhs, std::size_t rhs)
{
  if (lhs != 0 && rhs > std::numeric_limits<std::size_t>::max () / lhs)
    throw std::overflow_error ("complex assignment selection size overflow");
  return lhs * rhs;
}

PreparedComplexAssignmentOperand
prepare_complex_assignment_rhs (const octave_value& value)
{
  PreparedComplexAssignmentOperand prepared;
  if (is_mp_value (value))
    {
      const octave_value payload = require_mp_payload (value);
      if (payload.type_id ()
          == octave_mplapack_mpc_scalar_internal::static_type_id ())
        {
          const octave_value kept_payload = payload;
          const auto& scalar
            = octave_mplapack_mpc_scalar_internal::checked_value (
                kept_payload).storage ();
          prepared.rows = prepared.columns = 1;
          prepared.precision_bits = scalar.precision_bits ();
          prepared.has_mp_precision = true;
          prepared.copy_element
            = [kept_payload] (mpfrxx::mpc_class& destination,
                              std::size_t, std::size_t)
            {
              const auto& source
                = octave_mplapack_mpc_scalar_internal::checked_value (
                    kept_payload).storage ();
              mpc_set (destination.mpc_data (), source.native_value ().mpc_data (),
                       MPC_RND (MPFR_RNDN, MPFR_RNDN));
            };
          return prepared;
        }
      if (payload.type_id ()
          == octave_mplapack_mpc_matrix_internal::static_type_id ())
        {
          const octave_value kept_payload = payload;
          const auto& matrix
            = octave_mplapack_mpc_matrix_internal::checked_value (
                kept_payload).storage ();
          if (matrix.numel () == 0)
            error_with_id ("mplapack:mp:DeletionUnsupported",
                           "empty RHS deletion is not supported");
          prepared.rows = matrix.rows ();
          prepared.columns = matrix.columns ();
          prepared.precision_bits = matrix.precision_bits ();
          prepared.has_mp_precision = true;
          prepared.copy_element
            = [kept_payload] (mpfrxx::mpc_class& destination,
                              std::size_t row, std::size_t column)
            {
              const auto& source
                = octave_mplapack_mpc_matrix_internal::checked_value (
                    kept_payload).storage ();
              mpc_set (destination.mpc_data (), source.at (row, column).mpc_data (),
                       MPC_RND (MPFR_RNDN, MPFR_RNDN));
            };
          return prepared;
        }
      if (payload.type_id ()
          == octave_mplapack_mpfr_scalar_internal::static_type_id ())
        {
          const octave_value kept_payload = payload;
          const auto& scalar
            = octave_mplapack_mpfr_scalar_internal::checked_value (
                kept_payload).storage ();
          prepared.rows = prepared.columns = 1;
          prepared.precision_bits = scalar.precision_bits ();
          prepared.has_mp_precision = true;
          prepared.copy_element
            = [kept_payload] (mpfrxx::mpc_class& destination,
                              std::size_t, std::size_t)
            {
              const auto& source
                = octave_mplapack_mpfr_scalar_internal::checked_value (
                    kept_payload).storage ();
              mpc_set_fr (destination.mpc_data (), source.native_value ().mpfr_data (),
                          MPC_RND (MPFR_RNDN, MPFR_RNDN));
            };
          return prepared;
        }
      if (payload.type_id ()
          == octave_mplapack_mpfr_matrix_internal::static_type_id ())
        {
          const octave_value kept_payload = payload;
          const auto& matrix
            = octave_mplapack_mpfr_matrix_internal::checked_value (
                kept_payload).storage ();
          if (matrix.numel () == 0)
            error_with_id ("mplapack:mp:DeletionUnsupported",
                           "empty RHS deletion is not supported");
          prepared.rows = matrix.rows ();
          prepared.columns = matrix.columns ();
          prepared.precision_bits = matrix.precision_bits ();
          prepared.has_mp_precision = true;
          prepared.copy_element
            = [kept_payload] (mpfrxx::mpc_class& destination,
                              std::size_t row, std::size_t column)
            {
              const auto& source
                = octave_mplapack_mpfr_matrix_internal::checked_value (
                    kept_payload).storage ();
              mpc_set_fr (destination.mpc_data (),
                          source.at (row, column).mpfr_data (),
                          MPC_RND (MPFR_RNDN, MPFR_RNDN));
            };
          return prepared;
        }
      error_with_id ("mplapack:mp:InvalidNativeValue",
                     "public mp value has an unknown native payload");
    }

  if (! value.is_double_type ())
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "complex assignment RHS supports mp and double values");
  if (value.issparse ())
    error_with_id ("mplapack:mp:SparseUnsupported",
                   "sparse assignment is not supported");
  if (value.is_real_scalar () || value.is_complex_scalar ())
    {
      const Complex scalar = value.complex_value ();
      prepared.rows = prepared.columns = 1;
      prepared.copy_element
        = [scalar] (mpfrxx::mpc_class& destination, std::size_t, std::size_t)
        { mpc_set_d_d (destination.mpc_data (), scalar.real (), scalar.imag (),
                       MPC_RND (MPFR_RNDN, MPFR_RNDN)); };
      return prepared;
    }
  if (value.ndims () != 2)
    error_with_id ("mplapack:mp:MatrixUnsupported",
                   "only two-dimensional assignment RHS values are supported");
  if (value.numel () == 0)
    error_with_id ("mplapack:mp:DeletionUnsupported",
                   "empty RHS deletion is not supported");
  const ComplexMatrix input = value.complex_matrix_value ();
  prepared.rows = checked_size_dimension (input.rows ());
  prepared.columns = checked_size_dimension (input.columns ());
  prepared.copy_element
    = [input] (mpfrxx::mpc_class& destination, std::size_t row,
               std::size_t column)
    {
      const Complex value = input.xelem (static_cast<octave_idx_type> (row),
                                         static_cast<octave_idx_type> (column));
      mpc_set_d_d (destination.mpc_data (), value.real (), value.imag (),
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
    };
  return prepared;
}

octave_value
complex_matrix_assignment_result (const octave_value& value,
                                  const octave_value& row_spec,
                                  const octave_value& column_spec,
                                  const octave_value& rhs_value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      != octave_mplapack_mpc_matrix_internal::static_type_id ())
    error_with_id ("mplapack:mp:AssignmentUnsupported",
                   "complex assignment requires a dense complex matrix lhs");
  const auto& source
    = octave_mplapack_mpc_matrix_internal::checked_value (payload).storage ();
  const auto row_indices
    = parse_index_vector (row_spec, source.rows (), "row index");
  const auto column_indices
    = parse_index_vector (column_spec, source.columns (), "column index");
  PreparedComplexAssignmentOperand rhs
    = prepare_complex_assignment_rhs (rhs_value);
  const std::size_t selected_count
    = checked_complex_assignment_product (row_indices.size (),
                                          column_indices.size ());
  if (selected_count == 0)
    {
      if (! complex_assignment_scalar (rhs)
          && checked_complex_assignment_product (rhs.rows, rhs.columns) != 0)
        error_with_id ("mplapack:mp:DimensionMismatch",
                       "non-scalar RHS is not conformant with an empty selection");
    }
  const bool scalar_rhs = complex_assignment_scalar (rhs);
  const bool exact_shape = rhs.rows == row_indices.size ()
                           && rhs.columns == column_indices.size ();
  const bool vector_shape
    = ! exact_shape && ! scalar_rhs
      && (row_indices.size () == 1 || column_indices.size () == 1)
      && (rhs.rows == 1 || rhs.columns == 1)
      && checked_complex_assignment_product (rhs.rows, rhs.columns)
           == selected_count;
  if (selected_count != 0 && ! scalar_rhs && ! exact_shape && ! vector_shape)
    error_with_id ("mplapack:mp:DimensionMismatch",
                   "assignment RHS dimensions are not conformant with the selection");
  for (std::size_t row : row_indices)
    if (row >= source.rows ())
      error_with_id ("mplapack:mp:IndexOutOfBounds", "assignment index is out of bounds");
  for (std::size_t column : column_indices)
    if (column >= source.columns ())
      error_with_id ("mplapack:mp:IndexOutOfBounds", "assignment index is out of bounds");

  const mpfr_prec_t result_precision
    = rhs.has_mp_precision
      ? std::max (source.precision_bits (), rhs.precision_bits)
      : source.precision_bits ();
  octave_mplapack::MpfrComplexMatrixStorage result (
    source.rows (), source.columns (), result_precision);
  for (std::size_t index = 0; index < source.numel (); ++index)
    mpc_set (result.data ()[index].mpc_data (), source.data ()[index].mpc_data (),
             MPC_RND (MPFR_RNDN, MPFR_RNDN));
  for (std::size_t column = 0; column < column_indices.size (); ++column)
    for (std::size_t row = 0; row < row_indices.size (); ++row)
      {
        std::size_t rhs_row = 0;
        std::size_t rhs_column = 0;
        if (! scalar_rhs)
          {
            if (exact_shape)
              { rhs_row = row; rhs_column = column; }
            else
              {
                const std::size_t linear = row + column * row_indices.size ();
                rhs_row = linear % rhs.rows;
                rhs_column = linear / rhs.rows;
              }
          }
        rhs.copy_element (result.at (row_indices[row], column_indices[column]),
                          rhs_row, rhs_column);
      }
  return make_complex_inspection_result (std::move (result));
}

octave_value
complex_matrix_linear_assignment_result (const octave_value& value,
                                         const octave_value& index_spec,
                                         const octave_value& rhs_value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      != octave_mplapack_mpc_matrix_internal::static_type_id ())
    error_with_id ("mplapack:mp:AssignmentUnsupported",
                   "complex assignment requires a dense complex matrix lhs");
  const auto& source
    = octave_mplapack_mpc_matrix_internal::checked_value (payload).storage ();
  std::vector<std::size_t> indices;
  if (is_colon_index (index_spec))
    {
      indices.resize (source.numel ());
      for (std::size_t index = 0; index < indices.size (); ++index)
        indices[index] = index;
    }
  else
    {
      indices = parse_index_vector (index_spec, source.numel (),
                                    "linear index");
      if (indices.size () != 1)
        error_with_id ("mplapack:mp:LinearAssignmentUnsupported",
                       "general vector linear assignment is not implemented");
    }
  PreparedComplexAssignmentOperand rhs
    = prepare_complex_assignment_rhs (rhs_value);
  const bool scalar_rhs = complex_assignment_scalar (rhs);
  const std::size_t rhs_count
    = checked_complex_assignment_product (rhs.rows, rhs.columns);
  if (! scalar_rhs && rhs_count != indices.size ())
    error_with_id ("mplapack:mp:DimensionMismatch",
                   "assignment RHS element count does not match linear selection");
  for (std::size_t index : indices)
    if (index >= source.numel ())
      error_with_id ("mplapack:mp:IndexOutOfBounds", "assignment index is out of bounds");

  const mpfr_prec_t result_precision
    = rhs.has_mp_precision
      ? std::max (source.precision_bits (), rhs.precision_bits)
      : source.precision_bits ();
  octave_mplapack::MpfrComplexMatrixStorage result (
    source.rows (), source.columns (), result_precision);
  for (std::size_t index = 0; index < source.numel (); ++index)
    mpc_set (result.data ()[index].mpc_data (), source.data ()[index].mpc_data (),
             MPC_RND (MPFR_RNDN, MPFR_RNDN));
  for (std::size_t index = 0; index < indices.size (); ++index)
    {
      const std::size_t rhs_row = scalar_rhs ? 0 : index % rhs.rows;
      const std::size_t rhs_column = scalar_rhs ? 0 : index / rhs.rows;
      rhs.copy_element (result.data ()[indices[index]], rhs_row, rhs_column);
    }
  return make_complex_inspection_result (std::move (result));
}

struct PreparedAssignmentOperand
{
  octave_value payload;
  octave_mplapack::MpfrAssignmentOperand descriptor;
};

PreparedAssignmentOperand
prepare_assignment_rhs (const octave_value& value)
{
  PreparedAssignmentOperand prepared;

  if (is_mp_value (value))
    {
      prepared.payload = require_mp_payload (value);
      if (prepared.payload.type_id ()
          == octave_mplapack_mpfr_scalar_internal::static_type_id ())
        {
          const octave_value kept_payload = prepared.payload;
          const auto& scalar
            = octave_mplapack_mpfr_scalar_internal::checked_value (
                kept_payload).storage ();
          prepared.descriptor.rows = 1;
          prepared.descriptor.columns = 1;
          prepared.descriptor.precision_bits = scalar.precision_bits ();
          prepared.descriptor.has_mp_precision = true;
          prepared.descriptor.copy_element
            = [kept_payload] (
                octave_mplapack::MpfrMatrixStorage::NativeScalar& destination,
                std::size_t, std::size_t)
            {
              const auto& source
                = octave_mplapack_mpfr_scalar_internal::checked_value (
                    kept_payload).storage ();
              mpfr_set (destination.mpfr_data (),
                        source.native_value ().mpfr_data (), MPFR_RNDN);
            };
          return prepared;
        }

      if (prepared.payload.type_id ()
          == octave_mplapack_mpfr_matrix_internal::static_type_id ())
        {
          const octave_value kept_payload = prepared.payload;
          const auto& matrix
            = octave_mplapack_mpfr_matrix_internal::checked_value (
                kept_payload).storage ();
          if (matrix.numel () == 0)
            error_with_id ("mplapack:mp:DeletionUnsupported",
                           "empty RHS deletion is not supported");
          prepared.descriptor.rows = matrix.rows ();
          prepared.descriptor.columns = matrix.columns ();
          prepared.descriptor.precision_bits = matrix.precision_bits ();
          prepared.descriptor.has_mp_precision = true;
          prepared.descriptor.copy_element
            = [kept_payload] (
                octave_mplapack::MpfrMatrixStorage::NativeScalar& destination,
                std::size_t row, std::size_t column)
            {
              const auto& source
                = octave_mplapack_mpfr_matrix_internal::checked_value (
                    kept_payload).storage ();
              mpfr_set (destination.mpfr_data (),
                        source.at (row, column).mpfr_data (), MPFR_RNDN);
            };
          return prepared;
        }

      error_with_id ("mplapack:mp:InvalidNativeValue",
                     "public mp value has an unknown native payload");
    }

  if (! value.is_double_type ())
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "assignment RHS supports mp and real double values");
  if (! value.isreal ())
    error_with_id ("mplapack:mp:ComplexUnsupported",
                   "complex assignment is not supported");
  if (value.issparse ())
    error_with_id ("mplapack:mp:SparseUnsupported",
                   "sparse assignment is not supported");
  if (! value.is_real_scalar () && value.ndims () != 2)
    error_with_id ("mplapack:mp:MatrixUnsupported",
                   "only two-dimensional assignment RHS values are supported");
  if (! value.is_real_scalar () && value.numel () == 0)
    error_with_id ("mplapack:mp:DeletionUnsupported",
                   "empty RHS deletion is not supported");

  if (value.is_real_scalar ())
    {
      const double scalar = value.double_value ();
      prepared.descriptor.rows = 1;
      prepared.descriptor.columns = 1;
      prepared.descriptor.copy_element
        = [scalar] (
            octave_mplapack::MpfrMatrixStorage::NativeScalar& destination,
            std::size_t, std::size_t)
        {
          mpfr_set_d (destination.mpfr_data (), scalar, MPFR_RNDN);
        };
      return prepared;
    }

  const Matrix input = value.matrix_value ();
  prepared.descriptor.rows = checked_size_dimension (input.rows ());
  prepared.descriptor.columns = checked_size_dimension (input.columns ());
  prepared.descriptor.copy_element
    = [input] (octave_mplapack::MpfrMatrixStorage::NativeScalar& destination,
               std::size_t row, std::size_t column)
    {
      mpfr_set_d (destination.mpfr_data (),
                  input.xelem (static_cast<octave_idx_type> (row),
                               static_cast<octave_idx_type> (column)),
                  MPFR_RNDN);
    };
  return prepared;
}

struct PreparedAssignmentLhs
{
  octave_value payload;
  std::optional<octave_mplapack::MpfrMatrixStorage> scalar_matrix;

  const octave_mplapack::MpfrMatrixStorage& matrix_storage () const
  {
    if (scalar_matrix)
      return *scalar_matrix;
    return octave_mplapack_mpfr_matrix_internal::checked_value (
      payload).storage ();
  }
};

PreparedAssignmentLhs
prepare_assignment_lhs (const octave_value& value)
{
  PreparedAssignmentLhs prepared;
  prepared.payload = require_mp_payload (value);
  if (prepared.payload.type_id ()
      == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    return prepared;

  const auto& scalar
    = octave_mplapack_mpfr_scalar_internal::checked_value (
        prepared.payload).storage ();
  prepared.scalar_matrix.emplace (1, 1, scalar.precision_bits ());
  mpfr_set (prepared.scalar_matrix->at (0, 0).mpfr_data (),
            scalar.native_value ().mpfr_data (), MPFR_RNDN);
  return prepared;
}

mpfr_prec_t
assignment_precision (const octave_mplapack::MpfrMatrixStorage& lhs,
                      const octave_mplapack::MpfrAssignmentOperand& rhs)
{
  mpfr_prec_t result = lhs.precision_bits ();
  if (rhs.has_mp_precision)
    result = std::max (result, rhs.precision_bits);
  return result;
}

mpfr_prec_t
assignment_precision_for_selection (
  const octave_mplapack::MpfrMatrixStorage& lhs,
  const octave_mplapack::MpfrAssignmentOperand& rhs,
  std::size_t selected_count)
{
  // An empty indexed selection is a no-op; it does not consume an RHS value
  // and therefore must not widen the lhs merely because the RHS is precise.
  return selected_count == 0 ? lhs.precision_bits ()
                             : assignment_precision (lhs, rhs);
}

octave_value
matrix_two_subscript_assignment_result (const octave_value& value,
                                         const octave_value& row_spec,
                                         const octave_value& column_spec,
                                         const octave_value& rhs_value)
{
  PreparedAssignmentLhs lhs = prepare_assignment_lhs (value);
  const auto& lhs_storage = lhs.matrix_storage ();
  const auto row_indices
    = parse_index_vector (row_spec, lhs_storage.rows (), "row index");
  const auto column_indices
    = parse_index_vector (column_spec, lhs_storage.columns (),
                          "column index");
  PreparedAssignmentOperand rhs = prepare_assignment_rhs (rhs_value);

  try
    {
      return make_inspection_result (
        octave_mplapack::mpfr_matrix_assign_two_subscript (
          lhs_storage, row_indices, column_indices, rhs.descriptor,
          assignment_precision_for_selection (
            lhs_storage, rhs.descriptor,
            row_indices.empty () || column_indices.empty () ? 0 : 1)));
    }
  catch (const std::out_of_range& exception)
    {
      error_with_id ("mplapack:mp:IndexOutOfBounds", "%s",
                     exception.what ());
    }
  catch (const std::invalid_argument& exception)
    {
      error_with_id ("mplapack:mp:DimensionMismatch", "%s",
                     exception.what ());
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:AssignmentError", "%s",
                     exception.what ());
    }
  return octave_value ();
}

octave_value
matrix_linear_assignment_result (const octave_value& value,
                                 const octave_value& index_spec,
                                 const octave_value& rhs_value)
{
  PreparedAssignmentLhs lhs = prepare_assignment_lhs (value);
  const auto& lhs_storage = lhs.matrix_storage ();
  std::vector<std::size_t> indices;
  if (is_colon_index (index_spec))
    {
      indices.resize (lhs_storage.numel ());
      for (std::size_t index = 0; index < indices.size (); ++index)
        indices[index] = index;
    }
  else
    {
      indices = parse_index_vector (index_spec, lhs_storage.numel (),
                                    "linear index");
      if (indices.size () != 1)
        error_with_id ("mplapack:mp:LinearAssignmentUnsupported",
                       "general vector linear assignment is not implemented");
    }

  PreparedAssignmentOperand rhs = prepare_assignment_rhs (rhs_value);
  try
    {
      return make_inspection_result (octave_mplapack::mpfr_matrix_assign_linear (
        lhs_storage, indices, rhs.descriptor,
        assignment_precision_for_selection (
          lhs_storage, rhs.descriptor, indices.size ())));
    }
  catch (const std::out_of_range& exception)
    {
      error_with_id ("mplapack:mp:IndexOutOfBounds", "%s",
                     exception.what ());
    }
  catch (const std::invalid_argument& exception)
    {
      error_with_id ("mplapack:mp:DimensionMismatch", "%s",
                     exception.what ());
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:AssignmentError", "%s",
                     exception.what ());
    }
  return octave_value ();
}

Matrix
matrix_to_double (const octave_value& value)
{
  const auto& source
    = octave_mplapack_mpfr_matrix_internal::checked_value (
        require_matrix_payload (value)).storage ();
  Matrix result (checked_octave_dimension_for_inspection (source.rows ()),
                 checked_octave_dimension_for_inspection (source.columns ()));
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      result.xelem (static_cast<octave_idx_type> (row),
                    static_cast<octave_idx_type> (column))
        = mpfr_get_d (source.at (row, column).mpfr_data (), MPFR_RNDN);
  return result;
}

ComplexMatrix
complex_matrix_to_double (const octave_value& value)
{
  const auto& source
    = octave_mplapack_mpc_matrix_internal::checked_value (
        require_matrix_payload (value)).storage ();
  ComplexMatrix result (
    checked_octave_dimension_for_inspection (source.rows ()),
    checked_octave_dimension_for_inspection (source.columns ()));
  for (std::size_t column = 0; column < source.columns (); ++column)
    for (std::size_t row = 0; row < source.rows (); ++row)
      result.xelem (static_cast<octave_idx_type> (row),
                    static_cast<octave_idx_type> (column))
        = Complex (source.at (row, column).real_to_double (),
                   source.at (row, column).imag_to_double ());
  return result;
}

std::string
matrix_display_text (const octave_value& value)
{
  const auto& source
    = octave_mplapack_mpfr_matrix_internal::checked_value (
        require_matrix_payload (value)).storage ();
  return octave_mplapack::format_matrix (source);
}

octave_scalar_map
value_shape_info (const octave_value& value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      == octave_mplapack_mpc_scalar_internal::static_type_id ())
    {
      const auto& scalar
        = octave_mplapack_mpc_scalar_internal::checked_value (payload);
      octave_scalar_map info;
      info.assign ("rows", octave_uint64 (1));
      info.assign ("columns", octave_uint64 (1));
      info.assign ("numel", octave_uint64 (1));
      info.assign ("precision_bits",
                   octave_uint64 (scalar.storage ().precision_bits ()));
      info.assign ("is_matrix", false);
      info.assign ("is_empty", false);
      info.assign ("is_complex", true);
      return info;
    }
  if (payload.type_id ()
      == octave_mplapack_mpc_matrix_internal::static_type_id ())
    {
      const auto& matrix
        = octave_mplapack_mpc_matrix_internal::checked_value (payload);
      const auto& storage = matrix.storage ();
      octave_scalar_map info;
      info.assign ("rows", octave_uint64 (storage.rows ()));
      info.assign ("columns", octave_uint64 (storage.columns ()));
      info.assign ("numel", octave_uint64 (storage.numel ()));
      info.assign ("precision_bits",
                   octave_uint64 (storage.precision_bits ()));
      info.assign ("is_matrix", true);
      info.assign ("is_empty", storage.numel () == 0);
      info.assign ("is_complex", true);
      return info;
    }
  octave_scalar_map info;
  if (payload.type_id ()
      == octave_mplapack_mpfr_scalar_internal::static_type_id ())
    {
      const auto& scalar
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload);
      info.assign ("rows", octave_uint64 (1));
      info.assign ("columns", octave_uint64 (1));
      info.assign ("numel", octave_uint64 (1));
      info.assign ("precision_bits",
                   octave_uint64 (scalar.storage ().precision_bits ()));
      info.assign ("is_matrix", false);
      info.assign ("is_empty", false);
      info.assign ("is_complex", false);
      return info;
    }

  const auto& matrix
    = octave_mplapack_mpfr_matrix_internal::checked_value (payload);
  const auto& storage = matrix.storage ();
  info.assign ("rows", octave_uint64 (storage.rows ()));
  info.assign ("columns", octave_uint64 (storage.columns ()));
  info.assign ("numel", octave_uint64 (storage.numel ()));
  info.assign ("precision_bits",
               octave_uint64 (storage.precision_bits ()));
  info.assign ("is_matrix", true);
  info.assign ("is_empty", storage.numel () == 0);
  info.assign ("is_complex", false);
  return info;
}

enum class ComplexScalarBinaryOperation
{
  add,
  subtract,
  multiply,
  divide
};

bool
is_complex_arithmetic_operand (const octave_value& value)
{
  if (is_mp_value (value))
    return is_complex_payload (value);
  return value.is_double_type () && ! value.isreal ();
}

mpfr_prec_t
arithmetic_mp_precision (const octave_value& value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      == octave_mplapack_mpfr_scalar_internal::static_type_id ())
    return octave_mplapack_mpfr_scalar_internal::checked_value (payload)
      .storage ().precision_bits ();
  if (payload.type_id ()
      == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    return octave_mplapack_mpfr_matrix_internal::checked_value (payload)
      .storage ().precision_bits ();
  if (payload.type_id ()
      == octave_mplapack_mpc_scalar_internal::static_type_id ())
    return octave_mplapack_mpc_scalar_internal::checked_value (payload)
      .storage ().precision_bits ();
  return octave_mplapack_mpc_matrix_internal::checked_value (payload)
    .storage ().precision_bits ();
}

struct PreparedComplexArithmeticOperand
{
  octave_value payload;
  std::optional<octave_mplapack::MpfrComplexScalarStorage> scalar_owned;
  std::optional<octave_mplapack::MpfrComplexMatrixStorage> matrix_owned;
  octave_mplapack::MpcElementwiseOperand view;
};

PreparedComplexArithmeticOperand
prepare_complex_arithmetic_operand (const octave_value& value,
                                    mpfr_prec_t operation_precision)
{
  PreparedComplexArithmeticOperand prepared;
  if (is_mp_value (value))
    {
      prepared.payload = require_mp_payload (value);
      if (prepared.payload.type_id ()
          == octave_mplapack_mpfr_scalar_internal::static_type_id ())
        prepared.view = octave_mplapack::MpcElementwiseOperand::from_real_scalar (
          octave_mplapack_mpfr_scalar_internal::checked_value (
            prepared.payload).storage ());
      else if (prepared.payload.type_id ()
               == octave_mplapack_mpfr_matrix_internal::static_type_id ())
        prepared.view = octave_mplapack::MpcElementwiseOperand::from_real_matrix (
          octave_mplapack_mpfr_matrix_internal::checked_value (
            prepared.payload).storage ());
      else if (prepared.payload.type_id ()
               == octave_mplapack_mpc_scalar_internal::static_type_id ())
        prepared.view = octave_mplapack::MpcElementwiseOperand::from_complex_scalar (
          octave_mplapack_mpc_scalar_internal::checked_value (
            prepared.payload).storage ());
      else
        prepared.view = octave_mplapack::MpcElementwiseOperand::from_complex_matrix (
          octave_mplapack_mpc_matrix_internal::checked_value (
            prepared.payload).storage ());
      return prepared;
    }

  if (! value.is_double_type ())
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "complex element-wise arithmetic supports mp and double operands");
  if (value.is_real_scalar () || value.is_complex_scalar ())
    {
      const Complex scalar = value.complex_value ();
      prepared.scalar_owned.emplace (scalar.real (), scalar.imag (),
                                     operation_precision);
      prepared.view
        = octave_mplapack::MpcElementwiseOperand::from_complex_scalar (
          *prepared.scalar_owned);
      return prepared;
    }
  if (value.ndims () != 2)
    error_with_id ("mplapack:mp:MatrixUnsupported",
                   "only two-dimensional matrix operands are supported");
  prepared.matrix_owned.emplace (
    make_complex_double_matrix_storage (value, operation_precision));
  prepared.view
    = octave_mplapack::MpcElementwiseOperand::from_complex_matrix (
      *prepared.matrix_owned);
  return prepared;
}

octave_value
complex_scalar_binary_operation (const octave_value& lhs_value,
                                 const octave_value& rhs_value,
                                 ComplexScalarBinaryOperation operation)
{
  mpfr_prec_t operation_precision = 0;
  if (is_mp_value (lhs_value))
    operation_precision = arithmetic_mp_precision (lhs_value);
  if (is_mp_value (rhs_value))
    operation_precision = std::max (operation_precision,
                                   arithmetic_mp_precision (rhs_value));
  if (operation_precision == 0)
    operation_precision = octave_mplapack::default_precision_bits ();

  const auto native_operation = [&] ()
  {
    switch (operation)
      {
      case ComplexScalarBinaryOperation::add:
        return octave_mplapack::MpcElementwiseBinaryOperation::add;
      case ComplexScalarBinaryOperation::subtract:
        return octave_mplapack::MpcElementwiseBinaryOperation::subtract;
      case ComplexScalarBinaryOperation::multiply:
        return octave_mplapack::MpcElementwiseBinaryOperation::multiply;
      case ComplexScalarBinaryOperation::divide:
        return octave_mplapack::MpcElementwiseBinaryOperation::divide;
      }
    throw std::logic_error ("unknown complex element-wise operation");
  } ();

  try
    {
      auto lhs = prepare_complex_arithmetic_operand (lhs_value,
                                                     operation_precision);
      auto rhs = prepare_complex_arithmetic_operand (rhs_value,
                                                     operation_precision);
      return make_complex_inspection_result (
        octave_mplapack::mpc_matrix_elementwise_binary (
          lhs.view, rhs.view, native_operation));
    }
  catch (const std::invalid_argument& exception)
    {
      const std::string message = exception.what ();
      if (message.find ("nonconformant") != std::string::npos)
        error_with_id ("mplapack:mp:DimensionMismatch", "%s",
                       exception.what ());
      error_with_id ("mplapack:mp:UnsupportedOperand", "%s",
                     exception.what ());
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:ArithmeticError", "%s", exception.what ());
    }
  return octave_value ();
}

enum class ScalarBinaryOperation
{
  add,
  subtract,
  multiply,
  divide
};

octave_mplapack::MpfrScalarStorage
apply_binary_operation (ScalarBinaryOperation operation,
                        const octave_mplapack::MpfrScalarStorage& lhs,
                        const octave_mplapack::MpfrScalarStorage& rhs)
{
  switch (operation)
    {
    case ScalarBinaryOperation::add:
      return lhs.add (rhs);
    case ScalarBinaryOperation::subtract:
      return lhs.subtract (rhs);
    case ScalarBinaryOperation::multiply:
      return lhs.multiply (rhs);
    case ScalarBinaryOperation::divide:
      return lhs.divide (rhs);
    }

  throw std::logic_error ("unknown scalar binary operation");
}

octave_value
scalar_binary_operation (const octave_value& lhs_value,
                         const octave_value& rhs_value,
                         ScalarBinaryOperation operation)
{
  if (is_complex_arithmetic_operand (lhs_value)
      || is_complex_arithmetic_operand (rhs_value))
    {
      const auto complex_operation = [&] ()
      {
        switch (operation)
          {
          case ScalarBinaryOperation::add:
            return ComplexScalarBinaryOperation::add;
          case ScalarBinaryOperation::subtract:
            return ComplexScalarBinaryOperation::subtract;
          case ScalarBinaryOperation::multiply:
            return ComplexScalarBinaryOperation::multiply;
          case ScalarBinaryOperation::divide:
            return ComplexScalarBinaryOperation::divide;
          }
        throw std::logic_error ("unknown complex element-wise operation");
      } ();
      return complex_scalar_binary_operation (lhs_value, rhs_value,
                                              complex_operation);
    }

  const bool lhs_is_mp = is_mp_value (lhs_value);
  const bool rhs_is_mp = is_mp_value (rhs_value);

  const bool lhs_is_matrix
    = lhs_is_mp && is_matrix_payload (lhs_value);
  const bool rhs_is_matrix
    = rhs_is_mp && is_matrix_payload (rhs_value);
  const bool lhs_is_double_matrix = is_double_matrix_operand (lhs_value);
  const bool rhs_is_double_matrix = is_double_matrix_operand (rhs_value);
  if (lhs_is_matrix || rhs_is_matrix || lhs_is_double_matrix
      || rhs_is_double_matrix)
    {
      const auto native_operation
        = [&] ()
        {
          switch (operation)
            {
            case ScalarBinaryOperation::add:
              return octave_mplapack::MpfrElementwiseBinaryOperation::add;
            case ScalarBinaryOperation::subtract:
              return octave_mplapack::MpfrElementwiseBinaryOperation::subtract;
            case ScalarBinaryOperation::multiply:
              return octave_mplapack::MpfrElementwiseBinaryOperation::multiply;
            case ScalarBinaryOperation::divide:
              return octave_mplapack::MpfrElementwiseBinaryOperation::divide;
            }
          throw std::logic_error ("unknown element-wise operation");
        } ();

      const bool lhs_is_complex_double
        = lhs_value.is_double_type () && ! lhs_value.isreal ();
      const bool rhs_is_complex_double
        = rhs_value.is_double_type () && ! rhs_value.isreal ();
      if (lhs_is_complex_double || rhs_is_complex_double)
        error_with_id ("mplapack:mp:ComplexUnsupported",
                       "complex element-wise arithmetic is not supported");

      struct PreparedOperand
      {
        octave_value payload;
        std::optional<octave_mplapack::MpfrScalarStorage> scalar_owned;
        std::optional<octave_mplapack::MpfrMatrixStorage> matrix_owned;
        octave_mplapack::MpfrElementwiseOperand view;
      };

      auto precision_of_mp = [] (const octave_value& value)
      {
        const octave_value payload = require_mp_payload (value);
        if (payload.type_id ()
            == octave_mplapack_mpfr_scalar_internal::static_type_id ())
          return octave_mplapack_mpfr_scalar_internal::checked_value (
            payload).storage ().precision_bits ();
        return octave_mplapack_mpfr_matrix_internal::checked_value (
          payload).storage ().precision_bits ();
      };

      if (! lhs_is_mp && ! rhs_is_mp)
        error_with_id ("mplapack:mp:UnsupportedOperand",
                       "element-wise arithmetic requires at least one mp operand");

      mpfr_prec_t operation_precision = 0;
      if (lhs_is_mp)
        operation_precision = precision_of_mp (lhs_value);
      if (rhs_is_mp)
        operation_precision = std::max (operation_precision,
                                        precision_of_mp (rhs_value));

      auto prepare = [operation_precision] (const octave_value& value)
      {
        PreparedOperand prepared;
        if (is_mp_value (value))
          {
            prepared.payload = require_mp_payload (value);
            return prepared;
          }

        if (value.is_double_type ())
          {
            if (! value.isreal ())
              error_with_id ("mplapack:mp:ComplexUnsupported",
                             "complex element-wise arithmetic is not supported");
            if (value.is_real_scalar ())
              {
                prepared.scalar_owned.emplace (value.double_value (),
                                               operation_precision);
              }
            else
              {
                prepared.matrix_owned.emplace (
                  make_double_matrix_storage (value, operation_precision));
              }
            return prepared;
          }

        error_with_id ("mplapack:mp:UnsupportedOperand",
                       "element-wise arithmetic supports mp and real double operands");
        return prepared;
      };

      try
        {
          PreparedOperand lhs = prepare (lhs_value);
          PreparedOperand rhs = prepare (rhs_value);
          auto bind = [] (PreparedOperand& prepared)
          {
            if (prepared.scalar_owned)
              prepared.view
                = octave_mplapack::MpfrElementwiseOperand::from_scalar (
                  *prepared.scalar_owned);
            else if (prepared.matrix_owned)
              prepared.view
                = octave_mplapack::MpfrElementwiseOperand::from_matrix (
                  *prepared.matrix_owned);
            else if (prepared.payload.type_id ()
                     == octave_mplapack_mpfr_scalar_internal::static_type_id ())
              {
                const auto& scalar
                  = octave_mplapack_mpfr_scalar_internal::checked_value (
                    prepared.payload).storage ();
                prepared.view
                  = octave_mplapack::MpfrElementwiseOperand::from_scalar (
                    scalar);
              }
            else
              {
                const auto& matrix
                  = octave_mplapack_mpfr_matrix_internal::checked_value (
                    prepared.payload).storage ();
                prepared.view
                  = octave_mplapack::MpfrElementwiseOperand::from_matrix (
                    matrix);
              }
          };
          bind (lhs);
          bind (rhs);
          auto result = octave_mplapack::mpfr_matrix_elementwise_binary (
            lhs.view, rhs.view, native_operation);
          if (result.rows () == 1 && result.columns () == 1)
            return make_internal_scalar (
              octave_mplapack::MpfrScalarStorage (
                std::move (result.at (0, 0))));
          return make_internal_matrix (std::move (result));
        }
      catch (const std::invalid_argument& exception)
        {
          const std::string message = exception.what ();
          if (message.find ("nonconformant") != std::string::npos)
            error_with_id ("mplapack:mp:DimensionMismatch", "%s",
                           exception.what ());
          error_with_id ("mplapack:mp:UnsupportedOperand", "%s",
                         exception.what ());
        }
      catch (const std::overflow_error& exception)
        {
          error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                         exception.what ());
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:mp:ArithmeticError", "%s",
                         exception.what ());
        }
      return octave_value ();
    }

  if (! lhs_is_mp && ! rhs_is_mp)
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "scalar arithmetic requires at least one mp operand");

  if (lhs_is_mp && rhs_is_mp)
    {
      const octave_value lhs_payload
        = require_arithmetic_mp_payload (lhs_value);
      const octave_value rhs_payload
        = require_arithmetic_mp_payload (rhs_value);
      const auto& lhs
        = octave_mplapack_mpfr_scalar_internal::checked_value (
            lhs_payload).storage ();
      const auto& rhs
        = octave_mplapack_mpfr_scalar_internal::checked_value (
            rhs_payload).storage ();
      try
        {
          return make_internal_scalar (
            apply_binary_operation (operation, lhs, rhs));
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:ArithmeticError", "%s",
                         exception.what ());
        }
    }

  if (lhs_is_mp)
    {
      const octave_value lhs_payload
        = require_arithmetic_mp_payload (lhs_value);
      const auto& lhs
        = octave_mplapack_mpfr_scalar_internal::checked_value (
            lhs_payload).storage ();
      const double rhs_double = require_arithmetic_double (rhs_value);
      try
        {
          const octave_mplapack::MpfrScalarStorage rhs (
            rhs_double, lhs.precision_bits ());
          return make_internal_scalar (
            apply_binary_operation (operation, lhs, rhs));
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:ArithmeticError", "%s",
                         exception.what ());
        }
    }

  const octave_value rhs_payload
    = require_arithmetic_mp_payload (rhs_value);
  const auto& rhs
    = octave_mplapack_mpfr_scalar_internal::checked_value (
        rhs_payload).storage ();
  const double lhs_double = require_arithmetic_double (lhs_value);
  try
    {
      const octave_mplapack::MpfrScalarStorage lhs (
        lhs_double, rhs.precision_bits ());
      return make_internal_scalar (
        apply_binary_operation (operation, lhs, rhs));
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:ArithmeticError", "%s", exception.what ());
    }

  return octave_value ();
}

octave_value
complex_mtimes_operation (const octave_value& lhs_value,
                          const octave_value& rhs_value)
{
  mpfr_prec_t operation_precision = 0;
  if (is_mp_value (lhs_value))
    operation_precision = arithmetic_mp_precision (lhs_value);
  if (is_mp_value (rhs_value))
    operation_precision = std::max (operation_precision,
                                   arithmetic_mp_precision (rhs_value));
  if (operation_precision == 0)
    operation_precision = octave_mplapack::default_precision_bits ();

  struct PreparedOperand
  {
    std::optional<octave_mplapack::MpfrComplexScalarStorage> scalar;
    std::optional<octave_mplapack::MpfrComplexMatrixStorage> matrix;
  };

  const auto prepare = [operation_precision] (const octave_value& value)
  {
    PreparedOperand prepared;
    if (is_mp_value (value))
      {
        const octave_value payload = require_mp_payload (value);
        if (payload.type_id ()
            == octave_mplapack_mpfr_scalar_internal::static_type_id ())
          prepared.scalar.emplace (
            octave_mplapack::mplapack_mpc_scalar_from_real (
              octave_mplapack_mpfr_scalar_internal::checked_value (payload)
                .storage (), operation_precision));
        else if (payload.type_id ()
                 == octave_mplapack_mpfr_matrix_internal::static_type_id ())
          prepared.matrix.emplace (
            octave_mplapack::mplapack_mpc_matrix_from_real (
              octave_mplapack_mpfr_matrix_internal::checked_value (payload)
                .storage (), operation_precision));
        else if (payload.type_id ()
                 == octave_mplapack_mpc_scalar_internal::static_type_id ())
          prepared.scalar.emplace (
            octave_mplapack::mplapack_mpc_scalar_copy_at_precision (
              octave_mplapack_mpc_scalar_internal::checked_value (payload)
                .storage (), operation_precision));
        else
          prepared.matrix.emplace (
            octave_mplapack::mplapack_mpc_matrix_copy_at_precision (
              octave_mplapack_mpc_matrix_internal::checked_value (payload)
                .storage (), operation_precision));
        return prepared;
      }

    if (! value.is_double_type ())
      error_with_id ("mplapack:mp:UnsupportedOperand",
                     "complex matrix multiplication supports mp and double operands");
    if (value.is_real_scalar () || value.is_complex_scalar ())
      {
        const Complex scalar = value.complex_value ();
        prepared.scalar.emplace (scalar.real (), scalar.imag (),
                                 operation_precision);
      }
    else
      prepared.matrix.emplace (make_complex_double_matrix_storage (
        value, operation_precision));
    return prepared;
  };

  try
    {
      const PreparedOperand lhs = prepare (lhs_value);
      const PreparedOperand rhs = prepare (rhs_value);
      if (lhs.matrix && rhs.matrix)
        return make_complex_inspection_result (
          octave_mplapack::mplapack_mpc_matrix_multiply (*lhs.matrix,
                                                         *rhs.matrix));
      if (lhs.matrix && rhs.scalar)
        return make_complex_inspection_result (
          octave_mplapack::mplapack_mpc_matrix_scale (*lhs.matrix,
                                                      *rhs.scalar));
      if (lhs.scalar && rhs.matrix)
        return make_complex_inspection_result (
          octave_mplapack::mplapack_mpc_matrix_scale (*rhs.matrix,
                                                      *lhs.scalar));
      return make_internal_complex_scalar (
        octave_mplapack::mplapack_mpc_scalar_multiply (*lhs.scalar,
                                                       *rhs.scalar));
    }
  catch (const std::invalid_argument& exception)
    {
      const std::string message = exception.what ();
      if (message.find ("dimension mismatch") != std::string::npos)
        error_with_id ("mplapack:mp:DimensionMismatch", "%s",
                       exception.what ());
      error_with_id ("mplapack:mp:UnsupportedOperand", "%s",
                     exception.what ());
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:MtimesError", "%s", exception.what ());
    }
  return octave_value ();
}

octave_value
complex_mldivide_operation (const octave_value& lhs_value,
                            const octave_value& rhs_value)
{
  mpfr_prec_t operation_precision = 0;
  if (is_mp_value (lhs_value))
    operation_precision = arithmetic_mp_precision (lhs_value);
  if (is_mp_value (rhs_value))
    operation_precision = std::max (operation_precision,
                                   arithmetic_mp_precision (rhs_value));
  if (operation_precision == 0)
    operation_precision = octave_mplapack::default_precision_bits ();

  struct PreparedOperand
  {
    std::optional<octave_mplapack::MpfrComplexScalarStorage> scalar;
    std::optional<octave_mplapack::MpfrComplexMatrixStorage> matrix;
  };

  const auto prepare = [operation_precision] (const octave_value& value)
  {
    PreparedOperand prepared;
    if (is_mp_value (value))
      {
        const octave_value payload = require_mp_payload (value);
        if (payload.type_id ()
            == octave_mplapack_mpfr_scalar_internal::static_type_id ())
          prepared.scalar.emplace (
            octave_mplapack::mplapack_mpc_scalar_from_real (
              octave_mplapack_mpfr_scalar_internal::checked_value (payload)
                .storage (), operation_precision));
        else if (payload.type_id ()
                 == octave_mplapack_mpfr_matrix_internal::static_type_id ())
          prepared.matrix.emplace (
            octave_mplapack::mplapack_mpc_matrix_from_real (
              octave_mplapack_mpfr_matrix_internal::checked_value (payload)
                .storage (), operation_precision));
        else if (payload.type_id ()
                 == octave_mplapack_mpc_scalar_internal::static_type_id ())
          prepared.scalar.emplace (
            octave_mplapack::mplapack_mpc_scalar_copy_at_precision (
              octave_mplapack_mpc_scalar_internal::checked_value (payload)
                .storage (), operation_precision));
        else
          prepared.matrix.emplace (
            octave_mplapack::mplapack_mpc_matrix_copy_at_precision (
              octave_mplapack_mpc_matrix_internal::checked_value (payload)
                .storage (), operation_precision));
        return prepared;
      }

    if (! value.is_double_type ())
      error_with_id ("mplapack:mp:UnsupportedOperand",
                     "complex left division supports mp and double operands");
    if (value.is_real_scalar () || value.is_complex_scalar ())
      {
        const Complex scalar = value.complex_value ();
        prepared.scalar.emplace (scalar.real (), scalar.imag (),
                                 operation_precision);
      }
    else
      prepared.matrix.emplace (make_complex_double_matrix_storage (
        value, operation_precision));
    return prepared;
  };

  try
    {
      const PreparedOperand lhs = prepare (lhs_value);
      const PreparedOperand rhs = prepare (rhs_value);

      if (lhs.scalar)
        {
          if (rhs.matrix)
            return make_complex_inspection_result (
              octave_mplapack::mpc_matrix_elementwise_binary (
                octave_mplapack::MpcElementwiseOperand::from_complex_matrix (
                  *rhs.matrix),
                octave_mplapack::MpcElementwiseOperand::from_complex_scalar (
                  *lhs.scalar),
                octave_mplapack::MpcElementwiseBinaryOperation::divide));

          return make_complex_inspection_result (
            octave_mplapack::mpc_matrix_elementwise_binary (
              octave_mplapack::MpcElementwiseOperand::from_complex_scalar (
                *rhs.scalar),
              octave_mplapack::MpcElementwiseOperand::from_complex_scalar (
                *lhs.scalar),
              octave_mplapack::MpcElementwiseBinaryOperation::divide));
        }

      std::optional<octave_mplapack::MpfrComplexMatrixStorage> rhs_matrix;
      if (rhs.matrix)
        rhs_matrix.emplace (*rhs.matrix);
      else
        {
          if (lhs.matrix->rows () != 1 || lhs.matrix->columns () != 1)
            throw std::invalid_argument (
              "matrix left division requires a dense right-hand matrix");
          rhs_matrix.emplace (1, 1, operation_precision);
          mpc_set (rhs_matrix->at (0, 0).mpc_data (),
                   rhs.scalar->native_value ().mpc_data (),
                   MPC_RND (MPFR_RNDN, MPFR_RNDN));
        }

      return make_complex_inspection_result (
        lhs.matrix->rows () == lhs.matrix->columns ()
          ? octave_mplapack::mplapack_mpc_matrix_solve (*lhs.matrix,
                                                        *rhs_matrix)
          : octave_mplapack::mplapack_mpc_matrix_rank_solve (
              *lhs.matrix, *rhs_matrix).solution);
    }
  catch (const octave_mplapack::MpcCgelsyError& exception)
    {
      if (exception.kind ()
          == octave_mplapack::MpcCgelsyError::Kind::convergence)
        error_with_id ("mplapack:mp:ConvergenceFailure",
                       "MPLAPACK Cgelsy failed to converge (info %d)",
                       static_cast<int> (exception.info ()));
      if (exception.kind ()
          == octave_mplapack::MpcCgelsyError::Kind::invalid_argument)
        error_with_id ("mplapack:mp:RankRevealingError",
                       "MPLAPACK Cgelsy rejected argument %d",
                       -static_cast<int> (exception.info ()));
      error_with_id ("mplapack:mp:RankRevealingInternalError", "%s",
                     exception.what ());
    }
  catch (const octave_mplapack::MpcCgesvError& exception)
    {
      if (exception.kind ()
          == octave_mplapack::MpcCgesvError::Kind::singular)
        error_with_id ("mplapack:mp:SingularMatrix",
                       "mp left division: complex coefficient matrix is singular");
      error_with_id ("mplapack:mp:CgesvError",
                     "MPLAPACK Cgesv rejected argument %d",
                     -static_cast<int> (exception.info ()));
    }
  catch (const std::invalid_argument& exception)
    {
      const std::string message = exception.what ();
      if (message.find ("square") != std::string::npos)
        error_with_id ("mplapack:mp:NonSquareMatrix", "%s",
                       exception.what ());
      if (message.find ("dimensions") != std::string::npos)
        error_with_id ("mplapack:mp:DimensionMismatch", "%s",
                       exception.what ());
      error_with_id ("mplapack:mp:UnsupportedOperand", "%s",
                     exception.what ());
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:CgesvError", "%s", exception.what ());
    }
  return octave_value ();
}

octave_value
make_mtimes_result (octave_mplapack::MpfrMatrixStorage storage)
{
  if (storage.rows () == 1 && storage.columns () == 1)
    {
      octave_mplapack::MpfrScalarStorage scalar (
        std::move (storage.at (0, 0)));
      return make_internal_scalar (std::move (scalar));
    }
  return make_internal_matrix (std::move (storage));
}

octave_value
make_mldivide_result (octave_mplapack::MpfrMatrixStorage storage)
{
  return make_mtimes_result (std::move (storage));
}

octave_value_list
complex_cholesky_operation (const octave_value& value, bool lower)
{
  const octave_value payload = require_mp_payload (value);
  std::optional<octave_mplapack::MpfrComplexMatrixStorage> scalar_matrix;
  const octave_mplapack::MpfrComplexMatrixStorage *input = nullptr;
  if (payload.type_id ()
      == octave_mplapack_mpc_scalar_internal::static_type_id ())
    {
      const auto& scalar
        = octave_mplapack_mpc_scalar_internal::checked_value (payload)
            .storage ();
      scalar_matrix.emplace (1, 1, scalar.precision_bits ());
      mpc_set (scalar_matrix->at (0, 0).mpc_data (),
               scalar.native_value ().mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
      input = &*scalar_matrix;
    }
  else if (payload.type_id ()
           == octave_mplapack_mpc_matrix_internal::static_type_id ())
    input = &octave_mplapack_mpc_matrix_internal::checked_value (payload)
              .storage ();
  else
    error_with_id ("mplapack:mp:InvalidInput",
                   "chol expects one complex mp value");

  try
    {
      const auto factor
        = octave_mplapack::mplapack_mpc_matrix_cholesky (*input, lower);
      return ovl (make_complex_inspection_result (factor.factor),
                  octave_value (static_cast<double> (factor.info)));
    }
  catch (const octave_mplapack::MpcCpotrfError& exception)
    {
      if (exception.kind ()
          == octave_mplapack::MpcCpotrfError::Kind::invalid_argument)
        error_with_id ("mplapack:mp:CpotrfError",
                       "MPLAPACK Cpotrf rejected argument %d",
                       -static_cast<int> (exception.info ()));
      error_with_id ("mplapack:mp:CpotrfInternalError", "%s",
                     exception.what ());
    }
  catch (const std::invalid_argument& exception)
    {
      if (std::string (exception.what ()).find ("square")
          != std::string::npos)
        error_with_id ("mplapack:mp:NonSquareMatrix", "%s",
                       exception.what ());
      error_with_id ("mplapack:mp:InvalidInput", "%s", exception.what ());
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:CpotrfError", "%s", exception.what ());
    }
  return ovl ();
}

octave_value_list
mp_cholesky_operation (const octave_value& value, bool lower)
{
  if (! is_mp_value (value))
    error_with_id ("mplapack:mp:InvalidInput",
                   "chol expects one real mp value");

  if (is_complex_payload (value))
    return complex_cholesky_operation (value, lower);

  std::optional<octave_mplapack::MpfrMatrixStorage> scalar_matrix;
  const octave_value payload = require_mp_payload (value);
  const octave_mplapack::MpfrMatrixStorage *input = nullptr;
  if (payload.type_id ()
      == octave_mplapack_mpfr_scalar_internal::static_type_id ())
    {
      const auto& scalar
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload)
            .storage ();
      scalar_matrix.emplace (1, 1, scalar.precision_bits ());
      mpfr_set (scalar_matrix->at (0, 0).mpfr_data (),
                scalar.native_value ().mpfr_data (), MPFR_RNDN);
      input = &*scalar_matrix;
    }
  else if (payload.type_id ()
           == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    input = &octave_mplapack_mpfr_matrix_internal::checked_value (payload)
              .storage ();
  else
    error_with_id ("mplapack:mp:InvalidInput",
                   "chol expects one real mp value");

  try
    {
      const auto factor
        = octave_mplapack::mplapack_mpfr_matrix_cholesky (*input, lower);
      return ovl (make_mtimes_result (factor.factor),
                  octave_value (static_cast<double> (factor.info)));
    }
  catch (const octave_mplapack::MpfrRpotrfError& exception)
    {
      if (exception.kind ()
          == octave_mplapack::MpfrRpotrfError::Kind::invalid_argument)
        error_with_id ("mplapack:mp:RpotrfError",
                       "MPLAPACK Rpotrf rejected argument %d",
                       -exception.info ());
      error_with_id ("mplapack:mp:RpotrfInternalError", "%s",
                     exception.what ());
    }
  catch (const std::invalid_argument& exception)
    {
      if (std::string (exception.what ()).find ("square")
          != std::string::npos)
        error_with_id ("mplapack:mp:NonSquareMatrix", "%s",
                       exception.what ());
      error_with_id ("mplapack:mp:InvalidInput", "%s", exception.what ());
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:CholeskyError", "%s", exception.what ());
    }
  return ovl ();
}

octave_value_list
complex_qr_operation (const octave_value& value, bool economy, bool want_q)
{
  const octave_value payload = require_mp_payload (value);
  std::optional<octave_mplapack::MpfrComplexMatrixStorage> scalar_matrix;
  const octave_mplapack::MpfrComplexMatrixStorage *input = nullptr;
  if (payload.type_id ()
      == octave_mplapack_mpc_scalar_internal::static_type_id ())
    {
      const auto& scalar
        = octave_mplapack_mpc_scalar_internal::checked_value (payload)
            .storage ();
      scalar_matrix.emplace (1, 1, scalar.precision_bits ());
      mpc_set (scalar_matrix->at (0, 0).mpc_data (),
               scalar.native_value ().mpc_data (),
               MPC_RND (MPFR_RNDN, MPFR_RNDN));
      input = &*scalar_matrix;
    }
  else if (payload.type_id ()
           == octave_mplapack_mpc_matrix_internal::static_type_id ())
    input = &octave_mplapack_mpc_matrix_internal::checked_value (payload)
              .storage ();
  else
    error_with_id ("mplapack:mp:InvalidInput",
                   "qr expects one complex mp value");

  try
    {
      const auto factors
        = octave_mplapack::mplapack_mpc_matrix_qr (*input, economy, want_q);
      const octave_value r = make_complex_inspection_result (factors.r);
      if (! want_q)
        return ovl (r);
      return ovl (make_complex_inspection_result (factors.q), r);
    }
  catch (const octave_mplapack::MpcQrError& exception)
    {
      if (exception.kind ()
          == octave_mplapack::MpcQrError::Kind::invalid_argument)
        error_with_id ("mplapack:mp:QrError",
                       "MPLAPACK complex QR rejected argument %d",
                       -static_cast<int> (exception.info ()));
      error_with_id ("mplapack:mp:QrInternalError", "%s",
                     exception.what ());
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::invalid_argument& exception)
    {
      error_with_id ("mplapack:mp:InvalidInput", "%s", exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:QrError", "%s", exception.what ());
    }
  return ovl ();
}

octave_value_list
mp_qr_operation (const octave_value& value, bool economy, bool want_q)
{
  if (! is_mp_value (value))
    error_with_id ("mplapack:mp:InvalidInput",
                   "qr expects one real mp value");

  std::optional<octave_mplapack::MpfrMatrixStorage> scalar_matrix;
  const octave_value payload = require_mp_payload (value);
  const octave_mplapack::MpfrMatrixStorage *input = nullptr;
  if (payload.type_id ()
      == octave_mplapack_mpfr_scalar_internal::static_type_id ())
    {
      const auto& scalar
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload)
            .storage ();
      scalar_matrix.emplace (1, 1, scalar.precision_bits ());
      mpfr_set (scalar_matrix->at (0, 0).mpfr_data (),
                scalar.native_value ().mpfr_data (), MPFR_RNDN);
      input = &*scalar_matrix;
    }
  else if (payload.type_id ()
           == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    input = &octave_mplapack_mpfr_matrix_internal::checked_value (payload)
              .storage ();
  else
    error_with_id ("mplapack:mp:InvalidInput",
                   "qr expects one real mp value");

  try
    {
      const auto factors
        = octave_mplapack::mplapack_mpfr_matrix_qr (
            *input, economy, want_q);
      const octave_value r = make_mtimes_result (factors.r);
      if (! want_q)
        return ovl (r);
      return ovl (make_mtimes_result (factors.q), r);
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::invalid_argument& exception)
    {
      error_with_id ("mplapack:mp:InvalidInput", "%s", exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:QrError", "%s", exception.what ());
    }
  return ovl ();
}

octave_value_list
mp_pivoted_qr_operation (const octave_value& value, bool economy,
                         bool vector_output)
{
  if (! is_mp_value (value))
    error_with_id ("mplapack:mp:InvalidInput",
                   "qr expects one real mp value");

  std::optional<octave_mplapack::MpfrMatrixStorage> scalar_matrix;
  const octave_value payload = require_mp_payload (value);
  const octave_mplapack::MpfrMatrixStorage *input = nullptr;
  if (payload.type_id ()
      == octave_mplapack_mpfr_scalar_internal::static_type_id ())
    {
      const auto& scalar
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload)
            .storage ();
      scalar_matrix.emplace (1, 1, scalar.precision_bits ());
      mpfr_set (scalar_matrix->at (0, 0).mpfr_data (),
                scalar.native_value ().mpfr_data (), MPFR_RNDN);
      input = &*scalar_matrix;
    }
  else if (payload.type_id ()
           == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    input = &octave_mplapack_mpfr_matrix_internal::checked_value (payload)
              .storage ();
  else
    error_with_id ("mplapack:mp:InvalidInput",
                   "qr expects one real mp value");

  try
    {
      const auto factors
        = octave_mplapack::mplapack_mpfr_matrix_pivoted_qr (
            *input, economy, true);
      const octave_value q = make_mtimes_result (factors.q);
      const octave_value r = make_mtimes_result (factors.r);
      const std::size_t n = factors.permutation.size ();
      if (vector_output)
        {
          Matrix p (1, checked_octave_dimension_for_inspection (n));
          for (std::size_t column = 0; column < n; ++column)
            p.xelem (0, static_cast<octave_idx_type> (column))
              = static_cast<double> (factors.permutation[column]);
          return ovl (q, r, octave_value (p));
        }

      const octave_idx_type dimension
        = checked_octave_dimension_for_inspection (n);
      Matrix p (dimension, dimension);
      for (std::size_t column = 0; column < n; ++column)
        {
          const auto source = factors.permutation[column] - 1;
          p.xelem (static_cast<octave_idx_type> (source),
                   static_cast<octave_idx_type> (column))
            = 1.0;
        }
      return ovl (q, r, octave_value (p));
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::invalid_argument& exception)
    {
      error_with_id ("mplapack:mp:InvalidInput", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:QrError", "%s", exception.what ());
    }
  return ovl ();
}

octave_value_list
mp_lu_operation (const octave_value& value, const std::string& output_mode)
{
  if (! is_mp_value (value))
    error_with_id ("mplapack:mp:InvalidInput",
                   "lu expects one real mp value");

  const octave_value payload = require_mp_payload (value);
  const octave_mplapack::MpfrMatrixStorage *input = nullptr;
  std::optional<octave_mplapack::MpfrMatrixStorage> scalar_matrix;
  if (payload.type_id ()
      == octave_mplapack_mpfr_scalar_internal::static_type_id ())
    {
      const auto& scalar
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload)
            .storage ();
      scalar_matrix.emplace (1, 1, scalar.precision_bits ());
      mpfr_set (scalar_matrix->at (0, 0).mpfr_data (),
                scalar.native_value ().mpfr_data (), MPFR_RNDN);
      input = &*scalar_matrix;
    }
  else if (payload.type_id ()
           == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    input = &octave_mplapack_mpfr_matrix_internal::checked_value (payload)
              .storage ();
  else
    error_with_id ("mplapack:mp:InvalidInput",
                   "lu expects one real mp value");

  try
    {
      auto factors = octave_mplapack::mplapack_mpfr_matrix_lu (*input);
      if (output_mode == "packed")
        return ovl (make_mtimes_result (std::move (factors.packed)));

      const std::size_t permutation_size = factors.permutation.size ();
      const auto p_dimension
        = checked_octave_dimension_for_inspection (permutation_size);

      if (output_mode == "two")
        {
          const std::size_t m = factors.lower.rows ();
          const std::size_t k = factors.lower.columns ();
          octave_mplapack::MpfrMatrixStorage lower_unpermuted (
            m, k, factors.lower.precision_bits ());
          std::vector<std::size_t> inverse (permutation_size);
          for (std::size_t destination = 0; destination < permutation_size;
               ++destination)
            {
              const auto source = factors.permutation[destination];
              if (source < 1 || source > permutation_size)
                error_with_id ("mplapack:mp:LuError",
                               "MPLAPACK Rgetrf returned an invalid permutation");
              inverse[static_cast<std::size_t> (source - 1)] = destination;
            }
          for (std::size_t column = 0; column < k; ++column)
            for (std::size_t row = 0; row < m; ++row)
              mpfr_set (lower_unpermuted.at (row, column).mpfr_data (),
                        factors.lower.at (inverse[row], column).mpfr_data (),
                        MPFR_RNDN);
          return ovl (make_mtimes_result (std::move (lower_unpermuted)),
                      make_mtimes_result (std::move (factors.upper)));
        }

      if (output_mode == "matrix" || output_mode == "vector")
        {
          if (output_mode == "vector")
            {
              Matrix permutation_vector = permutation_size == 0
                                             ? Matrix (0, 0)
                                             : Matrix (p_dimension, 1);
              for (std::size_t row = 0; row < permutation_size; ++row)
                permutation_vector.xelem (static_cast<octave_idx_type> (row),
                                         0)
                  = static_cast<double> (factors.permutation[row]);
              return ovl (make_mtimes_result (std::move (factors.lower)),
                          make_mtimes_result (std::move (factors.upper)),
                          octave_value (permutation_vector));
            }

          octave_mplapack::MpfrMatrixStorage::checked_element_count (
            permutation_size, permutation_size);
          Matrix permutation_matrix (p_dimension, p_dimension);
          for (std::size_t destination = 0; destination < permutation_size;
               ++destination)
            {
              const auto source = factors.permutation[destination];
              if (source < 1 || source > permutation_size)
                error_with_id ("mplapack:mp:LuError",
                               "MPLAPACK Rgetrf returned an invalid permutation");
              permutation_matrix.xelem (
                static_cast<octave_idx_type> (destination),
                static_cast<octave_idx_type> (source - 1)) = 1.0;
            }

          return ovl (make_mtimes_result (std::move (factors.lower)),
                      make_mtimes_result (std::move (factors.upper)),
                      octave_value (permutation_matrix));
        }

      error_with_id ("mplapack:mp:InvalidArguments",
                     "invalid LU output mode");
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::invalid_argument& exception)
    {
      error_with_id ("mplapack:mp:LuError", "%s", exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:LuError", "%s", exception.what ());
    }
  return ovl ();
}

octave_value
matrix_mtimes_operation (const octave_value& lhs_value,
                         const octave_value& rhs_value)
{
  std::optional<octave_mplapack::MpfrMatrixStorage> lhs_owned;
  std::optional<octave_mplapack::MpfrMatrixStorage> rhs_owned;
  const octave_mplapack::MpfrMatrixStorage *lhs = nullptr;
  const octave_mplapack::MpfrMatrixStorage *rhs = nullptr;

  if (is_mp_value (lhs_value) && is_matrix_payload (lhs_value))
    {
      const octave_value payload = require_matrix_payload (lhs_value);
      lhs = &octave_mplapack_mpfr_matrix_internal::checked_value (
        payload).storage ();
    }
  else if (is_real_double_matrix_operand (lhs_value))
    {
      // The other matrix determines the operation precision.  The caller
      // has already rejected two raw-double matrices before this function.
      const octave_value payload = require_matrix_payload (rhs_value);
      const auto& rhs_storage
        = octave_mplapack_mpfr_matrix_internal::checked_value (
            payload).storage ();
      lhs_owned.emplace (make_double_matrix_storage (
        lhs_value, rhs_storage.precision_bits ()));
      lhs = &*lhs_owned;
    }
  else
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "matrix multiplication requires a dense mp or real double matrix");

  if (is_mp_value (rhs_value) && is_matrix_payload (rhs_value))
    {
      const octave_value payload = require_matrix_payload (rhs_value);
      rhs = &octave_mplapack_mpfr_matrix_internal::checked_value (
        payload).storage ();
    }
  else if (is_real_double_matrix_operand (rhs_value))
    {
      if (! lhs)
        error_with_id ("mplapack:mp:UnsupportedOperand",
                       "matrix multiplication requires an mp operand");
      rhs_owned.emplace (make_double_matrix_storage (
        rhs_value, lhs->precision_bits ()));
      rhs = &*rhs_owned;
    }
  else
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "matrix multiplication requires a dense mp or real double matrix");

  const auto& lhs_storage = *lhs;
  const auto& rhs_storage = *rhs;

  if (lhs_storage.columns () != rhs_storage.rows ())
    error_with_id ("mplapack:mp:DimensionMismatch",
                   "matrix multiplication dimensions must agree");

  try
    {
      return make_mtimes_result (
        octave_mplapack::mplapack_mpfr_matrix_multiply (lhs_storage,
                                                        rhs_storage));
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:MtimesError", "%s", exception.what ());
    }
  return octave_value ();
}

octave_value
matrix_scale_storage_operation (
  const octave_mplapack::MpfrMatrixStorage& matrix,
  const octave_value& scalar_value)
{
  try
    {
      if (is_mp_value (scalar_value))
        {
          const octave_value scalar_payload
            = require_scalar_payload (scalar_value);
          const auto& scalar
            = octave_mplapack_mpfr_scalar_internal::checked_value (
                scalar_payload).storage ();
          return make_mtimes_result (
            octave_mplapack::mplapack_mpfr_matrix_scale (
              matrix, scalar.native_value ()));
        }

      return make_mtimes_result (
        octave_mplapack::mplapack_mpfr_matrix_scale (
          matrix, require_arithmetic_double (scalar_value)));
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:MtimesError", "%s", exception.what ());
    }
  return octave_value ();
}

octave_value
matrix_scale_operation (const octave_value& matrix_value,
                        const octave_value& scalar_value)
{
  const octave_value matrix_payload = require_matrix_payload (matrix_value);
  const auto& matrix
    = octave_mplapack_mpfr_matrix_internal::checked_value (
        matrix_payload).storage ();
  return matrix_scale_storage_operation (matrix, scalar_value);
}

octave_value
mp_mtimes_operation (const octave_value& lhs_value,
                     const octave_value& rhs_value)
{
  const bool lhs_is_mp = is_mp_value (lhs_value);
  const bool rhs_is_mp = is_mp_value (rhs_value);
  if (! lhs_is_mp && ! rhs_is_mp)
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "matrix multiplication requires at least one mp operand");

  const bool lhs_is_matrix
    = lhs_is_mp && is_matrix_payload (lhs_value);
  const bool rhs_is_matrix
    = rhs_is_mp && is_matrix_payload (rhs_value);
  const bool lhs_is_double_matrix = is_double_matrix_operand (lhs_value);
  const bool rhs_is_double_matrix = is_double_matrix_operand (rhs_value);

  if (lhs_is_double_matrix && ! lhs_value.isreal ())
    error_with_id ("mplapack:mp:ComplexUnsupported",
                   "complex matrix multiplication is not supported");
  if (rhs_is_double_matrix && ! rhs_value.isreal ())
    error_with_id ("mplapack:mp:ComplexUnsupported",
                   "complex matrix multiplication is not supported");

  if (lhs_is_double_matrix || rhs_is_double_matrix)
    {
      if (lhs_is_double_matrix && rhs_is_double_matrix)
        error_with_id ("mplapack:mp:UnsupportedOperand",
                       "matrix multiplication requires at least one mp matrix");

      if (lhs_is_matrix || rhs_is_matrix)
        return matrix_mtimes_operation (lhs_value, rhs_value);

      if (lhs_is_double_matrix && rhs_is_mp)
        {
          const octave_value scalar_payload = require_scalar_payload (rhs_value);
          const auto& scalar
            = octave_mplapack_mpfr_scalar_internal::checked_value (
                scalar_payload).storage ();
          try
            {
              const auto matrix = make_double_matrix_storage (
                lhs_value, scalar.precision_bits ());
              return make_mtimes_result (
                octave_mplapack::mplapack_mpfr_matrix_scale (
                  matrix, scalar.native_value ()));
            }
          catch (const std::exception& exception)
            {
              error_with_id ("mplapack:mp:MtimesError", "%s",
                             exception.what ());
            }
        }

      if (rhs_is_double_matrix && lhs_is_mp)
        {
          const octave_value scalar_payload = require_scalar_payload (lhs_value);
          const auto& scalar
            = octave_mplapack_mpfr_scalar_internal::checked_value (
                scalar_payload).storage ();
          try
            {
              const auto matrix = make_double_matrix_storage (
                rhs_value, scalar.precision_bits ());
              return make_mtimes_result (
                octave_mplapack::mplapack_mpfr_matrix_scale (
                  matrix, scalar.native_value ()));
            }
          catch (const std::exception& exception)
            {
              error_with_id ("mplapack:mp:MtimesError", "%s",
                             exception.what ());
            }
        }
    }

  if (lhs_is_matrix && rhs_is_matrix)
    return matrix_mtimes_operation (lhs_value, rhs_value);
  if (lhs_is_matrix)
    return matrix_scale_operation (lhs_value, rhs_value);
  if (rhs_is_matrix)
    return matrix_scale_operation (rhs_value, lhs_value);

  return scalar_binary_operation (lhs_value, rhs_value,
                                  ScalarBinaryOperation::multiply);
}

octave_value
mp_mldivide_operation (const octave_value& lhs_value,
                       const octave_value& rhs_value)
{
  const bool lhs_is_mp = is_mp_value (lhs_value);
  const bool rhs_is_mp = is_mp_value (rhs_value);
  if (! lhs_is_mp && ! rhs_is_mp)
    error_with_id ("mplapack:mp:UnsupportedOperand",
                   "left division requires at least one mp operand");

  const bool lhs_is_matrix = lhs_is_mp && is_matrix_payload (lhs_value);
  const bool rhs_is_matrix = rhs_is_mp && is_matrix_payload (rhs_value);
  const bool lhs_is_double_matrix = is_double_matrix_operand (lhs_value);
  const bool rhs_is_double_matrix = is_double_matrix_operand (rhs_value);

  if (lhs_is_double_matrix && ! lhs_value.isreal ())
    error_with_id ("mplapack:mp:ComplexUnsupported",
                   "complex matrix left division is not supported");
  if (rhs_is_double_matrix && ! rhs_value.isreal ())
    error_with_id ("mplapack:mp:ComplexUnsupported",
                   "complex matrix left division is not supported");

  try
    {
      // Scalar left division is native MPFR arithmetic, not a one-by-one
      // LAPACK call.  The right-hand matrix remains one native payload.
      if (! lhs_is_matrix && ! lhs_is_double_matrix)
        {
          const double lhs_double
            = lhs_is_mp ? 0.0 : require_arithmetic_double (lhs_value);
          std::optional<octave_mplapack::MpfrScalarStorage> lhs_storage;
          const octave_mplapack::MpfrScalarStorage *lhs_scalar = nullptr;
          if (lhs_is_mp)
            {
              const octave_value payload = require_scalar_payload (lhs_value);
              lhs_scalar = &octave_mplapack_mpfr_scalar_internal::checked_value (
                payload).storage ();
            }
          else
            {
              const octave_value rhs_payload = require_mp_payload (rhs_value);
              mpfr_prec_t precision_bits = 0;
              if (rhs_payload.type_id ()
                  == octave_mplapack_mpfr_scalar_internal::static_type_id ())
                precision_bits
                  = octave_mplapack_mpfr_scalar_internal::checked_value (
                      rhs_payload).storage ().precision_bits ();
              else
                precision_bits
                  = octave_mplapack_mpfr_matrix_internal::checked_value (
                      rhs_payload).storage ().precision_bits ();
              lhs_storage.emplace (lhs_double, precision_bits);
              lhs_scalar = &*lhs_storage;
            }

          if (rhs_is_matrix)
            {
              const octave_value rhs_payload = require_matrix_payload (rhs_value);
              const auto& rhs
                = octave_mplapack_mpfr_matrix_internal::checked_value (
                    rhs_payload).storage ();
              return make_mldivide_result (
                octave_mplapack::mplapack_mpfr_matrix_left_divide (
                  rhs, lhs_scalar->native_value ()));
            }
          if (rhs_is_double_matrix)
            {
              const mpfr_prec_t precision_bits = lhs_scalar->precision_bits ();
              const auto rhs = make_double_matrix_storage (
                rhs_value, precision_bits);
              return make_mldivide_result (
                octave_mplapack::mplapack_mpfr_matrix_left_divide (
                  rhs, lhs_scalar->native_value ()));
            }

          const octave_mplapack::MpfrScalarStorage rhs_scalar
            = [&] ()
            {
              if (rhs_is_mp)
                return octave_mplapack_mpfr_scalar_internal::checked_value (
                  require_scalar_payload (rhs_value)).storage ();
              const double value = require_arithmetic_double (rhs_value);
              return octave_mplapack::MpfrScalarStorage (
                value, lhs_scalar->precision_bits ());
            } ();
          return make_internal_scalar (rhs_scalar.divide (*lhs_scalar));
        }

      // A non-scalar left operand is a dense matrix.  A raw double matrix is
      // explicitly converted to the other mp operand's precision.
      const octave_mplapack::MpfrMatrixStorage *lhs = nullptr;
      std::optional<octave_mplapack::MpfrMatrixStorage> lhs_owned;
      if (lhs_is_matrix)
        lhs = &octave_mplapack_mpfr_matrix_internal::checked_value (
          require_matrix_payload (lhs_value)).storage ();
      else if (lhs_is_double_matrix && (rhs_is_matrix || rhs_is_mp))
        {
          const mpfr_prec_t rhs_precision
            = rhs_is_matrix
                ? octave_mplapack_mpfr_matrix_internal::checked_value (
                    require_matrix_payload (rhs_value)).storage ().precision_bits ()
                : octave_mplapack_mpfr_scalar_internal::checked_value (
                    require_scalar_payload (rhs_value)).storage ().precision_bits ();
          lhs_owned.emplace (make_double_matrix_storage (
            lhs_value, rhs_precision));
          lhs = &*lhs_owned;
        }
      else
        error_with_id ("mplapack:mp:UnsupportedOperand",
                       "matrix left division requires a dense mp or real double matrix");

      const octave_mplapack::MpfrMatrixStorage *rhs = nullptr;
      std::optional<octave_mplapack::MpfrMatrixStorage> rhs_owned;
      if (rhs_is_matrix)
        rhs = &octave_mplapack_mpfr_matrix_internal::checked_value (
          require_matrix_payload (rhs_value)).storage ();
      else if (rhs_is_double_matrix && lhs)
        {
          rhs_owned.emplace (make_double_matrix_storage (
            rhs_value, lhs->precision_bits ()));
          rhs = &*rhs_owned;
        }
      else if (lhs && lhs->rows () == 1 && ! rhs_is_matrix
               && ! rhs_is_double_matrix)
        {
          const mpfr_prec_t rhs_precision
            = rhs_is_mp
                ? octave_mplapack_mpfr_scalar_internal::checked_value (
                    require_scalar_payload (rhs_value)).storage ().precision_bits ()
                : lhs->precision_bits ();
          const mpfr_prec_t operation_precision
            = std::max (lhs->precision_bits (), rhs_precision);
          rhs_owned.emplace (1, 1, operation_precision);
          if (rhs_is_mp)
            {
              const auto& scalar
                = octave_mplapack_mpfr_scalar_internal::checked_value (
                    require_scalar_payload (rhs_value)).storage ();
              mpfr_set (rhs_owned->at (0, 0).mpfr_data (),
                        scalar.native_value ().mpfr_data (), MPFR_RNDN);
            }
          else
            mpfr_set_d (rhs_owned->at (0, 0).mpfr_data (),
                        require_arithmetic_double (rhs_value), MPFR_RNDN);
          rhs = &*rhs_owned;
        }
      else
        error_with_id ("mplapack:mp:UnsupportedOperand",
                       "matrix left division requires a dense mp or real double right-hand side");

      if (lhs->rows () != lhs->columns ())
        return make_mldivide_result (
          octave_mplapack::mplapack_mpfr_matrix_rank_revealing_solve (
            *lhs, *rhs).solution);

      return make_mldivide_result (
        octave_mplapack::mplapack_mpfr_matrix_solve (*lhs, *rhs));
    }
  catch (const octave_mplapack::MpfrRankRevealingError& exception)
    {
      if (exception.kind ()
          == octave_mplapack::MpfrRankRevealingError::Kind::convergence)
        error_with_id ("mplapack:mp:ConvergenceFailure",
                       "MPLAPACK Rgelss failed to converge (info %d)",
                       exception.info ());
      if (exception.kind ()
          == octave_mplapack::MpfrRankRevealingError::Kind::invalid_argument)
        error_with_id ("mplapack:mp:RankRevealingError",
                       "MPLAPACK Rgelss rejected argument %d",
                       -exception.info ());
      error_with_id ("mplapack:mp:RankRevealingInternalError", "%s",
                     exception.what ());
    }
  catch (const octave_mplapack::MpfrRgelsError& exception)
    {
      if (exception.kind ()
          == octave_mplapack::MpfrRgelsError::Kind::rank_deficient)
        error_with_id ("mplapack:mp:RankDeficient",
                       "mp left division: rectangular matrix is rank deficient");
      error_with_id ("mplapack:mp:RgelsError",
                     "MPLAPACK Rgels rejected argument %d",
                     -exception.info ());
    }
  catch (const octave_mplapack::MpfrRgesvError& exception)
    {
      if (exception.kind ()
          == octave_mplapack::MpfrRgesvError::Kind::singular)
        error_with_id ("mplapack:mp:SingularMatrix",
                       "mp left division: matrix is singular");
      error_with_id ("mplapack:mp:RgesvError",
                     "MPLAPACK Rgesv rejected argument %d",
                     -exception.info ());
    }
  catch (const std::overflow_error& exception)
    {
      error_with_id ("mplapack:mp:DimensionOverflow", "%s",
                     exception.what ());
    }
  catch (const std::invalid_argument& exception)
    {
      const std::string message = exception.what ();
      if (message.find ("square") != std::string::npos)
        error_with_id ("mplapack:mp:NonSquareMatrix", "%s",
                       exception.what ());
      if (message.find ("dimensions") != std::string::npos)
        error_with_id ("mplapack:mp:DimensionMismatch", "%s",
                       exception.what ());
      error_with_id ("mplapack:mp:MldivideError", "%s", exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:mp:MldivideError", "%s", exception.what ());
    }

  return octave_value ();
}

octave_value
scalar_negate (const octave_value& value)
{
  if (is_mp_value (value) && is_complex_payload (value))
    {
      const octave_value payload = require_mp_payload (value);
      if (payload.type_id ()
          == octave_mplapack_mpc_scalar_internal::static_type_id ())
        return make_internal_complex_scalar (
          octave_mplapack::mpc_scalar_negate (
            octave_mplapack_mpc_scalar_internal::checked_value (payload)
              .storage ()));
      try
        {
          return make_complex_inspection_result (
            octave_mplapack::mpc_matrix_negate (
              octave_mplapack_mpc_matrix_internal::checked_value (payload)
                .storage ()));
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:ArithmeticError", "%s",
                         exception.what ());
        }
    }

  if (is_mp_value (value) && is_matrix_payload (value))
    {
      try
        {
          auto result = octave_mplapack::mpfr_matrix_negate (
            octave_mplapack_mpfr_matrix_internal::checked_value (
              require_matrix_payload (value)).storage ());
          if (result.rows () == 1 && result.columns () == 1)
            return make_internal_scalar (
              octave_mplapack::MpfrScalarStorage (
                std::move (result.at (0, 0))));
          return make_internal_matrix (std::move (result));
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:ArithmeticError", "%s",
                         exception.what ());
        }
    }

  const octave_value payload = require_arithmetic_mp_payload (value);
  const auto& native
    = octave_mplapack_mpfr_scalar_internal::checked_value (
        payload).storage ();
  try
    {
      return make_internal_scalar (native.negate ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:ArithmeticError", "%s", exception.what ());
    }

  return octave_value ();
}

octave_value_list
version_info ()
{
  const mpfr_class epsilon = Rlamch_mpfr ("E");
  const double probe_value = epsilon.get_d ();
  const bool probe_ok = (std::isfinite (probe_value)
                         && probe_value > 0.0
                         && probe_value < 1.0);

  octave_scalar_map info;
  info.assign ("octave", OCTAVE_VERSION);
  info.assign ("mplapack", MPLAPACK_STRINGIFY (MPLAPACK_PKG_VERSION));
  info.assign ("backend", "mpfr");
  info.assign ("mpfr", MPFR_VERSION_STRING);
  info.assign ("probe_routine", "Rlamch_mpfr(\"E\")");
  info.assign ("probe_ok", probe_ok);
  info.assign ("probe_value", probe_value);

  return ovl (info);
}

} // namespace

DEFMETHOD_DLD (__mplapack_core__, interp, args, ,
               "Private native diagnostics for octave-mplapack.")
{
  if (args.length () < 1 || ! args(0).is_string ())
    error_with_id ("mplapack:InvalidCommand",
                   "__mplapack_core__ expects a string command");

  const bool module_locked = initialize_internal_type (interp);

  const std::string command = args(0).string_value ();
  if (command == "version")
    {
      require_argument_count (args, 1, command);
      return version_info ();
    }

  if (command == "module_test_locked")
    {
      require_argument_count (args, 1, command);
      return ovl (module_locked);
    }

  if (command == "precision_get_bits")
    {
      require_argument_count (args, 1, command);
      return ovl (precision_count_value (
        octave_mplapack::default_precision_bits ()));
    }

  if (command == "precision_set_bits")
    {
      require_argument_count (args, 2, command);
      const auto requested = require_precision_count (
        args(1), "mplapack:mpbits:InvalidPrecision");
      if (requested
          > static_cast<octave_mplapack::precision_count_t> (MPFR_PREC_MAX))
        error_with_id ("mplapack:mpbits:PrecisionOverflow",
                       "bit precision exceeds MPFR_PREC_MAX");

      octave_mplapack::set_default_precision_bits (
        static_cast<mpfr_prec_t> (requested));
      return ovl (precision_count_value (
        octave_mplapack::default_precision_bits ()));
    }

  if (command == "precision_get_digits")
    {
      require_argument_count (args, 1, command);
      return ovl (precision_count_value (
        octave_mplapack::decimal_digits_for_bits (
          octave_mplapack::default_precision_bits ())));
    }

  if (command == "precision_test_mpfr_global_bits")
    {
      require_argument_count (args, 1, command);
      return ovl (precision_count_value (mpfr_get_default_prec ()));
    }

  if (command == "precision_set_digits")
    {
      require_argument_count (args, 2, command);
      const auto requested = require_precision_count (
        args(1), "mplapack:mpdigits:InvalidPrecision");

      try
        {
          const mpfr_prec_t converted
            = octave_mplapack::bits_for_decimal_digits (requested);
          octave_mplapack::set_default_precision_bits (converted);
          return ovl (precision_count_value (
            octave_mplapack::decimal_digits_for_bits (converted)));
        }
      catch (const std::overflow_error&)
        {
          error_with_id ("mplapack:mpdigits:PrecisionOverflow",
                         "decimal precision exceeds the MPFR range");
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:NativeError", "%s", exception.what ());
        }
    }

  if (command == "matrix_create_double")
    {
      require_argument_count (args, 2, command);
      return ovl (make_matrix_from_double (args(1)));
    }

  if (command == "matrix_create_text_cell")
    {
      require_argument_count (args, 2, command);
      return ovl (make_matrix_from_text_cell (args(1)));
    }

  if (command == "value_shape_info")
    {
      require_argument_count (args, 2, command);
      return ovl (value_shape_info (args(1)));
    }

  if (command == "value_is_matrix")
    {
      require_argument_count (args, 2, command);
      return ovl (is_matrix_payload (args(1)));
    }

  if (command == "value_is_real")
    {
      require_argument_count (args, 2, command);
      return ovl (! is_complex_payload (args(1)));
    }

  if (command == "value_real")
    {
      require_argument_count (args, 2, command);
      if (is_complex_payload (args(1)))
        return ovl (complex_real_result (args(1)));
      return ovl (require_mp_payload (args(1)));
    }

  if (command == "value_imag")
    {
      require_argument_count (args, 2, command);
      if (is_complex_payload (args(1)))
        return ovl (complex_imag_result (args(1)));

      const octave_value payload = require_mp_payload (args(1));
      if (payload.type_id ()
          == octave_mplapack_mpfr_scalar_internal::static_type_id ())
        {
          const auto& source
            = octave_mplapack_mpfr_scalar_internal::checked_value (payload)
                .storage ();
          return ovl (make_internal_scalar (
            0.0, source.precision_bits ()));
        }

      const auto& source
        = octave_mplapack_mpfr_matrix_internal::checked_value (payload)
            .storage ();
      return ovl (make_internal_matrix (
        octave_mplapack::MpfrMatrixStorage (
          source.rows (), source.columns (), source.precision_bits ())));
    }

  if (command == "value_conj")
    {
      require_argument_count (args, 2, command);
      if (is_complex_payload (args(1)))
        return ovl (complex_conj_result (args(1)));
      return ovl (require_mp_payload (args(1)));
    }

  if (command == "matrix_subscript")
    {
      require_argument_count (args, 4, command);
      if (is_complex_payload (args(1)))
        return ovl (complex_matrix_subscript_result (
          args(1), args(2), args(3)));
      return ovl (matrix_subscript_result (args(1), args(2), args(3)));
    }

  if (command == "matrix_linear_subscript")
    {
      require_argument_count (args, 3, command);
      if (is_complex_payload (args(1)))
        return ovl (complex_matrix_linear_subscript_result (args(1), args(2)));
      return ovl (matrix_linear_subscript_result (args(1), args(2)));
    }

  if (command == "matrix_subsasgn")
    {
      require_argument_count (args, 5, command);
      if (is_complex_payload (args(1)))
        return ovl (complex_matrix_assignment_result (
          args(1), args(2), args(3), args(4)));
      return ovl (matrix_two_subscript_assignment_result (
        args(1), args(2), args(3), args(4)));
    }

  if (command == "matrix_linear_subsasgn")
    {
      require_argument_count (args, 4, command);
      if (is_complex_payload (args(1)))
        return ovl (complex_matrix_linear_assignment_result (
          args(1), args(2), args(3)));
      return ovl (matrix_linear_assignment_result (
        args(1), args(2), args(3)));
    }

  if (command == "matrix_transpose")
    {
      require_argument_count (args, 2, command);
      return ovl (matrix_transpose_result (args(1)));
    }

  if (command == "matrix_ctranspose")
    {
      require_argument_count (args, 2, command);
      return ovl (matrix_ctranspose_result (args(1)));
    }

  if (command == "matrix_reshape")
    {
      if (args.length () != 3 && args.length () != 4)
        error_with_id ("mplapack:InvalidArguments",
                       "__mplapack_core__(\"matrix_reshape\") expects two or three arguments");
      if (args.length () == 3)
        return ovl (matrix_reshape_result (args(1), args(2), nullptr));
      return ovl (matrix_reshape_result (args(1), args(2), &args(3)));
    }

  if (command == "matrix_horzcat" || command == "matrix_vertcat")
    {
      if (args.length () < 2)
        error_with_id ("mplapack:InvalidArguments",
                       "__mplapack_core__(\"%s\") expects at least one operand",
                       command.c_str ());
      return ovl (matrix_concatenate_result (
        args, command == "matrix_horzcat" ? 1 : 0));
    }

  if (command == "matrix_to_double")
    {
      require_argument_count (args, 2, command);
      if (is_mp_value (args(1)) && is_complex_payload (args(1)))
        return ovl (complex_matrix_to_double (args(1)));
      return ovl (matrix_to_double (args(1)));
    }

  if (command == "matrix_display_text")
    {
      require_argument_count (args, 2, command);
      try
        {
          if (is_complex_payload (args(1)))
            {
              const auto& source
                = octave_mplapack_mpc_matrix_internal::checked_value (
                    require_matrix_payload (args(1))).storage ();
              return ovl (octave_mplapack::format_complex_matrix (source));
            }
          return ovl (matrix_display_text (args(1)));
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:mp:DisplayError", "%s",
                         exception.what ());
        }
    }

  if (command == "matrix_test_info")
    {
      require_argument_count (args, 2, command);
      const octave_value payload = require_matrix_payload (args(1));
      if (payload.type_id ()
          == octave_mplapack_mpc_matrix_internal::static_type_id ())
        {
          const auto& matrix
            = octave_mplapack_mpc_matrix_internal::checked_value (payload);
          const auto& storage = matrix.storage ();
          octave_scalar_map info;
          info.assign ("internal_type", matrix.static_type_name ());
          info.assign ("rows", octave_uint64 (storage.rows ()));
          info.assign ("columns", octave_uint64 (storage.columns ()));
          info.assign ("numel", octave_uint64 (storage.numel ()));
          info.assign ("precision_bits",
                       octave_uint64 (storage.precision_bits ()));
          info.assign ("leading_dimension",
                       octave_int64 (storage.leading_dimension ()));
          info.assign ("storage_kind", "column_major_contiguous_complex");
          info.assign ("all_elements_same_precision",
                       storage.all_elements_have_uniform_precision ());
          info.assign ("is_complex", true);
          return ovl (info);
        }
      const auto& matrix
        = octave_mplapack_mpfr_matrix_internal::checked_value (payload);
      const auto& storage = matrix.storage ();

      octave_scalar_map info;
      info.assign ("internal_type", matrix.static_type_name ());
      info.assign ("rows", octave_uint64 (storage.rows ()));
      info.assign ("columns", octave_uint64 (storage.columns ()));
      info.assign ("numel", octave_uint64 (storage.numel ()));
      info.assign ("precision_bits",
                   octave_uint64 (storage.precision_bits ()));
      info.assign ("leading_dimension",
                   octave_int64 (storage.leading_dimension ()));
      info.assign ("storage_kind", "column_major_contiguous");
      info.assign ("all_elements_same_precision",
                   storage.all_elements_have_uniform_precision ());
      info.assign ("is_complex", false);
      return ovl (info);
    }

  if (command == "matrix_test_element_equal_text")
    {
      require_argument_count (args, 5, command);
      const octave_value payload = require_matrix_payload (args(1));
      if (payload.type_id ()
          == octave_mplapack_mpc_matrix_internal::static_type_id ())
        {
          const auto& storage
            = octave_mplapack_mpc_matrix_internal::checked_value (payload)
                .storage ();
          try
            {
              return ovl (storage.element_exactly_equal_text (
                require_matrix_index (args(2)), require_matrix_index (args(3)),
                require_string (args(4), "matrix test text")));
            }
          catch (const std::out_of_range&)
            { error_with_id ("mplapack:InvalidArguments", "matrix test index is out of range"); }
          catch (const std::invalid_argument&)
            { error_with_id ("mplapack:InvalidScalarText", "invalid complex matrix test text"); }
        }
      const auto& storage
        = octave_mplapack_mpfr_matrix_internal::checked_value (
            payload).storage ();
      const std::size_t row = require_matrix_index (args(2));
      const std::size_t column = require_matrix_index (args(3));
      const std::string text = require_string (args(4), "matrix test text");
      try
        {
          return ovl (storage.element_exactly_equal_text (row, column,
                                                          text));
        }
      catch (const std::out_of_range&)
        {
          error_with_id ("mplapack:InvalidArguments",
                         "matrix test index is out of range");
        }
      catch (const std::invalid_argument&)
        {
          error_with_id ("mplapack:InvalidScalarText",
                         "invalid matrix test text");
        }
    }

  if (command == "matrix_test_element_equal_double")
    {
      require_argument_count (args, 5, command);
      const octave_value payload = require_matrix_payload (args(1));
      if (payload.type_id ()
          == octave_mplapack_mpc_matrix_internal::static_type_id ())
        {
          const auto& storage
            = octave_mplapack_mpc_matrix_internal::checked_value (payload)
                .storage ();
          const std::size_t row = require_matrix_index (args(2));
          const std::size_t column = require_matrix_index (args(3));
          if (! args(4).is_complex_scalar () && ! args(4).is_real_scalar ())
            error_with_id ("mplapack:InvalidArguments",
                           "matrix test value must be a scalar");
          return ovl (storage.element_exactly_equal_double (
            row, column, args(4).complex_value ()));
        }
      const auto& storage
        = octave_mplapack_mpfr_matrix_internal::checked_value (
            payload).storage ();
      const std::size_t row = require_matrix_index (args(2));
      const std::size_t column = require_matrix_index (args(3));
      const double value
        = require_double_scalar (args(4), "matrix test value");
      if (row >= storage.rows () || column >= storage.columns ())
        error_with_id ("mplapack:InvalidArguments",
                       "matrix test index is out of range");
      return ovl (storage.element_exactly_equal_double (row, column, value));
    }

  if (command == "matrix_test_element_double")
    {
      require_argument_count (args, 4, command);
      const octave_value payload = require_matrix_payload (args(1));
      if (payload.type_id ()
          == octave_mplapack_mpc_matrix_internal::static_type_id ())
        {
          const auto& storage
            = octave_mplapack_mpc_matrix_internal::checked_value (payload)
                .storage ();
          const std::size_t row = require_matrix_index (args(2));
          const std::size_t column = require_matrix_index (args(3));
          if (row >= storage.rows () || column >= storage.columns ())
            error_with_id ("mplapack:InvalidArguments",
                           "matrix test index is out of range");
          return ovl (storage.at (row, column).real_to_double ());
        }
      const auto& storage
        = octave_mplapack_mpfr_matrix_internal::checked_value (
            payload).storage ();
      const std::size_t row = require_matrix_index (args(2));
      const std::size_t column = require_matrix_index (args(3));
      if (row >= storage.rows () || column >= storage.columns ())
        error_with_id ("mplapack:InvalidArguments",
                       "matrix test index is out of range");
      return ovl (mpfr_get_d (storage.at (row, column).mpfr_data (),
                              MPFR_RNDN));
    }

  if (command == "matrix_test_element_equal")
    {
      require_argument_count (args, 7, command);
      const auto& lhs
        = octave_mplapack_mpfr_matrix_internal::checked_value (
            require_matrix_payload (args(1))).storage ();
      const auto& rhs
        = octave_mplapack_mpfr_matrix_internal::checked_value (
            require_matrix_payload (args(4))).storage ();
      try
        {
          return ovl (lhs.element_exactly_equal (
            require_matrix_index (args(2)), require_matrix_index (args(3)),
            rhs, require_matrix_index (args(5)),
            require_matrix_index (args(6))));
        }
      catch (const std::out_of_range&)
        {
          error_with_id ("mplapack:InvalidArguments",
                         "matrix test index is out of range");
        }
    }

  if (command == "matrix_test_clone")
    {
      require_argument_count (args, 2, command);
      const auto& matrix
        = octave_mplapack_mpfr_matrix_internal::checked_value (
            require_matrix_payload (args(1)));
      try
        {
          return ovl (octave_value (matrix.clone ()));
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:NativeError", "%s", exception.what ());
        }
    }

  if (command == "mtimes")
    {
      require_argument_count (args, 3, command);
      if (is_complex_arithmetic_operand (args(1))
          || is_complex_arithmetic_operand (args(2)))
        return ovl (complex_mtimes_operation (args(1), args(2)));
      return ovl (mp_mtimes_operation (args(1), args(2)));
    }

  if (command == "mldivide")
    {
      require_argument_count (args, 3, command);
      if (is_complex_arithmetic_operand (args(1))
          || is_complex_arithmetic_operand (args(2)))
        return ovl (complex_mldivide_operation (args(1), args(2)));
      return ovl (mp_mldivide_operation (args(1), args(2)));
    }

  if (command == "chol")
    {
      require_argument_count (args, 3, command);
      const std::string option = require_string (args(2), "chol option");
      if (option != "upper" && option != "lower")
        error_with_id ("mplapack:mp:InvalidOption",
                       "chol option must be \"upper\" or \"lower\"");
      return mp_cholesky_operation (args(1), option == "lower");
    }

  if (command == "qr")
    {
      require_argument_count (args, 4, command);
      const std::string option = require_string (args(2), "qr option");
      const std::string outputs = require_string (args(3), "qr output mode");
      if (option != "full" && option != "econ")
        error_with_id ("mplapack:mp:InvalidOption",
                       "qr option must be \"full\" or \"econ\"");
      if (outputs != "r" && outputs != "qr")
        error_with_id ("mplapack:mp:InvalidArguments",
                       "qr output mode is invalid");
      if (is_complex_payload (args(1)))
        return complex_qr_operation (args(1), option == "econ",
                                     outputs == "qr");
      return mp_qr_operation (args(1), option == "econ", outputs == "qr");
    }

  if (command == "qr_pivoted")
    {
      require_argument_count (args, 4, command);
      const std::string option = require_string (args(2), "qr option");
      const std::string permutation
        = require_string (args(3), "qr permutation output");
      if (option != "full" && option != "econ")
        error_with_id ("mplapack:mp:InvalidOption",
                       "pivoted qr option must be \"full\" or \"econ\"");
      if (permutation != "matrix" && permutation != "vector")
        error_with_id ("mplapack:mp:InvalidArguments",
                       "pivoted qr permutation output is invalid");
      return mp_pivoted_qr_operation (args(1), option == "econ",
                                      permutation == "vector");
    }

  if (command == "lu")
    {
      require_argument_count (args, 3, command);
      const std::string output_mode
        = require_string (args(2), "lu output mode");
      if (output_mode != "packed" && output_mode != "two"
          && output_mode != "matrix" && output_mode != "vector")
        error_with_id ("mplapack:mp:InvalidArguments",
                       "lu output mode is invalid");
      return mp_lu_operation (args(1), output_mode);
    }

  if (command == "scalar_test_create")
    {
      require_argument_count (args, 3, command);
      const std::string text = require_string (args(1), "scalar text");
      const mpfr_prec_t precision_bits = require_precision (args(2));
      return ovl (make_internal_scalar (text, precision_bits));
    }

  if (command == "scalar_create_text")
    {
      require_argument_count (args, 2, command);
      const std::string text = require_string (args(1), "scalar text");
      return ovl (make_internal_scalar (
        text, octave_mplapack::default_precision_bits ()));
    }

  if (command == "scalar_create_complex_text")
    {
      require_argument_count (args, 3, command);
      const std::string real_text = require_string (args(1), "real text");
      const std::string imag_text = require_string (args(2), "imaginary text");
      return ovl (make_internal_complex_scalar (
        "(" + real_text + "," + imag_text + ")",
        octave_mplapack::default_precision_bits ()));
    }

  if (command == "scalar_create_complex_text_single")
    {
      require_argument_count (args, 2, command);
      const std::string text = require_string (args(1), "complex scalar text");
      return ovl (make_internal_complex_scalar (
        text, octave_mplapack::default_precision_bits ()));
    }

  if (command == "scalar_create_double")
    {
      require_argument_count (args, 2, command);
      const double value = require_double_scalar (args(1), "scalar value");
      return ovl (make_internal_scalar (
        value, octave_mplapack::default_precision_bits ()));
    }

  if (command == "scalar_create_complex_double")
    {
      require_argument_count (args, 2, command);
      if (! args(1).is_complex_scalar ())
        error_with_id ("mplapack:InvalidArguments",
                       "complex scalar value is required");
      return ovl (make_internal_complex_scalar (
        args(1).complex_value (),
        octave_mplapack::default_precision_bits ()));
    }

  if (command == "matrix_create_complex_double")
    {
      require_argument_count (args, 2, command);
      if (! args(1).is_double_type () || args(1).is_real_scalar ()
          || args(1).ndims () != 2)
        error_with_id ("mplapack:mp:InvalidInput",
                       "complex matrix input must be a two-dimensional array");
      const ComplexMatrix input = args(1).complex_matrix_value ();
      const std::size_t rows = checked_size_dimension (input.rows ());
      const std::size_t columns = checked_size_dimension (input.columns ());
      std::vector<Complex> values;
      values.reserve (octave_mplapack::MpfrComplexMatrixStorage::
                      checked_element_count (rows, columns));
      for (octave_idx_type column = 0; column < input.columns (); ++column)
        for (octave_idx_type row = 0; row < input.rows (); ++row)
          values.push_back (input.xelem (row, column));
      try
        {
          return ovl (make_internal_complex_matrix (
            octave_mplapack::MpfrComplexMatrixStorage (
              rows, columns, octave_mplapack::default_precision_bits (),
              values)));
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:NativeError", "%s", exception.what ());
        }
    }

  if (command == "scalar_default_precision")
    {
      require_argument_count (args, 1, command);
      return ovl (octave_int64 (
        octave_mplapack::default_precision_bits ()));
    }

  if (command == "scalar_test_info")
    {
      require_argument_count (args, 2, command);
      if (is_mp_value (args(1)) && is_complex_payload (args(1)))
        {
          const octave_value payload = require_mp_payload (args(1));
          const auto& value
            = octave_mplapack_mpc_scalar_internal::checked_value (payload);
          octave_scalar_map info;
          info.assign ("internal_type", value.static_type_name ());
          info.assign ("precision_bits",
                       octave_int64 (value.storage ().precision_bits ()));
          info.assign ("backend", "mpc");
          info.assign ("is_scalar", true);
          info.assign ("is_complex", true);
          info.assign ("is_nan", value.storage ().is_nan ());
          info.assign ("is_infinite", value.storage ().is_infinite ());
          info.assign ("is_zero", value.storage ().is_zero ());
          info.assign ("real_signbit", value.storage ().real_signbit ());
          info.assign ("imag_signbit", value.storage ().imag_signbit ());
          return ovl (info);
        }
      const octave_value payload = require_scalar_payload (args(1));
      const auto& value
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload);

      octave_scalar_map info;
      info.assign ("internal_type", value.static_type_name ());
      info.assign ("precision_bits",
                   octave_int64 (value.storage ().precision_bits ()));
      info.assign ("backend", "mpfr");
      info.assign ("is_scalar", true);
      info.assign ("is_nan", value.storage ().is_nan ());
      info.assign ("is_infinite", value.storage ().is_infinite ());
      info.assign ("is_zero", value.storage ().is_zero ());
      info.assign ("signbit", value.storage ().signbit ());
      info.assign ("is_complex", false);
      return ovl (info);
    }

  if (command == "scalar_to_canonical_text")
    {
      require_argument_count (args, 2, command);
      if (is_mp_value (args(1)) && is_complex_payload (args(1)))
        {
          const octave_value payload = require_mp_payload (args(1));
          const auto& value
            = octave_mplapack_mpc_scalar_internal::checked_value (payload);
          return ovl (value.storage ().to_canonical_string ());
        }
      const octave_value payload = require_scalar_payload (args(1));
      const auto& value
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload);

      try
        {
          return ovl (value.storage ().to_canonical_string ());
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:ConversionError", "%s",
                         exception.what ());
        }
    }

  if (command == "scalar_to_double")
    {
      require_argument_count (args, 2, command);
      if (is_complex_payload (args(1)))
        {
          const octave_value payload = require_mp_payload (args(1));
          const auto& value
            = octave_mplapack_mpc_scalar_internal::checked_value (payload);
          const std::complex<double> converted = value.storage ().to_double ();
          return ovl (Complex (converted.real (), converted.imag ()));
        }
      const octave_value payload = require_scalar_payload (args(1));
      const auto& value
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload);
      return ovl (value.storage ().to_double ());
    }

  if (command == "scalar_add")
    {
      require_argument_count (args, 3, command);
      return ovl (scalar_binary_operation (
        args(1), args(2), ScalarBinaryOperation::add));
    }

  if (command == "scalar_subtract")
    {
      require_argument_count (args, 3, command);
      return ovl (scalar_binary_operation (
        args(1), args(2), ScalarBinaryOperation::subtract));
    }

  if (command == "scalar_multiply")
    {
      require_argument_count (args, 3, command);
      return ovl (scalar_binary_operation (
        args(1), args(2), ScalarBinaryOperation::multiply));
    }

  if (command == "scalar_divide")
    {
      require_argument_count (args, 3, command);
      return ovl (scalar_binary_operation (
        args(1), args(2), ScalarBinaryOperation::divide));
    }

  if (command == "scalar_negate")
    {
      require_argument_count (args, 2, command);
      return ovl (scalar_negate (args(1)));
    }

  if (command == "scalar_test_clone")
    {
      require_argument_count (args, 2, command);
      const auto& value
        = octave_mplapack_mpfr_scalar_internal::checked_value (args(1));

      try
        {
          return ovl (octave_value (value.clone ()));
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:NativeError", "%s", exception.what ());
        }
    }

  if (command == "scalar_test_equal")
    {
      require_argument_count (args, 3, command);
      const octave_value lhs_payload = require_scalar_payload (args(1));
      const octave_value rhs_payload = require_scalar_payload (args(2));
      const auto& lhs
        = octave_mplapack_mpfr_scalar_internal::checked_value (lhs_payload);
      const auto& rhs
        = octave_mplapack_mpfr_scalar_internal::checked_value (rhs_payload);
      return ovl (lhs.storage ().exactly_equal (rhs.storage ()));
    }

  if (command == "scalar_test_equal_string")
    {
      require_argument_count (args, 3, command);
      const octave_value payload = require_scalar_payload (args(1));
      const auto& value
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload);
      const std::string text = require_string (args(2), "comparison text");

      try
        {
          return ovl (value.storage ().exactly_equal_string (text));
        }
      catch (const std::invalid_argument&)
        {
          error_with_id ("mplapack:InvalidScalarText",
                         "invalid scalar text");
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:NativeError", "%s", exception.what ());
        }
    }

  if (command == "scalar_test_equal_double")
    {
      require_argument_count (args, 3, command);
      const octave_value payload = require_scalar_payload (args(1));
      const auto& value
        = octave_mplapack_mpfr_scalar_internal::checked_value (payload);
      const double expected
        = require_double_scalar (args(2), "comparison value");
      return ovl (value.storage ().exactly_equal_double (expected));
    }

  error_with_id ("mplapack:InvalidCommand",
                 "unknown __mplapack_core__ command: %s",
                 command.c_str ());
  return ovl ();
}
