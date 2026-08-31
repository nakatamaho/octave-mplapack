// SPDX-License-Identifier: BSD-2-Clause

#include <cmath>
#include <string>

#include <octave/oct.h>
#include <octave/version.h>

#include <mplapack_mpfr.h>

#ifndef MPLAPACK_PKG_VERSION
#error "MPLAPACK_PKG_VERSION must be provided by the build"
#endif

#define MPLAPACK_STRINGIFY_IMPL(value) #value
#define MPLAPACK_STRINGIFY(value) MPLAPACK_STRINGIFY_IMPL(value)

DEFUN_DLD (__mplapack_core__, args, ,
           "Private native diagnostics for octave-mplapack.")
{
  if (args.length () != 1 || ! args(0).is_string ())
    error_with_id ("mplapack:InvalidCommand",
                   "__mplapack_core__ expects one string command");

  const std::string command = args(0).string_value ();
  if (command != "version")
    error_with_id ("mplapack:InvalidCommand",
                   "unknown __mplapack_core__ command: %s",
                   command.c_str ());

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
