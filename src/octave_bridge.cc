// SPDX-License-Identifier: BSD-2-Clause

#include <cmath>
#include <cstdint>
#include <exception>
#include <mutex>
#include <string>

#include <octave/oct.h>
#include <octave/interpreter.h>
#include <octave/ov-classdef.h>
#include <octave/ov-fcn.h>
#include <octave/pt-eval.h>
#include <octave/version.h>

#include <mplapack_mpfr.h>

#include "mp_value.h"
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

double
require_double_scalar (const octave_value& value, const char *description)
{
  if (! value.is_double_type () || ! value.is_real_scalar ())
    error_with_id ("mplapack:InvalidArguments",
                   "%s must be a real double scalar", description);

  return value.double_value ();
}

octave_value
require_scalar_payload (const octave_value& value)
{
  if (value.type_id ()
      == octave_mplapack_mpfr_scalar_internal::static_type_id ())
    return value;

  if (! value.is_classdef_object () || value.class_name () != "mp"
      || value.dims () != dim_vector (1, 1))
    error_with_id ("mplapack:InvalidNativeValue",
                   "expected an internal MPLAPACK MPFR scalar or public mp scalar");

  octave_classdef *object = value.classdef_object_value (true);
  if (! object || ! object->is_instance_of ("mp"))
    error_with_id ("mplapack:InvalidNativeValue",
                   "invalid public mp scalar representation");

  octave_value payload;
  try
    {
      payload = object->get_property (0, "payload_");
    }
  catch (const std::exception&)
    {
      error_with_id ("mplapack:InvalidNativeValue",
                     "public mp scalar has no valid native payload");
    }

  octave_mplapack_mpfr_scalar_internal::checked_value (payload);
  return payload;
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
