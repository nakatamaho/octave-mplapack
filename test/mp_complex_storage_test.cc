// SPDX-License-Identifier: BSD-2-Clause

#include "mp_complex_matrix_storage.h"
#include "mp_complex_precision.h"
#include "mp_complex_scalar_storage.h"

#include <atomic>
#include <cmath>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <thread>
#include <type_traits>
#include <utility>
#include <vector>

namespace
{
using Scalar = octave_mplapack::MpfrComplexScalarStorage;
using Matrix = octave_mplapack::MpfrComplexMatrixStorage;

void require (bool condition, const char *message)
{
  if (! condition)
    throw std::runtime_error (message);
}

void test_storage ()
{
  for (mpfr_prec_t precision : {128, 256, 512, 1024, 2048})
    {
      Scalar value ("(1.25,-0)", precision);
      require (value.precision_bits () == precision,
               "complex scalar precision mismatch");
      require (value.imag_signbit (), "negative imaginary zero was lost");
      Scalar copy (value);
      require (copy.exactly_equal (value), "complex copy changed value");
      Scalar moved (std::move (copy));
      require (moved.exactly_equal (value), "complex move changed value");

      Matrix matrix (2, 2, precision,
                     std::vector<std::string> {
                       "(1,2)", "(3,4)", "(5,6)", "(7,8)"});
      require (matrix.rows () == 2 && matrix.columns () == 2,
               "complex matrix shape mismatch");
      require (matrix.leading_dimension () == 2,
               "complex matrix leading dimension mismatch");
      require (matrix.all_elements_have_uniform_precision (),
               "complex matrix precision is not uniform");
      require (matrix.at (1, 0).real_to_double () == 3.0,
               "complex matrix column-major layout mismatch");
      Matrix matrix_copy (matrix);
      require (matrix_copy.data () != matrix.data (),
               "complex matrix copy aliases source");
      mpfr_set_si (mpc_realref (matrix_copy.at (0, 0).mpc_data ()), 99,
                   MPFR_RNDN);
      require (matrix.at (0, 0).real_to_double () == 1.0,
               "complex matrix work copy mutated source");
    }
}

void test_scope ()
{
  mpfrxx::set_default_precision_bits (333);
  mpfrxx::set_default_rounding_mode (MPFR_RNDD);
  mpfrxx::set_default_mpc_precision_bits (333, 257);
  mpfrxx::set_default_mpc_rounding_mode (MPFR_RNDD, MPFR_RNDU);
  {
    octave_mplapack::MpfrMpcPrecisionScope outer (1024);
    require (mpfrxx::default_precision_bits () == 1024,
             "outer MPFR scope did not apply");
    require (mpfrxx::default_mpc_real_precision_bits () == 1024
             && mpfrxx::default_mpc_imag_precision_bits () == 1024,
             "outer MPC scope did not apply");
    require (mpfrxx::default_rounding_mode () == MPFR_RNDN
             && mpfrxx::default_mpc_real_rounding_mode () == MPFR_RNDN
             && mpfrxx::default_mpc_imag_rounding_mode () == MPFR_RNDN,
             "outer scope did not normalize rounding");
    {
      octave_mplapack::MpfrMpcPrecisionScope inner (2048);
      require (mpfrxx::default_precision_bits () == 2048
               && mpfrxx::default_mpc_precision_bits () == 2048,
               "nested scope did not apply");
    }
    require (mpfrxx::default_precision_bits () == 1024
             && mpfrxx::default_mpc_real_precision_bits () == 1024,
             "nested scope did not restore outer state");
  }
  require (mpfrxx::default_precision_bits () == 333,
           "scope did not restore MPFR precision");
  require (mpfrxx::default_mpc_real_precision_bits () == 333
           && mpfrxx::default_mpc_imag_precision_bits () == 257,
           "scope did not restore MPC component precision");
  require (mpfrxx::default_rounding_mode () == MPFR_RNDD
           && mpfrxx::default_mpc_real_rounding_mode () == MPFR_RNDD
           && mpfrxx::default_mpc_imag_rounding_mode () == MPFR_RNDU,
           "scope did not restore rounding");

  bool exception_seen = false;
  try
    {
      octave_mplapack::MpfrMpcPrecisionScope scope (512);
      throw std::runtime_error ("scope test");
    }
  catch (const std::runtime_error&)
    { exception_seen = true; }
  require (exception_seen && mpfrxx::default_precision_bits () == 333,
           "exception path did not restore scope");
}

void test_tls ()
{
  mpfrxx::set_default_precision_bits (128);
  std::atomic<bool> worker_ok (false);
  std::thread worker ([&] {
    mpfrxx::set_default_precision_bits (2048);
    Scalar value (0.0, 1.0, 2048);
    worker_ok.store (value.precision_bits () == 2048
                     && mpfrxx::default_precision_bits () == 2048,
                     std::memory_order_release);
  });
  worker.join ();
  require (worker_ok.load (std::memory_order_acquire),
           "worker precision was not independent");
  require (mpfrxx::default_precision_bits () == 128,
           "worker changed main-thread precision");
}
}

int main ()
{
  try
    {
      test_storage ();
      test_scope ();
      test_tls ();
      std::cout << "PASS: complex storage, scope, TLS, lifetime, and special-value gates\n";
      return 0;
    }
  catch (const std::exception& exception)
    {
      std::cerr << "FAIL: " << exception.what () << '\n';
      return 1;
    }
}
