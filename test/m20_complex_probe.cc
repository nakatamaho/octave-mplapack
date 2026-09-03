// SPDX-License-Identifier: BSD-2-Clause

#include <atomic>
#include <iostream>
#include <stdexcept>
#include <thread>
#include <type_traits>
#include <vector>

#include <mplapack.h>
#include <mpblas_mpfr.h>
#include <mplapack_mpfr.h>
#include <mplapack_mpfr_precision.h>

namespace
{
using Real = mpfrxx::mpfr_class;
using Complex = mpfrxx::mpc_class;

static_assert (std::is_same_v<decltype (std::declval<Complex&> ().mpc_data ()),
                              mpc_t&>);
static_assert (sizeof (Complex) == sizeof (mpc_t));
static_assert (alignof (Complex) == alignof (mpc_t));

void check (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

Real real_at (mpfr_prec_t precision)
{
  return Real::with_precision (precision);
}

Complex complex_at (mpfr_prec_t precision)
{
  return Complex::with_precision (precision);
}

void set_ui (Real& value, unsigned long number)
{
  mpfr_set_ui (value.mpfr_data (), number, MPFR_RNDN);
}

void set_power (Real& value, mpfr_exp_t exponent)
{
  mpfr_set_ui_2exp (value.mpfr_data (), 1, exponent, MPFR_RNDN);
}

Complex make_complex (mpfr_prec_t precision, unsigned long real_number,
                      mpfr_exp_t imag_exponent)
{
  Real real = real_at (precision);
  Real imag = real_at (precision);
  set_ui (real, real_number);
  set_power (imag, imag_exponent);
  return Complex (real, imag);
}

void check_equal (const Complex& lhs, const Complex& rhs, const char *message)
{
  check (mpfr_equal_p (mpc_realref (lhs.mpc_data ()),
                       mpc_realref (rhs.mpc_data ())) != 0
         && mpfr_equal_p (mpc_imagref (lhs.mpc_data ()),
                          mpc_imagref (rhs.mpc_data ())) != 0,
         message);
}

void check_precision (const Complex& value, mpfr_prec_t precision,
                      const char *message)
{
  check (value.real_precision () == precision
         && value.imag_precision () == precision, message);
}

void run_basic_backend (mpfr_prec_t precision, mpfr_exp_t tail_exponent)
{
  const Complex one_tail = make_complex (precision, 1, tail_exponent);
  const Complex identity = Complex::with_precision (precision, 1.0, 0.0);
  const Complex zero = Complex::with_precision (precision, 0.0, 0.0);

  check_precision (one_tail, precision, "complex component precision mismatch");
  check (one_tail.real_precision () == one_tail.imag_precision (),
         "complex object has mixed component precision");

  // Cgemm: identity multiplication must preserve both MPFR component tails.
  std::vector<Complex> a (1, one_tail), b (1, identity), c (1, zero);
  {
    MplapackMpfrPrecisionScope scope (precision);
    Cgemm ("N", "N", 1, 1, 1, identity, a.data (), 1, b.data (), 1,
           zero, c.data (), 1);
  }
  check_equal (c[0], one_tail, "complex Cgemm identity lost tail");
  check_precision (c[0], precision, "Cgemm result precision mismatch");

  // Cgesv: one-by-one complex solve.
  std::vector<Complex> as (1, identity), bs (1, Complex::with_precision (precision, 2.0, 0.0));
  mplapackint pivot = 0;
  mplapackint info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    as[0] = Complex::with_precision (precision, 2.0, 0.0);
    Cgesv (1, 1, as.data (), 1, &pivot, bs.data (), 1, info);
  }
  check (info == 0, "complex Cgesv failed");
  check_equal (bs[0], identity, "complex Cgesv result mismatch");

  // Cpotrf: one-by-one positive definite factorization.
  std::vector<Complex> ap (1, Complex::with_precision (precision, 4.0, 0.0));
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Cpotrf ("U", 1, ap.data (), 1, info);
  }
  check (info == 0, "complex Cpotrf failed");
  check_equal (ap[0], Complex::with_precision (precision, 2.0, 0.0),
               "complex Cpotrf result mismatch");

  // Cgeqrf/Cungqr: exercise both QR entry points and their workspaces.
  std::vector<Complex> aq (1, one_tail), tau (1, complex_at (precision));
  std::vector<Complex> query (1, complex_at (precision));
  info = 0;
  {
    MplapackMpfrPrecisionScope scope (precision);
    Cgeqrf (1, 1, aq.data (), 1, tau.data (), query.data (), -1, info);
  }
  check (info == 0 && mpfr_integer_p (mpc_realref (query[0].mpc_data ())) != 0,
         "complex Cgeqrf workspace query failed");
  const mplapackint lwork = static_cast<mplapackint> (
    mpfr_get_si (mpc_realref (query[0].mpc_data ()), MPFR_RNDZ));
  check (lwork > 0, "complex Cgeqrf workspace length invalid");
  aq[0] = one_tail;
  tau[0] = complex_at (precision);
  std::vector<Complex> work (static_cast<std::size_t> (lwork), complex_at (precision));
  {
    MplapackMpfrPrecisionScope scope (precision);
    Cgeqrf (1, 1, aq.data (), 1, tau.data (), work.data (), lwork, info);
  }
  check (info == 0, "complex Cgeqrf failed");

  std::vector<Complex> qquery (1, complex_at (precision));
  {
    MplapackMpfrPrecisionScope scope (precision);
    Cungqr (1, 1, 1, aq.data (), 1, tau.data (), qquery.data (), -1, info);
  }
  check (info == 0 && mpfr_integer_p (mpc_realref (qquery[0].mpc_data ())) != 0,
         "complex Cungqr workspace query failed");
  const mplapackint qwork_length = static_cast<mplapackint> (
    mpfr_get_si (mpc_realref (qquery[0].mpc_data ()), MPFR_RNDZ));
  check (qwork_length > 0, "complex Cungqr workspace length invalid");
  std::vector<Complex> qwork (static_cast<std::size_t> (qwork_length),
                              complex_at (precision));
  {
    MplapackMpfrPrecisionScope scope (precision);
    Cungqr (1, 1, 1, aq.data (), 1, tau.data (), qwork.data (), qwork_length,
            info);
  }
  check (info == 0, "complex Cungqr failed");
  check_precision (aq[0], precision, "complex Cungqr precision mismatch");
}

void run_thread_probe ()
{
  mpfrxx::set_default_precision_bits (128);
  const auto main_before = mpfrxx::default_precision_bits ();
  std::atomic<bool> worker_ok (false);
  std::thread worker ([&] {
    mpfrxx::set_default_precision_bits (2048);
    const Complex value;
    worker_ok.store (value.real_precision () == 2048
                     && value.imag_precision () == 2048
                     && mpfrxx::default_precision_bits () == 2048,
                     std::memory_order_release);
  });
  worker.join ();
  check (worker_ok.load (std::memory_order_acquire),
         "complex worker precision was not independent");
  check (main_before == 128 && mpfrxx::default_precision_bits () == 128,
         "complex worker changed main-thread precision");
}

void run_special_value_probe ()
{
  const mpfr_prec_t precision = 256;
  Real plus_zero = real_at (precision);
  Real minus_zero = real_at (precision);
  mpfr_set_zero (plus_zero.mpfr_data (), 0);
  // MPFR uses a negative sign value for negative zero; +1 is positive.
  mpfr_set_zero (minus_zero.mpfr_data (), -1);
  const Complex signed_zero (plus_zero, minus_zero);
  const Complex signed_zero_copy (signed_zero);
  check (mpfr_zero_p (mpc_realref (signed_zero_copy.mpc_data ())) != 0
         && mpfr_zero_p (mpc_imagref (signed_zero_copy.mpc_data ())) != 0
         && mpfr_signbit (mpc_imagref (signed_zero_copy.mpc_data ())) != 0,
         "complex signed zero value was not preserved by copy");
  const bool imaginary_negative_zero_preserved =
      mpfr_signbit (mpc_imagref (signed_zero_copy.mpc_data ())) != 0;
  std::cout << "INFO: complex copy preserves imaginary negative zero: "
            << (imaginary_negative_zero_preserved ? "yes" : "no") << '\n';

  Real infinity = real_at (precision);
  Real nan = real_at (precision);
  mpfr_set_inf (infinity.mpfr_data (), 1);
  mpfr_set_nan (nan.mpfr_data ());
  const Complex special (infinity, nan);
  const Complex special_copy (special);
  check (mpfr_inf_p (mpc_realref (special_copy.mpc_data ())) != 0
         && mpfr_nan_p (mpc_imagref (special_copy.mpc_data ())) != 0,
         "complex Inf/NaN state was not preserved by copy");
}
} // namespace

int main ()
{
  try
    {
      mpfrxx::set_default_precision_bits (128);
      const Complex default_value;
      check_precision (default_value, 128, "default complex precision mismatch");
      run_basic_backend (1024, -700);
      run_basic_backend (2048, -1500);
      run_special_value_probe ();
      run_thread_probe ();
      check (mpfrxx::default_precision_bits () == 128,
             "complex probe leaked ambient precision");
    }
  catch (const std::exception& error)
    {
      std::cerr << "FAIL: " << error.what () << '\n';
      return 1;
    }

  std::cout << "PASS: installed MPLAPACK MPFR complex type/backend precision probe\n";
  return 0;
}
