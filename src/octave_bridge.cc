// SPDX-License-Identifier: BSD-2-Clause

#include <cmath>
#include <cstdint>
#include <exception>
#include <limits>
#include <mutex>
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
  });

  if (! function->islocked ())
    error_with_id ("mplapack:ModuleLifetime",
                   "failed to lock __mplapack_core__ in memory");

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
  octave_mplapack_mpfr_matrix_internal::checked_value (payload);
  return payload;
}

bool
is_matrix_payload (const octave_value& value)
{
  return require_mp_payload (value).type_id ()
         == octave_mplapack_mpfr_matrix_internal::static_type_id ();
}

bool
is_mp_value (const octave_value& value)
{
  return (value.type_id ()
          == octave_mplapack_mpfr_scalar_internal::static_type_id ())
         || (value.type_id ()
             == octave_mplapack_mpfr_matrix_internal::static_type_id ())
         || (value.is_classdef_object () && value.class_name () == "mp");
}

octave_value
require_arithmetic_mp_payload (const octave_value& value)
{
  const octave_value payload = require_mp_payload (value);
  if (payload.type_id ()
      == octave_mplapack_mpfr_matrix_internal::static_type_id ())
    error_with_id ("mplapack:mp:MatrixUnsupported",
                   "dense mp matrix arithmetic is not implemented in M07");
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
                       "matrix operands are not implemented before M07");
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

octave_scalar_map
value_shape_info (const octave_value& value)
{
  const octave_value payload = require_mp_payload (value);
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
  return info;
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
  const bool lhs_is_mp = is_mp_value (lhs_value);
  const bool rhs_is_mp = is_mp_value (rhs_value);

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
scalar_negate (const octave_value& value)
{
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

  if (command == "matrix_test_info")
    {
      require_argument_count (args, 2, command);
      const octave_value payload = require_matrix_payload (args(1));
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
      return ovl (info);
    }

  if (command == "matrix_test_element_equal_text")
    {
      require_argument_count (args, 5, command);
      const octave_value payload = require_matrix_payload (args(1));
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

  if (command == "scalar_create_double")
    {
      require_argument_count (args, 2, command);
      const double value = require_double_scalar (args(1), "scalar value");
      return ovl (make_internal_scalar (
        value, octave_mplapack::default_precision_bits ()));
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
      return ovl (info);
    }

  if (command == "scalar_to_canonical_text")
    {
      require_argument_count (args, 2, command);
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
