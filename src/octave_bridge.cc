// SPDX-License-Identifier: BSD-2-Clause

#include <cmath>
#include <exception>
#include <mutex>
#include <string>

#include <octave/oct.h>
#include <octave/interpreter.h>
#include <octave/ov-fcn.h>
#include <octave/pt-eval.h>
#include <octave/version.h>

#include <mplapack_mpfr.h>

#include "mp_value.h"

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

octave_value
make_internal_scalar (const std::string& text, mpfr_prec_t precision_bits)
{
  try
    {
      return octave_value (
        new octave_mplapack_mpfr_scalar_internal (text, precision_bits));
    }
  catch (const std::invalid_argument& exception)
    {
      error_with_id ("mplapack:InvalidScalarText", "%s",
                     exception.what ());
    }
  catch (const std::exception& exception)
    {
      error_with_id ("mplapack:NativeError", "%s", exception.what ());
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

  if (command == "scalar_test_create")
    {
      require_argument_count (args, 3, command);
      const std::string text = require_string (args(1), "scalar text");
      const mpfr_prec_t precision_bits = require_precision (args(2));
      return ovl (make_internal_scalar (text, precision_bits));
    }

  if (command == "scalar_test_info")
    {
      require_argument_count (args, 2, command);
      const auto& value
        = octave_mplapack_mpfr_scalar_internal::checked_value (args(1));

      octave_scalar_map info;
      info.assign ("internal_type", value.static_type_name ());
      info.assign ("precision_bits",
                   octave_int64 (value.storage ().precision_bits ()));
      info.assign ("backend", "mpfr");
      info.assign ("is_scalar", true);
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
      const auto& lhs
        = octave_mplapack_mpfr_scalar_internal::checked_value (args(1));
      const auto& rhs
        = octave_mplapack_mpfr_scalar_internal::checked_value (args(2));
      return ovl (lhs.storage ().exactly_equal (rhs.storage ()));
    }

  if (command == "scalar_test_equal_string")
    {
      require_argument_count (args, 3, command);
      const auto& value
        = octave_mplapack_mpfr_scalar_internal::checked_value (args(1));
      const std::string text = require_string (args(2), "comparison text");

      try
        {
          return ovl (value.storage ().exactly_equal_string (text));
        }
      catch (const std::invalid_argument& exception)
        {
          error_with_id ("mplapack:InvalidScalarText", "%s",
                         exception.what ());
        }
      catch (const std::exception& exception)
        {
          error_with_id ("mplapack:NativeError", "%s", exception.what ());
        }
    }

  error_with_id ("mplapack:InvalidCommand",
                 "unknown __mplapack_core__ command: %s",
                 command.c_str ());
  return ovl ();
}
