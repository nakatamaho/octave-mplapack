// SPDX-License-Identifier: BSD-2-Clause

#include <iostream>
#include <stdexcept>
#include <vector>

#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>

namespace
{

using Real = mpfrxx::mpfr_class;

Real
at_precision (mpfr_prec_t precision)
{
  return Real::with_precision (precision);
}

void
set_integer (Real& value, long integer)
{
  mpfr_set_si (value.mpfr_data (), integer, MPFR_RNDN);
}

void
set_power_of_two (Real& value, long exponent)
{
  mpfr_set_ui_2exp (value.mpfr_data (), 1, exponent, MPFR_RNDN);
}

void
check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

void
check_spd (mpfr_prec_t precision, long exponent)
{
  std::vector<Real> a (4, at_precision (precision));
  set_integer (a[0], 1);
  set_integer (a[1], 1);
  set_integer (a[2], 1);
  Real delta = at_precision (precision);
  set_power_of_two (delta, exponent);
  mpfr_add (a[3].mpfr_data (), delta.mpfr_data (), a[0].mpfr_data (),
            MPFR_RNDN);
  const auto original_default = mpfrxx::default_precision_bits ();
  mplapackint info = -1;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Rpotrf ("U", 2, a.data (), 2, info);
    check (mpfrxx::default_precision_bits () == precision,
           "Rpotrf changed the scoped precision");
  }
  check (info == 0, "Rpotrf SPD probe failed");
  check (mpfrxx::default_precision_bits () == original_default,
         "Rpotrf did not restore ambient precision");
  Real expected_tail = at_precision (precision);
  set_power_of_two (expected_tail, exponent / 2);
  check (mpfr_equal_p (a[3].mpfr_data (), expected_tail.mpfr_data ()) != 0,
         "Rpotrf factor tail was not preserved");
}

void
check_high_ambient ()
{
  const mpfr_prec_t source_precision = 256;
  std::vector<Real> a (4, at_precision (source_precision));
  set_integer (a[0], 4);
  set_integer (a[1], 2);
  set_integer (a[2], 2);
  set_integer (a[3], 10);
  mpfrxx::set_default_precision_bits (4096);
  mplapackint info = -1;
  {
    MplapackMpfrPrecisionScope scope (source_precision);
    Rpotrf ("U", 2, a.data (), 2, info);
  }
  check (info == 0, "Rpotrf high-ambient probe failed");
  check (mpfrxx::default_precision_bits () == 4096,
         "Rpotrf high ambient precision was not restored");
  check (a[0].precision () == source_precision
         && a[3].precision () == source_precision,
         "Rpotrf high-ambient storage precision changed");
}

void
check_non_pd ()
{
  std::vector<Real> a (4, at_precision (1024));
  set_integer (a[0], 1);
  set_integer (a[1], 1);
  set_integer (a[2], 1);
  set_integer (a[3], 1);
  mplapackint info = -1;
  {
    MplapackMpfrPrecisionScope scope (1024);
    Rpotrf ("U", 2, a.data (), 2, info);
  }
  check (info > 0, "Rpotrf non-positive-definite probe did not fail");
}

} // namespace

int
main ()
{
  try
    {
      mpfrxx::set_default_precision_bits (128);
      check_spd (1024, -700);
      check_spd (2048, -1500);
      check_high_ambient ();
      mpfrxx::set_default_precision_bits (128);
      check_non_pd ();
      check (mpfrxx::default_precision_bits () == 128,
             "Rpotrf probe leaked ambient precision");
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
  std::cout << "PASS: installed MPLAPACK MPFR Rpotrf precision probe\n";
  return 0;
}
