// SPDX-License-Identifier: BSD-2-Clause

#include <iostream>
#include <stdexcept>

#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>

namespace
{

using Real = mpfrxx::mpfr_class;

void
require (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

Real
at_precision (mpfr_prec_t precision)
{
  return Real::with_precision (precision);
}

void
set_one (Real& value)
{
  mpfr_set_ui (value.mpfr_data (), 1, MPFR_RNDN);
}

void
set_two (Real& value)
{
  mpfr_set_ui (value.mpfr_data (), 2, MPFR_RNDN);
}

void
add_power_of_two (Real& value, long exponent)
{
  Real increment = at_precision (value.precision ());
  mpfr_set_ui_2exp (increment.mpfr_data (), 1, exponent, MPFR_RNDN);
  mpfr_add (value.mpfr_data (), value.mpfr_data (), increment.mpfr_data (),
            MPFR_RNDN);
}

class DefaultPrecisionGuard
{
public:
  explicit DefaultPrecisionGuard (mpfr_prec_t precision)
    : m_saved (mpfrxx::default_precision_bits ())
  {
    mpfrxx::set_default_precision_bits (precision);
  }

  ~DefaultPrecisionGuard () noexcept
  {
    mpfrxx::set_default_precision_bits (m_saved);
  }

private:
  mpfr_prec_t m_saved;
};

void
run_probe (mpfr_prec_t operation_precision)
{
  constexpr long epsilon_exponent = -700;
  Real a[4] = {at_precision (operation_precision),
               at_precision (operation_precision),
               at_precision (operation_precision),
               at_precision (operation_precision)};
  Real b[2] = {at_precision (operation_precision),
               at_precision (operation_precision)};

  set_one (a[0]);
  set_one (a[1]);
  set_one (a[2]);
  set_one (a[3]);
  add_power_of_two (a[3], epsilon_exponent);
  set_two (b[0]);
  set_two (b[1]);
  add_power_of_two (b[1], epsilon_exponent);

  mplapackint pivots[2] = {0, 0};
  mplapackint info = -1;
  {
    MplapackMpfrPrecisionScope scope (operation_precision);
    Rgesv (2, 1, a, 2, pivots, b, 2, info);
    require (mpfrxx::default_precision_bits () == operation_precision,
             "Rgesv changed the scoped precision");
  }

  require (info == 0, "Rgesv precision probe did not converge");
  Real expected = at_precision (operation_precision);
  set_one (expected);
  require (mpfr_equal_p (b[0].mpfr_data (), expected.mpfr_data ()) != 0,
           "Rgesv precision probe first solution mismatch");
  require (mpfr_equal_p (b[1].mpfr_data (), expected.mpfr_data ()) != 0,
           "Rgesv precision probe second solution mismatch");
}

} // namespace

int
main ()
{
  try
    {
      DefaultPrecisionGuard guard (128);
      run_probe (1024);
      require (mpfrxx::default_precision_bits () == 128,
               "Rgesv precision probe did not restore the outside default");
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }

  std::cout << "PASS: installed MPLAPACK MPFR Rgesv precision probe\n";
  return 0;
}
